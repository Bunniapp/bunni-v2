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
        length = int24(bound(length, 1, maxUsableTick / tickSpacing - 1));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick)), tickSpacing);

        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        bytes32 ldfParams = bytes32(abi.encodePacked(minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));
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
        length = int24(bound(length, 1, maxUsableTick / tickSpacing - 1));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick)), tickSpacing);
        currentTick = int24(bound(currentTick, minUsableTick, maxUsableTick));

        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        bytes32 ldfParams = bytes32(abi.encodePacked(minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));
        _test_query_cumulativeAmounts(currentTick, tickSpacing, ldfParams);
    }

    function test_inverseCumulativeAmount0(
        int24 tick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha,
        bool roundUp
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        length = int24(bound(length, 1, maxUsableTick / tickSpacing - 1));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick)), tickSpacing);
        tick = int24(bound(tick, minUsableTick, maxUsableTick));

        console2.log("tick", tick);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        bytes32 ldfParams = bytes32(abi.encodePacked(minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        (, uint256 cumulativeAmount0DensityX96,) =
            LibGeometricDistribution.query(roundTickSingle(tick, tickSpacing), tickSpacing, minTick, length, alphaX96);

        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        (bool success, int24 resultRoundedTick) = LibGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, roundUp
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick < minTick
            ? minTick
            : roundedTick >= minTick + length * tickSpacing ? minTick + length * tickSpacing : roundedTick + tickSpacing;
        console2.log("x", (expectedTick - minTick) / tickSpacing);
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_inverseCumulativeAmount1(
        int24 tick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha,
        bool roundUp
    ) external virtual {
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        length = int24(bound(length, 1, maxUsableTick / tickSpacing - 1));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick)), tickSpacing);
        tick = int24(bound(tick, minUsableTick, maxUsableTick));

        console2.log("tick", tick);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        bytes32 ldfParams = bytes32(abi.encodePacked(minTick, int16(length), uint32(alpha)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e8;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        (,, uint256 cumulativeAmount1DensityX96) =
            LibGeometricDistribution.query(roundTickSingle(tick, tickSpacing), tickSpacing, minTick, length, alphaX96);

        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        (bool success, int24 resultRoundedTick) = LibGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, minTick, length, alphaX96, roundUp
        );
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick <= minTick
            ? minTick - tickSpacing
            : roundedTick >= minTick + length * tickSpacing
                ? minTick + (length - 1) * tickSpacing
                : roundedTick - tickSpacing;
        console2.log("x", (expectedTick - minTick) / tickSpacing);
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }
}
