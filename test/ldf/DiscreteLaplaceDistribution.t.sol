// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/contracts/libraries/FullMath.sol";
import {FixedPoint96} from "@uniswap/v4-core/contracts/libraries/FixedPoint96.sol";

import "../../src/lib/Math.sol";
import {DiscreteLaplaceDistribution} from "../../src/ldf/DiscreteLaplaceDistribution.sol";

contract DiscreteLaplaceDistributionTest is Test {
    using TickMath for int24;

    uint256 internal constant MAX_ERROR = 1e16;
    int24 internal constant MAX_TICK_SPACING = type(int16).max;
    int24 internal constant MIN_TICK_SPACING = 1000; // >1 to make brute forcing viable
    uint256 internal constant MIN_ALPHA = 1e14;
    uint256 internal constant MAX_ALPHA = 0.9e18;

    DiscreteLaplaceDistribution internal ldf;

    function setUp() external {
        ldf = new DiscreteLaplaceDistribution();
        vm.label(address(ldf), "LDF");
    }

    function test_liquidityDensity_sumUpToOne(int24 tickSpacing, int24 mu, uint256 alpha) external {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minTick, int24 maxTick) = (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        mu = roundTickSingle(int24(bound(mu, minTick, maxTick)), tickSpacing);
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);

        uint256 cumulativeLiquidityDensity;
        for (int24 tick = minTick; tick <= maxTick; tick += tickSpacing) {
            cumulativeLiquidityDensity +=
                ldf.liquidityDensity(tick, 0, tickSpacing, false, bytes11(abi.encodePacked(mu, uint64(alpha))));
        }

        assertApproxEqRel(
            cumulativeLiquidityDensity, FixedPointMathLib.WAD, MAX_ERROR, "liquidity density doesn't add up to one"
        );
    }

    function test_query_cumulativeAmounts(int24 currentTick, int24 tickSpacing, int24 mu, uint256 alpha) external {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minTick, int24 maxTick) = (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        currentTick = int24(bound(currentTick, minTick, maxTick));
        mu = roundTickSingle(int24(bound(mu, minTick, maxTick)), tickSpacing);
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);

        int24 roundedTick = roundTickSingle(currentTick, tickSpacing);
        (, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96) =
            ldf.query(roundedTick, 0, tickSpacing, false, bytes11(abi.encodePacked(mu, uint64(alpha))));
        uint256 bruteForceAmount0X96 =
            _bruteForceCumulativeAmount0Density(roundedTick + tickSpacing, tickSpacing, mu, alpha);
        uint256 bruteForceAmount1X96 =
            _bruteForceCumulativeAmount1Density(roundedTick - tickSpacing, tickSpacing, mu, alpha);

        uint256 minAbsoluteError = FixedPoint96.Q96 / 1e3;
        if (_absoluteDiff(cumulativeAmount0DensityX96, bruteForceAmount0X96) > minAbsoluteError) {
            assertApproxEqRel(
                cumulativeAmount0DensityX96, bruteForceAmount0X96, MAX_ERROR, "cumulativeAmount0DensityX96 incorrect"
            );
        }

        if (_absoluteDiff(cumulativeAmount1DensityX96, bruteForceAmount1X96) > minAbsoluteError) {
            assertApproxEqRel(
                cumulativeAmount1DensityX96, bruteForceAmount1X96, MAX_ERROR, "cumulativeAmount1DensityX96 incorrect"
            );
        }
    }

    function _bruteForceCumulativeAmount0Density(int24 roundedTick, int24 tickSpacing, int24 mu, uint256 alpha)
        internal
        view
        returns (uint256 cumulativeAmount0DensityX96)
    {
        int24 maxTick = TickMath.maxUsableTick(tickSpacing);
        for (int24 tick = roundedTick; tick <= maxTick; tick += tickSpacing) {
            uint256 liquidityDensity =
                ldf.liquidityDensity(tick, 0, tickSpacing, false, bytes11(abi.encodePacked(mu, uint64(alpha))));
            uint256 amount0DensityX96 = _amount0DensityX96(tick, tickSpacing);
            cumulativeAmount0DensityX96 += FullMath.mulDiv(amount0DensityX96, liquidityDensity, FixedPointMathLib.WAD);
        }
    }

    function _amount0DensityX96(int24 roundedTick, int24 tickSpacing)
        internal
        pure
        returns (uint256 amount0DensityX96)
    {
        return FullMath.mulDiv(
            FixedPoint96.Q96 - (-tickSpacing).getSqrtRatioAtTick(), _getSqrtRatioAtTick(-roundedTick), FixedPoint96.Q96
        );
    }

    function _getSqrtRatioAtTick(int24 tick) internal pure returns (uint160) {
        if (tick < TickMath.MIN_TICK) return 0;
        if (tick > TickMath.MAX_TICK) return TickMath.MAX_SQRT_RATIO;
        return tick.getSqrtRatioAtTick();
    }

    function _bruteForceCumulativeAmount1Density(int24 roundedTick, int24 tickSpacing, int24 mu, uint256 alpha)
        internal
        view
        returns (uint256 cumulativeAmount1DensityX96)
    {
        int24 minTick = TickMath.minUsableTick(tickSpacing);
        for (int24 tick = minTick; tick <= roundedTick; tick += tickSpacing) {
            uint256 liquidityDensity =
                ldf.liquidityDensity(tick, 0, tickSpacing, false, bytes11(abi.encodePacked(mu, uint64(alpha))));
            uint256 amount1DensityX96 = _amount1DensityX96(tick, tickSpacing);
            cumulativeAmount1DensityX96 += FullMath.mulDiv(amount1DensityX96, liquidityDensity, FixedPointMathLib.WAD);
        }
    }

    function _amount1DensityX96(int24 roundedTick, int24 tickSpacing)
        internal
        pure
        returns (uint256 amount1DensityX96)
    {
        return FullMath.mulDiv(
            tickSpacing.getSqrtRatioAtTick() - FixedPoint96.Q96, _getSqrtRatioAtTick(roundedTick), FixedPoint96.Q96
        );
    }

    function _absoluteDiff(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : b - a;
    }
}
