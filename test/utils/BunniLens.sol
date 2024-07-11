// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "../../src/BunniHook.sol";
import "../../src/lib/VaultMath.sol";
import "../../src/types/PoolState.sol";
import {LiquidityAmounts} from "../../src/lib/LiquidityAmounts.sol";

contract BunniLens {
    using SafeCastLib for *;
    using FixedPointMathLib for *;
    using PoolIdLibrary for PoolKey;

    IBunniHub public immutable hub;

    constructor(IBunniHub hub_) {
        hub = hub_;
    }

    function getExcessLiquidity(PoolKey calldata key)
        external
        view
        returns (uint256 excessLiquidity0, uint256 excessLiquidity1, uint256 totalLiquidity)
    {
        PoolId id = key.toId();
        IBunniHook hook = IBunniHook(address(key.hooks));

        // load fresh state
        PoolState memory bunniState = hub.poolState(id);

        (uint160 updatedSqrtPriceX96, int24 updatedTick,,) = hook.slot0s(id);

        int24 arithmeticMeanTick;
        if (bunniState.twapSecondsAgo != 0) {
            arithmeticMeanTick = _getTwap(key, bunniState.twapSecondsAgo);
        }
        bytes32 newLdfState = hook.ldfStates(id);

        // compute the ratio (excessLiquidity / totalLiquidity)
        // excessLiquidity is the minimum amount of liquidity that can be supported by the excess tokens

        // get fresh token balances
        (uint256 balance0, uint256 balance1) = (
            bunniState.rawBalance0 + getReservesInUnderlying(bunniState.reserve0, bunniState.vault0),
            bunniState.rawBalance1 + getReservesInUnderlying(bunniState.reserve1, bunniState.vault1)
        );

        // compute total liquidity
        uint256 currentActiveBalance0;
        uint256 currentActiveBalance1;

        (int24 roundedTick, int24 nextRoundedTick) = roundTick(updatedTick, key.tickSpacing);
        (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
            (TickMath.getSqrtPriceAtTick(roundedTick), TickMath.getSqrtPriceAtTick(nextRoundedTick));
        (
            uint256 liquidityDensityOfRoundedTickX96,
            uint256 density0RightOfRoundedTickX96,
            uint256 density1LeftOfRoundedTickX96,
            ,
        ) = bunniState.liquidityDensityFunction.query(
            key, roundedTick, arithmeticMeanTick, updatedTick, bunniState.ldfParams, newLdfState
        );
        {
            (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts
                .getAmountsForLiquidity(
                updatedSqrtPriceX96,
                roundedTickSqrtRatio,
                nextRoundedTickSqrtRatio,
                uint128(liquidityDensityOfRoundedTickX96),
                false
            );
            uint256 totalDensity0X96_ = density0RightOfRoundedTickX96 + density0OfRoundedTickX96;
            uint256 totalDensity1X96_ = density1LeftOfRoundedTickX96 + density1OfRoundedTickX96;
            uint256 totalLiquidityEstimate0 = totalDensity0X96_ == 0 ? 0 : balance0.fullMulDiv(Q96, totalDensity0X96_);
            uint256 totalLiquidityEstimate1 = totalDensity1X96_ == 0 ? 0 : balance1.fullMulDiv(Q96, totalDensity1X96_);
            if (totalLiquidityEstimate0 == 0) {
                totalLiquidity = totalLiquidityEstimate1;
            } else if (totalLiquidityEstimate1 == 0) {
                totalLiquidity = totalLiquidityEstimate0;
            } else {
                totalLiquidity = FixedPointMathLib.min(totalLiquidityEstimate0, totalLiquidityEstimate1);
            }
        }

        // compute active balance, which is the balance implied by the total liquidity & the LDF
        {
            uint128 updatedRoundedTickLiquidity =
                ((totalLiquidity * liquidityDensityOfRoundedTickX96) >> 96).toUint128();
            (currentActiveBalance0, currentActiveBalance1) = LiquidityAmounts.getAmountsForLiquidity(
                updatedSqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, updatedRoundedTickLiquidity, false
            );
            (currentActiveBalance0, currentActiveBalance1) = (
                currentActiveBalance0 + ((density0RightOfRoundedTickX96 * totalLiquidity) >> 96),
                currentActiveBalance1 + ((density1LeftOfRoundedTickX96 * totalLiquidity) >> 96)
            );
        }

        // compute excess liquidity if there's any
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(key.tickSpacing), TickMath.maxUsableTick(key.tickSpacing) - key.tickSpacing);
        excessLiquidity0 = balance0 > currentActiveBalance0
            ? (balance0 - currentActiveBalance0).divWad(
                bunniState.liquidityDensityFunction.cumulativeAmount0(
                    key, minUsableTick, WAD, arithmeticMeanTick, updatedTick, bunniState.ldfParams, newLdfState
                )
            )
            : 0;
        excessLiquidity1 = balance1 > currentActiveBalance1
            ? (balance1 - currentActiveBalance1).divWad(
                bunniState.liquidityDensityFunction.cumulativeAmount1(
                    key, maxUsableTick, WAD, arithmeticMeanTick, updatedTick, bunniState.ldfParams, newLdfState
                )
            )
            : 0;
    }

    function _getTwap(PoolKey memory poolKey, uint24 twapSecondsAgo) internal view returns (int24 arithmeticMeanTick) {
        IBunniHook hook = IBunniHook(address(poolKey.hooks));
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = twapSecondsAgo;
        secondsAgos[1] = 0;
        int56[] memory tickCumulatives = hook.observe(poolKey, secondsAgos);
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        return int24(tickCumulativesDelta / int56(uint56(twapSecondsAgo)));
    }
}
