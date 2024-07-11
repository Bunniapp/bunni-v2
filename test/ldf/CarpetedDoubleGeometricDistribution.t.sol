// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import "./LiquidityDensityFunctionTest.sol";
import "../../src/ldf/CarpetedDoubleGeometricDistribution.sol";
import "../../src/ldf/LibCarpetedDoubleGeometricDistribution.sol";

contract CarpetedDoubleGeometricDistributionTest is LiquidityDensityFunctionTest {
    uint256 internal constant MIN_ALPHA = 1e3;
    uint256 internal constant MAX_ALPHA = 12e8;

    function _setUpLDF() internal override {
        ldf = ILiquidityDensityFunction(address(new CarpetedDoubleGeometricDistribution()));
    }

    function test_liquidityDensity_sumUpToOne(
        int24 tickSpacing,
        int24 minTick,
        int24 length0,
        uint256 alpha0,
        int24 length1,
        uint256 alpha1,
        uint32 weight0,
        uint32 weight1,
        uint256 weightMain
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        weight0 = uint32(bound(weight0, 1, 1e6));
        weight1 = uint32(bound(weight1, 1, 1e6));

        alpha1 = bound(alpha1, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha1 != 1e8); // 1e8 is a special case that causes overflow
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 3 * tickSpacing)), tickSpacing);
        length1 = int24(bound(length1, 1, (maxUsableTick - minTick) / tickSpacing - 2));

        alpha0 = bound(alpha0, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha0 != 1e8); // 1e8 is a special case that causes overflow
        length0 = int24(bound(length0, 1, (maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1));

        weightMain = bound(weightMain, 0.5e9, 0.99e9);

        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("alpha0", alpha0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes32 ldfParams = bytes32(
            abi.encodePacked(
                ShiftMode.STATIC,
                minTick,
                int16(length0),
                uint32(alpha0),
                weight0,
                int16(length1),
                uint32(alpha1),
                weight1,
                uint32(weightMain)
            )
        );
        vm.assume(ldf.isValidParams(key, 0, ldfParams));
        _test_liquidityDensity_sumUpToOne(tickSpacing, ldfParams);
    }

    function test_query_cumulativeAmounts(
        int24 currentTick,
        int24 tickSpacing,
        int24 minTick,
        int24 length0,
        uint256 alpha0,
        int24 length1,
        uint256 alpha1,
        uint32 weight0,
        uint32 weight1,
        uint256 weightMain
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        weight0 = uint32(bound(weight0, 1, 1e6));
        weight1 = uint32(bound(weight1, 1, 1e6));

        alpha1 = bound(alpha1, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha1 != 1e8); // 1e8 is a special case that causes overflow
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length1 = int24(bound(length1, 1, (maxUsableTick - minTick) / tickSpacing - 1));

        alpha0 = bound(alpha0, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha0 != 1e8); // 1e8 is a special case that causes overflow
        vm.assume((maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1 >= 1);
        length0 = int24(bound(length0, 1, (maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1));

        weightMain = bound(weightMain, 0.5e9, 0.99e9);

        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("alpha0", alpha0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes32 ldfParams = bytes32(
            abi.encodePacked(
                ShiftMode.STATIC,
                minTick,
                int16(length0),
                uint32(alpha0),
                weight0,
                int16(length1),
                uint32(alpha1),
                weight1,
                uint32(weightMain)
            )
        );
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        currentTick = int24(bound(currentTick, minUsableTick, maxUsableTick));
        _test_query_cumulativeAmounts(currentTick, tickSpacing, ldfParams);
    }

    function test_inverseCumulativeAmount0(
        int24 tick,
        int24 tickSpacing,
        int24 minTick,
        int24 length0,
        uint256 alpha0,
        int24 length1,
        uint256 alpha1,
        uint32 weight0,
        uint32 weight1,
        uint256 weightMain
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        weight0 = uint32(bound(weight0, 1, 1e6));
        weight1 = uint32(bound(weight1, 1, 1e6));

        alpha1 = bound(alpha1, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha1 != 1e8); // 1e8 is a special case that causes overflow
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length1 = int24(bound(length1, 1, (maxUsableTick - minTick) / tickSpacing - 1));

        alpha0 = bound(alpha0, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha0 != 1e8); // 1e8 is a special case that causes overflow
        vm.assume((maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1 >= 1);
        length0 = int24(bound(length0, 1, (maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1));

        tick = int24(bound(tick, minUsableTick, maxUsableTick - tickSpacing));

        weightMain = bound(weightMain, 0.5e9, 0.99e9);

        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("alpha0", alpha0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes32 ldfParams = bytes32(
            abi.encodePacked(
                ShiftMode.STATIC,
                minTick,
                int16(length0),
                uint32(alpha0),
                weight0,
                int16(length1),
                uint32(alpha1),
                weight1,
                uint32(weightMain)
            )
        );
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        LibCarpetedDoubleGeometricDistribution.Params memory params =
            LibCarpetedDoubleGeometricDistribution.decodeParams(minTick, tickSpacing, ldfParams);

        uint256 cumulativeAmount0DensityX96 =
            LibCarpetedDoubleGeometricDistribution.cumulativeAmount0(roundedTick, liquidity, tickSpacing, params);
        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedDoubleGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, params, true
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
        int24 length0,
        uint256 alpha0,
        int24 length1,
        uint256 alpha1,
        uint32 weight0,
        uint32 weight1,
        uint256 weightMain
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        weight0 = uint32(bound(weight0, 1, 1e6));
        weight1 = uint32(bound(weight1, 1, 1e6));

        alpha1 = bound(alpha1, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha1 != 1e8); // 1e8 is a special case that causes overflow
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length1 = int24(bound(length1, 1, (maxUsableTick - minTick) / tickSpacing - 1));

        alpha0 = bound(alpha0, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha0 != 1e8); // 1e8 is a special case that causes overflow
        vm.assume((maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1 >= 1);
        length0 = int24(bound(length0, 1, (maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1));

        tick = int24(bound(tick, minUsableTick, maxUsableTick - tickSpacing));

        weightMain = bound(weightMain, 0.5e9, 0.99e9);

        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("alpha0", alpha0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes32 ldfParams = bytes32(
            abi.encodePacked(
                ShiftMode.STATIC,
                minTick,
                int16(length0),
                uint32(alpha0),
                weight0,
                int16(length1),
                uint32(alpha1),
                weight1,
                uint32(weightMain)
            )
        );
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        LibCarpetedDoubleGeometricDistribution.Params memory params =
            LibCarpetedDoubleGeometricDistribution.decodeParams(minTick, tickSpacing, ldfParams);

        uint256 cumulativeAmount1DensityX96 =
            LibCarpetedDoubleGeometricDistribution.cumulativeAmount1(roundedTick, liquidity, tickSpacing, params);
        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedDoubleGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, params, true
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
        int24 length0,
        uint256 alpha0,
        int24 length1,
        uint256 alpha1,
        uint32 weight0,
        uint32 weight1,
        uint256 weightMain
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        weight0 = uint32(bound(weight0, 1, 1e6));
        weight1 = uint32(bound(weight1, 1, 1e6));

        alpha1 = bound(alpha1, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha1 != 1e8); // 1e8 is a special case that causes overflow
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length1 = int24(bound(length1, 1, (maxUsableTick - minTick) / tickSpacing - 1));

        alpha0 = bound(alpha0, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha0 != 1e8); // 1e8 is a special case that causes overflow
        vm.assume((maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1 >= 1);
        length0 = int24(bound(length0, 1, (maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1));

        tick = int24(bound(tick, minUsableTick, maxUsableTick - tickSpacing));

        weightMain = bound(weightMain, 0.5e9, 0.99e9);

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("alpha0", alpha0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes32 ldfParams = bytes32(
            abi.encodePacked(
                ShiftMode.STATIC,
                minTick,
                int16(length0),
                uint32(alpha0),
                weight0,
                int16(length1),
                uint32(alpha1),
                weight1,
                uint32(weightMain)
            )
        );
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        LibCarpetedDoubleGeometricDistribution.Params memory params =
            LibCarpetedDoubleGeometricDistribution.decodeParams(minTick, tickSpacing, ldfParams);

        uint256 cumulativeAmount0DensityX96 =
            LibCarpetedDoubleGeometricDistribution.cumulativeAmount0(roundedTick, liquidity, tickSpacing, params);

        // purturb density upwards
        {
            uint256 nextCumulativeAmount0DensityX96 = LibCarpetedDoubleGeometricDistribution.cumulativeAmount0(
                roundedTick - tickSpacing, liquidity, tickSpacing, params
            );
            cumulativeAmount0DensityX96 = nextCumulativeAmount0DensityX96 > cumulativeAmount0DensityX96
                ? (cumulativeAmount0DensityX96 + nextCumulativeAmount0DensityX96) / 2
                : cumulativeAmount0DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedDoubleGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, params, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

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
        int24 length0,
        uint256 alpha0,
        int24 length1,
        uint256 alpha1,
        uint32 weight0,
        uint32 weight1,
        uint256 weightMain
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        weight0 = uint32(bound(weight0, 1, 1e6));
        weight1 = uint32(bound(weight1, 1, 1e6));

        alpha1 = bound(alpha1, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha1 != 1e8); // 1e8 is a special case that causes overflow
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length1 = int24(bound(length1, 1, (maxUsableTick - minTick) / tickSpacing - 1));

        alpha0 = bound(alpha0, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha0 != 1e8); // 1e8 is a special case that causes overflow
        vm.assume((maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1 >= 1);
        length0 = int24(bound(length0, 1, (maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1));

        tick = int24(bound(tick, minUsableTick, maxUsableTick - tickSpacing));

        weightMain = bound(weightMain, 0.5e9, 0.99e9);

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("alpha0", alpha0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes32 ldfParams = bytes32(
            abi.encodePacked(
                ShiftMode.STATIC,
                minTick,
                int16(length0),
                uint32(alpha0),
                weight0,
                int16(length1),
                uint32(alpha1),
                weight1,
                uint32(weightMain)
            )
        );
        vm.assume(ldf.isValidParams(key, 0, ldfParams));

        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        LibCarpetedDoubleGeometricDistribution.Params memory params =
            LibCarpetedDoubleGeometricDistribution.decodeParams(minTick, tickSpacing, ldfParams);

        uint256 cumulativeAmount1DensityX96 =
            LibCarpetedDoubleGeometricDistribution.cumulativeAmount1(roundedTick, liquidity, tickSpacing, params);

        // purturb density upwards
        {
            uint256 nextCumulativeAmount1DensityX96 = LibCarpetedDoubleGeometricDistribution.cumulativeAmount1(
                roundedTick + tickSpacing, liquidity, tickSpacing, params
            );
            console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);
            console2.log("nextCumulativeAmount1DensityX96", nextCumulativeAmount1DensityX96);
            cumulativeAmount1DensityX96 = nextCumulativeAmount1DensityX96 > cumulativeAmount1DensityX96
                ? (cumulativeAmount1DensityX96 + nextCumulativeAmount1DensityX96) / 2
                : cumulativeAmount1DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedDoubleGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, params, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

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
        uint32 alpha0 = 0.9e8;
        uint32 alpha1 = 1.1e8;
        uint32 weight0 = 1;
        uint32 weight1 = 1;
        uint32 weightMain = 0.9e9;
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        // invalid when minTick < minUsableTick
        (int24 minTick, int24 length0, int24 length1) = (minUsableTick - tickSpacing, 1, 1);
        bytes32 ldfParams = bytes32(
            abi.encodePacked(
                ShiftMode.STATIC,
                minTick,
                int16(length0),
                uint32(alpha0),
                weight0,
                int16(length1),
                uint32(alpha1),
                weight1,
                weightMain
            )
        );
        assertFalse(ldf.isValidParams(key, 0, ldfParams));

        // invalid when maxTick > maxUsableTick
        (minTick, length0, length1) = (maxUsableTick - tickSpacing, 1, 1);
        ldfParams = bytes32(
            abi.encodePacked(
                ShiftMode.STATIC,
                minTick,
                int16(length0),
                uint32(alpha0),
                weight0,
                int16(length1),
                uint32(alpha1),
                weight1,
                weightMain
            )
        );
        assertFalse(ldf.isValidParams(key, 0, ldfParams));

        // valid test
        (minTick, length0, length1) = (0, 1, 1);
        ldfParams = bytes32(
            abi.encodePacked(
                ShiftMode.STATIC,
                minTick,
                int16(length0),
                uint32(alpha0),
                weight0,
                int16(length1),
                uint32(alpha1),
                weight1,
                weightMain
            )
        );
        assertTrue(ldf.isValidParams(key, 0, ldfParams));
    }

    function test_boundary_dynamic_boundedWhenDecoding(int24 tickSpacing) external view {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        uint32 alpha0 = 0.9e8;
        uint32 alpha1 = 1.1e8;
        uint32 weight0 = 1;
        uint32 weight1 = 1;
        uint32 weightMain = 0.9e9;
        ShiftMode shiftMode = ShiftMode.RIGHT;
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        // bounded when minTick < minUsableTick
        (int24 offset, int24 length0, int24 length1) = (minUsableTick - tickSpacing, 1, 1);
        bytes32 ldfParams = bytes32(
            abi.encodePacked(
                shiftMode,
                offset,
                int16(length0),
                uint32(alpha0),
                weight0,
                int16(length1),
                uint32(alpha1),
                weight1,
                weightMain
            )
        );
        assertTrue(ldf.isValidParams(key, 1, ldfParams), "invalid params 0");
        LibCarpetedDoubleGeometricDistribution.Params memory params =
            LibCarpetedDoubleGeometricDistribution.decodeParams(0, tickSpacing, ldfParams);
        assertEq(params.minTick, minUsableTick, "minTick incorrect");
        assertTrue(params.shiftMode == shiftMode, "shiftMode incorrect");

        // bounded when maxTick > maxUsableTick
        (offset, length0, length1) = (maxUsableTick - tickSpacing, 1, 1);
        ldfParams = ldfParams = bytes32(
            abi.encodePacked(
                shiftMode,
                offset,
                int16(length0),
                uint32(alpha0),
                weight0,
                int16(length1),
                uint32(alpha1),
                weight1,
                weightMain
            )
        );
        assertTrue(ldf.isValidParams(key, 1, ldfParams), "invalid params 1");
        params = LibCarpetedDoubleGeometricDistribution.decodeParams(0, tickSpacing, ldfParams);
        assertEq(params.minTick + (length0 + length1) * tickSpacing, maxUsableTick, "maxTick incorrect");
        assertTrue(params.shiftMode == shiftMode, "shiftMode incorrect");
    }
}
