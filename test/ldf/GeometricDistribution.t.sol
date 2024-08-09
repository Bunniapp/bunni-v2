// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import "./LiquidityDensityFunctionTest.sol";
import "../../src/ldf/GeometricDistribution.sol";
import "../../src/ldf/LibGeometricDistribution.sol";

contract GeometricDistributionTest is LiquidityDensityFunctionTest {
    uint256 internal constant MIN_ALPHA = 1e3;
    uint256 internal constant MAX_ALPHA = 12e8;
    uint256 internal constant INVCUM0_MAX_ERROR = 3;

    function _setUpLDF() internal override {
        ldf = ILiquidityDensityFunction(address(new GeometricDistribution()));
    }

    function test_liquidityDensity_sumUpToOne(int24 tickSpacing, int24 minTick, int24 length, uint256 alpha)
        external
        virtual
    {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));

        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));
        _test_liquidityDensity_sumUpToOne(tickSpacing, ldfParams);
    }

    function test_query_cumulativeAmounts(
        int24 currentTick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        currentTick = int24(bound(currentTick, minUsableTick, maxUsableTick));

        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));
        _test_query_cumulativeAmounts(currentTick, tickSpacing, ldfParams);
    }

    function test_inverseCumulativeAmount0(
        uint256 liquidity,
        uint256 cumulativeAmount0,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha
    ) external virtual {
        liquidity = bound(liquidity, 1e18, 1e36);
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        uint256 alphaX96 = (alpha << 96) / 1e8;
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, maxUsableTick / tickSpacing));

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint256 maxCumulativeAmount0 =
            LibGeometricDistribution.cumulativeAmount0(minUsableTick, liquidity, tickSpacing, minTick, length, alphaX96);
        cumulativeAmount0 = bound(cumulativeAmount0, 0, maxCumulativeAmount0);

        console2.log("cumulativeAmount0", cumulativeAmount0);
        console2.log("maxCumulativeAmount0", maxCumulativeAmount0);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        (bool success, int24 resultRoundedTick) = LibGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0, liquidity, tickSpacing, minTick, length, alphaX96
        );
        assertTrue(success, "inverseCumulativeAmount0 failed");
        console2.log("resultRoundedTick", resultRoundedTick);

        uint256 resultCumulativeAmount0 = LibGeometricDistribution.cumulativeAmount0(
            resultRoundedTick, liquidity, tickSpacing, minTick, length, alphaX96
        );

        // NOTE: in rare cases resultCumulativeAmount0 may be slightly greater than cumulativeAmount0
        // the frequency of such errors is bounded by INVCUM0_MAX_ERROR
        assertLe(
            _subError(resultCumulativeAmount0, INVCUM0_MAX_ERROR),
            cumulativeAmount0,
            "resultCumulativeAmount0 > cumulativeAmount0"
        );

        if (resultRoundedTick > minTick && cumulativeAmount0 > 1.2e4) {
            // NOTE: when cumulativeAmount0 is small this assertion may fail due to rounding errors
            uint256 nextCumulativeAmount0 = LibGeometricDistribution.cumulativeAmount0(
                resultRoundedTick - tickSpacing, liquidity, tickSpacing, minTick, length, alphaX96
            );
            assertGt(nextCumulativeAmount0, cumulativeAmount0, "nextCumulativeAmount0 <= cumulativeAmount0");
        }
    }

    function test_inverseCumulativeAmount1(
        uint256 liquidity,
        uint256 cumulativeAmount1,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha
    ) external virtual {
        liquidity = bound(liquidity, 1e18, 1e36);
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        uint256 alphaX96 = (alpha << 96) / 1e8;
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, maxUsableTick / tickSpacing));

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint256 maxCumulativeAmount1 =
            LibGeometricDistribution.cumulativeAmount1(maxUsableTick, liquidity, tickSpacing, minTick, length, alphaX96);
        vm.assume(maxCumulativeAmount1 != 0);
        cumulativeAmount1 = bound(cumulativeAmount1, 0, maxCumulativeAmount1);

        console2.log("cumulativeAmount1", cumulativeAmount1);
        console2.log("maxCumulativeAmount1", maxCumulativeAmount1);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        (bool success, int24 resultRoundedTick) = LibGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1, liquidity, tickSpacing, minTick, length, alphaX96
        );
        assertTrue(success, "inverseCumulativeAmount1 failed");
        console2.log("resultRoundedTick", resultRoundedTick);

        uint256 resultCumulativeAmount1 = LibGeometricDistribution.cumulativeAmount1(
            resultRoundedTick, liquidity, tickSpacing, minTick, length, alphaX96
        );

        assertGe(resultCumulativeAmount1, cumulativeAmount1, "resultCumulativeAmount1 < cumulativeAmount1");

        if (resultRoundedTick > minTick) {
            uint256 nextCumulativeAmount1 = LibGeometricDistribution.cumulativeAmount1(
                resultRoundedTick - tickSpacing, liquidity, tickSpacing, minTick, length, alphaX96
            );
            assertLt(nextCumulativeAmount1, cumulativeAmount1, "nextCumulativeAmount1 >= cumulativeAmount1");
        }
    }

    function test_boundary_static_invalidWhenOutOfBounds(int24 tickSpacing) external view {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        uint32 alpha = 0.9e8;
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        // invalid when minTick < minUsableTick
        (int24 minTick, int24 length) = (minUsableTick - tickSpacing, 2);
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha)));
        assertFalse(ldf.isValidParams(key, 0, ldfParams));

        // invalid when maxTick > maxUsableTick
        (minTick, length) = (maxUsableTick - tickSpacing, 2);
        ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha)));
        assertFalse(ldf.isValidParams(key, 0, ldfParams));

        // valid test
        (minTick, length) = (0, 2);
        ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha)));
        assertTrue(ldf.isValidParams(key, 0, ldfParams));
    }

    function test_boundary_dynamic_boundedWhenDecoding(int24 tickSpacing) external view {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        uint32 alpha = 0.9e8;
        ShiftMode shiftMode = ShiftMode.RIGHT;
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        // bounded when minTick < minUsableTick
        (int24 offset, int24 length) = (minUsableTick - tickSpacing, 2);
        bytes32 ldfParams = bytes32(abi.encodePacked(shiftMode, offset, int16(length), uint32(alpha)));
        assertTrue(ldf.isValidParams(key, 1, ldfParams));
        (int24 minTick,,, ShiftMode decodedShiftMode) = LibGeometricDistribution.decodeParams(0, tickSpacing, ldfParams);
        assertEq(minTick, minUsableTick, "minTick incorrect");
        assertTrue(shiftMode == decodedShiftMode, "shiftMode incorrect");

        // bounded when maxTick > maxUsableTick
        (offset, length) = (maxUsableTick - tickSpacing, 2);
        ldfParams = bytes32(abi.encodePacked(shiftMode, offset, int16(length), uint32(alpha)));
        assertTrue(ldf.isValidParams(key, 1, ldfParams));
        (minTick,,, decodedShiftMode) = LibGeometricDistribution.decodeParams(0, tickSpacing, ldfParams);
        assertEq(minTick + length * tickSpacing, maxUsableTick, "maxTick incorrect");
        assertTrue(shiftMode == decodedShiftMode, "shiftMode incorrect");
    }
}
