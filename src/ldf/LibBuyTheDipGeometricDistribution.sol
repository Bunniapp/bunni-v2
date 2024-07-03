// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

import "../lib/Math.sol";
import "../base/Constants.sol";
import "./LibGeometricDistribution.sol";

library LibBuyTheDipGeometricDistribution {
    using FixedPointMathLib for uint256;

    uint256 internal constant MIN_ALPHA = 1e3;
    uint256 internal constant MAX_ALPHA = 12e8;
    uint256 internal constant ALPHA_BASE = 1e8; // alpha uses 8 decimals in ldfParams
    uint256 internal constant WEIGHT_BASE = 1e9; // weight uses 9 decimals in ldfParams

    /// @dev Queries the liquidity density and the cumulative amounts at the given rounded tick.
    /// @param roundedTick The rounded tick to query
    /// @param tickSpacing The spacing of the ticks
    /// @return liquidityDensityX96_ The liquidity density at the given rounded tick. Range is [0, 1]. Scaled by 2^96.
    /// @return cumulativeAmount0DensityX96 The cumulative amount of token0 in the rounded ticks [roundedTick + tickSpacing, minTick + length * tickSpacing)
    /// @return cumulativeAmount1DensityX96 The cumulative amount of token1 in the rounded ticks [minTick, roundedTick - tickSpacing]
    function query(
        int24 roundedTick,
        int24 tickSpacing,
        int24 twapTick,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 altAlphaX96,
        int24 altThreshold,
        bool altThresholdDirection
    )
        internal
        pure
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        // compute liquidityDensityX96
        liquidityDensityX96_ = liquidityDensityX96(
            roundedTick,
            tickSpacing,
            twapTick,
            minTick,
            length,
            alphaX96,
            altAlphaX96,
            altThreshold,
            altThresholdDirection
        );

        // compute cumulativeAmount0DensityX96
        cumulativeAmount0DensityX96 = cumulativeAmount0(
            roundedTick + tickSpacing,
            Q96,
            tickSpacing,
            twapTick,
            minTick,
            length,
            alphaX96,
            altAlphaX96,
            altThreshold,
            altThresholdDirection
        );

        // compute cumulativeAmount1DensityX96
        cumulativeAmount1DensityX96 = cumulativeAmount1(
            roundedTick - tickSpacing,
            Q96,
            tickSpacing,
            twapTick,
            minTick,
            length,
            alphaX96,
            altAlphaX96,
            altThreshold,
            altThresholdDirection
        );
    }

    /// @dev Computes the cumulative amount of token0 in the rounded ticks [roundedTick, tickUpper).
    function cumulativeAmount0(
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 twapTick,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 altAlphaX96,
        int24 altThreshold,
        bool altThresholdDirection
    ) internal pure returns (uint256 amount0) {
        if (shouldUseAltAlpha(twapTick, altThreshold, altThresholdDirection)) {
            return LibGeometricDistribution.cumulativeAmount0(
                roundedTick, totalLiquidity, tickSpacing, minTick, length, altAlphaX96
            );
        } else {
            return LibGeometricDistribution.cumulativeAmount0(
                roundedTick, totalLiquidity, tickSpacing, minTick, length, alphaX96
            );
        }
    }

    /// @dev Computes the cumulative amount of token1 in the rounded ticks [tickLower, roundedTick].
    function cumulativeAmount1(
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 twapTick,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 altAlphaX96,
        int24 altThreshold,
        bool altThresholdDirection
    ) internal pure returns (uint256 amount1) {
        if (shouldUseAltAlpha(twapTick, altThreshold, altThresholdDirection)) {
            return LibGeometricDistribution.cumulativeAmount1(
                roundedTick, totalLiquidity, tickSpacing, minTick, length, altAlphaX96
            );
        } else {
            return LibGeometricDistribution.cumulativeAmount1(
                roundedTick, totalLiquidity, tickSpacing, minTick, length, alphaX96
            );
        }
    }

    /// @dev Given a cumulativeAmount0, computes the rounded tick whose cumulativeAmount0 is closest to the input. Range is [tickLower, tickUpper].
    ///      If roundUp is true, the returned tick will be the smallest rounded tick whose cumulativeAmount0 is less than or equal to the input.
    ///      If roundUp is false, the returned tick will be the largest rounded tick whose cumulativeAmount0 is greater than or equal to the input.
    ///      In the case that the input exceeds the cumulativeAmount0 of all rounded ticks, the function will return (false, 0).
    function inverseCumulativeAmount0(
        uint256 cumulativeAmount0_,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 twapTick,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 altAlphaX96,
        int24 altThreshold,
        bool altThresholdDirection,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        if (shouldUseAltAlpha(twapTick, altThreshold, altThresholdDirection)) {
            return LibGeometricDistribution.inverseCumulativeAmount0(
                cumulativeAmount0_, totalLiquidity, tickSpacing, minTick, length, altAlphaX96, roundUp
            );
        } else {
            return LibGeometricDistribution.inverseCumulativeAmount0(
                cumulativeAmount0_, totalLiquidity, tickSpacing, minTick, length, alphaX96, roundUp
            );
        }
    }

    /// @dev Given a cumulativeAmount1, computes the rounded tick whose cumulativeAmount1 is closest to the input. Range is [tickLower - tickSpacing, tickUpper - tickSpacing].
    ///      If roundUp is true, the returned tick will be the smallest rounded tick whose cumulativeAmount1 is greater than or equal to the input.
    ///      If roundUp is false, the returned tick will be the largest rounded tick whose cumulativeAmount1 is less than or equal to the input.
    ///      In the case that the input exceeds the cumulativeAmount1 of all rounded ticks, the function will return (false, 0).
    function inverseCumulativeAmount1(
        uint256 cumulativeAmount1_,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 twapTick,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 altAlphaX96,
        int24 altThreshold,
        bool altThresholdDirection,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        if (shouldUseAltAlpha(twapTick, altThreshold, altThresholdDirection)) {
            return LibGeometricDistribution.inverseCumulativeAmount1(
                cumulativeAmount1_, totalLiquidity, tickSpacing, minTick, length, altAlphaX96, roundUp
            );
        } else {
            return LibGeometricDistribution.inverseCumulativeAmount1(
                cumulativeAmount1_, totalLiquidity, tickSpacing, minTick, length, alphaX96, roundUp
            );
        }
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams) internal pure returns (bool) {
        // decode params
        uint32 altAlpha = uint32(bytes4(ldfParams << 80));
        (int24 minTick, int24 length, uint256 alphaX96, uint256 altAlphaX96, int24 altThreshold,) =
            decodeParams(ldfParams);
        bytes32 altLdfParams = bytes32(abi.encodePacked(minTick, int16(length), altAlpha));

        // validity conditions:
        // - need TWAP to be enabled to trigger the alt alpha switch
        // - both LDFs are valid
        // - threshold makes sense i.e. both LDFs can be used at some point
        // - alpha and altAlpha are on different sides of 1
        return (twapSecondsAgo != 0) && geometricIsValidParams(tickSpacing, 0, ldfParams)
            && geometricIsValidParams(tickSpacing, 0, altLdfParams) && altThreshold < minTick + length * tickSpacing
            && altThreshold > minTick && ((alphaX96 < Q96) != (altAlphaX96 < Q96));
    }

    /// @dev Should be the same as LibGeometricDistribution.isValidParams but without checks for minimum liquidity.
    /// This LDF requires one end of the distribution to have essentially 0 liquidity so that when the alt LDF
    /// is activated liquidity can move to a specified price to "buy the dip".
    function geometricIsValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams)
        internal
        pure
        returns (bool)
    {
        // ensure length > 0 and doesn't overflow when multiplied by tickSpacing
        // ensure length can be contained between minUsableTick and maxUsableTick
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        int24 length = int24(int16(uint16(bytes2(ldfParams << 24))));
        if (
            length <= 0 || int256(length) * int256(tickSpacing) > type(int24).max
                || length > maxUsableTick / tickSpacing || -length < minUsableTick / tickSpacing
        ) return false;

        // ensure alpha is in range
        uint256 alpha = uint32(bytes4(ldfParams << 40));
        if (alpha < MIN_ALPHA || alpha > MAX_ALPHA || alpha == ALPHA_BASE) return false;

        bool useTwap = twapSecondsAgo != 0;
        int24 minTick;
        if (useTwap) {
            // use rounded TWAP value + offset as minTick
            // | offset - 3 bytes | length - 2 bytes | alpha - 4 bytes | shiftMode - 1 byte |
            int24 offset = int24(uint24(bytes3(ldfParams))); // the offset (in rounded ticks) applied to the twap tick to get the minTick
            uint8 shiftMode = uint8(bytes1(ldfParams << 72));

            // ensure the following:
            // - shiftMode is within the valid range
            // - offset doesn't overflow when multiplied by tickSpacing
            if (shiftMode > uint8(type(ShiftMode).max) || int256(offset) * int256(tickSpacing) > type(int24).max) {
                return false;
            }
        } else {
            // static minTick set in params
            // | minTick - 3 bytes | length - 2 bytes | alpha - 4 bytes |
            minTick = int24(uint24(bytes3(ldfParams))); // must be aligned to tickSpacing
            int24 maxTick = minTick + length * tickSpacing;

            // ensure the following:
            // - minTick is aligned to tickSpacing and within the valid range
            // - maxTick is within the valid range
            if (minTick % tickSpacing != 0 || minTick < minUsableTick || maxTick > maxUsableTick) return false;
        }

        // if all conditions are met, return true
        return true;
    }

    function liquidityDensityX96(
        int24 roundedTick,
        int24 tickSpacing,
        int24 twapTick,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 altAlphaX96,
        int24 altThreshold,
        bool altThresholdDirection
    ) internal pure returns (uint256) {
        if (shouldUseAltAlpha(twapTick, altThreshold, altThresholdDirection)) {
            return LibGeometricDistribution.liquidityDensityX96(roundedTick, tickSpacing, minTick, length, altAlphaX96);
        } else {
            return LibGeometricDistribution.liquidityDensityX96(roundedTick, tickSpacing, minTick, length, alphaX96);
        }
    }

    /// @dev Combines several operations used during a swap into one function to save gas.
    ///      Given a cumulative amount, it computes its inverse to find the closest rounded tick, then computes the cumulative amount at that tick,
    ///      and finally computes the liquidity of the tick that will handle the remainder of the swap.
    function computeSwap(
        uint256 inverseCumulativeAmountInput,
        uint256 totalLiquidity,
        bool zeroForOne,
        bool exactIn,
        int24 tickSpacing,
        int24 twapTick,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 altAlphaX96,
        int24 altThreshold,
        bool altThresholdDirection
    ) internal pure returns (bool success, int24 roundedTick, uint256 cumulativeAmount, uint256 swapLiquidity) {
        if (exactIn == zeroForOne) {
            // compute roundedTick by inverting the cumulative amount
            // below is an illustration of 4 rounded ticks, the input amount, and the resulting roundedTick (rick)
            // notice that the inverse tick is between two rounded ticks, and we round up to the rounded tick to the right
            // e.g. go from 1.5 to 2
            //       input
            //      ├──────┤
            // ┌──┬──┬──┬──┐
            // │  │ █│██│██│
            // │  │ █│██│██│
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //       │
            //       ▼
            //      rick
            (success, roundedTick) = inverseCumulativeAmount0(
                inverseCumulativeAmountInput,
                totalLiquidity,
                tickSpacing,
                twapTick,
                minTick,
                length,
                alphaX96,
                altAlphaX96,
                altThreshold,
                altThresholdDirection,
                true
            );
            if (!success) return (false, 0, 0, 0);

            // compute the cumulative amount up to roundedTick
            // below is an illustration of the cumulative amount at roundedTick
            // notice that (input - cum) is the remainder of the swap that will be handled by Uniswap math
            //         cum
            //       ├─────┤
            // ┌──┬──┬──┬──┐
            // │  │ █│██│██│
            // │  │ █│██│██│
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //       │
            //       ▼
            //      rick
            cumulativeAmount = cumulativeAmount0(
                roundedTick,
                totalLiquidity,
                tickSpacing,
                twapTick,
                minTick,
                length,
                alphaX96,
                altAlphaX96,
                altThreshold,
                altThresholdDirection
            );

            // compute liquidity of the rounded tick that will handle the remainder of the swap
            // below is an illustration of the liquidity of the rounded tick that will handle the remainder of the swap
            // because we got rick by rounding up, the liquidity of (rick - tickSpacing) is used by the Uniswap math
            //    liq
            //    ├──┤
            // ┌──┬──┬──┬──┐
            // │  │ █│██│██│
            // │  │ █│██│██│
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //    │
            //    ▼
            //   rick - tickSpacing
            swapLiquidity = (
                liquidityDensityX96(
                    roundedTick - tickSpacing,
                    tickSpacing,
                    twapTick,
                    minTick,
                    length,
                    alphaX96,
                    altAlphaX96,
                    altThreshold,
                    altThresholdDirection
                ) * totalLiquidity
            ) >> 96;
        } else {
            // compute roundedTick by inverting the cumulative amount
            // below is an illustration of 4 rounded ticks, the input amount, and the resulting roundedTick (rick)
            // notice that the inverse tick is between two rounded ticks, and we round up to the rounded tick to the right
            // e.g. go from 1.5 to 2
            //  input
            // ├──────┤
            // ┌──┬──┬──┬──┐
            // │██│██│█ │  │
            // │██│██│█ │  │
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //       │
            //       ▼
            //      rick
            (success, roundedTick) = inverseCumulativeAmount1(
                inverseCumulativeAmountInput,
                totalLiquidity,
                tickSpacing,
                twapTick,
                minTick,
                length,
                alphaX96,
                altAlphaX96,
                altThreshold,
                altThresholdDirection,
                true
            );
            if (!success) return (false, 0, 0, 0);

            // compute the cumulative amount up to roundedTick
            // below is an illustration of the cumulative amount at roundedTick
            // notice that (input - cum) is the remainder of the swap that will be handled by Uniswap math
            //   cum
            // ├─────┤
            // ┌──┬──┬──┬──┐
            // │██│██│█ │  │
            // │██│██│█ │  │
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //    │
            //    ▼
            //   rick - tickSpacing
            cumulativeAmount = cumulativeAmount1(
                roundedTick - tickSpacing,
                totalLiquidity,
                tickSpacing,
                twapTick,
                minTick,
                length,
                alphaX96,
                altAlphaX96,
                altThreshold,
                altThresholdDirection
            );

            // compute liquidity of the rounded tick that will handle the remainder of the swap
            // below is an illustration of the liquidity of the rounded tick that will handle the remainder of the swap
            //       liq
            //       ├──┤
            // ┌──┬──┬──┬──┐
            // │██│██│█ │  │
            // │██│██│█ │  │
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //       │
            //       ▼
            //      rick
            swapLiquidity = (
                liquidityDensityX96(
                    roundedTick,
                    tickSpacing,
                    twapTick,
                    minTick,
                    length,
                    alphaX96,
                    altAlphaX96,
                    altThreshold,
                    altThresholdDirection
                ) * totalLiquidity
            ) >> 96;
        }
    }

    /// @return minTick The minimum rounded tick of the distribution
    /// @return length The length of the geometric distribution in number of rounded ticks
    /// @return alphaX96 The alpha of the geometric distribution
    /// @return altAlphaX96 The alternative alpha value used when (altThresholdDirection ? twapTick <= altThreshold : twapTick >= altThreshold)
    /// @return altThreshold The threshold used to switch to the alternative alpha value
    /// @return altThresholdDirection The direction of the threshold. True if the alternative alpha value is used when twapTick < altThreshold, false if when twapTick > altThreshold
    function decodeParams(bytes32 ldfParams)
        internal
        pure
        returns (
            int24 minTick,
            int24 length,
            uint256 alphaX96,
            uint256 altAlphaX96,
            int24 altThreshold,
            bool altThresholdDirection
        )
    {
        // static minTick set in params
        // | minTick - 3 bytes | length - 2 bytes | alpha - 4 bytes | 0 - 1 byte | altAlpha - 4 bytes | altThreshold - 3 bytes | altThresholdDirection - 1 byte |
        minTick = int24(uint24(bytes3(ldfParams))); // must be aligned to tickSpacing
        length = int24(int16(uint16(bytes2(ldfParams << 24))));
        uint256 alpha = uint32(bytes4(ldfParams << 40));
        alphaX96 = alpha.mulDiv(Q96, ALPHA_BASE);
        uint256 altAlpha = uint32(bytes4(ldfParams << 80));
        altAlphaX96 = altAlpha.mulDiv(Q96, ALPHA_BASE);
        altThreshold = int24(uint24(bytes3(ldfParams << 112)));
        altThresholdDirection = uint8(bytes1(ldfParams << 136)) != 0;
    }

    /// @dev Whether the alternative alpha value should be used based on the TWAP tick and the threshold.
    function shouldUseAltAlpha(int24 twapTick, int24 altThreshold, bool altThresholdDirection)
        internal
        pure
        returns (bool)
    {
        return altThresholdDirection ? twapTick <= altThreshold : twapTick >= altThreshold;
    }
}
