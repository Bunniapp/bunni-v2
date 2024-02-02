// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {SqrtPriceMath} from "@uniswap/v4-core/src/libraries/SqrtPriceMath.sol";

import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";

import "./Math.sol";
import "./Constants.sol";
import {LiquidityAmounts} from "./LiquidityAmounts.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

library BunniSwapMath {
    using TickMath for int24;
    using SafeCastLib for uint256;
    using FixedPointMathLib for uint256;

    function computeSwap(
        PoolKey calldata key,
        uint256 totalLiquidity,
        uint256 liquidityDensityOfRoundedTickX96,
        uint256 density0RightOfRoundedTickX96,
        uint256 density1LeftOfRoundedTickX96,
        uint160 sqrtPriceX96,
        int24 currentTick,
        uint160 roundedTickSqrtRatio,
        uint160 nextRoundedTickSqrtRatio,
        uint256 balance0,
        uint256 balance1,
        ILiquidityDensityFunction liquidityDensityFunction,
        int24 arithmeticMeanTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState,
        IPoolManager.SwapParams memory params
    )
        internal
        view
        returns (uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount, uint256 outputAmount)
    {
        uint256 outputTokenBalance = params.zeroForOne ? balance1 : balance0;
        if (params.amountSpecified < 0 && uint256(-params.amountSpecified) > outputTokenBalance) {
            // exact output swap where the requested output amount exceeds the output token balance
            // change swap to an exact output swap where the output amount is the output token balance
            params.amountSpecified = -outputTokenBalance.toInt256();
        }

        // compute first pass result
        (updatedSqrtPriceX96, updatedTick, inputAmount, outputAmount) = _computeSwap(
            key,
            totalLiquidity,
            liquidityDensityOfRoundedTickX96,
            density0RightOfRoundedTickX96,
            density1LeftOfRoundedTickX96,
            sqrtPriceX96,
            currentTick,
            roundedTickSqrtRatio,
            nextRoundedTickSqrtRatio,
            liquidityDensityFunction,
            arithmeticMeanTick,
            useTwap,
            ldfParams,
            ldfState,
            params
        );

        // ensure that the output amount is lte the output token balance
        if (outputAmount > outputTokenBalance) {
            // exactly output the output token's balance
            // need to recompute swap
            params.amountSpecified = -outputTokenBalance.toInt256();
            (updatedSqrtPriceX96, updatedTick, inputAmount, outputAmount) = _computeSwap(
                key,
                totalLiquidity,
                liquidityDensityOfRoundedTickX96,
                density0RightOfRoundedTickX96,
                density1LeftOfRoundedTickX96,
                sqrtPriceX96,
                currentTick,
                roundedTickSqrtRatio,
                nextRoundedTickSqrtRatio,
                liquidityDensityFunction,
                arithmeticMeanTick,
                useTwap,
                ldfParams,
                ldfState,
                params
            );

            if (outputAmount > outputTokenBalance) {
                // somehow the output amount is still greater than the balance due to rounding errors
                // just set outputAmount to the balance
                outputAmount = outputTokenBalance;
            }
        }
    }

    function _computeSwap(
        PoolKey calldata key,
        uint256 totalLiquidity,
        uint256 liquidityDensityOfRoundedTickX96,
        uint256 density0RightOfRoundedTickX96,
        uint256 density1LeftOfRoundedTickX96,
        uint160 sqrtPriceX96,
        int24 currentTick,
        uint160 roundedTickSqrtRatio,
        uint160 nextRoundedTickSqrtRatio,
        ILiquidityDensityFunction liquidityDensityFunction,
        int24 arithmeticMeanTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState,
        IPoolManager.SwapParams memory params
    )
        private
        view
        returns (uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount, uint256 outputAmount)
    {
        // bound sqrtPriceLimit so that we never end up at an invalid rounded tick
        (uint160 minSqrtPrice, uint160 maxSqrtPrice) = (
            TickMath.minUsableTick(key.tickSpacing).getSqrtRatioAtTick(),
            TickMath.maxUsableTick(key.tickSpacing).getSqrtRatioAtTick()
        );
        uint160 sqrtPriceLimitX96 = params.sqrtPriceLimitX96;
        if (
            (params.zeroForOne && sqrtPriceLimitX96 < minSqrtPrice)
                || (!params.zeroForOne && sqrtPriceLimitX96 >= maxSqrtPrice)
        ) {
            sqrtPriceLimitX96 = params.zeroForOne ? minSqrtPrice : maxSqrtPrice - 1;
        }

        // compute updated current tick liquidity
        // totalLiquidity could exceed uint128 so .toUint128() is used
        uint128 updatedRoundedTickLiquidity = ((totalLiquidity * liquidityDensityOfRoundedTickX96) >> 96).toUint128();

        bool exactIn = params.amountSpecified >= 0;

        inputAmount = exactIn ? uint256(params.amountSpecified) : 0;
        outputAmount = exactIn ? 0 : uint256(-params.amountSpecified);

        // handle special case when we don't cross rounded ticks
        uint160 naiveSwapNextSqrtPriceX96;
        if (updatedRoundedTickLiquidity != 0) {
            naiveSwapNextSqrtPriceX96 = exactIn
                ? SqrtPriceMath.getNextSqrtPriceFromInput(
                    sqrtPriceX96, updatedRoundedTickLiquidity, inputAmount, params.zeroForOne
                )
                : SqrtPriceMath.getNextSqrtPriceFromOutput(
                    sqrtPriceX96, updatedRoundedTickLiquidity, outputAmount, params.zeroForOne
                );
        }
        if (
            (updatedRoundedTickLiquidity != 0)
                && (
                    (params.zeroForOne && naiveSwapNextSqrtPriceX96 >= roundedTickSqrtRatio)
                        || (!params.zeroForOne && naiveSwapNextSqrtPriceX96 < nextRoundedTickSqrtRatio)
                )
        ) {
            // swap doesn't cross rounded tick
            updatedSqrtPriceX96 =
                _boundSqrtPriceByLimit(naiveSwapNextSqrtPriceX96, sqrtPriceLimitX96, params.zeroForOne);

            if (exactIn) {
                outputAmount = params.zeroForOne
                    ? SqrtPriceMath.getAmount1Delta(sqrtPriceX96, updatedSqrtPriceX96, updatedRoundedTickLiquidity, false)
                    : SqrtPriceMath.getAmount0Delta(sqrtPriceX96, updatedSqrtPriceX96, updatedRoundedTickLiquidity, false);
            } else {
                inputAmount = params.zeroForOne
                    ? SqrtPriceMath.getAmount0Delta(sqrtPriceX96, updatedSqrtPriceX96, updatedRoundedTickLiquidity, true)
                    : SqrtPriceMath.getAmount1Delta(sqrtPriceX96, updatedSqrtPriceX96, updatedRoundedTickLiquidity, true);
            }

            updatedTick = TickMath.getTickAtSqrtRatio(updatedSqrtPriceX96);
        } else {
            // swap crosses rounded tick
            (uint256 currentActiveBalance0, uint256 currentActiveBalance1) = LiquidityAmounts.getAmountsForLiquidity(
                sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, updatedRoundedTickLiquidity, false
            );
            (currentActiveBalance0, currentActiveBalance1) = (
                currentActiveBalance0 + ((density0RightOfRoundedTickX96 * totalLiquidity) >> 96),
                currentActiveBalance1 + ((density1LeftOfRoundedTickX96 * totalLiquidity) >> 96)
            );

            // compute updated sqrt ratio & tick
            {
                uint256 inverseCumulativeAmountFnInput;
                if (exactIn) {
                    // exact input swap
                    inverseCumulativeAmountFnInput =
                        params.zeroForOne ? currentActiveBalance0 + inputAmount : currentActiveBalance1 + inputAmount;
                } else {
                    // exact output swap
                    inverseCumulativeAmountFnInput =
                        params.zeroForOne ? currentActiveBalance1 - outputAmount : currentActiveBalance0 - outputAmount;
                }

                (bool success, int24 updatedRoundedTick, uint256 cumulativeAmount, uint128 swapLiquidity) =
                liquidityDensityFunction.computeSwap(
                    key,
                    inverseCumulativeAmountFnInput,
                    totalLiquidity,
                    params.zeroForOne,
                    exactIn,
                    arithmeticMeanTick,
                    currentTick,
                    useTwap,
                    ldfParams,
                    ldfState
                );

                if (success && swapLiquidity != 0) {
                    // use Uniswap math to compute updated sqrt price
                    uint160 startSqrtPriceX96 = TickMath.getSqrtRatioAtTick(updatedRoundedTick);
                    updatedSqrtPriceX96 = exactIn
                        ? SqrtPriceMath.getNextSqrtPriceFromInput(
                            startSqrtPriceX96,
                            swapLiquidity,
                            inverseCumulativeAmountFnInput - cumulativeAmount,
                            params.zeroForOne
                        )
                        : SqrtPriceMath.getNextSqrtPriceFromOutput(
                            startSqrtPriceX96,
                            swapLiquidity,
                            cumulativeAmount - inverseCumulativeAmountFnInput,
                            params.zeroForOne
                        );
                    updatedTick = TickMath.getTickAtSqrtRatio(updatedSqrtPriceX96);
                    console2.log("updatedTick", updatedTick);
                    console2.log("updatedSqrtPriceX96", updatedSqrtPriceX96);
                } else {
                    // liquidity is insufficient to handle all of the input/output tokens
                    (updatedTick, updatedSqrtPriceX96) = params.zeroForOne
                        ? (TickMath.MIN_TICK, TickMath.MIN_SQRT_RATIO)
                        : (TickMath.MAX_TICK, TickMath.MAX_SQRT_RATIO);
                }

                // bound sqrt price by limit
                updatedSqrtPriceX96 = _boundSqrtPriceByLimit(updatedSqrtPriceX96, sqrtPriceLimitX96, params.zeroForOne);
                if (updatedSqrtPriceX96 == sqrtPriceLimitX96) {
                    updatedTick = TickMath.getTickAtSqrtRatio(updatedSqrtPriceX96);
                }
            }

            // compute token amounts
            {
                (int24 updatedRoundedTick, int24 updatedNextRoundedTick) = roundTick(updatedTick, key.tickSpacing);
                (
                    uint256 updatedLiquidityDensityOfRoundedTickX96,
                    uint256 updatedDensity0RightOfRoundedTickX96,
                    uint256 updatedDensity1LeftOfRoundedTickX96,
                    ,
                ) = liquidityDensityFunction.query(
                    key, updatedRoundedTick, arithmeticMeanTick, updatedTick, useTwap, ldfParams, ldfState
                );
                updatedRoundedTickLiquidity =
                    ((totalLiquidity * updatedLiquidityDensityOfRoundedTickX96) >> 96).toUint128();
                console2.log("updatedRoundedTickLiquidity", updatedRoundedTickLiquidity);
                (uint256 updatedActiveBalance0, uint256 updatedActiveBalance1) = LiquidityAmounts.getAmountsForLiquidity(
                    updatedSqrtPriceX96,
                    TickMath.getSqrtRatioAtTick(updatedRoundedTick),
                    TickMath.getSqrtRatioAtTick(updatedNextRoundedTick),
                    updatedRoundedTickLiquidity,
                    true
                );
                (updatedActiveBalance0, updatedActiveBalance1) = (
                    updatedActiveBalance0 + updatedDensity0RightOfRoundedTickX96.mulDivUp(totalLiquidity, Q96),
                    updatedActiveBalance1 + updatedDensity1LeftOfRoundedTickX96.mulDivUp(totalLiquidity, Q96)
                );
                console2.log("updatedActiveBalance0", updatedActiveBalance0);
                console2.log("updatedActiveBalance1", updatedActiveBalance1);
                console2.log("currentActiveBalance0", currentActiveBalance0);
                console2.log("currentActiveBalance1", currentActiveBalance1);

                (inputAmount, outputAmount) = params.zeroForOne
                    ? (
                        updatedActiveBalance0 - currentActiveBalance0,
                        currentActiveBalance1 < updatedActiveBalance1 ? 0 : currentActiveBalance1 - updatedActiveBalance1
                    )
                    : (
                        updatedActiveBalance1 - currentActiveBalance1,
                        currentActiveBalance0 < updatedActiveBalance0 ? 0 : currentActiveBalance0 - updatedActiveBalance0
                    );

                if (exactIn && inputAmount == uint256(params.amountSpecified) + 1) {
                    // exact input swap where the input amount exceeds the amount specified
                    (inputAmount, outputAmount) = (uint256(params.amountSpecified), outputAmount - 1);
                }
            }
        }
    }

    function _boundSqrtPriceByLimit(uint160 sqrtPriceX96, uint160 sqrtPriceLimitX96, bool zeroForOne)
        private
        pure
        returns (uint160)
    {
        if ((zeroForOne && sqrtPriceLimitX96 > sqrtPriceX96) || (!zeroForOne && sqrtPriceLimitX96 < sqrtPriceX96)) {
            return sqrtPriceLimitX96;
        }
        return sqrtPriceX96;
    }
}
