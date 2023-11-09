// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import "./LiquidityDensityFunctionTest.sol";
import "../../src/ldf/GeometricDistribution.sol";

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
        length = int24(bound(length, 1, (maxUsableTick - minUsableTick) / tickSpacing - 1));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick)), tickSpacing);

        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        _test_liquidityDensity_sumUpToOne(
            tickSpacing, bytes11(abi.encodePacked(minTick, int16(length), uint32(alpha), uint16(0)))
        );
    }

    function test_query_cumulativeAmounts(
        int24 currentTick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alpha
    ) external virtual {
        (currentTick, tickSpacing, minTick, length, alpha) = (0, 0, 0, -2491, 4);
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha != 1e8); // 1e8 is a special case that causes overflow
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        length = int24(bound(length, 1, (maxUsableTick - minUsableTick) / tickSpacing - 1));
        minTick = roundTickSingle(int24(bound(minTick, minUsableTick, maxUsableTick)), tickSpacing);
        currentTick = int24(bound(currentTick, minUsableTick, maxUsableTick));

        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("minTick", minTick);
        console2.log("length", length);

        _test_query_cumulativeAmounts(
            currentTick, tickSpacing, bytes11(abi.encodePacked(minTick, int16(length), uint32(alpha), uint16(0)))
        );
    }
}
