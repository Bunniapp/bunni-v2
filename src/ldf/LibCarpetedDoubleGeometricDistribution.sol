// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./ShiftMode.sol";
import "../lib/Math.sol";
import "../lib/ExpMath.sol";
import "../lib/Constants.sol";
import "./LibUniformDistribution.sol";
import "./LibDoubleGeometricDistribution.sol";

library LibCarpetedDoubleGeometricDistribution {
    using SafeCastLib for uint256;
    using FixedPointMathLib for uint256;

    uint256 internal constant ALPHA_BASE = 1e8; // alpha uses 8 decimals in ldfParams
    uint256 internal constant WEIGHT_BASE = 1e9; // weight uses 9 decimals in ldfParams
    uint256 internal constant MIN_LIQUIDITY_DENSITY = Q96 / 1e3;

    struct Params {
        int24 minTick;
        int24 length0;
        uint256 alpha0X96;
        uint256 weight0;
        int24 length1;
        uint256 alpha1X96;
        uint256 weight1;
        uint256 weightMain;
        ShiftMode shiftMode;
    }

    /// @dev Queries the liquidity density and the cumulative amounts at the given rounded tick.
    /// @param roundedTick The rounded tick to query
    /// @param tickSpacing The spacing of the ticks
    /// @return liquidityDensityX96_ The liquidity density at the given rounded tick. Range is [0, 1]. Scaled by 2^96.
    /// @return cumulativeAmount0DensityX96 The cumulative amount of token0 in the rounded ticks [roundedTick + tickSpacing, minTick + length * tickSpacing)
    /// @return cumulativeAmount1DensityX96 The cumulative amount of token1 in the rounded ticks [minTick, roundedTick - tickSpacing]
    function query(int24 roundedTick, int24 tickSpacing, Params memory params)
        internal
        pure
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        // compute liquidityDensityX96
        liquidityDensityX96_ = liquidityDensityX96(roundedTick, tickSpacing, params);

        // compute cumulativeAmount0DensityX96
        cumulativeAmount0DensityX96 = cumulativeAmount0(roundedTick + tickSpacing, Q96, tickSpacing, params);

        // compute cumulativeAmount1DensityX96
        cumulativeAmount1DensityX96 = cumulativeAmount1(roundedTick - tickSpacing, Q96, tickSpacing, params);
    }

    /// @dev Computes the cumulative amount of token0 in the rounded ticks [roundedTick, tickUpper).
    function cumulativeAmount0(int24 roundedTick, uint256 totalLiquidity, int24 tickSpacing, Params memory params)
        internal
        pure
        returns (uint256 amount0)
    {
        int24 length = params.length0 + params.length1;
        (
            uint256 leftCarpetLiquidity,
            uint256 mainLiquidity,
            uint256 rightCarpetLiquidity,
            int24 minUsableTick,
            int24 maxUsableTick
        ) = getCarpetedLiquidity(totalLiquidity, tickSpacing, params.minTick, length, params.weightMain);

        return LibUniformDistribution.cumulativeAmount0(
            roundedTick, leftCarpetLiquidity, tickSpacing, minUsableTick, params.minTick
        )
            + LibDoubleGeometricDistribution.cumulativeAmount0(
                roundedTick,
                mainLiquidity,
                tickSpacing,
                params.minTick,
                params.length0,
                params.length1,
                params.alpha0X96,
                params.alpha1X96,
                params.weight0,
                params.weight1
            )
            + LibUniformDistribution.cumulativeAmount0(
                roundedTick, rightCarpetLiquidity, tickSpacing, params.minTick + length * tickSpacing, maxUsableTick
            );
    }

    /// @dev Computes the cumulative amount of token1 in the rounded ticks [tickLower, roundedTick].
    function cumulativeAmount1(int24 roundedTick, uint256 totalLiquidity, int24 tickSpacing, Params memory params)
        internal
        pure
        returns (uint256 amount1)
    {
        int24 length = params.length0 + params.length1;
        (
            uint256 leftCarpetLiquidity,
            uint256 mainLiquidity,
            uint256 rightCarpetLiquidity,
            int24 minUsableTick,
            int24 maxUsableTick
        ) = getCarpetedLiquidity(totalLiquidity, tickSpacing, params.minTick, length, params.weightMain);

        return LibUniformDistribution.cumulativeAmount1(
            roundedTick, leftCarpetLiquidity, tickSpacing, minUsableTick, params.minTick
        )
            + LibDoubleGeometricDistribution.cumulativeAmount1(
                roundedTick,
                mainLiquidity,
                tickSpacing,
                params.minTick,
                params.length0,
                params.length1,
                params.alpha0X96,
                params.alpha1X96,
                params.weight0,
                params.weight1
            )
            + LibUniformDistribution.cumulativeAmount1(
                roundedTick, rightCarpetLiquidity, tickSpacing, params.minTick + length * tickSpacing, maxUsableTick
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
        Params memory params,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        // try LDFs in the order of right carpet, main, left carpet
        int24 length = params.length0 + params.length1;
        (
            uint256 leftCarpetLiquidity,
            uint256 mainLiquidity,
            uint256 rightCarpetLiquidity,
            int24 minUsableTick,
            int24 maxUsableTick
        ) = getCarpetedLiquidity(totalLiquidity, tickSpacing, params.minTick, length, params.weightMain);
        uint256 rightCarpetCumulativeAmount0 = LibUniformDistribution.cumulativeAmount0(
            params.minTick + length * tickSpacing,
            rightCarpetLiquidity,
            tickSpacing,
            params.minTick + length * tickSpacing,
            maxUsableTick
        );

        if (cumulativeAmount0_ <= rightCarpetCumulativeAmount0 && rightCarpetLiquidity != 0) {
            // use right carpet
            return LibUniformDistribution.inverseCumulativeAmount0(
                cumulativeAmount0_,
                rightCarpetLiquidity,
                tickSpacing,
                params.minTick + length * tickSpacing,
                maxUsableTick,
                roundUp
            );
        } else {
            uint256 remainder = cumulativeAmount0_ - rightCarpetCumulativeAmount0;
            uint256 mainCumulativeAmount0 = LibDoubleGeometricDistribution.cumulativeAmount0(
                params.minTick,
                mainLiquidity,
                tickSpacing,
                params.minTick,
                params.length0,
                params.length1,
                params.alpha0X96,
                params.alpha1X96,
                params.weight0,
                params.weight1
            );

            if (remainder <= mainCumulativeAmount0) {
                // use main
                return LibDoubleGeometricDistribution.inverseCumulativeAmount0(
                    remainder,
                    mainLiquidity,
                    tickSpacing,
                    params.minTick,
                    params.length0,
                    params.length1,
                    params.alpha0X96,
                    params.alpha1X96,
                    params.weight0,
                    params.weight1,
                    roundUp
                );
            } else if (leftCarpetLiquidity != 0) {
                // use left carpet
                remainder -= mainCumulativeAmount0;
                return LibUniformDistribution.inverseCumulativeAmount0(
                    remainder, leftCarpetLiquidity, tickSpacing, minUsableTick, params.minTick, roundUp
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
        Params memory params,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        // try LDFs in the order of left carpet, main, right carpet
        int24 length = params.length0 + params.length1;
        (
            uint256 leftCarpetLiquidity,
            uint256 mainLiquidity,
            uint256 rightCarpetLiquidity,
            int24 minUsableTick,
            int24 maxUsableTick
        ) = getCarpetedLiquidity(totalLiquidity, tickSpacing, params.minTick, length, params.weightMain);
        uint256 leftCarpetCumulativeAmount1 = LibUniformDistribution.cumulativeAmount1(
            params.minTick, leftCarpetLiquidity, tickSpacing, minUsableTick, params.minTick
        );

        if (cumulativeAmount1_ <= leftCarpetCumulativeAmount1 && leftCarpetLiquidity != 0) {
            // use left carpet
            return LibUniformDistribution.inverseCumulativeAmount1(
                cumulativeAmount1_, leftCarpetLiquidity, tickSpacing, minUsableTick, params.minTick, roundUp
            );
        } else {
            uint256 remainder = cumulativeAmount1_ - leftCarpetCumulativeAmount1;
            uint256 mainCumulativeAmount1 = LibDoubleGeometricDistribution.cumulativeAmount1(
                params.minTick + length * tickSpacing,
                mainLiquidity,
                tickSpacing,
                params.minTick,
                params.length0,
                params.length1,
                params.alpha0X96,
                params.alpha1X96,
                params.weight0,
                params.weight1
            );

            if (remainder <= mainCumulativeAmount1) {
                // use main
                return LibDoubleGeometricDistribution.inverseCumulativeAmount1(
                    remainder,
                    mainLiquidity,
                    tickSpacing,
                    params.minTick,
                    params.length0,
                    params.length1,
                    params.alpha0X96,
                    params.alpha1X96,
                    params.weight0,
                    params.weight1,
                    roundUp
                );
            } else if (rightCarpetLiquidity != 0) {
                // use right carpet
                remainder -= mainCumulativeAmount1;
                return LibUniformDistribution.inverseCumulativeAmount1(
                    remainder,
                    rightCarpetLiquidity,
                    tickSpacing,
                    params.minTick + length * tickSpacing,
                    maxUsableTick,
                    roundUp
                );
            }
        }
        return (false, 0);
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams) internal pure returns (bool) {
        int24 minTick;
        int24 length0 = int24(int16(uint16(bytes2(ldfParams << 24))));
        uint32 alpha0 = uint32(bytes4(ldfParams << 40));
        uint256 weight0 = uint32(bytes4(ldfParams << 72));
        int24 length1 = int24(int16(uint16(bytes2(ldfParams << 104))));
        uint32 alpha1 = uint32(bytes4(ldfParams << 120));
        uint256 weight1 = uint32(bytes4(ldfParams << 152));
        uint256 weightMain = uint32(bytes4(ldfParams << 184));

        return LibDoubleGeometricDistribution.isValidParams(tickSpacing, twapSecondsAgo, ldfParams) && weightMain != 0
            && weightMain < WEIGHT_BASE
            && LibDoubleGeometricDistribution.checkMinLiquidityDensity(
                Q96.mulDiv(weightMain, WEIGHT_BASE),
                tickSpacing,
                minTick,
                length0,
                alpha0,
                weight0,
                length1,
                alpha1,
                weight1
            );
    }

    function liquidityDensityX96(int24 roundedTick, int24 tickSpacing, Params memory params)
        internal
        pure
        returns (uint256)
    {
        int24 length = params.length0 + params.length1;
        if (roundedTick >= params.minTick && roundedTick < params.minTick + length * tickSpacing) {
            return LibDoubleGeometricDistribution.liquidityDensityX96(
                roundedTick,
                tickSpacing,
                params.minTick,
                params.length0,
                params.length1,
                params.alpha0X96,
                params.alpha1X96,
                params.weight0,
                params.weight1
            ).mulDiv(params.weightMain, WEIGHT_BASE);
        } else {
            (int24 minUsableTick, int24 maxUsableTick) =
                (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
            int24 numRoundedTicksCarpeted = (maxUsableTick - minUsableTick) / tickSpacing - length;
            if (numRoundedTicksCarpeted <= 0) {
                return 0;
            }
            uint256 mainLiquidity = Q96.mulDiv(params.weightMain, WEIGHT_BASE);
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
        Params memory params
    ) internal pure returns (bool success, int24 roundedTick, uint256 cumulativeAmount, uint128 swapLiquidity) {
        if (exactIn == zeroForOne) {
            // compute roundedTick by inverting the cumulative amount
            (success, roundedTick) =
                inverseCumulativeAmount0(inverseCumulativeAmountInput, totalLiquidity, tickSpacing, params, true);
            if (!success) return (false, 0, 0, 0);

            // compute the cumulative amount up to roundedTick
            cumulativeAmount = cumulativeAmount0(roundedTick, totalLiquidity, tickSpacing, params);

            // compute liquidity of the rounded tick that will handle the remainder of the swap
            swapLiquidity = (
                (liquidityDensityX96(roundedTick - tickSpacing, tickSpacing, params) * totalLiquidity) >> 96
            ).toUint128();
        } else {
            // compute roundedTick by inverting the cumulative amount
            (success, roundedTick) =
                inverseCumulativeAmount1(inverseCumulativeAmountInput, totalLiquidity, tickSpacing, params, true);
            if (!success) return (false, 0, 0, 0);

            // compute the cumulative amount up to roundedTick
            cumulativeAmount = cumulativeAmount1(roundedTick - tickSpacing, totalLiquidity, tickSpacing, params);

            // compute liquidity of the rounded tick that will handle the remainder of the swap
            swapLiquidity = ((liquidityDensityX96(roundedTick, tickSpacing, params) * totalLiquidity) >> 96).toUint128();
        }
    }

    /// @return params
    /// minTick The minimum rounded tick of the distribution
    /// length0 The length of the right distribution in number of rounded ticks
    /// length1 The length of the left distribution in number of rounded ticks
    /// alpha0X96 The alpha of the right distribution
    /// alpha1X96 The alpha of the left distribution
    /// weight0 The weight of the right distribution
    /// weight1 The weight of the left distribution
    /// weightMain The weight of the main distribution, 9 decimals
    /// shiftMode The shift mode of the distribution
    function decodeParams(int24 twapTick, int24 tickSpacing, bool useTwap, bytes32 ldfParams)
        internal
        pure
        returns (Params memory params)
    {
        if (useTwap) {
            // use rounded TWAP value + offset as minTick
            // | offset - 3 bytes | length0 - 2 bytes | alpha0 - 4 bytes | weight0 - 4 bytes | length1 - 2 bytes | alpha1 - 4 bytes | weight1 - 4 bytes | weightMain - 4 bytes | shiftMode - 1 byte |
            int24 offset = int24(uint24(bytes3(ldfParams))); // the offset applied to the twap tick to get the minTick
            params.minTick = roundTickSingle(twapTick + offset * tickSpacing, tickSpacing);
            params.shiftMode = ShiftMode(uint8(bytes1(ldfParams << 216)));
        } else {
            // static minTick set in params
            // | minTick - 3 bytes | length0 - 2 bytes | alpha0 - 4 bytes | weight0 - 4 bytes | length1 - 2 bytes | alpha1 - 4 bytes | weight1 - 4 bytes | weightMain - 4 bytes |
            params.minTick = int24(uint24(bytes3(ldfParams))); // must be aligned to tickSpacing
            params.shiftMode = ShiftMode.BOTH;
        }
        params.length0 = int24(int16(uint16(bytes2(ldfParams << 24))));
        uint256 alpha0 = uint32(bytes4(ldfParams << 40));
        params.weight0 = uint32(bytes4(ldfParams << 72));
        params.length1 = int24(int16(uint16(bytes2(ldfParams << 104))));
        uint256 alpha1 = uint32(bytes4(ldfParams << 120));
        params.weight1 = uint32(bytes4(ldfParams << 152));
        params.weightMain = uint32(bytes4(ldfParams << 184));

        params.alpha0X96 = alpha0.mulDiv(Q96, ALPHA_BASE);
        params.alpha1X96 = alpha1.mulDiv(Q96, ALPHA_BASE);

        // bound distribution to be within the range of usable ticks
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        if (params.minTick < minUsableTick) {
            params.minTick = minUsableTick;
        } else if (params.minTick > maxUsableTick - (params.length0 + params.length1) * tickSpacing) {
            params.minTick = maxUsableTick - (params.length0 + params.length1) * tickSpacing;
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
