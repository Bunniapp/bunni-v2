// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./Math.sol";
import "../base/Errors.sol";
import "../base/Constants.sol";
import "../types/IdleBalance.sol";
import {SwapMath} from "./SwapMath.sol";
import {queryLDF} from "./QueryLDF.sol";
import {FullMathX96} from "./FullMathX96.sol";
import {SqrtPriceMath} from "./SqrtPriceMath.sol";
import {LiquidityAmounts} from "./LiquidityAmounts.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

library BunniSwapMath {
    using TickMath for *;
    using FullMathX96 for *;
    using SafeCastLib for uint256;
    using FixedPointMathLib for uint256;

    struct BunniComputeSwapInput {
        PoolKey key;
        uint256 totalLiquidity;
        uint256 liquidityDensityOfRoundedTickX96;
        uint256 currentActiveBalance0;
        uint256 currentActiveBalance1;
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
    /// @return updatedSqrtPriceX96 The updated sqrt price after the swap
    /// @return updatedTick The updated tick after the swap
    /// @return inputAmount The input amount of the swap
    /// @return outputAmount The output amount of the swap
    function computeSwap(BunniComputeSwapInput calldata input)
        external
        view
        returns (uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount, uint256 outputAmount)
    {
        // initialize input and output amounts based on initial info
        bool exactIn = input.swapParams.amountSpecified < 0;
        inputAmount = exactIn ? uint256(-input.swapParams.amountSpecified) : 0;
        outputAmount = exactIn ? 0 : uint256(input.swapParams.amountSpecified);
        bool zeroForOne = input.swapParams.zeroForOne;

        // initialize updatedTick to the current tick
        updatedTick = input.currentTick;

        uint160 sqrtPriceLimitX96 = input.swapParams.sqrtPriceLimitX96;
        {
            (uint160 minSqrtPrice, uint160 maxSqrtPrice) = (
                TickMath.minUsableTick(input.key.tickSpacing).getSqrtPriceAtTick(),
                TickMath.maxUsableTick(input.key.tickSpacing).getSqrtPriceAtTick()
            );
            // bound sqrtPriceLimit so that we never end up at an invalid rounded tick
            if ((zeroForOne && sqrtPriceLimitX96 <= minSqrtPrice) || (!zeroForOne && sqrtPriceLimitX96 >= maxSqrtPrice))
            {
                sqrtPriceLimitX96 = zeroForOne ? minSqrtPrice + 1 : maxSqrtPrice - 1;
            }

            // compute updated current tick liquidity
            uint256 updatedRoundedTickLiquidity = (input.totalLiquidity * input.liquidityDensityOfRoundedTickX96) >> 96;

            // handle the special case when we don't cross rounded ticks
            if (updatedRoundedTickLiquidity != 0) {
                // compute the resulting sqrt price assuming no rounded tick is crossed
                (int24 roundedTick, int24 nextRoundedTick) = roundTick(input.currentTick, input.key.tickSpacing);
                int24 tickNext = zeroForOne ? roundedTick : nextRoundedTick;
                uint160 sqrtPriceNextX96 = TickMath.getSqrtPriceAtTick(tickNext);

                // use boundary prices as sqrtPriceNextX96 in getSqrtPriceTarget() to let the swap execute as far as possible
                // we'll check later if the resulting sqrtPrice exceeds sqrtPriceNextX96 to determine if the swap crossed to
                // the next rounded tick
                (uint160 naiveSwapResultSqrtPriceX96, uint256 naiveSwapAmountIn, uint256 naiveSwapAmountOut) = SwapMath
                    .computeSwapStep({
                    sqrtPriceCurrentX96: input.sqrtPriceX96,
                    sqrtPriceTargetX96: SwapMath.getSqrtPriceTarget(
                        zeroForOne, zeroForOne ? minSqrtPrice + 1 : maxSqrtPrice - 1, sqrtPriceLimitX96
                    ),
                    liquidity: updatedRoundedTickLiquidity,
                    amountRemaining: input.swapParams.amountSpecified
                });
                if (
                    (zeroForOne && naiveSwapResultSqrtPriceX96 >= sqrtPriceNextX96)
                        || (!zeroForOne && naiveSwapResultSqrtPriceX96 <= sqrtPriceNextX96)
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

                    // naiveSwapAmountOut should be at most the corresponding active balance
                    // this may be violated due to precision loss
                    naiveSwapAmountOut = FixedPointMathLib.min(
                        naiveSwapAmountOut, zeroForOne ? input.currentActiveBalance1 : input.currentActiveBalance0
                    );

                    // early return
                    return (naiveSwapResultSqrtPriceX96, updatedTick, naiveSwapAmountIn, naiveSwapAmountOut);
                }
            }
        }

        // swap crosses rounded tick
        // need to use LDF to compute the swap
        // compute updated sqrt ratio & tick
        {
            uint256 inverseCumulativeAmountFnInput;
            if (exactIn) {
                // exact input swap
                inverseCumulativeAmountFnInput =
                    zeroForOne ? input.currentActiveBalance0 + inputAmount : input.currentActiveBalance1 + inputAmount;
            } else {
                // exact output swap
                inverseCumulativeAmountFnInput = zeroForOne
                    ? input.currentActiveBalance1 - FixedPointMathLib.min(outputAmount, input.currentActiveBalance1)
                    : input.currentActiveBalance0 - FixedPointMathLib.min(outputAmount, input.currentActiveBalance0);
            }

            (
                bool success,
                int24 updatedRoundedTick,
                uint256 cumulativeAmount0,
                uint256 cumulativeAmount1,
                uint256 swapLiquidity
            ) = input.liquidityDensityFunction.computeSwap(
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
                // the swap is called "partial swap" or "naive swap"
                // which always has the same exactIn and zeroForOne as the overall swap
                (int24 tickStart, int24 tickNext) = zeroForOne
                    ? (updatedRoundedTick + input.key.tickSpacing, updatedRoundedTick)
                    : (updatedRoundedTick, updatedRoundedTick + input.key.tickSpacing);
                uint160 startSqrtPriceX96 = tickStart.getSqrtPriceAtTick();
                uint160 sqrtPriceNextX96 = tickNext.getSqrtPriceAtTick();

                // handle the case where sqrtPriceLimitX96 has already been reached
                if (
                    (zeroForOne && sqrtPriceLimitX96 <= startSqrtPriceX96)
                        || (!zeroForOne && sqrtPriceLimitX96 >= startSqrtPriceX96)
                ) {
                    int256 amountSpecifiedRemaining = exactIn
                        ? -(inverseCumulativeAmountFnInput - (zeroForOne ? cumulativeAmount0 : cumulativeAmount1)).toInt256()
                        : ((zeroForOne ? cumulativeAmount1 : cumulativeAmount0) - inverseCumulativeAmountFnInput).toInt256();
                    (uint160 naiveSwapResultSqrtPriceX96, uint256 naiveSwapAmountIn, uint256 naiveSwapAmountOut) =
                    SwapMath.computeSwapStep({
                        sqrtPriceCurrentX96: startSqrtPriceX96,
                        sqrtPriceTargetX96: SwapMath.getSqrtPriceTarget(zeroForOne, sqrtPriceNextX96, sqrtPriceLimitX96),
                        liquidity: swapLiquidity,
                        amountRemaining: amountSpecifiedRemaining
                    });

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

                    if (
                        (zeroForOne && cumulativeAmount1 < naiveSwapAmountOut)
                            || (!zeroForOne && cumulativeAmount0 < naiveSwapAmountOut)
                    ) {
                        // in rare cases the rounding error can cause one of the active balances to be negative
                        // revert in such cases to avoid leaking value
                        revert BunniSwapMath__SwapFailed();
                    }

                    (uint256 updatedActiveBalance0, uint256 updatedActiveBalance1) = zeroForOne
                        ? (cumulativeAmount0 + naiveSwapAmountIn, cumulativeAmount1 - naiveSwapAmountOut)
                        : (cumulativeAmount0 - naiveSwapAmountOut, cumulativeAmount1 + naiveSwapAmountIn);

                    // compute input and output token amounts
                    // NOTE: The rounding direction of all the values involved are correct:
                    // - cumulative amounts are rounded up
                    // - naiveSwapAmountIn is rounded up
                    // - naiveSwapAmountOut is rounded down
                    // - currentActiveBalance0 and currentActiveBalance1 are rounded down
                    // Overall this leads to inputAmount being rounded up and outputAmount being rounded down
                    // which is safe.
                    // Use subReLU so that when the computed output is somehow negative (most likely due to precision loss)
                    // we output 0 instead of reverting.
                    (inputAmount, outputAmount) = zeroForOne
                        ? (
                            updatedActiveBalance0 - input.currentActiveBalance0,
                            subReLU(input.currentActiveBalance1, updatedActiveBalance1)
                        )
                        : (
                            updatedActiveBalance1 - input.currentActiveBalance1,
                            subReLU(input.currentActiveBalance0, updatedActiveBalance0)
                        );

                    return (updatedSqrtPriceX96, updatedTick, inputAmount, outputAmount);
                }
            }

            // liquidity is insufficient to handle all of the input/output tokens
            // or the sqrt price limit has been reached
            (updatedSqrtPriceX96, updatedTick) = (success && swapLiquidity == 0)
                ? (updatedRoundedTick.getSqrtPriceAtTick(), updatedRoundedTick)
                : (
                    sqrtPriceLimitX96,
                    sqrtPriceLimitX96 == input.sqrtPriceX96 ? input.currentTick : sqrtPriceLimitX96.getTickAtSqrtPrice() // recompute tick unless we haven't moved
                );

            // Rounding directions:
            // currentActiveBalance: down
            // totalDensity: up
            // updatedActiveBalance: up
            (, uint256 totalDensity0X96, uint256 totalDensity1X96,,,,,) = queryLDF({
                key: input.key,
                sqrtPriceX96: updatedSqrtPriceX96,
                tick: updatedTick,
                arithmeticMeanTick: input.arithmeticMeanTick,
                ldf: input.liquidityDensityFunction,
                ldfParams: input.ldfParams,
                ldfState: input.ldfState,
                balance0: 0,
                balance1: 0,
                idleBalance: IdleBalanceLibrary.ZERO
            });
            (uint256 updatedActiveBalance0, uint256 updatedActiveBalance1) = (
                totalDensity0X96.fullMulX96Up(input.totalLiquidity), totalDensity1X96.fullMulX96Up(input.totalLiquidity)
            );
            // Use subReLU so that when the computed output is somehow negative (most likely due to precision loss)
            // we output 0 instead of reverting.
            if (zeroForOne) {
                (inputAmount, outputAmount) = (
                    updatedActiveBalance0 - input.currentActiveBalance0,
                    subReLU(input.currentActiveBalance1, updatedActiveBalance1)
                );
            } else {
                (inputAmount, outputAmount) = (
                    updatedActiveBalance1 - input.currentActiveBalance1,
                    subReLU(input.currentActiveBalance0, updatedActiveBalance0)
                );
            }
        }
    }
}
