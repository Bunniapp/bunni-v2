// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import "./LiquidityDensityFunctionTest.sol";
import "../../src/ldf/UniformDistribution.sol";
import "../../src/ldf/LibUniformDistribution.sol";

contract UniformDistributionTest is LiquidityDensityFunctionTest {
    function _setUpLDF() internal override {
        ldf = ILiquidityDensityFunction(address(new UniformDistribution()));
    }

    function test_liquidityDensity_sumUpToOne(int24 tickSpacing, int24 tickLower, int24 tickUpper) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        tickLower = roundTickSingle(int24(bound(tickLower, minUsableTick, maxUsableTick - tickSpacing)), tickSpacing);
        tickUpper = roundTickSingle(int24(bound(tickUpper, tickLower + tickSpacing, maxUsableTick)), tickSpacing);

        console2.log("tickSpacing", tickSpacing);
        console2.log("tickLower", tickLower);
        console2.log("tickUpper", tickUpper);

        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));
        _test_liquidityDensity_sumUpToOne(tickSpacing, ldfParams);
    }

    function test_query_cumulativeAmounts(int24 currentTick, int24 tickSpacing, int24 tickLower, int24 tickUpper)
        external
        virtual
    {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        tickLower = roundTickSingle(int24(bound(tickLower, minUsableTick, maxUsableTick - tickSpacing)), tickSpacing);
        tickUpper = roundTickSingle(int24(bound(tickUpper, tickLower + tickSpacing, maxUsableTick)), tickSpacing);
        currentTick = int24(bound(currentTick, minUsableTick, maxUsableTick));

        console2.log("tickSpacing", tickSpacing);
        console2.log("tickLower", tickLower);
        console2.log("tickUpper", tickUpper);
        console2.log("currentTick", currentTick);

        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));
        _test_query_cumulativeAmounts(currentTick, tickSpacing, ldfParams);
    }

    function test_inverseCumulativeAmount0(int24 tick, int24 tickSpacing, int24 tickLower, int24 tickUpper)
        external
        virtual
    {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        tickLower = roundTickSingle(int24(bound(tickLower, minUsableTick, maxUsableTick - tickSpacing)), tickSpacing);
        tickUpper = roundTickSingle(int24(bound(tickUpper, tickLower + tickSpacing, maxUsableTick)), tickSpacing);
        tick = int24(bound(tick, minUsableTick, maxUsableTick));

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("tickLower", tickLower);
        console2.log("tickUpper", tickUpper);

        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount0DensityX96 =
            LibUniformDistribution.cumulativeAmount0(roundedTick, liquidity, tickSpacing, tickLower, tickUpper);
        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibUniformDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, tickLower, tickUpper, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick < tickLower ? tickLower : roundedTick >= tickUpper ? tickUpper : roundedTick;
        assertTrue(success, "inverseCumulativeAmount0 failed");
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_inverseCumulativeAmount1(int24 tick, int24 tickSpacing, int24 tickLower, int24 tickUpper)
        external
        virtual
    {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        tickLower = roundTickSingle(int24(bound(tickLower, minUsableTick, maxUsableTick - tickSpacing)), tickSpacing);
        tickUpper = roundTickSingle(int24(bound(tickUpper, tickLower + tickSpacing, maxUsableTick)), tickSpacing);
        tick = int24(bound(tick, minUsableTick, maxUsableTick));

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("tickLower", tickLower);
        console2.log("tickUpper", tickUpper);

        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount1DensityX96 =
            LibUniformDistribution.cumulativeAmount1(roundedTick, liquidity, tickSpacing, tickLower, tickUpper);
        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibUniformDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, tickLower, tickUpper, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick < tickLower
            ? tickLower
            : roundedTick > tickUpper - tickSpacing ? tickUpper - tickSpacing : roundedTick;
        if (cumulativeAmount1DensityX96 == 0) expectedTick = tickLower - tickSpacing;

        assertTrue(success, "inverseCumulativeAmount1 failed");
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_inverseCumulativeAmount0_withPurturbation(
        int24 tick,
        int24 tickSpacing,
        int24 tickLower,
        int24 tickUpper
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        tickLower = roundTickSingle(int24(bound(tickLower, minUsableTick, maxUsableTick - tickSpacing)), tickSpacing);
        tickUpper = roundTickSingle(int24(bound(tickUpper, tickLower + tickSpacing, maxUsableTick)), tickSpacing);
        tick = int24(bound(tick, tickLower + tickSpacing, tickUpper));

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("tickLower", tickLower);
        console2.log("tickUpper", tickUpper);

        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount0DensityX96 =
            LibUniformDistribution.cumulativeAmount0(roundedTick, liquidity, tickSpacing, tickLower, tickUpper);

        // purturb density upwards
        {
            uint256 nextCumulativeAmount0DensityX96 = LibUniformDistribution.cumulativeAmount0(
                roundedTick - tickSpacing, liquidity, tickSpacing, tickLower, tickUpper
            );
            cumulativeAmount0DensityX96 = nextCumulativeAmount0DensityX96 > cumulativeAmount0DensityX96
                ? (cumulativeAmount0DensityX96 + nextCumulativeAmount0DensityX96) / 2
                : cumulativeAmount0DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibUniformDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, tickLower, tickUpper, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick <= tickLower ? tickLower : roundedTick >= tickUpper ? tickUpper : roundedTick;

        assertTrue(success, "inverseCumulativeAmount0 failed");
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_inverseCumulativeAmount1_withPurturbation(
        int24 tick,
        int24 tickSpacing,
        int24 tickLower,
        int24 tickUpper
    ) external virtual {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        tickLower = roundTickSingle(int24(bound(tickLower, minUsableTick, maxUsableTick - tickSpacing)), tickSpacing);
        tickUpper = roundTickSingle(int24(bound(tickUpper, tickLower + tickSpacing, maxUsableTick)), tickSpacing);
        tick = int24(bound(tick, tickLower, tickUpper - tickSpacing));

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("tickLower", tickLower);
        console2.log("tickUpper", tickUpper);

        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount1DensityX96 =
            LibUniformDistribution.cumulativeAmount1(roundedTick, liquidity, tickSpacing, tickLower, tickUpper);

        // purturb density upwards
        {
            uint256 nextCumulativeAmount1DensityX96 = LibUniformDistribution.cumulativeAmount1(
                roundedTick + tickSpacing, liquidity, tickSpacing, tickLower, tickUpper
            );
            cumulativeAmount1DensityX96 = nextCumulativeAmount1DensityX96 > cumulativeAmount1DensityX96
                ? (cumulativeAmount1DensityX96 + nextCumulativeAmount1DensityX96) / 2
                : cumulativeAmount1DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibUniformDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, tickLower, tickUpper, true
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick < tickLower
            ? tickLower
            : roundedTick >= tickUpper - tickSpacing ? int24(0) : roundedTick + tickSpacing;

        assertTrue(success || roundedTick >= tickUpper - tickSpacing, "inverseCumulativeAmount1 failed");
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_boundary_static_invalidWhenOutOfBounds(int24 tickSpacing) external view {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));

        // invalid when minTick < minUsableTick
        (int24 tickLower, int24 tickUpper) = (minUsableTick - tickSpacing, minUsableTick + tickSpacing);
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper));
        assertFalse(ldf.isValidParams(tickSpacing, 0, ldfParams));

        // invalid when maxTick > maxUsableTick
        (tickLower, tickUpper) = (maxUsableTick - tickSpacing, maxUsableTick + tickSpacing);
        ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper));
        assertFalse(ldf.isValidParams(tickSpacing, 0, ldfParams));

        // valid test
        (tickLower, tickUpper) = (0, tickSpacing);
        ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper));
        assertTrue(ldf.isValidParams(tickSpacing, 0, ldfParams));
    }

    function test_boundary_dynamic_boundedWhenDecoding(int24 tickSpacing) external view {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        ShiftMode shiftMode = ShiftMode.RIGHT;

        // bounded when minTick < minUsableTick
        (int24 offset, int24 length) = (minUsableTick - tickSpacing, 2);
        bytes32 ldfParams = bytes32(abi.encodePacked(shiftMode, offset, length));
        assertTrue(ldf.isValidParams(tickSpacing, 1, ldfParams), "invalid params 0");
        (int24 tickLower, int24 tickUpper, ShiftMode decodedShiftMode) =
            LibUniformDistribution.decodeParams(0, tickSpacing, ldfParams);
        assertEq(tickLower, minUsableTick, "tickLower incorrect");
        assertTrue(decodedShiftMode == shiftMode, "shiftMode incorrect");

        // bounded when maxTick > maxUsableTick
        (offset, length) = (maxUsableTick - tickSpacing, 2);
        ldfParams = bytes32(abi.encodePacked(shiftMode, offset, length));
        assertTrue(ldf.isValidParams(tickSpacing, 1, ldfParams), "invalid params 1");
        (tickLower, tickUpper, decodedShiftMode) = LibUniformDistribution.decodeParams(0, tickSpacing, ldfParams);
        assertEq(tickUpper, maxUsableTick, "tickUpper incorrect");
        assertTrue(decodedShiftMode == shiftMode, "shiftMode incorrect");

        // bounded when minTick < minUsableTick and maxTick > maxUsableTick
        (offset, length) = (minUsableTick - tickSpacing, (maxUsableTick - minUsableTick) / tickSpacing + 2);
        ldfParams = bytes32(abi.encodePacked(shiftMode, offset, length));
        assertTrue(ldf.isValidParams(tickSpacing, 1, ldfParams), "invalid params 2");
        (tickLower, tickUpper, decodedShiftMode) = LibUniformDistribution.decodeParams(0, tickSpacing, ldfParams);
        assertEq(tickLower, minUsableTick, "tickLower incorrect");
        assertEq(tickUpper, maxUsableTick, "tickUpper incorrect");
        assertTrue(decodedShiftMode == shiftMode, "shiftMode incorrect");
    }
}
