// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import "./LiquidityDensityFunctionTest.sol";
import "../../src/ldf/CarpetedGeometricDistribution.sol";
import "../../src/ldf/LibCarpetedGeometricDistribution.sol";

contract CarpetedGeometricDistributionTest is LiquidityDensityFunctionTest {
    uint256 internal constant MIN_ALPHA = 1e3;
    uint256 internal constant MAX_ALPHA = 12e8;

    function _setUpLDF() internal override {
        ldf = ILiquidityDensityFunction(address(new CarpetedGeometricDistribution()));
    }

    function test_liquidityDensity_sumUpToOne(
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha,
        uint256 weightCarpet
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        weightCarpet = bound(weightCarpet, 1, 1e9);

        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);
        console2.log("weightCarpet", weightCarpet);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams =
            bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha), uint32(weightCarpet)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));
        _test_liquidityDensity_sumUpToOne(tickSpacing, ldfParams);
    }

    function test_query_cumulativeAmounts(
        int24 currentTick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha,
        uint256 weightCarpet
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        currentTick = int24(bound(currentTick, minUsableTick, maxUsableTick));
        weightCarpet = bound(weightCarpet, 1e9, type(uint32).max);

        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams =
            bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha), uint32(weightCarpet)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));
        _test_query_cumulativeAmounts(currentTick, tickSpacing, ldfParams);
    }

    function test_inverseCumulativeAmount0(
        int24 tick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha,
        uint256 weightCarpet
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        tick = int24(bound(tick, minUsableTick, maxUsableTick));
        weightCarpet = bound(weightCarpet, 1e9, type(uint32).max);

        console2.log("tick", tick);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams =
            bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha), uint32(weightCarpet)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount0DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount0(
            roundedTick, liquidity, tickSpacing, minTick, length, alphaX96, weightCarpet
        );
        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, weightCarpet, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick;
        console2.log("x", (expectedTick - minTick) / tickSpacing);
        assertTrue(success, "inverseCumulativeAmount0 failed");
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_inverseCumulativeAmount1(
        int24 tick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha,
        uint256 weightCarpet
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        tick = int24(bound(tick, minUsableTick, maxUsableTick));
        weightCarpet = bound(weightCarpet, 1e6, type(uint32).max);

        console2.log("tick", tick);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams =
            bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha), uint32(weightCarpet)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount1DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount1(
            roundedTick, liquidity, tickSpacing, minTick, length, alphaX96, weightCarpet
        );
        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, weightCarpet, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick;
        console2.log("x", (expectedTick - minTick) / tickSpacing);
        assertTrue(success, "inverseCumulativeAmount1 failed");
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_inverseCumulativeAmount0_withPurturbation(
        int24 tick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha,
        uint256 weightCarpet
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        tick = int24(bound(tick, minUsableTick, maxUsableTick - tickSpacing));
        weightCarpet = bound(weightCarpet, 1e9, type(uint32).max);

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);
        console2.log("alpha", alpha);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams =
            bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha), uint32(weightCarpet)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount0DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount0(
            roundedTick, liquidity, tickSpacing, minTick, length, alphaX96, weightCarpet
        );

        // purturb density upwards
        {
            uint256 nextCumulativeAmount0DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount0(
                roundedTick - tickSpacing, liquidity, tickSpacing, minTick, length, alphaX96, weightCarpet
            );
            cumulativeAmount0DensityX96 = nextCumulativeAmount0DensityX96 > cumulativeAmount0DensityX96
                ? (cumulativeAmount0DensityX96 + nextCumulativeAmount0DensityX96) / 2
                : cumulativeAmount0DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, weightCarpet, true
        );

        if (success) {
            console2.log("resultRoundedTick", resultRoundedTick);
            int24 expectedTick = roundedTick;
            assertEq(resultRoundedTick, expectedTick, "tick incorrect");
        } else {
            assertEq(roundedTick, minUsableTick, "tick not minUsableTick");
        }
    }

    function test_inverseCumulativeAmount1_withPurturbation(
        int24 tick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha,
        uint256 weightCarpet
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        tick = int24(bound(tick, minUsableTick, maxUsableTick - tickSpacing));
        weightCarpet = bound(weightCarpet, 1e9, type(uint32).max);

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);
        console2.log("alpha", alpha);

        PoolKey memory key;
        key.tickSpacing = tickSpacing;
        bytes32 ldfParams =
            bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), uint32(alpha), uint32(weightCarpet)));
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount1DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount1(
            roundedTick, liquidity, tickSpacing, minTick, length, alphaX96, weightCarpet
        );

        // purturb density upwards
        {
            uint256 nextCumulativeAmount1DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount1(
                roundedTick + tickSpacing, liquidity, tickSpacing, minTick, length, alphaX96, weightCarpet
            );
            console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);
            console2.log("nextCumulativeAmount1DensityX96", nextCumulativeAmount1DensityX96);
            cumulativeAmount1DensityX96 = nextCumulativeAmount1DensityX96 > cumulativeAmount1DensityX96
                ? (cumulativeAmount1DensityX96 + nextCumulativeAmount1DensityX96) / 2
                : cumulativeAmount1DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, weightCarpet, true
        );

        if (success) {
            console2.log("resultRoundedTick", resultRoundedTick);
            int24 expectedTick = roundedTick + tickSpacing;
            assertEq(resultRoundedTick, expectedTick, "tick incorrect");
        } else {
            assertEq(roundedTick, maxUsableTick - tickSpacing, "tick not maxUsableTick");
        }
    }

    function test_boundary_static_invalidWhenOutOfBounds(int24 tickSpacing) external view {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        uint32 alpha = 0.9e8;
        uint32 weightCarpet = 0.9e9;
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        // invalid when minTick < minUsableTick
        (int24 minTick, int24 length) = (minUsableTick - tickSpacing, 2);
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), alpha, weightCarpet));
        assertFalse(ldf.isValidParams(key, 0, ldfParams));

        // invalid when maxTick > maxUsableTick
        (minTick, length) = (maxUsableTick - tickSpacing, 2);
        ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), alpha, weightCarpet));
        assertFalse(ldf.isValidParams(key, 0, ldfParams));

        // valid test
        (minTick, length) = (0, 2);
        ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, minTick, int16(length), alpha, weightCarpet));
        assertTrue(ldf.isValidParams(key, 0, ldfParams));
    }

    function test_boundary_dynamic_boundedWhenDecoding(int24 tickSpacing) external view {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        uint32 alpha = 0.9e8;
        uint32 weightCarpet = 0.9e9;
        ShiftMode shiftMode = ShiftMode.RIGHT;
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        // bounded when minTick < minUsableTick
        (int24 offset, int24 length) = (minUsableTick - tickSpacing, 2);
        bytes32 ldfParams = bytes32(abi.encodePacked(shiftMode, offset, int16(length), alpha, weightCarpet));
        assertTrue(ldf.isValidParams(key, 1, ldfParams), "invalid params 0");
        (int24 minTick,,,, ShiftMode decodedShiftMode) =
            LibCarpetedGeometricDistribution.decodeParams(0, tickSpacing, ldfParams);
        assertEq(minTick, minUsableTick, "minTick incorrect");
        assertTrue(shiftMode == decodedShiftMode, "shiftMode incorrect");

        // bounded when maxTick > maxUsableTick
        (offset, length) = (maxUsableTick - tickSpacing, 2);
        ldfParams = bytes32(abi.encodePacked(shiftMode, offset, int16(length), alpha, weightCarpet));
        assertTrue(ldf.isValidParams(key, 1, ldfParams), "invalid params 1");
        (minTick,,,, decodedShiftMode) = LibCarpetedGeometricDistribution.decodeParams(0, tickSpacing, ldfParams);
        assertEq(minTick + length * tickSpacing, maxUsableTick, "maxTick incorrect");
        assertTrue(shiftMode == decodedShiftMode, "shiftMode incorrect");
    }
}
