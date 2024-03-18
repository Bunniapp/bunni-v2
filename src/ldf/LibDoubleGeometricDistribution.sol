// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./ShiftMode.sol";
import "../lib/Math.sol";
import "../lib/ExpMath.sol";
import "../lib/Constants.sol";
import "./LibGeometricDistribution.sol";

library LibDoubleGeometricDistribution {
    using SafeCastLib for uint256;
    using FixedPointMathLib for uint256;

    uint256 internal constant ALPHA_BASE = 1e8; // alpha uses 8 decimals in ldfParams
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
        int24 length0,
        int24 length1,
        uint256 alpha0X96,
        uint256 alpha1X96,
        uint256 weight0,
        uint256 weight1
    )
        internal
        pure
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        // compute liquidityDensityX96
        liquidityDensityX96_ = liquidityDensityX96(
            roundedTick, tickSpacing, minTick, length0, length1, alpha0X96, alpha1X96, weight0, weight1
        );

        // compute cumulativeAmount0DensityX96
        cumulativeAmount0DensityX96 = cumulativeAmount0(
            roundedTick + tickSpacing,
            Q96,
            tickSpacing,
            minTick,
            length0,
            length1,
            alpha0X96,
            alpha1X96,
            weight0,
            weight1
        );

        // compute cumulativeAmount1DensityX96
        cumulativeAmount1DensityX96 = cumulativeAmount1(
            roundedTick - tickSpacing,
            Q96,
            tickSpacing,
            minTick,
            length0,
            length1,
            alpha0X96,
            alpha1X96,
            weight0,
            weight1
        );
    }

    /// @dev Computes the cumulative amount of token0 in the rounded ticks [roundedTick, tickUpper).
    function cumulativeAmount0(
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 minTick,
        int24 length0,
        int24 length1,
        uint256 alpha0X96,
        uint256 alpha1X96,
        uint256 weight0,
        uint256 weight1
    ) internal pure returns (uint256 amount0) {
        uint256 totalLiquidity0 = totalLiquidity.mulDiv(weight0, weight0 + weight1);
        uint256 totalLiquidity1 = totalLiquidity.mulDiv(weight1, weight0 + weight1);
        amount0 = LibGeometricDistribution.cumulativeAmount0(
            roundedTick, totalLiquidity0, tickSpacing, minTick + length1 * tickSpacing, length0, alpha0X96
        )
            + LibGeometricDistribution.cumulativeAmount0(
                roundedTick, totalLiquidity1, tickSpacing, minTick, length1, alpha1X96
            );
    }

    /// @dev Computes the cumulative amount of token1 in the rounded ticks [tickLower, roundedTick].
    function cumulativeAmount1(
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 minTick,
        int24 length0,
        int24 length1,
        uint256 alpha0X96,
        uint256 alpha1X96,
        uint256 weight0,
        uint256 weight1
    ) internal pure returns (uint256 amount1) {
        uint256 totalLiquidity0 = totalLiquidity.mulDiv(weight0, weight0 + weight1);
        uint256 totalLiquidity1 = totalLiquidity.mulDiv(weight1, weight0 + weight1);
        amount1 = LibGeometricDistribution.cumulativeAmount1(
            roundedTick, totalLiquidity0, tickSpacing, minTick + length1 * tickSpacing, length0, alpha0X96
        )
            + LibGeometricDistribution.cumulativeAmount1(
                roundedTick, totalLiquidity1, tickSpacing, minTick, length1, alpha1X96
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
        int24 length0,
        int24 length1,
        uint256 alpha0X96,
        uint256 alpha1X96,
        uint256 weight0,
        uint256 weight1,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        // try ldf0 first, if fails then try ldf1 with remainder
        int24 minTick0 = minTick + length1 * tickSpacing;
        uint256 totalLiquidity0 = totalLiquidity.mulDiv(weight0, weight0 + weight1);
        uint256 ldf0CumulativeAmount0 = LibGeometricDistribution.cumulativeAmount0(
            minTick0, totalLiquidity0, tickSpacing, minTick0, length0, alpha0X96
        );

        if (cumulativeAmount0_ <= ldf0CumulativeAmount0) {
            return LibGeometricDistribution.inverseCumulativeAmount0(
                cumulativeAmount0_, totalLiquidity0, tickSpacing, minTick0, length0, alpha0X96, roundUp
            );
        } else {
            uint256 remainder = cumulativeAmount0_ - ldf0CumulativeAmount0;
            uint256 totalLiquidity1 = totalLiquidity.mulDiv(weight1, weight0 + weight1);
            return LibGeometricDistribution.inverseCumulativeAmount0(
                remainder, totalLiquidity1, tickSpacing, minTick, length1, alpha1X96, roundUp
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
        int24 minTick,
        int24 length0,
        int24 length1,
        uint256 alpha0X96,
        uint256 alpha1X96,
        uint256 weight0,
        uint256 weight1,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        // try ldf1 first, if fails then try ldf0 with remainder
        uint256 totalLiquidity1 = totalLiquidity.mulDiv(weight1, weight0 + weight1);
        uint256 ldf1CumulativeAmount1 = LibGeometricDistribution.cumulativeAmount1(
            minTick + length1 * tickSpacing, totalLiquidity1, tickSpacing, minTick, length1, alpha1X96
        );

        if (cumulativeAmount1_ <= ldf1CumulativeAmount1) {
            return LibGeometricDistribution.inverseCumulativeAmount1(
                cumulativeAmount1_, totalLiquidity1, tickSpacing, minTick, length1, alpha1X96, roundUp
            );
        } else {
            uint256 remainder = cumulativeAmount1_ - ldf1CumulativeAmount1;
            uint256 totalLiquidity0 = totalLiquidity.mulDiv(weight0, weight0 + weight1);
            return LibGeometricDistribution.inverseCumulativeAmount1(
                remainder, totalLiquidity0, tickSpacing, minTick + length1 * tickSpacing, length0, alpha0X96, roundUp
            );
        }
    }

    function checkMinLiquidityDensity(
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 minTick,
        int24 length0,
        uint256 alpha0,
        uint256 weight0,
        int24 length1,
        uint256 alpha1,
        uint256 weight1
    ) internal pure returns (bool) {
        // ensure liquidity density is nowhere equal to zero
        // can check boundaries since function is monotonic
        {
            uint256 alpha0X96 = uint256(alpha0).mulDiv(Q96, ALPHA_BASE);
            uint256 minLiquidityDensityX96;
            int24 minTick0 = minTick + length1 * tickSpacing;
            if (alpha0 > ALPHA_BASE) {
                // monotonically increasing
                // check left boundary
                minLiquidityDensityX96 =
                    LibGeometricDistribution.liquidityDensityX96(minTick0, tickSpacing, minTick0, length0, alpha0X96);
            } else {
                // monotonically decreasing
                // check right boundary
                minLiquidityDensityX96 = LibGeometricDistribution.liquidityDensityX96(
                    minTick0 + (length0 - 1) * tickSpacing, tickSpacing, minTick0, length0, alpha0X96
                );
            }
            minLiquidityDensityX96 =
                minLiquidityDensityX96.mulDiv(weight0, weight0 + weight1).mulDiv(totalLiquidity, Q96);
            if (minLiquidityDensityX96 < MIN_LIQUIDITY_DENSITY) {
                return false;
            }
        }

        {
            uint256 alpha1X96 = uint256(alpha1).mulDiv(Q96, ALPHA_BASE);
            uint256 minLiquidityDensityX96;
            if (alpha1 > ALPHA_BASE) {
                // monotonically increasing
                // check left boundary
                minLiquidityDensityX96 =
                    LibGeometricDistribution.liquidityDensityX96(minTick, tickSpacing, minTick, length1, alpha1X96);
            } else {
                // monotonically decreasing
                // check right boundary
                minLiquidityDensityX96 = LibGeometricDistribution.liquidityDensityX96(
                    minTick + (length1 - 1) * tickSpacing, tickSpacing, minTick, length1, alpha1X96
                );
            }
            minLiquidityDensityX96 =
                minLiquidityDensityX96.mulDiv(weight1, weight0 + weight1).mulDiv(totalLiquidity, Q96);
            if (minLiquidityDensityX96 < MIN_LIQUIDITY_DENSITY) {
                return false;
            }
        }

        return true;
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams) internal pure returns (bool) {
        // | minTick - 3 bytes | length0 - 2 bytes | alpha0 - 4 bytes | weight0 - 4 bytes | length1 - 2 bytes | alpha1 - 2 bytes | weight1 - 4 bytes |
        int24 minTick = int24(uint24(bytes3(ldfParams)));
        int24 length0 = int24(int16(uint16(bytes2(ldfParams << 24))));
        uint32 alpha0 = uint32(bytes4(ldfParams << 40));
        uint256 weight0 = uint32(bytes4(ldfParams << 72));
        int24 length1 = int24(int16(uint16(bytes2(ldfParams << 104))));
        uint32 alpha1 = uint32(bytes4(ldfParams << 120));
        uint256 weight1 = uint32(bytes4(ldfParams << 152));

        return LibGeometricDistribution.isValidParams(
            tickSpacing, twapSecondsAgo, bytes32(abi.encodePacked(minTick, int16(length1), alpha1))
        )
            && LibGeometricDistribution.isValidParams(
                tickSpacing,
                twapSecondsAgo,
                bytes32(abi.encodePacked(minTick + length1 * tickSpacing, int16(length0), alpha0))
            ) && weight0 != 0 && weight1 != 0
            && checkMinLiquidityDensity(Q96, tickSpacing, minTick, length0, alpha0, weight0, length1, alpha1, weight1);
    }

    function liquidityDensityX96(
        int24 roundedTick,
        int24 tickSpacing,
        int24 minTick,
        int24 length0,
        int24 length1,
        uint256 alpha0X96,
        uint256 alpha1X96,
        uint256 weight0,
        uint256 weight1
    ) internal pure returns (uint256) {
        return weightedSum(
            LibGeometricDistribution.liquidityDensityX96(
                roundedTick, tickSpacing, minTick + length1 * tickSpacing, length0, alpha0X96
            ),
            weight0,
            LibGeometricDistribution.liquidityDensityX96(roundedTick, tickSpacing, minTick, length1, alpha1X96),
            weight1
        );
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
        int24 length0,
        int24 length1,
        uint256 alpha0X96,
        uint256 alpha1X96,
        uint256 weight0,
        uint256 weight1
    ) internal pure returns (bool success, int24 roundedTick, uint256 cumulativeAmount, uint128 swapLiquidity) {
        if (exactIn == zeroForOne) {
            // compute roundedTick by inverting the cumulative amount
            (success, roundedTick) = inverseCumulativeAmount0(
                inverseCumulativeAmountInput,
                totalLiquidity,
                tickSpacing,
                minTick,
                length0,
                length1,
                alpha0X96,
                alpha1X96,
                weight0,
                weight1,
                true
            );
            if (!success) return (false, 0, 0, 0);

            // compute the cumulative amount up to roundedTick
            cumulativeAmount = cumulativeAmount0(
                roundedTick,
                totalLiquidity,
                tickSpacing,
                minTick,
                length0,
                length1,
                alpha0X96,
                alpha1X96,
                weight0,
                weight1
            );

            // compute liquidity of the rounded tick that will handle the remainder of the swap
            swapLiquidity = (
                (
                    liquidityDensityX96(
                        roundedTick - tickSpacing,
                        tickSpacing,
                        minTick,
                        length0,
                        length1,
                        alpha0X96,
                        alpha1X96,
                        weight0,
                        weight1
                    ) * totalLiquidity
                ) >> 96
            ).toUint128();
        } else {
            // compute roundedTick by inverting the cumulative amount
            (success, roundedTick) = inverseCumulativeAmount1(
                inverseCumulativeAmountInput,
                totalLiquidity,
                tickSpacing,
                minTick,
                length0,
                length1,
                alpha0X96,
                alpha1X96,
                weight0,
                weight1,
                true
            );
            if (!success) return (false, 0, 0, 0);

            // compute the cumulative amount up to roundedTick
            cumulativeAmount = cumulativeAmount1(
                roundedTick - tickSpacing,
                totalLiquidity,
                tickSpacing,
                minTick,
                length0,
                length1,
                alpha0X96,
                alpha1X96,
                weight0,
                weight1
            );

            // compute liquidity of the rounded tick that will handle the remainder of the swap
            swapLiquidity = (
                (
                    liquidityDensityX96(
                        roundedTick, tickSpacing, minTick, length0, length1, alpha0X96, alpha1X96, weight0, weight1
                    ) * totalLiquidity
                ) >> 96
            ).toUint128();
        }
    }

    /// @return minTick The minimum rounded tick of the distribution
    /// @return length0 The length of the right distribution in number of rounded ticks
    /// @return length1 The length of the left distribution in number of rounded ticks
    /// @return alpha0X96 The alpha of the right distribution
    /// @return alpha1X96 The alpha of the left distribution
    /// @return weight0 The weight of the right distribution
    /// @return weight1 The weight of the left distribution
    /// @return shiftMode The shift mode of the distribution
    function decodeParams(int24 twapTick, int24 tickSpacing, bool useTwap, bytes32 ldfParams)
        internal
        pure
        returns (
            int24 minTick,
            int24 length0,
            int24 length1,
            uint256 alpha0X96,
            uint256 alpha1X96,
            uint256 weight0,
            uint256 weight1,
            ShiftMode shiftMode
        )
    {
        uint256 alpha0;
        uint256 alpha1;
        if (useTwap) {
            // use rounded TWAP value + offset as minTick
            // | offset - 3 bytes | length0 - 2 bytes | alpha0 - 4 bytes | weight0 - 4 bytes | length1 - 2 bytes | alpha1 - 4 bytes | weight1 - 4 bytes | shiftMode - 1 byte |
            int24 offset = int24(uint24(bytes3(ldfParams))); // the offset applied to the twap tick to get the minTick
            minTick = roundTickSingle(twapTick + offset * tickSpacing, tickSpacing);
            shiftMode = ShiftMode(uint8(bytes1(ldfParams << 184)));
        } else {
            // static minTick set in params
            // | minTick - 3 bytes | length0 - 2 bytes | alpha0 - 4 bytes | weight0 - 4 bytes | length1 - 2 bytes | alpha1 - 4 bytes | weight1 - 4 bytes |
            minTick = int24(uint24(bytes3(ldfParams))); // must be aligned to tickSpacing
            shiftMode = ShiftMode.BOTH;
        }
        length0 = int24(int16(uint16(bytes2(ldfParams << 24))));
        alpha0 = uint32(bytes4(ldfParams << 40));
        weight0 = uint32(bytes4(ldfParams << 72));
        length1 = int24(int16(uint16(bytes2(ldfParams << 104))));
        alpha1 = uint32(bytes4(ldfParams << 120));
        weight1 = uint32(bytes4(ldfParams << 152));

        alpha0X96 = alpha0.mulDiv(Q96, ALPHA_BASE);
        alpha1X96 = alpha1.mulDiv(Q96, ALPHA_BASE);

        // bound distribution to be within the range of usable ticks
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        if (minTick < minUsableTick) {
            minTick = minUsableTick;
        } else if (minTick > maxUsableTick - (length0 + length1) * tickSpacing) {
            minTick = maxUsableTick - (length0 + length1) * tickSpacing;
        }
    }
}
