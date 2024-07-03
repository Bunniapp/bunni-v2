// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./ShiftMode.sol";
import "../lib/Math.sol";
import "../lib/ExpMath.sol";
import "../base/Constants.sol";
import "./LibUniformDistribution.sol";
import "./LibGeometricDistribution.sol";

library LibCarpetedGeometricDistribution {
    using SafeCastLib for uint256;
    using FixedPointMathLib for uint256;

    uint256 internal constant ALPHA_BASE = 1e8; // alpha uses 8 decimals in ldfParams
    uint256 internal constant WEIGHT_BASE = 1e9; // weight uses 9 decimals in ldfParams
    uint256 internal constant MIN_LIQUIDITY_DENSITY = Q96 / 1e3;

    /// @dev Queries the liquidity density and the cumulative amounts at the given rounded tick.
    /// @param roundedTick The rounded tick to query
    /// @param tickSpacing The spacing of the ticks
    /// @return liquidityDensityX96_ The liquidity density at the given rounded tick. Range is [0, 1]. Scaled by 2^96.
    /// @return cumulativeAmount0DensityX96 The cumulative amount of token0 in the rounded ticks [roundedTick + tickSpacing, minTick + length * tickSpacing)
    /// @return cumulativeAmount1DensityX96 The cumulative amount of token1 in the rounded ticks [minTick, roundedTick - tickSpacing]
    function query(
        int24 roundedTick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 weightMain
    )
        internal
        pure
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        // compute liquidityDensityX96
        liquidityDensityX96_ = liquidityDensityX96(roundedTick, tickSpacing, minTick, length, alphaX96, weightMain);

        // compute cumulativeAmount0DensityX96
        cumulativeAmount0DensityX96 =
            cumulativeAmount0(roundedTick + tickSpacing, Q96, tickSpacing, minTick, length, alphaX96, weightMain);

        // compute cumulativeAmount1DensityX96
        cumulativeAmount1DensityX96 =
            cumulativeAmount1(roundedTick - tickSpacing, Q96, tickSpacing, minTick, length, alphaX96, weightMain);
    }

    /// @dev Computes the cumulative amount of token0 in the rounded ticks [roundedTick, tickUpper).
    function cumulativeAmount0(
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 weightMain
    ) internal pure returns (uint256 amount0) {
        (
            uint256 leftCarpetLiquidity,
            uint256 mainLiquidity,
            uint256 rightCarpetLiquidity,
            int24 minUsableTick,
            int24 maxUsableTick
        ) = getCarpetedLiquidity(totalLiquidity, tickSpacing, minTick, length, weightMain);

        return LibUniformDistribution.cumulativeAmount0(
            roundedTick, leftCarpetLiquidity, tickSpacing, minUsableTick, minTick
        )
            + LibGeometricDistribution.cumulativeAmount0(roundedTick, mainLiquidity, tickSpacing, minTick, length, alphaX96)
            + LibUniformDistribution.cumulativeAmount0(
                roundedTick, rightCarpetLiquidity, tickSpacing, minTick + length * tickSpacing, maxUsableTick
            );
    }

    /// @dev Computes the cumulative amount of token1 in the rounded ticks [tickLower, roundedTick].
    function cumulativeAmount1(
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 weightMain
    ) internal pure returns (uint256 amount1) {
        (
            uint256 leftCarpetLiquidity,
            uint256 mainLiquidity,
            uint256 rightCarpetLiquidity,
            int24 minUsableTick,
            int24 maxUsableTick
        ) = getCarpetedLiquidity(totalLiquidity, tickSpacing, minTick, length, weightMain);

        return LibUniformDistribution.cumulativeAmount1(
            roundedTick, leftCarpetLiquidity, tickSpacing, minUsableTick, minTick
        )
            + LibGeometricDistribution.cumulativeAmount1(roundedTick, mainLiquidity, tickSpacing, minTick, length, alphaX96)
            + LibUniformDistribution.cumulativeAmount1(
                roundedTick, rightCarpetLiquidity, tickSpacing, minTick + length * tickSpacing, maxUsableTick
            );
    }

    /// @dev Given a cumulativeAmount0, computes the rounded tick whose cumulativeAmount0 is closest to the input. Range is [tickLower, tickUpper].
    ///      If roundUp is true, the returned tick will be the smallest rounded tick whose cumulativeAmount0 is less than or equal to the input.
    ///      If roundUp is false, the returned tick will be the largest rounded tick whose cumulativeAmount0 is greater than or equal to the input.
    ///      In the case that the input exceeds the cumulativeAmount0 of all rounded ticks, the function will return (false, 0).
    function inverseCumulativeAmount0(
        uint256 cumulativeAmount0_,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 weightMain,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        // try LDFs in the order of right carpet, main, left carpet
        (
            uint256 leftCarpetLiquidity,
            uint256 mainLiquidity,
            uint256 rightCarpetLiquidity,
            int24 minUsableTick,
            int24 maxUsableTick
        ) = getCarpetedLiquidity(totalLiquidity, tickSpacing, minTick, length, weightMain);
        uint256 rightCarpetCumulativeAmount0 = LibUniformDistribution.cumulativeAmount0(
            minTick + length * tickSpacing,
            rightCarpetLiquidity,
            tickSpacing,
            minTick + length * tickSpacing,
            maxUsableTick
        );

        if (cumulativeAmount0_ <= rightCarpetCumulativeAmount0 && rightCarpetLiquidity != 0) {
            // use right carpet
            return LibUniformDistribution.inverseCumulativeAmount0(
                cumulativeAmount0_,
                rightCarpetLiquidity,
                tickSpacing,
                minTick + length * tickSpacing,
                maxUsableTick,
                roundUp
            );
        } else {
            uint256 remainder = cumulativeAmount0_ - rightCarpetCumulativeAmount0;
            uint256 mainCumulativeAmount0 = LibGeometricDistribution.cumulativeAmount0(
                minTick, mainLiquidity, tickSpacing, minTick, length, alphaX96
            );

            if (remainder <= mainCumulativeAmount0) {
                // use main
                return LibGeometricDistribution.inverseCumulativeAmount0(
                    remainder, mainLiquidity, tickSpacing, minTick, length, alphaX96, roundUp
                );
            } else if (leftCarpetLiquidity != 0) {
                // use left carpet
                remainder -= mainCumulativeAmount0;
                return LibUniformDistribution.inverseCumulativeAmount0(
                    remainder, leftCarpetLiquidity, tickSpacing, minUsableTick, minTick, roundUp
                );
            }
        }
        return (false, 0);
    }

    /// @dev Given a cumulativeAmount1, computes the rounded tick whose cumulativeAmount1 is closest to the input. Range is [tickLower - tickSpacing, tickUpper - tickSpacing].
    ///      If roundUp is true, the returned tick will be the smallest rounded tick whose cumulativeAmount1 is greater than or equal to the input.
    ///      If roundUp is false, the returned tick will be the largest rounded tick whose cumulativeAmount1 is less than or equal to the input.
    ///      In the case that the input exceeds the cumulativeAmount1 of all rounded ticks, the function will return (false, 0).
    function inverseCumulativeAmount1(
        uint256 cumulativeAmount1_,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 weightMain,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        // try LDFs in the order of left carpet, main, right carpet
        (
            uint256 leftCarpetLiquidity,
            uint256 mainLiquidity,
            uint256 rightCarpetLiquidity,
            int24 minUsableTick,
            int24 maxUsableTick
        ) = getCarpetedLiquidity(totalLiquidity, tickSpacing, minTick, length, weightMain);
        uint256 leftCarpetCumulativeAmount1 =
            LibUniformDistribution.cumulativeAmount1(minTick, leftCarpetLiquidity, tickSpacing, minUsableTick, minTick);

        if (cumulativeAmount1_ <= leftCarpetCumulativeAmount1 && leftCarpetLiquidity != 0) {
            // use left carpet
            return LibUniformDistribution.inverseCumulativeAmount1(
                cumulativeAmount1_, leftCarpetLiquidity, tickSpacing, minUsableTick, minTick, roundUp
            );
        } else {
            uint256 remainder = cumulativeAmount1_ - leftCarpetCumulativeAmount1;
            uint256 mainCumulativeAmount1 = LibGeometricDistribution.cumulativeAmount1(
                minTick + length * tickSpacing, mainLiquidity, tickSpacing, minTick, length, alphaX96
            );

            if (remainder <= mainCumulativeAmount1) {
                // use main
                return LibGeometricDistribution.inverseCumulativeAmount1(
                    remainder, mainLiquidity, tickSpacing, minTick, length, alphaX96, roundUp
                );
            } else if (rightCarpetLiquidity != 0) {
                // use right carpet
                remainder -= mainCumulativeAmount1;
                return LibUniformDistribution.inverseCumulativeAmount1(
                    remainder, rightCarpetLiquidity, tickSpacing, minTick + length * tickSpacing, maxUsableTick, roundUp
                );
            }
        }
        return (false, 0);
    }

    function checkMinLiquidityDensity(int24 tickSpacing, int24 length, uint256 alpha, uint256 weightMain)
        internal
        pure
        returns (bool)
    {
        // ensure liquidity density is nowhere equal to zero
        // can check boundaries since function is monotonic
        int24 minTick = 0; // no loss of generality since shifting doesn't change the min liquidity density
        {
            uint256 alphaX96 = uint256(alpha).mulDiv(Q96, ALPHA_BASE);
            uint256 minLiquidityDensityX96;
            if (alpha > ALPHA_BASE) {
                // monotonically increasing
                // check left boundary
                minLiquidityDensityX96 =
                    LibGeometricDistribution.liquidityDensityX96(minTick, tickSpacing, minTick, length, alphaX96);
            } else {
                // monotonically decreasing
                // check right boundary
                minLiquidityDensityX96 = LibGeometricDistribution.liquidityDensityX96(
                    minTick + (length - 1) * tickSpacing, tickSpacing, minTick, length, alphaX96
                );
            }
            minLiquidityDensityX96 = minLiquidityDensityX96.mulDiv(weightMain, WEIGHT_BASE);
            if (minLiquidityDensityX96 < MIN_LIQUIDITY_DENSITY) {
                return false;
            }
        }

        return true;
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams) internal pure returns (bool) {
        int24 minTickOrOffset = int24(uint24(bytes3(ldfParams)));
        int24 length = int24(int16(uint16(bytes2(ldfParams << 24))));
        uint32 alpha = uint32(bytes4(ldfParams << 40));
        uint32 weightMain = uint32(bytes4(ldfParams << 72));
        uint8 shiftMode = uint8(bytes1(ldfParams << 104));
        bytes32 geometricLdfParams = bytes32(abi.encodePacked(minTickOrOffset, int16(length), alpha, shiftMode));

        return LibGeometricDistribution.isValidParams(tickSpacing, twapSecondsAgo, geometricLdfParams)
            && weightMain != 0 && weightMain < WEIGHT_BASE
            && checkMinLiquidityDensity(tickSpacing, length, alpha, weightMain);
    }

    function liquidityDensityX96(
        int24 roundedTick,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 weightMain
    ) internal pure returns (uint256) {
        if (roundedTick >= minTick && roundedTick < minTick + length * tickSpacing) {
            return LibGeometricDistribution.liquidityDensityX96(roundedTick, tickSpacing, minTick, length, alphaX96)
                .mulDiv(weightMain, WEIGHT_BASE);
        } else {
            (int24 minUsableTick, int24 maxUsableTick) =
                (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
            int24 numRoundedTicksCarpeted = (maxUsableTick - minUsableTick) / tickSpacing - length;
            if (numRoundedTicksCarpeted <= 0) {
                return 0;
            }
            uint256 mainLiquidity = Q96.mulDiv(weightMain, WEIGHT_BASE);
            uint256 carpetLiquidity = Q96 - mainLiquidity;
            return carpetLiquidity / uint24(numRoundedTicksCarpeted);
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
        int24 minTick,
        int24 length,
        uint256 alphaX96,
        uint256 weightMain
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
                inverseCumulativeAmountInput, totalLiquidity, tickSpacing, minTick, length, alphaX96, weightMain, true
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
            cumulativeAmount =
                cumulativeAmount0(roundedTick, totalLiquidity, tickSpacing, minTick, length, alphaX96, weightMain);

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
                liquidityDensityX96(roundedTick - tickSpacing, tickSpacing, minTick, length, alphaX96, weightMain)
                    * totalLiquidity
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
                inverseCumulativeAmountInput, totalLiquidity, tickSpacing, minTick, length, alphaX96, weightMain, true
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
                roundedTick - tickSpacing, totalLiquidity, tickSpacing, minTick, length, alphaX96, weightMain
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
                liquidityDensityX96(roundedTick, tickSpacing, minTick, length, alphaX96, weightMain) * totalLiquidity
            ) >> 96;
        }
    }

    /// @return minTick The minimum rounded tick of the distribution
    /// @return length The length of the geometric distribution in number of rounded ticks
    /// @return alphaX96 The alpha of the geometric distribution
    /// @return weightMain The weight of the geometric distribution, 9 decimals
    /// @return shiftMode The shift mode of the distribution
    function decodeParams(int24 twapTick, int24 tickSpacing, bool useTwap, bytes32 ldfParams)
        internal
        pure
        returns (int24 minTick, int24 length, uint256 alphaX96, uint256 weightMain, ShiftMode shiftMode)
    {
        length = int24(int16(uint16(bytes2(ldfParams << 24))));
        uint256 alpha = uint32(bytes4(ldfParams << 40));
        weightMain = uint32(bytes4(ldfParams << 72));

        alphaX96 = alpha.mulDiv(Q96, ALPHA_BASE);

        if (useTwap) {
            // use rounded TWAP value + offset as minTick
            // | offset - 3 bytes | length - 2 bytes | alpha - 4 bytes | weightMain - 4 bytes | shiftMode - 1 byte |
            int24 offset = int24(uint24(bytes3(ldfParams))); // the offset applied to the twap tick to get the minTick
            minTick = roundTickSingle(twapTick + offset * tickSpacing, tickSpacing);
            shiftMode = ShiftMode(uint8(bytes1(ldfParams << 104)));

            // bound distribution to be within the range of usable ticks
            (int24 minUsableTick, int24 maxUsableTick) =
                (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
            if (minTick < minUsableTick) {
                minTick = minUsableTick;
            } else if (minTick > maxUsableTick - length * tickSpacing) {
                minTick = maxUsableTick - length * tickSpacing;
            }
        } else {
            // static minTick set in params
            // | minTick - 3 bytes | length - 2 bytes | alpha - 4 bytes | weightMain - 4 bytes |
            minTick = int24(uint24(bytes3(ldfParams))); // must be aligned to tickSpacing
            shiftMode = ShiftMode.BOTH;
        }
    }

    function getCarpetedLiquidity(
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 weightMain
    )
        internal
        pure
        returns (
            uint256 leftCarpetLiquidity,
            uint256 mainLiquidity,
            uint256 rightCarpetLiquidity,
            int24 minUsableTick,
            int24 maxUsableTick
        )
    {
        (minUsableTick, maxUsableTick) = (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        int24 numRoundedTicksCarpeted = (maxUsableTick - minUsableTick) / tickSpacing - length;
        if (numRoundedTicksCarpeted <= 0) {
            return (0, totalLiquidity, 0, minUsableTick, maxUsableTick);
        }
        mainLiquidity = totalLiquidity.mulDiv(weightMain, WEIGHT_BASE);
        uint256 carpetLiquidity = totalLiquidity - mainLiquidity;
        rightCarpetLiquidity = carpetLiquidity.mulDiv(
            uint24((maxUsableTick - minTick) / tickSpacing - length), uint24(numRoundedTicksCarpeted)
        );
        leftCarpetLiquidity = carpetLiquidity - rightCarpetLiquidity;
    }
}
