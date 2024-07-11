// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import "forge-std/console2.sol";

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import {roundTick} from "./Math.sol";
import {Q96} from "../base/Constants.sol";
import {LiquidityAmounts} from "./LiquidityAmounts.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

using FixedPointMathLib for uint256;

/// @notice Queries the liquidity density function for the given pool and tick
/// @param key The pool key
/// @param sqrtPriceX96 The current sqrt price of the pool
/// @param tick The current tick of the pool
/// @param arithmeticMeanTick The TWAP oracle value
/// @param ldf The liquidity density function
/// @param ldfParams The parameters for the liquidity density function
/// @param ldfState The current state of the liquidity density function
/// @param balance0 The balance of token0 in the pool
/// @param balance1 The balance of token1 in the pool
/// @return totalLiquidity The total liquidity in the pool
/// @return totalDensity0X96 The total density of token0 in the pool, scaled by Q96
/// @return totalDensity1X96 The total density of token1 in the pool, scaled by Q96
/// @return liquidityDensityOfRoundedTickX96 The liquidity density of the rounded tick, scaled by Q96
/// @return newLdfState The new state of the liquidity density function
/// @return shouldSurge Whether the pool should surge
function queryLDF(
    PoolKey memory key,
    uint160 sqrtPriceX96,
    int24 tick,
    int24 arithmeticMeanTick,
    ILiquidityDensityFunction ldf,
    bytes32 ldfParams,
    bytes32 ldfState,
    uint256 balance0,
    uint256 balance1
)
    view
    returns (
        uint256 totalLiquidity,
        uint256 totalDensity0X96,
        uint256 totalDensity1X96,
        uint256 liquidityDensityOfRoundedTickX96,
        bytes32 newLdfState,
        bool shouldSurge
    )
{
    (int24 roundedTick, int24 nextRoundedTick) = roundTick(tick, key.tickSpacing);
    (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
        (TickMath.getSqrtPriceAtTick(roundedTick), TickMath.getSqrtPriceAtTick(nextRoundedTick));
    uint256 density0RightOfRoundedTickX96;
    uint256 density1LeftOfRoundedTickX96;
    (
        liquidityDensityOfRoundedTickX96,
        density0RightOfRoundedTickX96,
        density1LeftOfRoundedTickX96,
        newLdfState,
        shouldSurge
    ) = ldf.query(key, roundedTick, arithmeticMeanTick, tick, ldfParams, ldfState);

    (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts.getAmountsForLiquidity(
        sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, uint128(liquidityDensityOfRoundedTickX96), false
    );
    totalDensity0X96 = density0RightOfRoundedTickX96 + density0OfRoundedTickX96;
    totalDensity1X96 = density1LeftOfRoundedTickX96 + density1OfRoundedTickX96;
    uint256 totalLiquidityEstimate0 =
        (balance0 == 0 || totalDensity0X96 == 0) ? 0 : balance0.fullMulDiv(Q96, totalDensity0X96);
    uint256 totalLiquidityEstimate1 =
        (balance1 == 0 || totalDensity1X96 == 0) ? 0 : balance1.fullMulDiv(Q96, totalDensity1X96);
    if (totalLiquidityEstimate0 == 0) {
        totalLiquidity = totalLiquidityEstimate1;
    } else if (totalLiquidityEstimate1 == 0) {
        totalLiquidity = totalLiquidityEstimate0;
    } else {
        totalLiquidity = FixedPointMathLib.min(totalLiquidityEstimate0, totalLiquidityEstimate1);
    }
}
