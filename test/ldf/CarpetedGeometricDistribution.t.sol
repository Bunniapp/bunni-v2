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
        uint256 weightMain
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        weightMain = bound(weightMain, 1, 1e9);

        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);
        console2.log("weightMain", weightMain);

        bytes32 ldfParams = bytes32(abi.encodePacked(minTick, int16(length), uint32(alpha), uint32(weightMain)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));
        _test_liquidityDensity_sumUpToOne(tickSpacing, ldfParams);
    }

    function test_query_cumulativeAmounts(
        int24 currentTick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha,
        uint256 weightMain
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        currentTick = int24(bound(currentTick, minUsableTick, maxUsableTick));
        weightMain = bound(weightMain, 1, 1e9);

        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        bytes32 ldfParams = bytes32(abi.encodePacked(minTick, int16(length), uint32(alpha), uint32(weightMain)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));
        _test_query_cumulativeAmounts(currentTick, tickSpacing, ldfParams);
    }

    function test_inverseCumulativeAmount0(
        int24 tick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha,
        uint256 weightMain
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        tick = int24(bound(tick, minUsableTick, maxUsableTick));
        weightMain = bound(weightMain, 5e8, 0.99e9);

        console2.log("tick", tick);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        bytes32 ldfParams = bytes32(abi.encodePacked(minTick, int16(length), uint32(alpha), uint32(weightMain)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount0DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount0(
            roundedTick, liquidity, tickSpacing, minTick, length, alphaX96, weightMain
        );
        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, weightMain, true
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
        uint256 weightMain
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        tick = int24(bound(tick, minUsableTick, maxUsableTick));
        weightMain = bound(weightMain, 5e8, 0.99e9);

        console2.log("tick", tick);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        bytes32 ldfParams = bytes32(abi.encodePacked(minTick, int16(length), uint32(alpha), uint32(weightMain)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount1DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount1(
            roundedTick, liquidity, tickSpacing, minTick, length, alphaX96, weightMain
        );
        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, weightMain, true
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
        uint256 weightMain
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        tick = int24(bound(tick, minUsableTick, maxUsableTick - tickSpacing));
        weightMain = bound(weightMain, 5e8, 0.99e9);

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);
        console2.log("alpha", alpha);

        bytes32 ldfParams = bytes32(abi.encodePacked(minTick, int16(length), uint32(alpha), uint32(weightMain)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount0DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount0(
            roundedTick, liquidity, tickSpacing, minTick, length, alphaX96, weightMain
        );

        // purturb density upwards
        {
            uint256 nextCumulativeAmount0DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount0(
                roundedTick - tickSpacing, liquidity, tickSpacing, minTick, length, alphaX96, weightMain
            );
            cumulativeAmount0DensityX96 = nextCumulativeAmount0DensityX96 > cumulativeAmount0DensityX96
                ? (cumulativeAmount0DensityX96 + nextCumulativeAmount0DensityX96) / 2
                : cumulativeAmount0DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, weightMain, true
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
        uint256 weightMain
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick - 2 * tickSpacing)), tickSpacing);
        length = int24(bound(length, 1, (maxUsableTick - minTick) / tickSpacing - 1));
        tick = int24(bound(tick, minUsableTick, maxUsableTick - tickSpacing));
        weightMain = bound(weightMain, 5e8, 0.99e9);

        console2.log("tick", tick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);
        console2.log("alpha", alpha);

        bytes32 ldfParams = bytes32(abi.encodePacked(minTick, int16(length), uint32(alpha), uint32(weightMain)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        uint256 cumulativeAmount1DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount1(
            roundedTick, liquidity, tickSpacing, minTick, length, alphaX96, weightMain
        );

        // purturb density upwards
        {
            uint256 nextCumulativeAmount1DensityX96 = LibCarpetedGeometricDistribution.cumulativeAmount1(
                roundedTick + tickSpacing, liquidity, tickSpacing, minTick, length, alphaX96, weightMain
            );
            console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);
            console2.log("nextCumulativeAmount1DensityX96", nextCumulativeAmount1DensityX96);
            cumulativeAmount1DensityX96 = nextCumulativeAmount1DensityX96 > cumulativeAmount1DensityX96
                ? (cumulativeAmount1DensityX96 + nextCumulativeAmount1DensityX96) / 2
                : cumulativeAmount1DensityX96 * 101 / 100;
        }

        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibCarpetedGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, weightMain, true
        );

        if (success) {
            console2.log("resultRoundedTick", resultRoundedTick);
            int24 expectedTick = roundedTick + tickSpacing;
            assertEq(resultRoundedTick, expectedTick, "tick incorrect");
        } else {
            assertEq(roundedTick, maxUsableTick - tickSpacing, "tick not maxUsableTick");
        }
    }
}
