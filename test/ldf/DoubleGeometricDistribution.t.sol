// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import "./LiquidityDensityFunctionTest.sol";
import "../../src/ldf/DoubleGeometricDistribution.sol";

contract DoubleGeometricDistributionTest is LiquidityDensityFunctionTest {
    uint256 internal constant MIN_ALPHA = 1e3;
    uint256 internal constant MAX_ALPHA = 10e8;

    function _setUpLDF() internal override {
        ldf = ILiquidityDensityFunction(address(new DoubleGeometricDistribution()));
    }

    function test_liquidityDensity_sumUpToOne(
        int24 tickSpacing,
        int24 minTick,
        int24 length0,
        uint256 alpha0,
        int24 length1,
        uint256 alpha1,
        uint32 weight0,
        uint32 weight1
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));

        weight0 = uint32(bound(weight0, 1, 1e6));
        weight1 = uint32(bound(weight1, 1, 1e6));

        alpha1 = bound(alpha1, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha1 != 1e8); // 1e8 is a special case that causes overflow
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 3 * tickSpacing)), tickSpacing);
        length1 = int24(bound(length1, 1, (maxUsableTick - minTick) / tickSpacing - 2));

        alpha0 = bound(alpha0, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha0 != 1e8); // 1e8 is a special case that causes overflow
        length0 = int24(bound(length0, 1, (maxUsableTick - (minTick + length1 * tickSpacing)) / tickSpacing - 1));

        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("alpha0", alpha0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes32 ldfParams = bytes32(
            abi.encodePacked(minTick, int16(length0), uint32(alpha0), weight0, int16(length1), uint32(alpha1), weight1)
        );
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));
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
        uint32 weight1
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));

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

        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("alpha0", alpha0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes32 ldfParams = bytes32(
            abi.encodePacked(minTick, int16(length0), uint32(alpha0), weight0, int16(length1), uint32(alpha1), weight1)
        );
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

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
        uint32 weight1
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));

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

        tick = int24(bound(tick, minUsableTick, maxUsableTick));

        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("alpha0", alpha0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes32 ldfParams = bytes32(
            abi.encodePacked(minTick, int16(length0), uint32(alpha0), weight0, int16(length1), uint32(alpha1), weight1)
        );
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alpha0X96 = (alpha0 << 96) / 1e8;
        uint256 alpha1X96 = (alpha1 << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount0DensityX96 = LibDoubleGeometricDistribution.cumulativeAmount0(
            roundedTick, liquidity, tickSpacing, minTick, length0, length1, alpha0X96, alpha1X96, weight0, weight1
        );
        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibDoubleGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96,
            liquidity,
            tickSpacing,
            minTick,
            length0,
            length1,
            alpha0X96,
            alpha1X96,
            weight0,
            weight1,
            true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick < minTick
            ? minTick
            : roundedTick >= minTick + (length0 + length1) * tickSpacing
                ? minTick + (length0 + length1) * tickSpacing
                : roundedTick;
        console2.log("expected x", (expectedTick - minTick) / tickSpacing);
        console2.log("actual x", (resultRoundedTick - minTick) / tickSpacing);
        console2.log(
            "actual cumulative amount",
            LibDoubleGeometricDistribution.cumulativeAmount0(
                resultRoundedTick,
                liquidity,
                tickSpacing,
                minTick,
                length0,
                length1,
                alpha0X96,
                alpha1X96,
                weight0,
                weight1
            )
        );
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
        uint32 weight1
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));

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

        tick = int24(bound(tick, minUsableTick, maxUsableTick));

        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("alpha0", alpha0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes32 ldfParams = bytes32(
            abi.encodePacked(minTick, int16(length0), uint32(alpha0), weight0, int16(length1), uint32(alpha1), weight1)
        );
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alpha0X96 = (alpha0 << 96) / 1e8;
        uint256 alpha1X96 = (alpha1 << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount1DensityX96 = LibDoubleGeometricDistribution.cumulativeAmount1(
            roundedTick, liquidity, tickSpacing, minTick, length0, length1, alpha0X96, alpha1X96, weight0, weight1
        );
        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibDoubleGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96,
            liquidity,
            tickSpacing,
            minTick,
            length0,
            length1,
            alpha0X96,
            alpha1X96,
            weight0,
            weight1,
            true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick < minTick
            ? minTick
            : roundedTick > minTick + (length0 + length1 - 1) * tickSpacing
                ? minTick + (length0 + length1 - 1) * tickSpacing
                : roundedTick;
        if (cumulativeAmount1DensityX96 == 0) expectedTick = minTick - tickSpacing;
        console2.log("expected x", (expectedTick - minTick) / tickSpacing);
        console2.log("actual x", (resultRoundedTick - minTick) / tickSpacing);
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
        uint32 weight1
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));

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

        tick = int24(bound(tick, minTick, minTick + (length0 + length1) * tickSpacing));

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
            abi.encodePacked(minTick, int16(length0), uint32(alpha0), weight0, int16(length1), uint32(alpha1), weight1)
        );
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alpha0X96 = (alpha0 << 96) / 1e8;
        uint256 alpha1X96 = (alpha1 << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount0DensityX96 = LibDoubleGeometricDistribution.cumulativeAmount0(
            roundedTick, liquidity, tickSpacing, minTick, length0, length1, alpha0X96, alpha1X96, weight0, weight1
        );

        // purturb density upwards
        {
            uint256 nextCumulativeAmount0DensityX96 = LibDoubleGeometricDistribution.cumulativeAmount0(
                roundedTick - tickSpacing,
                liquidity,
                tickSpacing,
                minTick,
                length0,
                length1,
                alpha0X96,
                alpha1X96,
                weight0,
                weight1
            );
            cumulativeAmount0DensityX96 = nextCumulativeAmount0DensityX96 > cumulativeAmount0DensityX96
                ? (cumulativeAmount0DensityX96 + nextCumulativeAmount0DensityX96) / 2
                : cumulativeAmount0DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibDoubleGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96,
            liquidity,
            tickSpacing,
            minTick,
            length0,
            length1,
            alpha0X96,
            alpha1X96,
            weight0,
            weight1,
            true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        if (success) {
            int24 expectedTick = roundedTick <= minTick
                ? minTick
                : roundedTick >= minTick + (length0 + length1) * tickSpacing
                    ? minTick + (length0 + length1) * tickSpacing
                    : roundedTick;
            assertEq(resultRoundedTick, expectedTick, "tick incorrect");
        } else {
            assertLe(roundedTick, minTick, "inverseCumulativeAmount0 failed");
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
        uint32 weight1
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));

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

        tick = int24(bound(tick, minTick, minTick + (length0 + length1) * tickSpacing));

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
            abi.encodePacked(minTick, int16(length0), uint32(alpha0), weight0, int16(length1), uint32(alpha1), weight1)
        );
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alpha0X96 = (alpha0 << 96) / 1e8;
        uint256 alpha1X96 = (alpha1 << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount1DensityX96 = LibDoubleGeometricDistribution.cumulativeAmount1(
            roundedTick, liquidity, tickSpacing, minTick, length0, length1, alpha0X96, alpha1X96, weight0, weight1
        );

        // purturb density upwards
        {
            uint256 nextCumulativeAmount1DensityX96 = LibDoubleGeometricDistribution.cumulativeAmount1(
                roundedTick + tickSpacing,
                liquidity,
                tickSpacing,
                minTick,
                length0,
                length1,
                alpha0X96,
                alpha1X96,
                weight0,
                weight1
            );
            console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);
            console2.log("nextCumulativeAmount1DensityX96", nextCumulativeAmount1DensityX96);
            cumulativeAmount1DensityX96 = nextCumulativeAmount1DensityX96 > cumulativeAmount1DensityX96
                ? (cumulativeAmount1DensityX96 + nextCumulativeAmount1DensityX96) / 2
                : cumulativeAmount1DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibDoubleGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96,
            liquidity,
            tickSpacing,
            minTick,
            length0,
            length1,
            alpha0X96,
            alpha1X96,
            weight0,
            weight1,
            true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick < minTick
            ? minTick
            : roundedTick >= minTick + (length0 + length1 - 1) * tickSpacing ? int24(0) : roundedTick + tickSpacing;

        assertTrue(
            success || roundedTick >= minTick + (length0 + length1 - 1) * tickSpacing, "inverseCumulativeAmount1 failed"
        );
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_boundary_static_invalidWhenOutOfBounds(int24 tickSpacing) external view {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        uint32 alpha0 = 0.9e8;
        uint32 alpha1 = 1.1e8;
        uint32 weight0 = 1;
        uint32 weight1 = 1;

        // invalid when minTick < minUsableTick
        (int24 minTick, int24 length0, int24 length1) = (minUsableTick - tickSpacing, 1, 1);
        bytes32 ldfParams = bytes32(
            abi.encodePacked(minTick, int16(length0), uint32(alpha0), weight0, int16(length1), uint32(alpha1), weight1)
        );
        assertFalse(ldf.isValidParams(tickSpacing, 0, ldfParams));

        // invalid when maxTick > maxUsableTick
        (minTick, length0, length1) = (maxUsableTick - tickSpacing, 1, 1);
        ldfParams = bytes32(
            abi.encodePacked(minTick, int16(length0), uint32(alpha0), weight0, int16(length1), uint32(alpha1), weight1)
        );
        assertFalse(ldf.isValidParams(tickSpacing, 0, ldfParams));

        // valid test
        (minTick, length0, length1) = (0, 1, 1);
        ldfParams = bytes32(
            abi.encodePacked(minTick, int16(length0), uint32(alpha0), weight0, int16(length1), uint32(alpha1), weight1)
        );
        assertTrue(ldf.isValidParams(tickSpacing, 0, ldfParams));
    }

    function test_boundary_dynamic_boundedWhenDecoding(int24 tickSpacing) external view {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        uint32 alpha0 = 0.9e8;
        uint32 alpha1 = 1.1e8;
        uint32 weight0 = 1;
        uint32 weight1 = 1;
        ShiftMode shiftMode = ShiftMode.RIGHT;

        // bounded when minTick < minUsableTick
        (int24 offset, int24 length0, int24 length1) = (minUsableTick / tickSpacing - 1, 1, 1);
        bytes32 ldfParams = bytes32(
            abi.encodePacked(
                offset, int16(length0), uint32(alpha0), weight0, int16(length1), uint32(alpha1), weight1, shiftMode
            )
        );
        assertTrue(ldf.isValidParams(tickSpacing, 1, ldfParams));
        (int24 minTick,,,,,,, ShiftMode decodedShiftMode) =
            LibDoubleGeometricDistribution.decodeParams(0, tickSpacing, true, ldfParams);
        assertEq(minTick, minUsableTick, "minTick incorrect");
        assertTrue(shiftMode == decodedShiftMode, "shiftMode incorrect");

        // bounded when maxTick > maxUsableTick
        (offset, length0, length1) = (maxUsableTick / tickSpacing - 1, 1, 1);
        ldfParams = ldfParams = bytes32(
            abi.encodePacked(
                offset, int16(length0), uint32(alpha0), weight0, int16(length1), uint32(alpha1), weight1, shiftMode
            )
        );
        assertTrue(ldf.isValidParams(tickSpacing, 1, ldfParams));
        (minTick,,,,,,, decodedShiftMode) = LibDoubleGeometricDistribution.decodeParams(0, tickSpacing, true, ldfParams);
        assertEq(minTick + (length0 + length1) * tickSpacing, maxUsableTick, "maxTick incorrect");
        assertTrue(shiftMode == decodedShiftMode, "shiftMode incorrect");
    }
}
