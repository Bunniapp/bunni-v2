// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";

import "../lib/Math.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract DiscreteLaplaceDistribution is ILiquidityDensityFunction {
    using TickMath for int24;
    using SafeCastLib for int256;
    using FixedPointMathLib for uint160;
    using FixedPointMathLib for uint256;

    uint256 internal constant MIN_ALPHA = 1e14;
    uint256 internal constant MAX_ALPHA = 0.9e18;
    uint256 internal constant WAD = 1e18;
    uint256 internal constant Q96 = 0x1000000000000000000000000;

    function query(int24 roundedTick, int24 twapTick, int24 tickSpacing, bool useTwap, bytes11 decodedLDFParams)
        external
        pure
        override
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        (int24 mu, uint256 alphaX96) = _decodeParams(twapTick, tickSpacing, useTwap, decodedLDFParams);
        (int24 minTick, int24 maxTick) = (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        uint256 totalDensityX96 = _totalDensityX96(alphaX96, mu, minTick, maxTick, tickSpacing);

        // compute liquidityDensityX96
        liquidityDensityX96_ =
            alphaX96.rpow(abs((roundedTick - mu) / tickSpacing), Q96).mulDivDown(Q96, totalDensityX96);

        // compute cumulativeAmount0DensityX96 for the rounded tick to the right of the rounded current tick
        {
            uint256 sqrtRatioNegTickSpacing = (-tickSpacing).getSqrtRatioAtTick();
            uint256 c = Q96 - sqrtRatioNegTickSpacing;
            int24 roundedTickRight = roundedTick + tickSpacing;
            if (roundedTick < mu) {
                uint256 sqrtRatioNegMu = (-mu).getSqrtRatioAtTick();
                (bool term1DenominatorIsPositive, uint256 term1Denominator) = absDiff(alphaX96, sqrtRatioNegTickSpacing);
                uint256 x = (-roundedTickRight).getSqrtRatioAtTick().mulDivDown(
                    alphaX96.rpow(uint256(int256((mu - roundedTickRight) / tickSpacing)) + 1, Q96), term1Denominator
                );
                uint256 y = sqrtRatioNegMu.mulDivDown(alphaX96, term1Denominator);
                (bool term1NumeratorIsPositive, uint256 term1) = absDiff(x, y);
                uint256 term2 = sqrtRatioNegMu.mulDivDown(Q96, Q96 - sqrtRatioNegTickSpacing.mulDivDown(alphaX96, Q96));
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
                    alphaX96.rpow(uint256(int256((roundedTickRight - mu) / tickSpacing)), Q96), totalDensityX96
                );
                uint256 denominator = Q96 - sqrtRatioNegTickSpacing.mulDivDown(alphaX96, Q96);
                cumulativeAmount0DensityX96 = c.mulDivDown(numerator, denominator);
            }
        }

        // compute cumulativeAmount1DensityX96 for the rounded tick to the left of the rounded current tick
        {
            uint256 sqrtRatioTickSpacing = tickSpacing.getSqrtRatioAtTick();
            uint256 c = sqrtRatioTickSpacing - Q96;
            int24 roundedTickLeft = roundedTick - tickSpacing;
            if (roundedTickLeft < mu) {
                uint256 term1 = roundedTick.getSqrtRatioAtTick().mulDivDown(
                    alphaX96.rpow(uint256(int256((mu - roundedTickLeft) / tickSpacing)), Q96),
                    sqrtRatioTickSpacing - alphaX96
                );
                cumulativeAmount1DensityX96 = c.mulDivDown(term1, totalDensityX96);
            } else {
                uint256 sqrtRatioMu = mu.getSqrtRatioAtTick();
                uint256 denominatorSub = sqrtRatioTickSpacing.mulDivDown(alphaX96, Q96);
                (bool denominatorIsPositive, uint256 denominator) = absDiff(Q96, denominatorSub);
                uint256 x = alphaX96.mulDivDown(sqrtRatioMu, sqrtRatioTickSpacing - alphaX96);
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
        }
    }

    function liquidityDensityX96(
        int24 roundedTick,
        int24 twapTick,
        int24 tickSpacing,
        bool useTwap,
        bytes11 decodedLDFParams
    ) external pure override returns (uint256) {
        (int24 mu, uint256 alphaX96) = _decodeParams(twapTick, tickSpacing, useTwap, decodedLDFParams);
        uint256 totalDensityX96 = _totalDensityX96(
            alphaX96, mu, TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing), tickSpacing
        );
        return alphaX96.rpow(abs((roundedTick - mu) / tickSpacing), Q96).mulDivDown(Q96, totalDensityX96);
    }

    function isValidParams(int24 tickSpacing, bool useTwap, bytes11 decodedLDFParams)
        external
        pure
        override
        returns (bool)
    {
        uint256 alpha;
        if (useTwap) {
            // use rounded TWAP value as mu
            // | alpha - 8 bytes |
            alpha = uint256(uint64(bytes8(decodedLDFParams)));
        } else {
            // static mu set in params
            // | mu - 3 bytes | alpha - 8 bytes |
            int24 mu = int24(uint24(bytes3(decodedLDFParams)));
            alpha = uint256(uint64(bytes8(decodedLDFParams << 24)));

            // ensure mu is aligned to tickSpacing
            if (mu % tickSpacing != 0) return false;
        }

        // ensure alpha is in range
        if (alpha < MIN_ALPHA || alpha > MAX_ALPHA) return false;

        // if all conditions are met, return true
        return true;
    }

    function _totalDensityX96(uint256 alphaX96, int24 mu, int24 minTick, int24 maxTick, int24 tickSpacing)
        internal
        pure
        returns (uint256)
    {
        return (
            alphaX96.mulDivDown(
                Q96 + Q96.mulDivDown(Q96, alphaX96) - alphaX96.rpow(uint256(int256((mu - minTick) / tickSpacing)), Q96)
                    - alphaX96.rpow(uint256(int256((maxTick - mu) / tickSpacing)), Q96),
                Q96
            )
        ).mulDivDown(Q96, Q96 - alphaX96);
    }

    /// @return mu Center of the distribution
    /// @return alphaX96 Parameter of the discrete laplace distribution, FixedPoint96
    function _decodeParams(int24 twapTick, int24 tickSpacing, bool useTwap, bytes11 decodedLDFParams)
        internal
        pure
        returns (int24 mu, uint256 alphaX96)
    {
        uint256 alpha;
        if (useTwap) {
            // use rounded TWAP value as mu
            // | alpha - 8 bytes |
            mu = roundTickSingle(twapTick, tickSpacing);
            alpha = uint256(uint64(bytes8(decodedLDFParams)));
        } else {
            // static mu set in params
            // | mu - 3 bytes | alpha - 8 bytes |
            mu = int24(uint24(bytes3(decodedLDFParams)));
            alpha = uint256(uint64(bytes8(decodedLDFParams << 24)));
        }
        alphaX96 = alpha.mulDivDown(Q96, WAD);
    }
}
