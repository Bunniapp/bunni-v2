// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {FixedPoint96} from "@uniswap/v4-core/src/libraries/FixedPoint96.sol";

import "../../src/lib/Math.sol";
import {ShiftMode} from "../../src/ldf/ShiftMode.sol";
import {ILiquidityDensityFunction} from "../../src/interfaces/ILiquidityDensityFunction.sol";

abstract contract LiquidityDensityFunctionTest is Test {
    using TickMath for int24;
    using FixedPointMathLib for uint256;

    uint256 internal constant MAX_ERROR = 1e10;
    int24 internal constant MAX_TICK_SPACING = type(int16).max;
    int24 internal constant MIN_TICK_SPACING = 1000; // >1 to make brute forcing viable
    uint256 internal constant MIN_ABS_ERROR = FixedPoint96.Q96 / 1e9;
    bytes32 internal constant LDF_STATE = bytes32(0);

    ILiquidityDensityFunction internal ldf;

    function setUp() external virtual {
        _setUpLDF();
        vm.label(address(ldf), "LDF");
    }

    function _setUpLDF() internal virtual;

    function _test_liquidityDensity_sumUpToOne(int24 tickSpacing, bytes32 decodedLDFParams) internal view {
        uint256 cumulativeLiquidityDensity;
        (int24 minTick, int24 maxTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing) - tickSpacing);
        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        int24 spotPriceTick = 0;
        for (int24 tick = minTick; tick <= maxTick; tick += tickSpacing) {
            (uint256 liquidityDensityX96,,,,) = ldf.query(key, tick, 0, spotPriceTick, decodedLDFParams, LDF_STATE);
            cumulativeLiquidityDensity += liquidityDensityX96;
        }

        assertApproxEqRel(
            cumulativeLiquidityDensity, FixedPoint96.Q96, MAX_ERROR, "liquidity density doesn't add up to one"
        );
    }

    function _test_query_cumulativeAmounts(int24 currentTick, int24 tickSpacing, bytes32 decodedLDFParams)
        internal
        view
    {
        int24 roundedTick = roundTickSingle(currentTick, tickSpacing);
        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        (, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96,,) =
            ldf.query(key, roundedTick, 0, currentTick, decodedLDFParams, LDF_STATE);
        uint256 bruteForceAmount0X96 =
            _bruteForceCumulativeAmount0Density(roundedTick + tickSpacing, tickSpacing, decodedLDFParams);
        uint256 bruteForceAmount1X96 =
            _bruteForceCumulativeAmount1Density(roundedTick - tickSpacing, tickSpacing, decodedLDFParams);

        (, uint256 error0) = absDiff(cumulativeAmount0DensityX96, bruteForceAmount0X96);
        if (error0 > MIN_ABS_ERROR) {
            assertApproxEqRel(
                cumulativeAmount0DensityX96, bruteForceAmount0X96, MAX_ERROR, "cumulativeAmount0DensityX96 incorrect"
            );
        }

        (, uint256 error1) = absDiff(cumulativeAmount1DensityX96, bruteForceAmount1X96);
        if (error1 > MIN_ABS_ERROR) {
            assertApproxEqRel(
                cumulativeAmount1DensityX96, bruteForceAmount1X96, MAX_ERROR, "cumulativeAmount1DensityX96 incorrect"
            );
        }
    }

    function _bruteForceCumulativeAmount0Density(int24 roundedTick, int24 tickSpacing, bytes32 decodedLDFParams)
        internal
        view
        returns (uint256 cumulativeAmount0DensityX96)
    {
        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        int24 spotPriceTick = 0;
        int24 maxTick = TickMath.maxUsableTick(tickSpacing) - tickSpacing;
        for (int24 tick = roundedTick; tick <= maxTick; tick += tickSpacing) {
            (uint256 liquidityDensityX96,,,,) = ldf.query(key, tick, 0, spotPriceTick, decodedLDFParams, LDF_STATE);
            uint256 amount0DensityX96 = _amount0DensityX96(tick, tickSpacing);
            cumulativeAmount0DensityX96 += amount0DensityX96.fullMulDiv(liquidityDensityX96, FixedPoint96.Q96);
        }
    }

    function _amount0DensityX96(int24 roundedTick, int24 tickSpacing)
        internal
        pure
        returns (uint256 amount0DensityX96)
    {
        return (FixedPoint96.Q96 - (-tickSpacing).getSqrtPriceAtTick()).fullMulDiv(
            FixedPoint96.Q96, (roundedTick).getSqrtPriceAtTick()
        );
    }

    function _bruteForceCumulativeAmount1Density(int24 roundedTick, int24 tickSpacing, bytes32 decodedLDFParams)
        internal
        view
        returns (uint256 cumulativeAmount1DensityX96)
    {
        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        int24 spotPriceTick = 0;
        int24 minTick = TickMath.minUsableTick(tickSpacing);
        for (int24 tick = minTick; tick <= roundedTick; tick += tickSpacing) {
            (uint256 liquidityDensityX96,,,,) = ldf.query(key, tick, 0, spotPriceTick, decodedLDFParams, LDF_STATE);
            uint256 amount1DensityX96 = _amount1DensityX96(tick, tickSpacing);
            cumulativeAmount1DensityX96 += amount1DensityX96.fullMulDiv(liquidityDensityX96, FixedPoint96.Q96);
        }
    }

    function _amount1DensityX96(int24 roundedTick, int24 tickSpacing)
        internal
        pure
        returns (uint256 amount1DensityX96)
    {
        return (tickSpacing.getSqrtPriceAtTick() - FixedPoint96.Q96).fullMulDiv(
            (roundedTick).getSqrtPriceAtTick(), FixedPoint96.Q96
        );
    }
}

function _subError(uint256 x, uint256 err) pure returns (uint256) {
    return x >= err ? x - err : 0;
}
