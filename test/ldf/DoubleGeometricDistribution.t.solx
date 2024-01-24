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
        int24 minTick0,
        int24 length0,
        uint256 alpha0,
        int24 minTick1,
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

        alpha0 = bound(alpha0, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha0 != 1e8); // 1e8 is a special case that causes overflow
        length0 = int24(bound(length0, 1, maxUsableTick / tickSpacing - 1));
        minTick0 = roundTickSingle(int24(bound(minTick0, minUsableTick, maxUsableTick)), tickSpacing);

        alpha1 = bound(alpha1, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha1 != 1e8); // 1e8 is a special case that causes overflow
        length1 = int24(bound(length1, 1, maxUsableTick / tickSpacing - 1));
        minTick1 = roundTickSingle(int24(bound(minTick1, minUsableTick, maxUsableTick)), tickSpacing);

        console2.log("tickSpacing", tickSpacing);
        console2.log("alpha0", alpha0);
        console2.log("minTick0", minTick0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("minTick1", minTick1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes9 ldfParams0 = bytes9(abi.encodePacked(minTick0, int16(length0), uint32(alpha0)));
        bytes9 ldfParams1 = bytes9(abi.encodePacked(minTick1, int16(length1), uint32(alpha1)));
        bytes32 ldfParams = bytes32(abi.encodePacked(weight0, weight1, ldfParams0, ldfParams1));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));
        _test_liquidityDensity_sumUpToOne(tickSpacing, ldfParams);
    }

    function test_query_cumulativeAmounts(
        int24 currentTick,
        int24 tickSpacing,
        int24 minTick0,
        int24 length0,
        uint256 alpha0,
        int24 minTick1,
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

        alpha0 = bound(alpha0, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha0 != 1e8); // 1e8 is a special case that causes overflow
        length0 = int24(bound(length0, 1, maxUsableTick / tickSpacing - 1));
        minTick0 = roundTickSingle(int24(bound(minTick0, minUsableTick, maxUsableTick)), tickSpacing);

        alpha1 = bound(alpha1, MIN_ALPHA, MAX_ALPHA);
        vm.assume(alpha1 != 1e8); // 1e8 is a special case that causes overflow
        length1 = int24(bound(length1, 1, maxUsableTick / tickSpacing - 1));
        minTick1 = roundTickSingle(int24(bound(minTick1, minUsableTick, maxUsableTick)), tickSpacing);

        console2.log("currentTick", currentTick);
        console2.log("tickSpacing", tickSpacing);
        console2.log("alpha0", alpha0);
        console2.log("minTick0", minTick0);
        console2.log("length0", length0);
        console2.log("alpha1", alpha1);
        console2.log("minTick1", minTick1);
        console2.log("length1", length1);
        console2.log("weight0", weight0);
        console2.log("weight1", weight1);

        bytes9 ldfParams0 = bytes9(abi.encodePacked(minTick0, int16(length0), uint32(alpha0)));
        bytes9 ldfParams1 = bytes9(abi.encodePacked(minTick1, int16(length1), uint32(alpha1)));
        bytes32 ldfParams = bytes32(abi.encodePacked(weight0, weight1, ldfParams0, ldfParams1));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        currentTick = int24(bound(currentTick, minUsableTick, maxUsableTick));
        _test_query_cumulativeAmounts(currentTick, tickSpacing, ldfParams);
    }
}
