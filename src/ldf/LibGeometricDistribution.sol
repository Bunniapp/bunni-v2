// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

import "./ShiftMode.sol";
import "../lib/Math.sol";
import "../lib/ExpMath.sol";
import "../lib/Constants.sol";

library LibGeometricDistribution {
    using TickMath for int24;
    using ExpMath for int256;
    using SafeCastLib for int256;
    using SafeCastLib for uint256;
    using FixedPointMathLib for int256;
    using FixedPointMathLib for uint160;
    using FixedPointMathLib for uint256;

    uint256 internal constant ALPHA_BASE = 1e8; // alpha uses 8 decimals in ldfParams
    uint256 internal constant MIN_ALPHA = 1e3;
    uint256 internal constant MAX_ALPHA = 12e8;
    uint256 internal constant MIN_LIQUIDITY_DENSITY = Q96 / 1e3;

    /// @dev Queries the liquidity density and the cumulative amounts at the given rounded tick.
    /// @param roundedTick The rounded tick to query
    /// @param tickSpacing The spacing of the ticks
    /// @return liquidityDensityX96_ The liquidity density at the given rounded tick. Range is [0, 1]. Scaled by 2^96.
    /// @return cumulativeAmount0DensityX96 The cumulative amount of token0 in the rounded ticks [roundedTick + tickSpacing, minTick + length * tickSpacing)
    /// @return cumulativeAmount1DensityX96 The cumulative amount of token1 in the rounded ticks [minTick, roundedTick - tickSpacing]
    function query(int24 roundedTick, int24 tickSpacing, int24 minTick, int24 length, uint256 alphaX96)
        internal
        pure
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        // compute liquidityDensityX96
        liquidityDensityX96_ = liquidityDensityX96(roundedTick, tickSpacing, minTick, length, alphaX96);

        // x is the index of the roundedTick in the distribution
        // should be in the range [0, length)
        int24 x;
        if (roundedTick < minTick) {
            // roundedTick is to the left of the distribution
            // set x = -1
            x = -1;
        } else if (roundedTick >= minTick + length * tickSpacing) {
            // roundedTick is to the right of the distribution
            // set x = length
            x = length;
        } else {
            // roundedTick is in the distribution
            x = (roundedTick - minTick) / tickSpacing;
        }

        uint256 sqrtRatioTickSpacing = tickSpacing.getSqrtRatioAtTick();
        uint256 sqrtRatioNegTickSpacing = (-tickSpacing).getSqrtRatioAtTick();
        uint256 sqrtRatioMinTick = minTick.getSqrtRatioAtTick();
        uint256 sqrtRatioNegMinTick = (-minTick).getSqrtRatioAtTick();

        if (alphaX96 > Q96) {
            // alpha > 1
            // need to make sure that alpha^x doesn't overflow by using alpha^-1 during exponentiation
            uint256 alphaInvX96 = Q96.mulDiv(Q96, alphaX96);

            // compute cumulativeAmount0DensityX96 for the rounded tick to the right of the rounded current tick
            if (x >= length - 1) {
                // roundedTick is the last tick in the distribution
                // cumulativeAmount0DensityX96 is just 0
                cumulativeAmount0DensityX96 = 0;
            } else {
                int24 xPlus1 = x + 1; // the rounded tick to the right of the current rounded tick

                uint256 numerator = dist(
                    alphaInvX96.rpow(uint24(length - xPlus1), Q96),
                    (-tickSpacing * (length - xPlus1)).getSqrtRatioAtTick()
                ) * (-tickSpacing * xPlus1).getSqrtRatioAtTick();

                uint256 denominator = dist(Q96, alphaX96.mulDiv(sqrtRatioNegTickSpacing, Q96))
                    * (Q96 - alphaInvX96.rpow(uint24(length), Q96));

                cumulativeAmount0DensityX96 = (Q96 - sqrtRatioNegTickSpacing).fullMulDiv(numerator, denominator).mulDiv(
                    alphaX96 - Q96, sqrtRatioMinTick
                );
            }

            // compute cumulativeAmount1DensityX96 for the rounded tick to the left of the rounded current tick
            if (x <= 0) {
                // roundedTick is the first tick in the distribution
                // cumulativeAmount1DensityX96 is just 0
                cumulativeAmount1DensityX96 = 0;
            } else {
                uint256 alphaInvPowLengthX96 = alphaInvX96.rpow(uint24(length), Q96);

                uint256 baseX96 = alphaX96.mulDiv(sqrtRatioTickSpacing, Q96);
                uint256 numerator1 = alphaX96 - Q96;
                uint256 denominator1 = baseX96 - Q96;
                uint256 numerator2 = alphaInvX96.rpow(uint24(length - x), Q96).mulDiv(
                    (x * tickSpacing).getSqrtRatioAtTick(), Q96
                ) - alphaInvPowLengthX96;
                uint256 denominator2 = Q96 - alphaInvPowLengthX96;
                cumulativeAmount1DensityX96 = Q96.mulDiv(numerator1, denominator1).mulDiv(numerator2, denominator2)
                    .mulDiv(sqrtRatioTickSpacing - Q96, sqrtRatioNegMinTick);
            }
        } else {
            // alpha <= 1
            // will revert if alpha == 1 but that's ok

            // compute cumulativeAmount0DensityX96 for the rounded tick to the right of the rounded current tick
            if (x >= length - 1) {
                // roundedTick is the last tick in the distribution
                // cumulativeAmount0DensityX96 is just 0
                cumulativeAmount0DensityX96 = 0;
            } else {
                uint256 baseX96 = alphaX96.mulDiv(sqrtRatioNegTickSpacing, Q96);
                uint256 numerator =
                    (Q96 - alphaX96) * (baseX96.rpow(uint24(x + 1), Q96) - baseX96.rpow(uint24(length), Q96));
                uint256 denominator = (Q96 - alphaX96.rpow(uint24(length), Q96)) * (Q96 - baseX96);
                cumulativeAmount0DensityX96 =
                    (Q96 - sqrtRatioNegTickSpacing).fullMulDiv(numerator, denominator).mulDiv(Q96, sqrtRatioMinTick);
            }

            // compute cumulativeAmount1DensityX96 for the rounded tick to the left of the rounded current tick
            if (x <= 0) {
                // roundedTick is the first tick in the distribution
                // cumulativeAmount1DensityX96 is just 0
                cumulativeAmount1DensityX96 = 0;
            } else {
                uint256 baseX96 = alphaX96.mulDiv(sqrtRatioTickSpacing, Q96);
                uint256 numerator = dist(Q96, baseX96.rpow(uint24(x), Q96)) * (Q96 - alphaX96);
                uint256 denominator = dist(Q96, baseX96) * (Q96 - alphaX96.rpow(uint24(length), Q96));
                cumulativeAmount1DensityX96 =
                    (sqrtRatioTickSpacing - Q96).fullMulDiv(numerator, denominator).mulDiv(sqrtRatioMinTick, Q96);
            }
        }
    }

    /// @dev Computes the cumulative amount of token0 in the rounded ticks [roundedTick, tickUpper).
    function cumulativeAmount0(
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alphaX96
    ) internal pure returns (uint256 amount0) {
        uint256 cumulativeAmount0DensityX96;

        // x is the index of the roundedTick in the distribution
        // should be in the range [0, length)
        int24 x;
        if (roundedTick < minTick) {
            // roundedTick is to the left of the distribution
            x = 0;
        } else if (roundedTick >= minTick + length * tickSpacing) {
            // roundedTick is to the right of the distribution
            return 0;
        } else {
            // roundedTick is in the distribution
            x = (roundedTick - minTick) / tickSpacing;
        }

        uint256 sqrtRatioNegTickSpacing = (-tickSpacing).getSqrtRatioAtTick();
        uint256 sqrtRatioMinTick = minTick.getSqrtRatioAtTick();

        if (alphaX96 > Q96) {
            // alpha > 1
            // need to make sure that alpha^x doesn't overflow by using alpha^-1 during exponentiation
            uint256 alphaInvX96 = Q96.mulDiv(Q96, alphaX96);

            // compute cumulativeAmount0DensityX96 for the rounded tick to the right of the rounded current tick
            if (x >= length) {
                // roundedTick is to the right of the last tick in the distribution
                // cumulativeAmount0DensityX96 is just 0
                cumulativeAmount0DensityX96 = 0;
            } else {
                uint256 numerator = dist(
                    alphaInvX96.rpow(uint24(length - x), Q96), (-tickSpacing * (length - x)).getSqrtRatioAtTick()
                ) * (-tickSpacing * x).getSqrtRatioAtTick();

                uint256 denominator = dist(Q96, alphaX96.mulDiv(sqrtRatioNegTickSpacing, Q96))
                    * (Q96 - alphaInvX96.rpow(uint24(length), Q96));

                cumulativeAmount0DensityX96 = (Q96 - sqrtRatioNegTickSpacing).fullMulDiv(numerator, denominator).mulDiv(
                    alphaX96 - Q96, sqrtRatioMinTick
                );
            }
        } else {
            // alpha <= 1
            // will revert if alpha == 1 but that's ok

            // compute cumulativeAmount0DensityX96 for the rounded tick to the right of the rounded current tick
            if (x >= length) {
                // roundedTick is to the right of the last tick in the distribution
                // cumulativeAmount0DensityX96 is just 0
                cumulativeAmount0DensityX96 = 0;
            } else {
                uint256 baseX96 = alphaX96.mulDiv(sqrtRatioNegTickSpacing, Q96);
                uint256 numerator =
                    (Q96 - alphaX96) * (baseX96.rpow(uint24(x), Q96) - baseX96.rpow(uint24(length), Q96));
                uint256 denominator = (Q96 - alphaX96.rpow(uint24(length), Q96)) * (Q96 - baseX96);
                cumulativeAmount0DensityX96 =
                    (Q96 - sqrtRatioNegTickSpacing).fullMulDiv(numerator, denominator).mulDiv(Q96, sqrtRatioMinTick);
            }
        }

        amount0 = cumulativeAmount0DensityX96.mulDiv(totalLiquidity, Q96);
    }

    /// @dev Computes the cumulative amount of token1 in the rounded ticks [tickLower, roundedTick].
    function cumulativeAmount1(
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 minTick,
        int24 length,
        uint256 alphaX96
    ) internal pure returns (uint256 amount1) {
        uint256 cumulativeAmount1DensityX96;

        // x is the index of the roundedTick in the distribution
        // should be in the range [0, length)
        int24 x;
        if (roundedTick < minTick) {
            // roundedTick is to the left of the distribution
            return 0;
        } else if (roundedTick >= minTick + length * tickSpacing) {
            // roundedTick is to the right of the distribution
            // set x = length
            x = length - 1;
        } else {
            // roundedTick is in the distribution
            x = (roundedTick - minTick) / tickSpacing;
        }

        uint256 sqrtRatioTickSpacing = tickSpacing.getSqrtRatioAtTick();
        uint256 sqrtRatioMinTick = minTick.getSqrtRatioAtTick();
        uint256 sqrtRatioNegMinTick = (-minTick).getSqrtRatioAtTick();

        if (alphaX96 > Q96) {
            // alpha > 1
            // need to make sure that alpha^x doesn't overflow by using alpha^-1 during exponentiation
            uint256 alphaInvX96 = Q96.mulDiv(Q96, alphaX96);

            // compute cumulativeAmount1DensityX96 for the rounded tick to the left of the rounded current tick
            if (x < 0) {
                // roundedTick is to the left of the first tick in the distribution
                // cumulativeAmount1DensityX96 is just 0
                cumulativeAmount1DensityX96 = 0;
            } else {
                uint256 alphaInvPowLengthX96 = alphaInvX96.rpow(uint24(length), Q96);

                uint256 baseX96 = alphaX96.mulDiv(sqrtRatioTickSpacing, Q96);
                uint256 numerator1 = alphaX96 - Q96;
                uint256 denominator1 = baseX96 - Q96;
                uint256 numerator2 = alphaInvX96.rpow(uint24(length - x - 1), Q96).mulDiv(
                    ((x + 1) * tickSpacing).getSqrtRatioAtTick(), Q96
                ) - alphaInvPowLengthX96;
                uint256 denominator2 = Q96 - alphaInvPowLengthX96;
                cumulativeAmount1DensityX96 = Q96.mulDiv(numerator1, denominator1).mulDiv(numerator2, denominator2)
                    .mulDiv(sqrtRatioTickSpacing - Q96, sqrtRatioNegMinTick);
            }
        } else {
            // alpha <= 1
            // will revert if alpha == 1 but that's ok

            // compute cumulativeAmount1DensityX96 for the rounded tick to the left of the rounded current tick
            if (x < 0) {
                // roundedTick is to the left of the first tick in the distribution
                // cumulativeAmount1DensityX96 is just 0
                cumulativeAmount1DensityX96 = 0;
            } else {
                uint256 baseX96 = alphaX96.mulDiv(sqrtRatioTickSpacing, Q96);
                uint256 numerator = dist(Q96, baseX96.rpow(uint24(x + 1), Q96)) * (Q96 - alphaX96);
                uint256 denominator = dist(Q96, baseX96) * (Q96 - alphaX96.rpow(uint24(length), Q96));
                cumulativeAmount1DensityX96 =
                    (sqrtRatioTickSpacing - Q96).fullMulDiv(numerator, denominator).mulDiv(sqrtRatioMinTick, Q96);
            }
        }

        amount1 = cumulativeAmount1DensityX96.mulDiv(totalLiquidity, Q96);
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
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        uint256 cumulativeAmount0DensityX96 = cumulativeAmount0_.mulDiv(Q96, totalLiquidity);
        if (cumulativeAmount0DensityX96 == 0) {
            // return right boundary of distribution
            return (true, minTick + length * tickSpacing);
        }

        uint256 sqrtRatioNegTickSpacing = (-tickSpacing).getSqrtRatioAtTick();
        uint256 sqrtRatioMinTick = minTick.getSqrtRatioAtTick();
        uint256 baseX96 = alphaX96.mulDiv(sqrtRatioNegTickSpacing, Q96);
        int256 lnBaseX96 = int256(baseX96).lnQ96(); // int256 conversion is safe since baseX96 < Q96

        int256 xWad;
        if (alphaX96 > Q96) {
            // alpha > 1
            // need to make sure that alpha^x doesn't overflow by using alpha^-1 during exponentiation
            uint256 alphaInvX96 = Q96.mulDiv(Q96, alphaX96);

            uint256 alphaInvPowLengthX96 = alphaInvX96.rpow(uint24(length), Q96);
            uint256 denominator = dist(Q96, baseX96) * (Q96 - alphaInvPowLengthX96);
            uint256 numerator = cumulativeAmount0DensityX96.mulDiv(sqrtRatioMinTick, alphaX96 - Q96).fullMulDiv(
                denominator, Q96 - sqrtRatioNegTickSpacing
            );
            uint256 sqrtRatioNegTickSpacingMulLength = (-tickSpacing * length).getSqrtRatioAtTick();
            uint256 tmp0 = sqrtRatioNegTickSpacingMulLength << 96;
            if (Q96 <= baseX96 && tmp0 < numerator) return (false, 0);
            uint256 tmpX96 = ((Q96 >= baseX96 ? tmp0 + numerator : tmp0 - numerator) >> 96);
            xWad = (tmpX96.toInt256().lnQ96() + int256(length) * int256(alphaX96).lnQ96()).sDivWad(lnBaseX96);
        } else {
            uint256 denominator = (Q96 - alphaX96.rpow(uint24(length), Q96)) * (Q96 - baseX96);
            uint256 numerator = cumulativeAmount0DensityX96.mulDiv(sqrtRatioMinTick, Q96).fullMulDiv(
                denominator, Q96 - sqrtRatioNegTickSpacing
            );
            uint256 basePowXX96 = (numerator / (Q96 - alphaX96) + baseX96.rpow(uint24(length), Q96));
            xWad = basePowXX96.toInt256().lnQ96().sDivWad(lnBaseX96);
        }

        // round xWad to reduce error
        // limits tick precision to 1e-6 of a rounded tick
        int256 remainder = xWad % 1e12;
        xWad = (xWad / 1e12) * 1e12; // clear everything beyond 9 decimals
        // if (remainder > 5e11) xWad += 1e12;
        assembly {
            xWad := add(mul(sgt(remainder, 500000000000), 1000000000000), xWad) // round up if remainder > 0.5
        }

        console2.log("xWad: %d", xWad);

        // get rounded tick from xWad
        success = true;
        roundedTick = xWadToRoundedTick(xWad, minTick, tickSpacing, roundUp);

        // ensure roundedTick is within the valid range
        if (roundedTick < minTick || roundedTick > minTick + length * tickSpacing) {
            return (false, 0);
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
        int24 length,
        uint256 alphaX96,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        uint256 cumulativeAmount1DensityX96 = cumulativeAmount1_.fullMulDiv(Q96, totalLiquidity);
        if (cumulativeAmount1DensityX96 == 0) {
            // return left boundary of distribution
            return (true, minTick - tickSpacing);
        }

        uint256 sqrtRatioTickSpacing = tickSpacing.getSqrtRatioAtTick();
        uint256 sqrtRatioNegMinTick = (-minTick).getSqrtRatioAtTick();
        uint256 baseX96 = alphaX96.mulDiv(sqrtRatioTickSpacing, Q96);
        int256 lnBaseX96 = int256(baseX96).lnQ96(); // int256 conversion is safe since baseX96 < Q96

        int256 xWad;
        if (alphaX96 > Q96) {
            // alpha > 1
            // need to make sure that alpha^x doesn't overflow by using alpha^-1 during exponentiation
            uint256 alphaInvX96 = Q96.mulDiv(Q96, alphaX96);
            uint256 alphaInvPowLengthX96 = alphaInvX96.rpow(uint24(length), Q96);

            uint256 numerator1 = alphaX96 - Q96;
            uint256 denominator1 = baseX96 - Q96;
            uint256 denominator2 = Q96 - alphaInvPowLengthX96;
            uint256 numerator2 = cumulativeAmount1DensityX96.fullMulDiv(denominator1, numerator1).fullMulDiv(
                denominator2, sqrtRatioTickSpacing - Q96
            ).fullMulDiv(sqrtRatioNegMinTick, Q96);
            if (numerator2 + alphaInvPowLengthX96 == 0) return (false, 0);
            xWad = ((numerator2 + alphaInvPowLengthX96).toInt256().lnQ96() + int256(length) * int256(alphaX96).lnQ96())
                .sDivWad(lnBaseX96) - int256(WAD);
        } else {
            uint256 denominator = dist(Q96, baseX96) * (Q96 - alphaX96.rpow(uint24(length), Q96));
            uint256 numerator = cumulativeAmount1DensityX96.fullMulDiv(denominator, Q96).fullMulDiv(
                sqrtRatioNegMinTick, sqrtRatioTickSpacing - Q96
            );
            if (Q96 > baseX96 && Q96 <= numerator / (Q96 - alphaX96)) return (false, 0);
            uint256 basePowXPlusOneX96 =
                Q96 > baseX96 ? Q96 - numerator / (Q96 - alphaX96) : Q96 + numerator / (Q96 - alphaX96);
            xWad = basePowXPlusOneX96.toInt256().lnQ96().sDivWad(lnBaseX96) - int256(WAD);
        }

        console2.log("xWad: %d", xWad);

        // round xWad to reduce error
        // limits tick precision to 1e-6 of a rounded tick
        uint256 remainder = (xWad % 1e12).abs();
        xWad = (xWad / 1e12) * 1e12; // clear everything beyond 6 decimals
        // if (remainder > 5e11) xWad += 1e12;
        assembly {
            xWad := add(mul(mul(gt(remainder, 500000000000), 1000000000000), sub(mul(sgt(xWad, 0), 2), 1)), xWad) // round towards infinity if remainder > 0.5
        }

        console2.log("xWad: %d", xWad);

        // get rounded tick from xWad
        success = true;
        roundedTick = xWadToRoundedTick(xWad, minTick, tickSpacing, roundUp);

        // ensure roundedTick is within the valid range
        if (roundedTick < minTick - tickSpacing || roundedTick >= minTick + length * tickSpacing) {
            return (false, 0);
        }
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams) internal pure returns (bool) {
        int24 minTick;
        int24 length = int24(int16(uint16(bytes2(ldfParams << 24))));
        uint256 alpha = uint32(bytes4(ldfParams << 40));
        if (twapSecondsAgo == 0) {
            // static minTick set in params
            // | minTick - 3 bytes | length - 2 bytes | alpha - 4 bytes |
            minTick = int24(uint24(bytes3(ldfParams))); // must be aligned to tickSpacing

            // ensure minTick is aligned to tickSpacing
            if (minTick % tickSpacing != 0) return false;
        }

        // ensure alpha is in range
        if (alpha < MIN_ALPHA || alpha > MAX_ALPHA || alpha == ALPHA_BASE) return false;

        // ensure length > 0
        if (length <= 0) return false;

        // ensure length can be contained between minUsableTick and maxUsableTick
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        if (length > maxUsableTick / tickSpacing || -length < minUsableTick / tickSpacing) return false;

        // ensure liquidity density is nowhere equal to zero
        // can check boundaries since function is monotonic
        uint256 alphaX96 = alpha.mulDiv(Q96, ALPHA_BASE);
        uint256 minLiquidityDensityX96;
        if (alpha > ALPHA_BASE) {
            // monotonically increasing
            // check left boundary
            minLiquidityDensityX96 = liquidityDensityX96(minTick, tickSpacing, minTick, length, alphaX96);
        } else {
            // monotonically decreasing
            // check right boundary
            minLiquidityDensityX96 =
                liquidityDensityX96(minTick + (length - 1) * tickSpacing, tickSpacing, minTick, length, alphaX96);
        }
        if (minLiquidityDensityX96 < MIN_LIQUIDITY_DENSITY) {
            return false;
        }

        // if all conditions are met, return true
        return true;
    }

    function liquidityDensityX96(int24 roundedTick, int24 tickSpacing, int24 minTick, int24 length, uint256 alphaX96)
        internal
        pure
        returns (uint256)
    {
        if (roundedTick < minTick || roundedTick >= minTick + length * tickSpacing) {
            // roundedTick is outside of the distribution
            return 0;
        }
        // x is the index of the roundedTick in the distribution
        // should be in the range [0, length)
        uint256 x = uint24((roundedTick - minTick) / tickSpacing);
        if (alphaX96 > Q96) {
            // alpha > 1
            // need to make sure that alpha^x doesn't overflow by using alpha^-1 during exponentiation
            uint256 alphaInvX96 = Q96.mulDiv(Q96, alphaX96);
            return alphaInvX96.rpow(uint24(length) - x, Q96).fullMulDiv(
                alphaX96 - Q96, Q96 - alphaInvX96.rpow(uint24(length), Q96)
            );
        } else {
            // alpha <= 1
            // will revert if alpha == 1 but that's ok
            return (Q96 - alphaX96).mulDiv(alphaX96.rpow(x, Q96), Q96 - alphaX96.rpow(uint24(length), Q96));
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
        uint256 alphaX96
    ) internal pure returns (bool success, int24 roundedTick, uint256 cumulativeAmount, uint128 swapLiquidity) {
        if (exactIn == zeroForOne) {
            // compute roundedTick by inverting the cumulative amount
            (success, roundedTick) = inverseCumulativeAmount0(
                inverseCumulativeAmountInput, totalLiquidity, tickSpacing, minTick, length, alphaX96, true
            );
            if (!success) return (false, 0, 0, 0);

            // compute the cumulative amount up to roundedTick
            cumulativeAmount = cumulativeAmount0(roundedTick, totalLiquidity, tickSpacing, minTick, length, alphaX96);

            // compute liquidity of the rounded tick that will handle the remainder of the swap
            swapLiquidity = (
                (
                    liquidityDensityX96(roundedTick - tickSpacing, tickSpacing, minTick, length, alphaX96)
                        * totalLiquidity
                ) >> 96
            ).toUint128();
        } else {
            // compute roundedTick by inverting the cumulative amount
            (success, roundedTick) = inverseCumulativeAmount1(
                inverseCumulativeAmountInput, totalLiquidity, tickSpacing, minTick, length, alphaX96, true
            );
            if (!success) return (false, 0, 0, 0);

            // compute the cumulative amount up to roundedTick
            cumulativeAmount =
                cumulativeAmount1(roundedTick - tickSpacing, totalLiquidity, tickSpacing, minTick, length, alphaX96);

            // compute liquidity of the rounded tick that will handle the remainder of the swap
            swapLiquidity = (
                (liquidityDensityX96(roundedTick, tickSpacing, minTick, length, alphaX96) * totalLiquidity) >> 96
            ).toUint128();
        }
    }

    /// @return minTick The minimum rounded tick of the distribution
    /// @return length The length of the distribution in number of rounded ticks (i.e. the number of ticks / tickSpacing)
    /// @return alphaX96 Parameter of the discrete laplace distribution, FixedPoint96
    function decodeParams(int24 twapTick, int24 tickSpacing, bool useTwap, bytes32 ldfParams)
        internal
        pure
        returns (int24 minTick, int24 length, uint256 alphaX96, ShiftMode shiftMode)
    {
        if (useTwap) {
            // use rounded TWAP value + offset as minTick
            // | offset - 3 bytes | length - 2 bytes | alpha - 4 bytes | shiftMode - 1 byte |
            int24 offset = int24(uint24(bytes3(ldfParams))); // the offset applied to the twap tick to get the minTick
            minTick = roundTickSingle(twapTick + offset * tickSpacing, tickSpacing);
            shiftMode = ShiftMode(uint8(bytes1(ldfParams << 72)));
        } else {
            // static minTick set in params
            // | minTick - 3 bytes | length - 2 bytes | alpha - 4 bytes |
            minTick = int24(uint24(bytes3(ldfParams))); // must be aligned to tickSpacing
            shiftMode = ShiftMode.BOTH;
        }
        length = int24(int16(uint16(bytes2(ldfParams << 24))));
        uint256 alpha = uint32(bytes4(ldfParams << 40));

        alphaX96 = alpha.mulDiv(Q96, ALPHA_BASE);

        // bound distribution to be within the range of usable ticks
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        if (minTick < minUsableTick) {
            minTick = minUsableTick;
        } else if (minTick > maxUsableTick - length * tickSpacing) {
            minTick = maxUsableTick - length * tickSpacing;
        }
    }
}
