// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

import "../lib/Math.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract BoundedDiscreteLaplaceDistribution is ILiquidityDensityFunction {
    using TickMath for int24;
    using SafeCastLib for int256;
    using FixedPointMathLib for uint160;
    using FixedPointMathLib for uint256;

    uint256 internal constant MIN_ALPHA = 1e2;
    uint256 internal constant MAX_ALPHA = 10e5;
    uint256 internal constant ALPHA_BASE = 1e5; // alpha uses 5 decimals in ldfParams
    uint256 internal constant Q96 = 0x1000000000000000000000000;
    uint256 internal constant Q120 = 0x1000000000000000000000000000000;

    function query(int24 roundedTick, int24 twapTick, int24 tickSpacing, bool useTwap, bytes32 ldfParams)
        external
        pure
        override
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        (int24 mu, int24 lengthLeft, int24 lengthRight, uint256 alphaX96) =
            _decodeParams(twapTick, tickSpacing, useTwap, ldfParams);
        (int24 minTick, int24 maxTick) = (mu - lengthLeft * tickSpacing, mu + lengthRight * tickSpacing);
        uint256 totalDensityX96 = _totalDensityX96(alphaX96, lengthLeft, lengthRight);

        // compute liquidityDensityX96
        if (roundedTick < minTick || roundedTick > maxTick) {
            liquidityDensityX96_ = 0;
        } else {
            liquidityDensityX96_ =
                alphaX96.rpow(abs((roundedTick - mu) / tickSpacing), Q96).mulDivDown(Q96, totalDensityX96);
        }

        // keep rounded tick within bounds for computing cumulative amounts
        if (roundedTick < minTick) {
            roundedTick = minTick - tickSpacing;
        } else if (roundedTick > maxTick) {
            roundedTick = maxTick + tickSpacing;
        }

        // compute cumulativeAmount0DensityX96 for the rounded tick to the right of the rounded current tick
        if (roundedTick < maxTick) {
            uint256 sqrtRatioNegTickSpacing = (-tickSpacing).getSqrtRatioAtTick();
            uint256 c = Q96 - sqrtRatioNegTickSpacing;
            int24 roundedTickRight = roundedTick + tickSpacing;

            if (alphaX96 < Q96) {
                // alpha < 1

                // correction term when the max tick cannot be approximated to infinity
                uint256 boundCorrectionTerm = alphaX96.rpow(uint24(lengthRight) + 1, Q96).mulDivDown(
                    (-maxTick - tickSpacing).getSqrtRatioAtTick(), Q96
                );

                if (roundedTick < mu) {
                    uint256 sqrtRatioNegMu = (-mu).getSqrtRatioAtTick();
                    (bool term1DenominatorIsPositive, uint256 term1Denominator) =
                        absDiff(alphaX96, sqrtRatioNegTickSpacing);
                    uint256 x = (-roundedTickRight).getSqrtRatioAtTick().mulDivDown(
                        alphaX96.rpow(uint256(int256((mu - roundedTickRight) / tickSpacing)) + 1, Q96), term1Denominator
                    );
                    uint256 y = sqrtRatioNegMu.mulDivDown(alphaX96, term1Denominator);
                    (bool term1NumeratorIsPositive, uint256 term1) = absDiff(x, y);
                    uint256 term2 = (sqrtRatioNegMu - boundCorrectionTerm).mulDivDown(
                        Q96, Q96 - sqrtRatioNegTickSpacing.mulDivDown(alphaX96, Q96)
                    );
                    if (
                        (term1DenominatorIsPositive && term1NumeratorIsPositive)
                            || (!term1DenominatorIsPositive && !term1NumeratorIsPositive)
                    ) {
                        cumulativeAmount0DensityX96 = c.mulDivDown(term1 + term2, totalDensityX96);
                    } else {
                        cumulativeAmount0DensityX96 = c.mulDivDown(term2 - term1, totalDensityX96);
                    }
                } else {
                    uint256 numerator = (-roundedTickRight).getSqrtRatioAtTick().mulDivDown(
                        alphaX96.rpow(uint256(int256((roundedTickRight - mu) / tickSpacing)), Q96), Q96
                    ) - boundCorrectionTerm;
                    uint256 denominator = Q96 - sqrtRatioNegTickSpacing.mulDivDown(alphaX96, Q96);
                    cumulativeAmount0DensityX96 = c.mulDivDown(numerator, denominator).mulDivDown(Q96, totalDensityX96);
                }
            } else {
                // alpha > 1
                // need to make sure that alpha^x doesn't overflow by using alpha^-1 during exponentiation

                uint256 alphaInvX96 = Q96.mulDivDown(Q96, alphaX96);

                // correction term when the max tick cannot be approximated to infinity
                uint256 boundCorrectionTerm = (-maxTick - tickSpacing).getSqrtRatioAtTick().mulDivDown(
                    Q96, alphaInvX96.rpow(uint24(lengthRight) + 1, Q96)
                );

                if (roundedTick < mu) {
                    uint256 sqrtRatioNegMu = (-mu).getSqrtRatioAtTick();

                    (bool term1DenominatorIsPositive, uint256 term1Denominator) =
                        absDiff(alphaX96, sqrtRatioNegTickSpacing);
                    term1Denominator = term1Denominator.mulDivDown(
                        Q96, alphaInvX96.rpow(uint256(int256((mu - roundedTickRight) / tickSpacing)) + 1, Q96)
                    );
                    uint256 x = (-roundedTickRight).getSqrtRatioAtTick().mulDivDown(Q96, term1Denominator);
                    uint256 y = sqrtRatioNegMu.mulDivDown(alphaX96, term1Denominator);
                    (bool term1NumeratorIsPositive, uint256 term1) = absDiff(x, y);

                    (bool term2DenominatorIsPositive, uint256 term2Denominator) =
                        absDiff(Q96, sqrtRatioNegTickSpacing.mulDivDown(alphaX96, Q96));
                    (bool term2NumeratorIsPositive, uint256 term2Numerator) =
                        absDiff(sqrtRatioNegMu, boundCorrectionTerm);

                    uint256 term2 = term2Numerator.mulDivDown(Q96, term2Denominator);
                    if (
                        (term1DenominatorIsPositive && term1NumeratorIsPositive)
                            || (!term1DenominatorIsPositive && !term1NumeratorIsPositive)
                    ) {
                        if (
                            (term2DenominatorIsPositive && term2NumeratorIsPositive)
                                || (!term2DenominatorIsPositive && !term2NumeratorIsPositive)
                        ) cumulativeAmount0DensityX96 = c.mulDivDown(term1 + term2, totalDensityX96);
                        else cumulativeAmount0DensityX96 = c.mulDivDown(term1 - term2, totalDensityX96);
                    } else {
                        cumulativeAmount0DensityX96 = c.mulDivDown(term2 - term1, totalDensityX96);
                    }
                } else {
                    uint256 numerator = (-roundedTickRight).getSqrtRatioAtTick().mulDivDown(
                        Q96, alphaInvX96.rpow(uint256(int256((roundedTickRight - mu) / tickSpacing)), Q96)
                    ) - boundCorrectionTerm;
                    uint256 denominator = Q96 - sqrtRatioNegTickSpacing.mulDivDown(alphaX96, Q96);
                    cumulativeAmount0DensityX96 = c.mulDivDown(numerator, denominator).mulDivDown(Q96, totalDensityX96);
                }
            }
        }

        // compute cumulativeAmount1DensityX96 for the rounded tick to the left of the rounded current tick
        if (roundedTick > minTick) {
            uint256 sqrtRatioTickSpacing = tickSpacing.getSqrtRatioAtTick();
            uint256 c = sqrtRatioTickSpacing - Q96;
            int24 roundedTickLeft = roundedTick - tickSpacing;

            if (alphaX96 < Q96) {
                // alpha < 1

                if (roundedTickLeft < mu) {
                    // correction term when the min tick cannot be approximated to negative infinity
                    uint256 term1Denominator = sqrtRatioTickSpacing - alphaX96;
                    uint256 boundCorrectionTerm = alphaX96.rpow(uint24(lengthLeft) + 1, Q96).mulDivDown(
                        minTick.getSqrtRatioAtTick(), term1Denominator
                    );

                    uint256 term1Numerator = roundedTick.getSqrtRatioAtTick().mulDivDown(
                        alphaX96.rpow(uint256(int256((mu - roundedTickLeft) / tickSpacing)), Q96), term1Denominator
                    ) - boundCorrectionTerm;

                    cumulativeAmount1DensityX96 = c.mulDivDown(term1Numerator, totalDensityX96);
                } else {
                    // correction term when the min tick cannot be approximated to negative infinity
                    uint256 xDenominator = sqrtRatioTickSpacing - alphaX96;
                    uint256 boundCorrectionTerm = alphaX96.rpow(uint24(lengthLeft) + 1, Q96).mulDivDown(
                        minTick.getSqrtRatioAtTick(), xDenominator
                    );

                    uint256 sqrtRatioMu = mu.getSqrtRatioAtTick();
                    uint256 denominatorSub = sqrtRatioTickSpacing.mulDivDown(alphaX96, Q96);
                    (bool denominatorIsPositive, uint256 denominator) = absDiff(Q96, denominatorSub);
                    uint256 x = sqrtRatioMu.mulDivDown(alphaX96, xDenominator) - boundCorrectionTerm;
                    uint256 y = sqrtRatioMu.mulDivDown(Q96, denominator);
                    uint256 z = roundedTick.getSqrtRatioAtTick().mulDivDown(
                        alphaX96.rpow(uint256(int256((roundedTick - mu) / tickSpacing)), Q96), denominator
                    );
                    if (denominatorIsPositive) {
                        cumulativeAmount1DensityX96 = c.mulDivDown(x + y - z, totalDensityX96);
                    } else {
                        cumulativeAmount1DensityX96 = c.mulDivDown(x + z - y, totalDensityX96);
                    }
                }
            } else {
                // alpha > 1
                // need to make sure that alpha^x doesn't overflow by using alpha^-1 during exponentiation

                uint256 alphaInvX96 = Q96.mulDivDown(Q96, alphaX96);

                if (roundedTickLeft < mu) {
                    // correction term when the min tick cannot be approximated to negative infinity
                    uint256 term1Denominator = (sqrtRatioTickSpacing - alphaX96);
                    uint256 boundCorrectionTerm = Q96.mulDivDown(
                        minTick.getSqrtRatioAtTick(),
                        term1Denominator.mulDivDown(alphaInvX96.rpow(uint24(lengthLeft) + 1, Q96), Q96)
                    );

                    uint256 term1Numerator = roundedTick.getSqrtRatioAtTick().mulDivDown(
                        Q96,
                        term1Denominator.mulDivDown(
                            alphaInvX96.rpow(uint256(int256((mu - roundedTickLeft) / tickSpacing)), Q96), Q96
                        )
                    ) - boundCorrectionTerm;

                    cumulativeAmount1DensityX96 = c.mulDivDown(term1Numerator, totalDensityX96);
                } else {
                    // correction term when the min tick cannot be approximated to negative infinity
                    uint256 xDenominator = sqrtRatioTickSpacing - alphaX96;
                    uint256 boundCorrectionTerm = Q96.mulDivDown(
                        minTick.getSqrtRatioAtTick(),
                        xDenominator.mulDivDown(alphaInvX96.rpow(uint24(lengthLeft) + 1, Q96), Q96)
                    );

                    uint256 sqrtRatioMu = mu.getSqrtRatioAtTick();
                    uint256 denominatorSub = sqrtRatioTickSpacing.mulDivDown(alphaX96, Q96);
                    (bool denominatorIsPositive, uint256 denominator) = absDiff(Q96, denominatorSub);
                    uint256 x = sqrtRatioMu.mulDivDown(alphaX96, xDenominator) - boundCorrectionTerm;
                    uint256 y = sqrtRatioMu.mulDivDown(Q96, denominator);
                    uint256 z = roundedTick.getSqrtRatioAtTick().mulDivDown(
                        Q96,
                        denominator.mulDivDown(
                            alphaInvX96.rpow(uint256(int256((roundedTick - mu) / tickSpacing)), Q96), Q96
                        )
                    );
                    if (denominatorIsPositive) {
                        cumulativeAmount1DensityX96 = c.mulDivDown(x + y - z, totalDensityX96);
                    } else {
                        cumulativeAmount1DensityX96 = c.mulDivDown(x + z - y, totalDensityX96);
                    }
                }
            }
        }
    }

    function liquidityDensityX96(int24 roundedTick, int24 twapTick, int24 tickSpacing, bool useTwap, bytes32 ldfParams)
        external
        pure
        override
        returns (uint256)
    {
        (int24 mu, int24 lengthLeft, int24 lengthRight, uint256 alphaX96) =
            _decodeParams(twapTick, tickSpacing, useTwap, ldfParams);
        if (roundedTick < mu - lengthLeft * tickSpacing || roundedTick > mu + lengthRight * tickSpacing) {
            return 0;
        }

        uint256 x = abs((roundedTick - mu) / tickSpacing);
        if (alphaX96 < Q96) {
            uint256 totalDensityX96 = _totalDensityX96(alphaX96, lengthLeft, lengthRight);
            return alphaX96.rpow(x, Q96).mulDivDown(Q96, totalDensityX96);
        } else {
            uint256 alphaInvX120 = Q120.mulDivDown(Q96, alphaX96);

            /**
             *        alpha^(-(lengthLeft + lengthRight - x)) * (alpha - 1)
             * d(x) = --------------------------------------------------------------------------------------------------------
             *        alpha * (alpha^(-lengthLeft) + alpha^(-lengthRight)) - (alpha + 1) * alpha^(-(lengthLeft + lengthRight))
             */
            uint256 tmp = alphaInvX120.rpow(uint24(lengthLeft + lengthRight), Q120);
            uint256 numerator = alphaInvX120.rpow(uint24(lengthLeft + lengthRight) - x, Q120);
            uint256 denominator = (
                alphaInvX120.rpow(uint24(lengthLeft), Q120) + alphaInvX120.rpow(uint24(lengthRight), Q120) - tmp
            ).mulDivDown(alphaX96, Q96) - tmp;
            return (alphaX96 - Q96).mulDivDown(numerator, denominator);
        }
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        uint256 alpha;
        int24 lengthLeft;
        int24 lengthRight;
        if (twapSecondsAgo != 0) {
            // use rounded TWAP value + offset as mu
            // | offset - 1 byte | lengthLeft - 2 bytes | lengthRight - 2 bytes | alpha - 3 bytes |
            lengthLeft = int24(uint24(uint16(bytes2(ldfParams << 8))));
            lengthRight = int24(uint24(uint16(bytes2(ldfParams << 24))));
            alpha = uint24(bytes3(ldfParams << 40));
        } else {
            // static mu set in params
            // | mu - 3 bytes | lengthLeft - 2 bytes | lengthRight - 2 bytes | alpha - 3 bytes | 0 - 1 byte |
            int24 mu = int24(uint24(bytes3(ldfParams)));
            lengthLeft = int24(uint24(uint16(bytes2(ldfParams << 24))));
            lengthRight = int24(uint24(uint16(bytes2(ldfParams << 40))));
            alpha = uint24(bytes3(ldfParams << 56));

            // ensure mu is aligned to tickSpacing
            if (mu % tickSpacing != 0) return false;
        }

        // ensure alpha is in range
        // must not be 1 since all liquidity density would be 0
        if (alpha < MIN_ALPHA || alpha > MAX_ALPHA || alpha == ALPHA_BASE) return false;

        // ensure length can be contained between minUsableTick and maxUsableTick
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        if ((lengthLeft + lengthRight + 1) * tickSpacing > maxUsableTick - minUsableTick) return false;

        // if all conditions are met, return true
        return true;
    }

    function _totalDensityX96(uint256 alphaX96, int24 lengthLeft, int24 lengthRight) internal pure returns (uint256) {
        return alphaX96.mulDivDown(
            Q96 + Q96.mulDivDown(Q96, alphaX96) - alphaX96.rpow(uint24(lengthLeft), Q96)
                - alphaX96.rpow(uint24(lengthRight), Q96),
            Q96 - alphaX96
        );
    }

    /// @return mu Center of the distribution
    /// @return lengthLeft Number of rounded ticks to the left of mu
    /// @return lengthRight Number of rounded ticks to the right of mu
    /// @return alphaX96 Parameter of the discrete laplace distribution, FixedPoint96
    function _decodeParams(int24 twapTick, int24 tickSpacing, bool useTwap, bytes32 ldfParams)
        internal
        pure
        returns (int24 mu, int24 lengthLeft, int24 lengthRight, uint256 alphaX96)
    {
        uint256 alpha;
        if (useTwap) {
            // use rounded TWAP value + offset as mu
            // | offset - 1 byte | lengthLeft - 2 bytes | lengthRight - 2 bytes | alpha - 3 bytes |
            int24 offset = int8(uint8(bytes1(ldfParams)));
            mu = roundTickSingle(twapTick + offset * tickSpacing, tickSpacing);
            lengthLeft = int24(uint24(uint16(bytes2(ldfParams << 8))));
            lengthRight = int24(uint24(uint16(bytes2(ldfParams << 24))));
            alpha = uint24(bytes3(ldfParams << 40));
        } else {
            // static mu set in params
            // | mu - 3 bytes | lengthLeft - 2 bytes | lengthRight - 2 bytes | alpha - 3 bytes |
            mu = int24(uint24(bytes3(ldfParams)));
            lengthLeft = int24(uint24(uint16(bytes2(ldfParams << 24))));
            lengthRight = int24(uint24(uint16(bytes2(ldfParams << 40))));
            alpha = uint24(bytes3(ldfParams << 56));
        }
        alphaX96 = alpha.mulDivDown(Q96, ALPHA_BASE);

        // bound distribution to be within the range of usable ticks
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        if (mu - lengthLeft * tickSpacing < minUsableTick) {
            mu = minUsableTick + lengthLeft * tickSpacing;
        } else if (mu + (lengthRight + 1) * tickSpacing > maxUsableTick) {
            mu = maxUsableTick - (lengthRight + 1) * tickSpacing;
        }
    }
}
