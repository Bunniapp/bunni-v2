// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./Math.sol";
import "../base/Errors.sol";
import "../base/Constants.sol";
import {SwapMath} from "./SwapMath.sol";
import {queryLDF} from "./QueryLDF.sol";
import {SqrtPriceMath} from "./SqrtPriceMath.sol";
import {LiquidityAmounts} from "./LiquidityAmounts.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

library BunniSwapMath {
    using TickMath for int24;
    using SafeCastLib for uint256;
    using FixedPointMathLib for uint256;

    struct BunniComputeSwapInput {
        PoolKey key;
        uint256 totalLiquidity;
        uint256 liquidityDensityOfRoundedTickX96;
        uint256 totalDensity0X96;
        uint256 totalDensity1X96;
        uint160 sqrtPriceX96;
        int24 currentTick;
        ILiquidityDensityFunction liquidityDensityFunction;
        int24 arithmeticMeanTick;
        bytes32 ldfParams;
        bytes32 ldfState;
        IPoolManager.SwapParams swapParams;
    }

    /// @notice Computes the result of a swap given the input parameters
    /// @param input The input parameters for the swap
    /// @param balance0 The balance of token0 in the pool
    /// @param balance1 The balance of token1 in the pool
    /// @return updatedSqrtPriceX96 The updated sqrt price after the swap
    /// @return updatedTick The updated tick after the swap
    /// @return inputAmount The input amount of the swap
    /// @return outputAmount The output amount of the swap
    function computeSwap(BunniComputeSwapInput calldata input, uint256 balance0, uint256 balance1)
        external
        view
        returns (uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount, uint256 outputAmount)
    {
        uint256 outputTokenBalance = input.swapParams.zeroForOne ? balance1 : balance0;
        int256 amountSpecified = input.swapParams.amountSpecified;
        if (amountSpecified > 0 && uint256(amountSpecified) > outputTokenBalance) {
            // exact output swap where the requested output amount exceeds the output token balance
            // change swap to an exact output swap where the output amount is the output token balance
            amountSpecified = outputTokenBalance.toInt256();
        }

        // compute first pass result
        (updatedSqrtPriceX96, updatedTick, inputAmount, outputAmount) = _computeSwap(input, amountSpecified);

        // ensure that the output amount is lte the output token balance
        if (outputAmount > outputTokenBalance) {
            // exactly output the output token's balance
            // need to recompute swap
            amountSpecified = outputTokenBalance.toInt256();
            (updatedSqrtPriceX96, updatedTick, inputAmount, outputAmount) = _computeSwap(input, amountSpecified);

            if (outputAmount > outputTokenBalance) {
                // somehow the output amount is still greater than the balance due to rounding errors
                // just set outputAmount to the balance
                outputAmount = outputTokenBalance;
            }
        }
    }

    function _computeSwap(BunniComputeSwapInput calldata input, int256 amountSpecified)
        private
        view
        returns (uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount, uint256 outputAmount)
    {
        // bound sqrtPriceLimit so that we never end up at an invalid rounded tick
        uint160 sqrtPriceLimitX96 = input.swapParams.sqrtPriceLimitX96;
        {
            (uint160 minSqrtPrice, uint160 maxSqrtPrice) = (
                TickMath.minUsableTick(input.key.tickSpacing).getSqrtPriceAtTick(),
                TickMath.maxUsableTick(input.key.tickSpacing).getSqrtPriceAtTick()
            );
            if (
                (input.swapParams.zeroForOne && sqrtPriceLimitX96 < minSqrtPrice)
                    || (!input.swapParams.zeroForOne && sqrtPriceLimitX96 >= maxSqrtPrice)
            ) {
                sqrtPriceLimitX96 = input.swapParams.zeroForOne ? minSqrtPrice : maxSqrtPrice - 1;
            }
        }

        // initialize input and output amounts based on initial info
        bool exactIn = amountSpecified < 0;
        inputAmount = exactIn ? uint256(-amountSpecified) : 0;
        outputAmount = exactIn ? 0 : uint256(amountSpecified);
        bool zeroForOne = input.swapParams.zeroForOne;

        // compute updated current tick liquidity
        uint256 updatedRoundedTickLiquidity = (input.totalLiquidity * input.liquidityDensityOfRoundedTickX96) >> 96;

        // handle the special case when we don't cross rounded ticks
        if (updatedRoundedTickLiquidity != 0) {
            // compute the resulting sqrt price assuming no rounded tick is crossed
            (int24 roundedTick, int24 nextRoundedTick) = roundTick(input.currentTick, input.key.tickSpacing);
            int24 tickNext = zeroForOne ? roundedTick : nextRoundedTick;
            uint160 sqrtPriceNextX96 = TickMath.getSqrtPriceAtTick(tickNext);
            int256 amountSpecifiedRemaining = amountSpecified;
            (uint160 naiveSwapResultSqrtPriceX96, uint256 naiveSwapAmountIn, uint256 naiveSwapAmountOut) = SwapMath
                .computeSwapStep({
                sqrtPriceCurrentX96: input.sqrtPriceX96,
                sqrtPriceTargetX96: SwapMath.getSqrtPriceTarget(zeroForOne, sqrtPriceNextX96, sqrtPriceLimitX96),
                liquidity: updatedRoundedTickLiquidity,
                amountRemaining: amountSpecifiedRemaining
            });
            if (!exactIn) {
                unchecked {
                    amountSpecifiedRemaining -= naiveSwapAmountOut.toInt256();
                }
            } else {
                // safe because we test that amountSpecified > amountIn in SwapMath
                unchecked {
                    amountSpecifiedRemaining += naiveSwapAmountIn.toInt256();
                }
            }
            if (
                amountSpecifiedRemaining == 0 || naiveSwapResultSqrtPriceX96 == sqrtPriceLimitX96
                    || (zeroForOne && naiveSwapResultSqrtPriceX96 > sqrtPriceNextX96)
                    || (!zeroForOne && naiveSwapResultSqrtPriceX96 < sqrtPriceNextX96)
            ) {
                // swap doesn't cross rounded tick
                if (naiveSwapResultSqrtPriceX96 == sqrtPriceNextX96) {
                    // Equivalent to `updatedTick = zeroForOne ? tickNext - 1 : tickNext;`
                    unchecked {
                        // cannot cast a bool to an int24 in Solidity
                        int24 _zeroForOne;
                        assembly {
                            _zeroForOne := zeroForOne
                        }
                        updatedTick = tickNext - _zeroForOne;
                    }
                } else if (naiveSwapResultSqrtPriceX96 != input.sqrtPriceX96) {
                    // recompute unless we're on a lower tick boundary (i.e. already transitioned ticks), and haven't moved
                    updatedTick = TickMath.getTickAtSqrtPrice(naiveSwapResultSqrtPriceX96);
                }

                // early return
                return (naiveSwapResultSqrtPriceX96, updatedTick, naiveSwapAmountIn, naiveSwapAmountOut);
            }
        }

        // swap crosses rounded tick
        // need to use LDF to compute the swap
        (uint256 currentActiveBalance0, uint256 currentActiveBalance1) = (
            input.totalDensity0X96.fullMulDiv(input.totalLiquidity, Q96),
            input.totalDensity1X96.fullMulDiv(input.totalLiquidity, Q96)
        );

        // compute updated sqrt ratio & tick
        {
            uint256 inverseCumulativeAmountFnInput;
            if (exactIn) {
                // exact input swap
                inverseCumulativeAmountFnInput =
                    zeroForOne ? currentActiveBalance0 + inputAmount : currentActiveBalance1 + inputAmount;
            } else {
                // exact output swap
                inverseCumulativeAmountFnInput = zeroForOne
                    ? currentActiveBalance1 - FixedPointMathLib.min(outputAmount, currentActiveBalance1)
                    : currentActiveBalance0 - FixedPointMathLib.min(outputAmount, currentActiveBalance0);
            }

            (bool success, int24 updatedRoundedTick, uint256 cumulativeAmount, uint256 swapLiquidity) = input
                .liquidityDensityFunction
                .computeSwap(
                input.key,
                inverseCumulativeAmountFnInput,
                input.totalLiquidity,
                zeroForOne,
                exactIn,
                input.arithmeticMeanTick,
                input.currentTick,
                input.ldfParams,
                input.ldfState
            );

            if (success && swapLiquidity != 0) {
                // use Uniswap math to compute updated sqrt price
                uint160 startSqrtPriceX96 = TickMath.getSqrtPriceAtTick(updatedRoundedTick);
                bool partialSwapZeroForOne = (exactIn == zeroForOne);
                int24 tickNext = partialSwapZeroForOne
                    ? updatedRoundedTick - input.key.tickSpacing
                    : updatedRoundedTick + input.key.tickSpacing;
                uint160 sqrtPriceNextX96 = TickMath.getSqrtPriceAtTick(tickNext);

                // handle the case where sqrtPriceLimitX96 has already been reached
                // naiveSwapResultSqrtPriceX96 will be between startSqrtPriceX96 and sqrtPriceNextX96
                // leastChangeSqrtPriceX96 is the sqrt price bound closest to the initial sqrt price before this swap
                // if it already exceeds the sqrt price limit, we should use the fallback swap logic
                uint160 leastChangeSqrtPriceX96 = exactIn ? startSqrtPriceX96 : sqrtPriceNextX96;
                if (
                    (zeroForOne && sqrtPriceLimitX96 <= leastChangeSqrtPriceX96)
                        || (!zeroForOne && sqrtPriceLimitX96 >= leastChangeSqrtPriceX96)
                ) {
                    int256 amountSpecifiedRemaining = -(inverseCumulativeAmountFnInput - cumulativeAmount).toInt256();
                    (uint160 naiveSwapResultSqrtPriceX96, uint256 naiveSwapAmountIn, uint256 naiveSwapAmountOut) =
                    SwapMath.computeSwapStep({
                        sqrtPriceCurrentX96: startSqrtPriceX96,
                        // sqrtPriceLimitX96 is only meaningful if the partial swap and the overall swap are in the same direction
                        // which is when exactIn is true
                        sqrtPriceTargetX96: exactIn
                            ? SwapMath.getSqrtPriceTarget(partialSwapZeroForOne, sqrtPriceNextX96, sqrtPriceLimitX96)
                            : sqrtPriceNextX96,
                        liquidity: swapLiquidity,
                        amountRemaining: amountSpecifiedRemaining
                    });
                    // safe because we test that amountSpecified > amountIn in SwapMath
                    unchecked {
                        amountSpecifiedRemaining += naiveSwapAmountIn.toInt256();
                    }
                    if (naiveSwapResultSqrtPriceX96 == sqrtPriceNextX96) {
                        // Equivalent to `updatedTick = zeroForOne ? tickNext - 1 : tickNext;`
                        unchecked {
                            // cannot cast a bool to an int24 in Solidity
                            int24 _zeroForOne;
                            assembly {
                                _zeroForOne := zeroForOne
                            }
                            updatedTick = tickNext - _zeroForOne;
                        }
                    } else if (naiveSwapResultSqrtPriceX96 != startSqrtPriceX96) {
                        // recompute unless we're on a lower tick boundary (i.e. already transitioned ticks), and haven't moved
                        updatedTick = TickMath.getTickAtSqrtPrice(naiveSwapResultSqrtPriceX96);
                    }

                    updatedSqrtPriceX96 = naiveSwapResultSqrtPriceX96;

                    // compute input and output token amounts
                    if (exactIn) {
                        (inputAmount, outputAmount) = zeroForOne
                            ? (
                                naiveSwapAmountIn + cumulativeAmount - currentActiveBalance0,
                                currentActiveBalance1 + naiveSwapAmountOut
                                    - input.liquidityDensityFunction.cumulativeAmount1(
                                        input.key,
                                        updatedRoundedTick - input.key.tickSpacing,
                                        input.totalLiquidity,
                                        input.arithmeticMeanTick,
                                        updatedTick,
                                        input.ldfParams,
                                        input.ldfState
                                    )
                            )
                            : (
                                naiveSwapAmountIn + cumulativeAmount - currentActiveBalance1,
                                currentActiveBalance0 + naiveSwapAmountOut
                                    - input.liquidityDensityFunction.cumulativeAmount0(
                                        input.key,
                                        updatedRoundedTick,
                                        input.totalLiquidity,
                                        input.arithmeticMeanTick,
                                        updatedTick,
                                        input.ldfParams,
                                        input.ldfState
                                    )
                            );
                    } else {
                        (inputAmount, outputAmount) = zeroForOne
                            ? (
                                input.liquidityDensityFunction.cumulativeAmount0(
                                    input.key,
                                    updatedRoundedTick,
                                    input.totalLiquidity,
                                    input.arithmeticMeanTick,
                                    updatedTick,
                                    input.ldfParams,
                                    input.ldfState
                                ) - naiveSwapAmountOut - currentActiveBalance0,
                                currentActiveBalance1 - naiveSwapAmountIn - cumulativeAmount
                            )
                            : (
                                input.liquidityDensityFunction.cumulativeAmount1(
                                    input.key,
                                    updatedRoundedTick - input.key.tickSpacing,
                                    input.totalLiquidity,
                                    input.arithmeticMeanTick,
                                    updatedTick,
                                    input.ldfParams,
                                    input.ldfState
                                ) - naiveSwapAmountOut - currentActiveBalance1,
                                currentActiveBalance0 - naiveSwapAmountIn - cumulativeAmount
                            );
                    }

                    return (updatedSqrtPriceX96, updatedTick, inputAmount, outputAmount);
                }
            }

            // liquidity is insufficient to handle all of the input/output tokens
            // or the sqrt price limit has been reached
            updatedSqrtPriceX96 = sqrtPriceLimitX96;
            updatedTick = TickMath.getTickAtSqrtPrice(sqrtPriceLimitX96);

            (, uint256 totalDensity0X96, uint256 totalDensity1X96,,,) = queryLDF({
                key: input.key,
                sqrtPriceX96: updatedSqrtPriceX96,
                tick: updatedTick,
                arithmeticMeanTick: input.arithmeticMeanTick,
                ldf: input.liquidityDensityFunction,
                ldfParams: input.ldfParams,
                ldfState: input.ldfState,
                balance0: 0,
                balance1: 0
            });
            (uint256 updatedActiveBalance0, uint256 updatedActiveBalance1) = (
                totalDensity0X96.fullMulDivUp(input.totalLiquidity, Q96),
                totalDensity1X96.fullMulDivUp(input.totalLiquidity, Q96)
            );
            (inputAmount, outputAmount) = zeroForOne
                ? (
                    updatedActiveBalance0 - currentActiveBalance0,
                    currentActiveBalance1 < updatedActiveBalance1 ? 0 : currentActiveBalance1 - updatedActiveBalance1
                )
                : (
                    updatedActiveBalance1 - currentActiveBalance1,
                    currentActiveBalance0 < updatedActiveBalance0 ? 0 : currentActiveBalance0 - updatedActiveBalance0
                );

            if (exactIn) {
                uint256 inputAmountSpecified = uint256(-amountSpecified);
                if (inputAmount > inputAmountSpecified && inputAmount < inputAmountSpecified + 3) {
                    // if it's an exact input swap and inputAmount is greater than the specified input amount by 1 or 2 wei,
                    // round down to the specified input amount to avoid reverts. this assumes that it's not feasible to
                    // extract significant value from the pool if each swap can at most extract 2 wei.
                    inputAmount = inputAmountSpecified;
                }
            }
        }
    }
}
