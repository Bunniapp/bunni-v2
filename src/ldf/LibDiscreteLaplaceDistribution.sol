// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

import "./ShiftMode.sol";
import "../lib/Math.sol";
import "../lib/ExpMath.sol";
import "../lib/Constants.sol";

library LibDiscreteLaplaceDistribution {
    using TickMath for int24;
    using ExpMath for int256;
    using SafeCastLib for int256;
    using SafeCastLib for uint256;
    using FixedPointMathLib for int256;
    using FixedPointMathLib for uint160;
    using FixedPointMathLib for uint256;

    uint256 internal constant MIN_ALPHA = 1e14;
    uint256 internal constant MAX_ALPHA = 0.9e18;

    function query(int24 roundedTick, int24 tickSpacing, int24 mu, uint256 alphaX96)
        internal
        pure
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        (int24 minTick, int24 maxTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing) - tickSpacing);
        uint256 totalDensityX96 = _totalDensityX96(alphaX96, mu, minTick, maxTick, tickSpacing);

        // compute liquidityDensityX96
        liquidityDensityX96_ =
            alphaX96.rpow(FixedPointMathLib.abs((roundedTick - mu) / tickSpacing), Q96).mulDiv(Q96, totalDensityX96);

        // compute cumulativeAmount0DensityX96 for the rounded tick to the right of the rounded current tick
        {
            uint256 sqrtRatioNegTickSpacing = (-tickSpacing).getSqrtRatioAtTick();
            uint256 c = Q96 - sqrtRatioNegTickSpacing;
            int24 roundedTickRight = roundedTick + tickSpacing;
            if (roundedTick < mu) {
                uint256 sqrtRatioNegMu = (-mu).getSqrtRatioAtTick();
                (bool term1DenominatorIsPositive, uint256 term1Denominator) = absDiff(alphaX96, sqrtRatioNegTickSpacing);
                uint256 term1Left = (-roundedTickRight).getSqrtRatioAtTick().mulDiv(
                    alphaX96.rpow(uint256(int256((mu - roundedTickRight) / tickSpacing)) + 1, Q96), term1Denominator
                );
                uint256 term1Right = sqrtRatioNegMu.mulDiv(alphaX96, term1Denominator);
                (bool term1NumeratorIsPositive, uint256 term1) = absDiff(term1Left, term1Right);
                uint256 term2 = sqrtRatioNegMu.mulDiv(Q96, Q96 - sqrtRatioNegTickSpacing.mulDiv(alphaX96, Q96));
                if (term1DenominatorIsPositive == term1NumeratorIsPositive) {
                    cumulativeAmount0DensityX96 = c.mulDiv(term1 + term2, totalDensityX96);
                } else {
                    cumulativeAmount0DensityX96 = c.mulDiv(term2 - term1, totalDensityX96);
                }
            } else {
                uint256 numerator = (-roundedTickRight).getSqrtRatioAtTick().mulDiv(
                    alphaX96.rpow(uint256(int256((roundedTickRight - mu) / tickSpacing)), Q96), totalDensityX96
                );
                uint256 denominator = Q96 - sqrtRatioNegTickSpacing.mulDiv(alphaX96, Q96);
                cumulativeAmount0DensityX96 = c.mulDiv(numerator, denominator);
            }
        }

        // compute cumulativeAmount1DensityX96 for the rounded tick to the left of the rounded current tick
        {
            uint256 sqrtRatioTickSpacing = tickSpacing.getSqrtRatioAtTick();
            uint256 c = sqrtRatioTickSpacing - Q96;
            int24 roundedTickLeft = roundedTick - tickSpacing;

            if (roundedTickLeft < mu) {
                uint256 term1 = roundedTick.getSqrtRatioAtTick().mulDiv(
                    alphaX96.rpow(uint256(int256((mu - roundedTickLeft) / tickSpacing)), Q96),
                    sqrtRatioTickSpacing - alphaX96
                );
                cumulativeAmount1DensityX96 = c.mulDiv(term1, totalDensityX96);
            } else {
                uint256 sqrtRatioMu = mu.getSqrtRatioAtTick();
                uint256 denominatorSub = sqrtRatioTickSpacing.mulDiv(alphaX96, Q96);
                (bool denominatorIsPositive, uint256 denominator) = absDiff(Q96, denominatorSub);
                uint256 x = alphaX96.mulDiv(sqrtRatioMu, sqrtRatioTickSpacing - alphaX96);
                uint256 y = sqrtRatioMu.mulDiv(Q96, denominator);
                uint256 z = roundedTick.getSqrtRatioAtTick().mulDiv(
                    alphaX96.rpow(uint256(int256((roundedTick - mu) / tickSpacing)), Q96), denominator
                );
                if (denominatorIsPositive) {
                    if (x + y < z) cumulativeAmount1DensityX96 = 0;
                    else cumulativeAmount1DensityX96 = c.mulDiv(x + y - z, totalDensityX96);
                } else {
                    if (x + z < y) cumulativeAmount1DensityX96 = 0;
                    else cumulativeAmount1DensityX96 = c.mulDiv(x + z - y, totalDensityX96);
                }
            }
        }
    }

    function cumulativeAmount0(int24 roundedTick, uint256 totalLiquidity, int24 tickSpacing, int24 mu, uint256 alphaX96)
        internal
        pure
        returns (uint256 amount0)
    {
        (int24 minTick, int24 maxTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing) - tickSpacing);
        uint256 totalDensityX96 = _totalDensityX96(alphaX96, mu, minTick, maxTick, tickSpacing);

        uint256 cumulativeAmount0DensityX96;

        // compute cumulativeAmount0DensityX96 for the rounded tick
        {
            uint256 sqrtRatioNegTickSpacing = (-tickSpacing).getSqrtRatioAtTick();
            uint256 c = Q96 - sqrtRatioNegTickSpacing;
            if (roundedTick < mu + tickSpacing) {
                uint256 sqrtRatioNegMu = (-mu).getSqrtRatioAtTick();
                (bool term1DenominatorIsPositive, uint256 term1Denominator) = absDiff(alphaX96, sqrtRatioNegTickSpacing);
                uint256 term1Left = (-roundedTick).getSqrtRatioAtTick().mulDiv(
                    alphaX96.rpow(uint256(int256((mu - roundedTick) / tickSpacing)) + 1, Q96), term1Denominator
                );
                uint256 term1Right = sqrtRatioNegMu.mulDiv(alphaX96, term1Denominator);
                (bool term1NumeratorIsPositive, uint256 term1) = absDiff(term1Left, term1Right);
                uint256 term2 = sqrtRatioNegMu.mulDiv(Q96, Q96 - sqrtRatioNegTickSpacing.mulDiv(alphaX96, Q96));
                if (term1DenominatorIsPositive == term1NumeratorIsPositive) {
                    cumulativeAmount0DensityX96 = c.mulDiv(term1 + term2, totalDensityX96);
                } else {
                    cumulativeAmount0DensityX96 = c.mulDiv(term2 - term1, totalDensityX96);
                }
            } else {
                uint256 numerator = (-roundedTick).getSqrtRatioAtTick().mulDiv(
                    alphaX96.rpow(uint256(int256((roundedTick - mu) / tickSpacing)), Q96), totalDensityX96
                );
                uint256 denominator = Q96 - sqrtRatioNegTickSpacing.mulDiv(alphaX96, Q96);
                cumulativeAmount0DensityX96 = c.mulDiv(numerator, denominator);
            }
        }

        amount0 = cumulativeAmount0DensityX96.mulDiv(totalLiquidity, Q96);
    }

    function cumulativeAmount1(int24 roundedTick, uint256 totalLiquidity, int24 tickSpacing, int24 mu, uint256 alphaX96)
        internal
        pure
        returns (uint256 amount1)
    {
        (int24 minTick, int24 maxTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing) - tickSpacing);
        uint256 totalDensityX96 = _totalDensityX96(alphaX96, mu, minTick, maxTick, tickSpacing);

        uint256 cumulativeAmount1DensityX96;

        // compute cumulativeAmount1DensityX96 for the rounded tick
        {
            uint256 sqrtRatioTickSpacing = tickSpacing.getSqrtRatioAtTick();
            uint256 c = sqrtRatioTickSpacing - Q96;
            if (roundedTick < mu) {
                uint256 term1 = roundedTick.getSqrtRatioAtTick().mulDiv(
                    alphaX96.rpow(uint256(int256((mu - roundedTick) / tickSpacing)), Q96),
                    sqrtRatioTickSpacing - alphaX96
                );
                cumulativeAmount1DensityX96 = c.mulDiv(term1, totalDensityX96);
            } else {
                uint256 sqrtRatioMu = mu.getSqrtRatioAtTick();
                uint256 denominatorSub = sqrtRatioTickSpacing.mulDiv(alphaX96, Q96);
                (bool denominatorIsPositive, uint256 denominator) = absDiff(Q96, denominatorSub);
                uint256 x = alphaX96.mulDiv(sqrtRatioMu, sqrtRatioTickSpacing - alphaX96);
                uint256 y = sqrtRatioMu.mulDiv(Q96, denominator);
                uint256 z = (roundedTick + tickSpacing).getSqrtRatioAtTick().mulDiv(
                    alphaX96.rpow(uint256(int256((roundedTick + tickSpacing - mu) / tickSpacing)), Q96), denominator
                );
                if (denominatorIsPositive) {
                    if (x + y < z) cumulativeAmount1DensityX96 = 0;
                    else cumulativeAmount1DensityX96 = c.mulDiv(x + y - z, totalDensityX96);
                } else {
                    if (x + z < y) cumulativeAmount1DensityX96 = 0;
                    else cumulativeAmount1DensityX96 = c.mulDiv(x + z - y, totalDensityX96);
                }
            }
        }

        amount1 = cumulativeAmount1DensityX96.mulDiv(totalLiquidity, Q96);
    }

    function inverseCumulativeAmount0(
        uint256 cumulativeAmount0_,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 mu,
        uint256 alphaX96,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        uint256 cumulativeAmount0DensityX96 = cumulativeAmount0_.mulDiv(Q96, totalLiquidity);

        (int24 minTick, int24 maxTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing) - tickSpacing);
        uint256 totalDensityX96 = _totalDensityX96(alphaX96, mu, minTick, maxTick, tickSpacing);
        uint256 sqrtRatioNegTickSpacing = (-tickSpacing).getSqrtRatioAtTick();
        uint256 sqrtRatioNegMu = (-mu).getSqrtRatioAtTick();
        uint256 baseX96 = alphaX96.mulDiv(sqrtRatioNegTickSpacing, Q96);

        int256 xWad; // x = (roundedTick - mu) / tickSpacing
        {
            uint256 c = Q96 - sqrtRatioNegTickSpacing;

            // compute x assuming roundedTick >= mu + tickSpacing, i.e. x >= 1
            {
                int256 lnBaseX96 = int256(baseX96).lnQ96(); // int256 conversion is safe since baseX96 < Q96
                uint256 denominator = Q96 - sqrtRatioNegTickSpacing.mulDiv(alphaX96, Q96);
                uint256 numerator = cumulativeAmount0DensityX96.mulDiv(denominator, c);
                xWad = numerator.mulDiv(totalDensityX96, sqrtRatioNegMu).toInt256().lnQ96().sDivWad(lnBaseX96);
            }

            // console2.log("xWadFirst", xWad);

            // if the resulting x < 1, then compute x assuming roundedTick < mu + tickSpacing, i.e. x < 1
            if (xWad < int256(WAD)) {
                uint256 tmp = cumulativeAmount0DensityX96.mulDiv(totalDensityX96, c);
                // console2.log("tmp", tmp);
                uint256 term2 = sqrtRatioNegMu.mulDiv(Q96, Q96 - sqrtRatioNegTickSpacing.mulDiv(alphaX96, Q96));
                // console2.log("term2", term2);
                uint256 term1 = dist(tmp, term2);
                // console2.log("term1", term1);
                (bool term1DenominatorIsPositive, uint256 term1Denominator) = absDiff(alphaX96, sqrtRatioNegTickSpacing);
                // console2.log("alphaX96", alphaX96);
                // console2.log("sqrtRatioNegTickSpacing", sqrtRatioNegTickSpacing);
                // console2.log("term1Denominator", term1Denominator);
                uint256 term1Right = sqrtRatioNegMu.mulDiv(alphaX96, term1Denominator);
                // console2.log("term1Right", term1Right);
                bool term1NumeratorIsPositive = term1DenominatorIsPositive && tmp > term2;

                if (!term1NumeratorIsPositive && term1 > term1Right) {
                    return (false, 0);
                }

                uint256 term1Left = term1NumeratorIsPositive ? term1Right + term1 : term1Right - term1;
                // console2.log("term1Left", term1Left);
                xWad = term1Left.mulDiv(term1Denominator, alphaX96.mulDiv(sqrtRatioNegMu, Q96)).toInt256().lnQ96()
                    .sDivWad(int256(sqrtRatioNegTickSpacing.mulDiv(Q96, alphaX96)).lnQ96());
            }
        }

        // round xWad to reduce error
        // limits tick precision to 1e-6 of a rounded tick
        uint256 remainder = (xWad % 1e12).abs();
        xWad = (xWad / 1e12) * 1e12; // clear everything beyond 6 decimals
        // if (remainder > 5e11) xWad += 1e12;
        assembly {
            xWad := add(mul(mul(gt(remainder, 500000000000), 1000000000000), sub(mul(sgt(xWad, 0), 2), 1)), xWad) // round towards infinity if remainder > 0.5
        }

        // get rounded tick from xWad
        success = true;
        roundedTick = xWadToRoundedTick(xWad, mu, tickSpacing, roundUp);

        // console2.log("xWad", xWad);
        // console2.log("roundedTick", roundedTick);
    }

    function inverseCumulativeAmount1(
        uint256 cumulativeAmount1_,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 mu,
        uint256 alphaX96,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        uint256 cumulativeAmount1DensityX96 = cumulativeAmount1_.mulDiv(Q96, totalLiquidity);

        (int24 minTick, int24 maxTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing) - tickSpacing);
        uint256 totalDensityX96 = _totalDensityX96(alphaX96, mu, minTick, maxTick, tickSpacing);
        uint256 sqrtRatioTickSpacing = tickSpacing.getSqrtRatioAtTick();
        uint256 baseX96 = alphaX96.mulDiv(sqrtRatioTickSpacing, Q96);

        int256 xWad; // x = (roundedTick - mu) / tickSpacing
        {
            uint256 c = sqrtRatioTickSpacing - Q96;

            // compute x assuming roundedTick <= mu, i.e. x <= 0
            {
                uint256 term1 = cumulativeAmount1DensityX96.mulDiv(totalDensityX96, c);
                xWad = -term1.mulDiv(sqrtRatioTickSpacing - alphaX96, (mu + tickSpacing).getSqrtRatioAtTick()).toInt256().lnQ96(
                ).sDivWad(int256(alphaX96.mulDiv(Q96, sqrtRatioTickSpacing)).lnQ96());
            }

            // console2.log("xWadFirst", xWad);

            // if the resulting x > 0, then compute x assuming roundedTick > mu, i.e. x > 0
            if (xWad > 0) {
                uint256 sqrtRatioMu = mu.getSqrtRatioAtTick();

                (bool denominatorIsPositive, uint256 denominator) = absDiff(Q96, baseX96);
                uint256 x = alphaX96.mulDiv(sqrtRatioMu, sqrtRatioTickSpacing - alphaX96);
                // console2.log("x", x);
                uint256 y = sqrtRatioMu.mulDiv(Q96, denominator);
                // console2.log("y", y);
                uint256 yzDist = cumulativeAmount1DensityX96.mulDiv(totalDensityX96, c) - x;
                // console2.log("yzDist", yzDist);
                if (denominatorIsPositive && y < yzDist) return (false, 0);
                uint256 z = denominatorIsPositive ? y - yzDist : y + yzDist;
                // console2.log("z", z);
                // console2.log("ln input", z.mulDiv(denominator, sqrtRatioMu));
                xWad =
                    z.mulDiv(denominator, sqrtRatioMu).toInt256().lnQ96().sDivWad(int256(baseX96).lnQ96()) - int256(WAD);
            }
        }

        // round xWad to reduce error
        // limits tick precision to 1e-6 of a rounded tick
        uint256 remainder = (xWad % 1e12).abs();
        xWad = (xWad / 1e12) * 1e12; // clear everything beyond 6 decimals
        // if (remainder > 5e11) xWad += 1e12;
        assembly {
            xWad := add(mul(mul(gt(remainder, 500000000000), 1000000000000), sub(mul(sgt(xWad, 0), 2), 1)), xWad) // round towards infinity if remainder > 0.5
        }

        // get rounded tick from xWad
        success = true;
        roundedTick = xWadToRoundedTick(xWad, mu, tickSpacing, roundUp);

        // console2.log("xWad", xWad);
        // console2.log("roundedTick", roundedTick);
    }

    function liquidityDensityX96(int24 roundedTick, int24 tickSpacing, int24 mu, uint256 alphaX96)
        internal
        pure
        returns (uint256)
    {
        uint256 totalDensityX96 = _totalDensityX96(
            alphaX96,
            mu,
            TickMath.minUsableTick(tickSpacing),
            TickMath.maxUsableTick(tickSpacing) - tickSpacing,
            tickSpacing
        );
        return alphaX96.rpow(FixedPointMathLib.abs((roundedTick - mu) / tickSpacing), Q96).mulDiv(Q96, totalDensityX96);
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams) internal pure returns (bool) {
        uint256 alpha;
        if (twapSecondsAgo != 0) {
            // use rounded TWAP value as mu
            // | alpha - 8 bytes |
            alpha = uint256(uint64(bytes8(ldfParams)));
        } else {
            // static mu set in params
            // | mu - 3 bytes | alpha - 8 bytes |
            int24 mu = int24(uint24(bytes3(ldfParams)));
            alpha = uint256(uint64(bytes8(ldfParams << 24)));

            // ensure mu is aligned to tickSpacing
            if (mu % tickSpacing != 0) return false;
        }

        // ensure alpha is in range
        if (alpha < MIN_ALPHA || alpha > MAX_ALPHA) return false;

        // if all conditions are met, return true
        return true;
    }

    function computeSwap(
        uint256 inverseCumulativeAmountInput,
        uint256 totalLiquidity,
        bool zeroForOne,
        bool exactIn,
        int24 tickSpacing,
        int24 mu,
        uint256 alphaX96
    ) internal pure returns (bool success, int24 roundedTick, uint256 cumulativeAmount, uint128 swapLiquidity) {
        // compute roundedTick by inverting the cumulative amount
        (success, roundedTick) = ((exactIn == zeroForOne) ? inverseCumulativeAmount0 : inverseCumulativeAmount1)(
            inverseCumulativeAmountInput, totalLiquidity, tickSpacing, mu, alphaX96, true
        );
        if (!success) return (false, 0, 0, 0);

        // compute the cumulative amount up to roundedTick
        cumulativeAmount = (exactIn == zeroForOne)
            ? cumulativeAmount0(roundedTick, totalLiquidity, tickSpacing, mu, alphaX96)
            : cumulativeAmount1(roundedTick - tickSpacing, totalLiquidity, tickSpacing, mu, alphaX96);

        // compute liquidity of the rounded tick that will handle the remainder of the swap
        swapLiquidity = (
            (
                liquidityDensityX96(zeroForOne ? roundedTick - tickSpacing : roundedTick, tickSpacing, mu, alphaX96)
                    * totalLiquidity
            ) >> 96
        ).toUint128();
    }

    /// @return mu Center of the distribution
    /// @return alphaX96 Parameter of the discrete laplace distribution, FixedPoint96
    function decodeParams(int24 twapTick, int24 tickSpacing, bool useTwap, bytes32 ldfParams)
        internal
        pure
        returns (int24 mu, uint256 alphaX96, ShiftMode shiftMode)
    {
        uint256 alpha;
        if (useTwap) {
            // use rounded TWAP value as mu
            // | alpha - 8 bytes | shiftMode - 1 byte |
            mu = roundTickSingle(twapTick, tickSpacing);
            alpha = uint256(uint64(bytes8(ldfParams)));
            shiftMode = ShiftMode(uint8(bytes1(ldfParams << 64)));
        } else {
            // static mu set in params
            // | mu - 3 bytes | alpha - 8 bytes |
            mu = int24(uint24(bytes3(ldfParams)));
            alpha = uint256(uint64(bytes8(ldfParams << 24)));
            shiftMode = ShiftMode.BOTH;
        }
        alphaX96 = alpha.mulDiv(Q96, WAD);
    }

    function _totalDensityX96(uint256 alphaX96, int24 mu, int24 minTick, int24 maxTick, int24 tickSpacing)
        private
        pure
        returns (uint256)
    {
        return alphaX96.mulDiv(
            Q96 + Q96.mulDiv(Q96, alphaX96) - alphaX96.rpow(uint256(int256((mu - minTick) / tickSpacing)), Q96)
                - alphaX96.rpow(uint256(int256((maxTick - mu) / tickSpacing)), Q96),
            Q96 - alphaX96
        );
    }
}
