// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "./LiquidityDensityFunctionTest.sol";
import "../../src/ldf/BoundedDiscreteLaplaceDistribution.sol";

contract BoundedDiscreteLaplaceDistributionTest is LiquidityDensityFunctionTest {
    uint256 internal constant MIN_ALPHA = 1e2;
    uint256 internal constant MAX_ALPHA = 0.9e5;

    function _setUpLDF() internal override {
        ldf = ILiquidityDensityFunction(address(new BoundedDiscreteLaplaceDistribution()));
    }

    function test_liquidityDensity_sumUpToOne(
        int24 tickSpacing,
        int24 mu,
        int24 lengthLeft,
        int24 lengthRight,
        uint256 alpha
    ) external {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        mu = roundTickSingle(int24(bound(mu, minUsableTick + tickSpacing, maxUsableTick - tickSpacing)), tickSpacing);
        lengthLeft = int24(bound(lengthLeft, 0, (mu - minUsableTick) / tickSpacing - 1));
        lengthRight = int24(bound(lengthRight, 0, (maxUsableTick - mu) / tickSpacing - 1));
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);

        _test_liquidityDensity_sumUpToOne(
            tickSpacing, bytes11(abi.encodePacked(mu, int16(lengthLeft), int16(lengthRight), uint24(alpha), uint8(0)))
        );
    }

    function test_query_cumulativeAmounts(
        int24 currentTick,
        int24 tickSpacing,
        int24 mu,
        int24 lengthLeft,
        int24 lengthRight,
        uint256 alpha
    ) external {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        mu = roundTickSingle(int24(bound(mu, minUsableTick + tickSpacing, maxUsableTick - tickSpacing)), tickSpacing);
        lengthLeft = int24(bound(lengthLeft, 0, (mu - minUsableTick) / tickSpacing - 1));
        lengthRight = int24(bound(lengthRight, 0, (maxUsableTick - mu) / tickSpacing - 1));
        currentTick = int24(bound(currentTick, minUsableTick, maxUsableTick));
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);

        _test_query_cumulativeAmounts(
            currentTick,
            tickSpacing,
            bytes11(abi.encodePacked(mu, int16(lengthLeft), int16(lengthRight), uint24(alpha), uint8(0)))
        );
    }
}
