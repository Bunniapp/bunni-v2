// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "./LiquidityDensityFunctionTest.sol";
import "../../src/ldf/DiscreteLaplaceDistribution.sol";

contract DiscreteLaplaceDistributionTest is LiquidityDensityFunctionTest {
    uint256 internal constant MIN_ALPHA = 1e14;
    uint256 internal constant MAX_ALPHA = 0.9e18;

    function _setUpLDF() internal override {
        ldf = ILiquidityDensityFunction(address(new DiscreteLaplaceDistribution()));
    }

    function test_liquidityDensity_sumUpToOne(int24 tickSpacing, int24 mu, uint256 alpha) external {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minTick, int24 maxTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing) - tickSpacing);
        mu = roundTickSingle(int24(bound(mu, minTick, maxTick)), tickSpacing);
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);

        _test_liquidityDensity_sumUpToOne(tickSpacing, bytes32(abi.encodePacked(mu, uint64(alpha))));
    }

    function test_query_cumulativeAmounts(int24 currentTick, int24 tickSpacing, int24 mu, uint256 alpha) external {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minTick, int24 maxTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing) - tickSpacing);
        currentTick = int24(bound(currentTick, minTick, maxTick));
        mu = roundTickSingle(int24(bound(mu, minTick, maxTick)), tickSpacing);
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);

        _test_query_cumulativeAmounts(currentTick, tickSpacing, bytes32(abi.encodePacked(mu, uint64(alpha))));
    }
}
