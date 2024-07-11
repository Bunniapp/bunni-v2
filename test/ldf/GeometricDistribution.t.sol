// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import "./LiquidityDensityFunctionTest.sol";
import "../../src/ldf/GeometricDistribution.sol";
import "../../src/ldf/LibGeometricDistribution.sol";

contract GeometricDistributionTest is LiquidityDensityFunctionTest {
    uint256 internal constant MIN_ALPHA = 1e3;
    uint256 internal constant MAX_ALPHA = 12e8;

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

    function test_inverseCumulativeAmount0(int24 tick, int24 tickSpacing, int24 minTick, int24 length, uint256 alpha)
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
        tick = int24(bound(tick, minUsableTick, maxUsableTick));

        console2.log("tick", tick);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount0DensityX96 =
            LibGeometricDistribution.cumulativeAmount0(roundedTick, liquidity, tickSpacing, minTick, length, alphaX96);
        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick < minTick
            ? minTick
            : roundedTick >= minTick + length * tickSpacing ? minTick + length * tickSpacing : roundedTick;
        console2.log("x", (expectedTick - minTick) / tickSpacing);
        assertTrue(success, "inverseCumulativeAmount0 failed");
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_inverseCumulativeAmount1(int24 tick, int24 tickSpacing, int24 minTick, int24 length, uint256 alpha)
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
        tick = int24(bound(tick, minUsableTick, maxUsableTick));

        console2.log("tick", tick);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount1DensityX96 =
            LibGeometricDistribution.cumulativeAmount1(roundedTick, liquidity, tickSpacing, minTick, length, alphaX96);
        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick < minTick
            ? minTick
            : roundedTick > minTick + (length - 1) * tickSpacing ? minTick + (length - 1) * tickSpacing : roundedTick;
        if (cumulativeAmount1DensityX96 == 0) expectedTick = minTick - tickSpacing;
        console2.log("x", (expectedTick - minTick) / tickSpacing);
        assertTrue(success, "inverseCumulativeAmount1 failed");
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_inverseCumulativeAmount0_withPurturbation(
        int24 tick,
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
        tick = int24(bound(tick, minTick, minTick + length * tickSpacing));

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);
        console2.log("alpha", alpha);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount0DensityX96 =
            LibGeometricDistribution.cumulativeAmount0(roundedTick, liquidity, tickSpacing, minTick, length, alphaX96);

        // purturb density upwards
        {
            uint256 nextCumulativeAmount0DensityX96 = LibGeometricDistribution.cumulativeAmount0(
                roundedTick - tickSpacing, liquidity, tickSpacing, minTick, length, alphaX96
            );
            cumulativeAmount0DensityX96 = nextCumulativeAmount0DensityX96 > cumulativeAmount0DensityX96
                ? (cumulativeAmount0DensityX96 + nextCumulativeAmount0DensityX96) / 2
                : cumulativeAmount0DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        if (success) {
            int24 expectedTick = roundedTick <= minTick
                ? minTick
                : roundedTick >= minTick + length * tickSpacing ? minTick + length * tickSpacing : roundedTick;
            assertEq(resultRoundedTick, expectedTick, "tick incorrect");
        } else {
            assertLe(roundedTick, minTick, "inverseCumulativeAmount0 failed");
        }
    }

    function test_inverseCumulativeAmount1_withPurturbation(
        int24 tick,
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
        tick = int24(bound(tick, minTick, minTick + length * tickSpacing));

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);
        console2.log("alpha", alpha);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount1DensityX96 =
            LibGeometricDistribution.cumulativeAmount1(roundedTick, liquidity, tickSpacing, minTick, length, alphaX96);

        // purturb density upwards
        {
            uint256 nextCumulativeAmount1DensityX96 = LibGeometricDistribution.cumulativeAmount1(
                roundedTick + tickSpacing, liquidity, tickSpacing, minTick, length, alphaX96
            );
            console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);
            console2.log("nextCumulativeAmount1DensityX96", nextCumulativeAmount1DensityX96);
            cumulativeAmount1DensityX96 = nextCumulativeAmount1DensityX96 > cumulativeAmount1DensityX96
                ? (cumulativeAmount1DensityX96 + nextCumulativeAmount1DensityX96) / 2
                : cumulativeAmount1DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick < minTick
            ? minTick
            : roundedTick >= minTick + (length - 1) * tickSpacing ? int24(0) : roundedTick + tickSpacing;

        assertTrue(success || roundedTick >= minTick + (length - 1) * tickSpacing, "inverseCumulativeAmount1 failed");
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
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
