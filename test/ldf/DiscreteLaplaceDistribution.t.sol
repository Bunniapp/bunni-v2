// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "./LiquidityDensityFunctionTest.sol";
import "../../src/ldf/DiscreteLaplaceDistribution.sol";

contract DiscreteLaplaceDistributionTest is LiquidityDensityFunctionTest {
    uint256 internal constant MIN_ALPHA = 1e16;
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

    function test_inverseCumulativeAmount0(int24 tick, int24 tickSpacing, int24 mu, uint256 alpha, bool roundUp)
        external
        virtual
    {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minTick, int24 maxTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing) - tickSpacing);
        mu = roundTickSingle(int24(bound(mu, minTick, maxTick)), tickSpacing);
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        tick = int24(bound(tick, minTick, maxTick));

        console2.log("tick", tick);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("mu", mu);

        bytes32 ldfParams = bytes32(abi.encodePacked(mu, uint64(alpha)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e18;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        (, uint256 cumulativeAmount0DensityX96,) =
            LibDiscreteLaplaceDistribution.query(roundTickSingle(tick, tickSpacing), tickSpacing, mu, alphaX96);

        vm.assume(cumulativeAmount0DensityX96 > 0); // TODO: handle 0 case later

        console2.log("cumulativeAmount0DensityX96", cumulativeAmount0DensityX96);

        uint256 beforeGasLeft = gasleft();
        (, int24 resultRoundedTick) = LibDiscreteLaplaceDistribution.inverseCumulativeAmount0(
            cumulativeAmount0DensityX96, liquidity, tickSpacing, mu, alphaX96, roundUp
        );
        console2.log("gasUsed", beforeGasLeft - gasleft());
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick + tickSpacing;
        console2.log("x", (expectedTick - mu) / tickSpacing);
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_inverseCumulativeAmount1(int24 tick, int24 tickSpacing, int24 mu, uint256 alpha, bool roundUp)
        external
        virtual
    {
        tickSpacing = int24(bound(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minTick, int24 maxTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing) - tickSpacing);
        mu = roundTickSingle(int24(bound(mu, minTick, maxTick)), tickSpacing);
        alpha = bound(alpha, MIN_ALPHA, MAX_ALPHA);
        tick = int24(bound(tick, minTick, maxTick));

        console2.log("tick", tick);
        console2.log("alpha", alpha);
        console2.log("tickSpacing", tickSpacing);
        console2.log("mu", mu);

        bytes32 ldfParams = bytes32(abi.encodePacked(mu, uint64(alpha)));
        vm.assume(ldf.isValidParams(tickSpacing, 0, ldfParams));

        uint256 alphaX96 = (alpha << 96) / 1e18;
        uint128 liquidity = 1 << 96;
        int24 roundedTick = roundTickSingle(tick, tickSpacing);

        console2.log("roundedTick", roundedTick);

        (,, uint256 cumulativeAmount1DensityX96) =
            LibDiscreteLaplaceDistribution.query(roundTickSingle(tick, tickSpacing), tickSpacing, mu, alphaX96);

        vm.assume(cumulativeAmount1DensityX96 > 0); // TODO: handle 0 case later

        console2.log("cumulativeAmount1DensityX96", cumulativeAmount1DensityX96);

        uint256 beforeGasLeft = gasleft();
        (, int24 resultRoundedTick) = LibDiscreteLaplaceDistribution.inverseCumulativeAmount1(
            cumulativeAmount1DensityX96, liquidity, tickSpacing, mu, alphaX96, roundUp
        );
        console2.log("gasUsed", beforeGasLeft - gasleft());
        console2.log("resultRoundedTick", resultRoundedTick);

        int24 expectedTick = roundedTick - tickSpacing;
        console2.log("x", (expectedTick - mu) / tickSpacing);
        assertEq(resultRoundedTick, expectedTick, "tick incorrect");
    }

    function test_debug() external view {
        PoolKey memory key;
        key.tickSpacing = 2591;
        ldf.query(
            key,
            712525,
            0,
            0,
            false,
            0xf40f6e0c59ea48da1946c6000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000
        );
    }
}
