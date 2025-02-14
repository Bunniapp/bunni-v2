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

    /// @dev An infinitesimal fee rate is applied to naive swaps to protect against exact input vs exact output rate mismatches when swap amounts/liquidity are small.
    /// The current value corresponds to 0.003%.
    uint24 private constant EPSILON_FEE = 30;

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
        bool zeroForOne = input.swapParams.zeroForOne;
        bool exactIn = input.swapParams.amountSpecified < 0;

        // initialize input and output amounts based on initial info
        inputAmount = exactIn ? uint256(-input.swapParams.amountSpecified) : 0;
        outputAmount = exactIn ? 0 : uint256(input.swapParams.amountSpecified);

        // compute updated rounded tick liquidity
        uint256 updatedRoundedTickLiquidity = (input.totalLiquidity * input.liquidityDensityOfRoundedTickX96) >> 96;

        // initialize updatedTick to the current tick
        updatedTick = input.currentTick;

        // bound sqrtPriceLimitX96 by min/max possible values
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
        }

        {
            (int24 roundedTick, int24 nextRoundedTick) = roundTick(input.currentTick, input.key.tickSpacing);
            uint160 naiveSwapResultSqrtPriceX96;
            uint256 naiveSwapAmountIn;
            uint256 naiveSwapAmountOut;
            {
                // handle the special case when we don't cross rounded ticks
                if (updatedRoundedTickLiquidity != 0) {
                    // compute the resulting sqrt price using Uniswap math
                    int24 tickNext = zeroForOne ? roundedTick : nextRoundedTick;
                    uint160 sqrtPriceNextX96 = TickMath.getSqrtPriceAtTick(tickNext);
                    (naiveSwapResultSqrtPriceX96, naiveSwapAmountIn, naiveSwapAmountOut) = SwapMath.computeSwapStep({
                        sqrtPriceCurrentX96: input.sqrtPriceX96,
                        sqrtPriceTargetX96: SwapMath.getSqrtPriceTarget(zeroForOne, sqrtPriceNextX96, sqrtPriceLimitX96),
                        liquidity: updatedRoundedTickLiquidity,
                        amountRemaining: input.swapParams.amountSpecified,
                        feePips: 0
                    });

                    // check if naive swap exhausted the specified amount
                    if (
                        exactIn
                            ? naiveSwapAmountIn == uint256(-input.swapParams.amountSpecified)
                            : naiveSwapAmountOut == uint256(input.swapParams.amountSpecified)
                    ) {
                        // swap doesn't cross rounded tick

                        // compute the updated tick
                        // was initialized earlier as input.currentTick
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
            uint256 inverseCumulativeAmountFnInput;
            if (exactIn) {
                // exact input swap
                inverseCumulativeAmountFnInput =
                    zeroForOne ? input.currentActiveBalance0 + inputAmount : input.currentActiveBalance1 + inputAmount;
            } else {
                // exact output swap
                inverseCumulativeAmountFnInput =
                    zeroForOne ? input.currentActiveBalance1 - outputAmount : input.currentActiveBalance0 - outputAmount;
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

            if (success) {
                // edge case: LDF says we're still in the same rounded tick
                // or in a rounded tick in the opposite direction as the swap
                // meaning first naive swap was insufficient but it should have been
                // use the result from the first naive swap
                if (zeroForOne ? updatedRoundedTick >= roundedTick : updatedRoundedTick <= roundedTick) {
                    if (updatedRoundedTickLiquidity == 0) {
                        // no liquidity, return trivial swap
                        return (input.sqrtPriceX96, input.currentTick, 0, 0);
                    }

                    // compute the updated tick
                    // was initialized earlier as input.currentTick
                    int24 _tickNext = zeroForOne ? roundedTick : nextRoundedTick;
                    if (naiveSwapResultSqrtPriceX96 == TickMath.getSqrtPriceAtTick(_tickNext)) {
                        // Equivalent to `updatedTick = zeroForOne ? _tickNext - 1 : _tickNext;`
                        unchecked {
                            // cannot cast a bool to an int24 in Solidity
                            int24 _zeroForOne;
                            assembly {
                                _zeroForOne := zeroForOne
                            }
                            updatedTick = _tickNext - _zeroForOne;
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

                // use Uniswap math to compute updated sqrt price
                // the swap is called "partial swap"
                // which always has the same exactIn and zeroForOne as the overall swap
                (int24 tickStart, int24 tickNext) = zeroForOne
                    ? (updatedRoundedTick + input.key.tickSpacing, updatedRoundedTick)
                    : (updatedRoundedTick, updatedRoundedTick + input.key.tickSpacing);
                uint160 startSqrtPriceX96 = tickStart.getSqrtPriceAtTick();

                // make sure the price limit is not reached
                if (
                    (zeroForOne && sqrtPriceLimitX96 <= startSqrtPriceX96)
                        || (!zeroForOne && sqrtPriceLimitX96 >= startSqrtPriceX96)
                ) {
                    uint160 sqrtPriceNextX96 = tickNext.getSqrtPriceAtTick();

                    // adjust the cumulativeAmount of the input token to be at least the corresponding currentActiveBalance
                    // we know that we're swapping in a different rounded tick as the starting one (based on the first naive swap)
                    // so this should be true but sometimes isn't due to precision error which is why the adjustment is necessary
                    if (zeroForOne) {
                        cumulativeAmount0 = FixedPointMathLib.max(cumulativeAmount0, input.currentActiveBalance0);
                    } else {
                        cumulativeAmount1 = FixedPointMathLib.max(cumulativeAmount1, input.currentActiveBalance1);
                    }

                    // perform naive swap within the updated rounded tick
                    bool hitSqrtPriceLimit;
                    if (swapLiquidity == 0 || sqrtPriceLimitX96 == startSqrtPriceX96) {
                        // don't move from the starting price
                        (naiveSwapResultSqrtPriceX96, naiveSwapAmountIn, naiveSwapAmountOut) = (startSqrtPriceX96, 0, 0);
                    } else {
                        // has swap liquidity, use Uniswap math to compute updated sqrt price and input/output amounts
                        int256 amountSpecifiedRemaining = exactIn
                            ? -(inverseCumulativeAmountFnInput - (zeroForOne ? cumulativeAmount0 : cumulativeAmount1)).toInt256(
                            )
                            : ((zeroForOne ? cumulativeAmount1 : cumulativeAmount0) - inverseCumulativeAmountFnInput)
                                .toInt256();
                        (naiveSwapResultSqrtPriceX96, naiveSwapAmountIn, naiveSwapAmountOut) = SwapMath.computeSwapStep({
                            sqrtPriceCurrentX96: startSqrtPriceX96,
                            sqrtPriceTargetX96: SwapMath.getSqrtPriceTarget(zeroForOne, sqrtPriceNextX96, sqrtPriceLimitX96),
                            liquidity: swapLiquidity,
                            amountRemaining: amountSpecifiedRemaining,
                            feePips: EPSILON_FEE
                        });
                        if (naiveSwapResultSqrtPriceX96 == sqrtPriceLimitX96 && sqrtPriceLimitX96 != sqrtPriceNextX96) {
                            // give up if the swap hits the sqrt price limit
                            hitSqrtPriceLimit = true;
                        }
                    }

                    if (!hitSqrtPriceLimit) {
                        // initialize updatedTick to tickStart
                        updatedTick = tickStart;

                        // compute updatedTick
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

                        // set updatedSqrtPriceX96
                        updatedSqrtPriceX96 = naiveSwapResultSqrtPriceX96;

                        if (
                            exactIn
                                ? naiveSwapAmountIn == uint256(-input.swapParams.amountSpecified)
                                : naiveSwapAmountOut == uint256(input.swapParams.amountSpecified)
                        ) {
                            // edge case: the partial swap consumed the entire amount specified
                            // return the result of the partial swap directly

                            // naiveSwapAmountOut should be at most the corresponding active balance
                            // this may be violated due to precision loss
                            naiveSwapAmountOut = FixedPointMathLib.min(
                                naiveSwapAmountOut,
                                zeroForOne ? input.currentActiveBalance1 : input.currentActiveBalance0
                            );

                            return (naiveSwapResultSqrtPriceX96, updatedTick, naiveSwapAmountIn, naiveSwapAmountOut);
                        }

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
            }
        }

        // the sqrt price limit has been reached
        (updatedSqrtPriceX96, updatedTick) = (
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
        (uint256 _updatedActiveBalance0, uint256 _updatedActiveBalance1) =
            (totalDensity0X96.fullMulX96Up(input.totalLiquidity), totalDensity1X96.fullMulX96Up(input.totalLiquidity));
        // Use subReLU so that when the computed output is somehow negative (most likely due to precision loss)
        // we output 0 instead of reverting.
        if (zeroForOne) {
            (inputAmount, outputAmount) = (
                _updatedActiveBalance0 - input.currentActiveBalance0,
                subReLU(input.currentActiveBalance1, _updatedActiveBalance1)
            );
        } else {
            (inputAmount, outputAmount) = (
                _updatedActiveBalance1 - input.currentActiveBalance1,
                subReLU(input.currentActiveBalance0, _updatedActiveBalance0)
            );
        }
    }
}
