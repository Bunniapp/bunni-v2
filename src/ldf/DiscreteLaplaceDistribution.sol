// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/contracts/libraries/FullMath.sol";
import {FixedPoint96} from "@uniswap/v4-core/contracts/libraries/FixedPoint96.sol";

import "../lib/Math.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract DiscreteLaplaceDistribution is ILiquidityDensityFunction {
    using TickMath for int24;
    using SafeCastLib for int256;
    using FixedPointMathLib for uint256;

    uint256 internal constant MIN_ALPHA = 1e9;
    uint256 internal constant MAX_ALPHA = 0.9e18;

    error DiscreteLaplaceDistribution__InvalidMu(int24 mu);
    error DiscreteLaplaceDistribution__InvalidAlpha(uint256 alpha);

    function query(
        int24 roundedTick,
        int24 currentTick,
        int24 twapTick,
        int24 tickSpacing,
        bool useTwap,
        bytes11 decodedLDFParams
    )
        external
        pure
        override
        returns (uint256 liquidityDensity_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        (int24 mu, uint256 alpha) = _decodeParams(twapTick, tickSpacing, useTwap, decodedLDFParams);
        uint256 alphaPowTickSpacing = alpha.rpow(uint256(int256(tickSpacing)), FixedPointMathLib.WAD);
        uint256 totalDensity = _totalDensity(alphaPowTickSpacing);

        // compute liquidityDensity
        {
            uint256 numerator = alpha.rpow(abs(roundedTick - mu), FixedPointMathLib.WAD);
            liquidityDensity_ = numerator.divWadDown(totalDensity);
        }

        // compute cumulativeAmount0DensityX96
        {
            uint256 sqrtRatioNegTickSpacing = (-tickSpacing).getSqrtRatioAtTick();
            uint256 c = FixedPoint96.Q96 - sqrtRatioNegTickSpacing;
            if (currentTick < mu + tickSpacing) {
                uint256 sqrtRatioNegMu = (-mu).getSqrtRatioAtTick();
                uint256 term1 = FullMath.mulDiv(
                    FullMath.mulDiv(
                        alpha.rpow(uint256(int256(mu - currentTick)), FixedPoint96.Q96),
                        (-currentTick).getSqrtRatioAtTick(),
                        FixedPoint96.Q96
                    ) - sqrtRatioNegMu,
                    FixedPoint96.Q96,
                    FixedPoint96.Q96
                        - FullMath.mulDiv(
                            FixedPointMathLib.WAD.divWadDown(alphaPowTickSpacing),
                            sqrtRatioNegTickSpacing,
                            FixedPointMathLib.WAD
                        )
                );
                uint256 term2 = FullMath.mulDiv(
                    sqrtRatioNegMu,
                    FixedPoint96.Q96,
                    FixedPoint96.Q96
                        - FullMath.mulDiv(alphaPowTickSpacing, sqrtRatioNegTickSpacing, FixedPointMathLib.WAD)
                );
                cumulativeAmount0DensityX96 = FullMath.mulDiv(c, term1 + term2, FixedPoint96.Q96);
            } else {
                uint256 numerator = FullMath.mulDiv(
                    alpha.rpow(uint256(int256(currentTick - mu)), FixedPoint96.Q96),
                    (-currentTick).getSqrtRatioAtTick(),
                    FixedPoint96.Q96
                );
                uint256 denominator = FixedPoint96.Q96
                    - FullMath.mulDiv(alphaPowTickSpacing, sqrtRatioNegTickSpacing, FixedPointMathLib.WAD);
                cumulativeAmount0DensityX96 = FullMath.mulDiv(c, numerator, denominator);
            }
            // divide by total density
            cumulativeAmount0DensityX96 =
                FullMath.mulDiv(cumulativeAmount0DensityX96, FixedPointMathLib.WAD, totalDensity);
        }

        // compute cumulativeAmount1DensityX96
        {
            uint256 sqrtRatioTickSpacing = tickSpacing.getSqrtRatioAtTick();
            uint256 c = sqrtRatioTickSpacing - FixedPoint96.Q96;
            if (currentTick < mu) {
                uint256 term1 = FullMath.mulDiv(
                    FullMath.mulDiv(
                        alpha.rpow(uint256(int256(mu - currentTick)), FixedPoint96.Q96),
                        (currentTick + tickSpacing).getSqrtRatioAtTick(),
                        FixedPoint96.Q96
                    ),
                    FixedPoint96.Q96,
                    sqrtRatioTickSpacing - alpha.rpow(uint256(int256(tickSpacing)), FixedPoint96.Q96)
                );
                cumulativeAmount1DensityX96 = FullMath.mulDiv(c, term1, FixedPoint96.Q96);
            } else {
                uint256 sqrtRatioMu = mu.getSqrtRatioAtTick();
                uint256 term1 =
                    FullMath.mulDiv(alphaPowTickSpacing, sqrtRatioMu, sqrtRatioTickSpacing - alphaPowTickSpacing);
                uint256 numerator2 = sqrtRatioMu
                    - FullMath.mulDiv(
                        alpha.rpow(uint256(int256(currentTick + tickSpacing - mu)), FixedPoint96.Q96),
                        (currentTick + tickSpacing).getSqrtRatioAtTick(),
                        FixedPoint96.Q96
                    );
                uint256 denominator2 =
                    FixedPoint96.Q96 - FullMath.mulDiv(alphaPowTickSpacing, sqrtRatioTickSpacing, FixedPointMathLib.WAD);
                cumulativeAmount1DensityX96 =
                    FullMath.mulDiv(c, term1, FixedPoint96.Q96) + FullMath.mulDiv(c, numerator2, denominator2);
            }
            // divide by total density
            cumulativeAmount1DensityX96 =
                FullMath.mulDiv(cumulativeAmount1DensityX96, FixedPointMathLib.WAD, totalDensity);
        }
    }

    function liquidityDensity(
        int24 roundedTick,
        int24, /*currentTick*/
        int24 twapTick,
        int24 tickSpacing,
        bool useTwap,
        bytes11 decodedLDFParams
    ) external pure override returns (uint256) {
        (int24 mu, uint256 alpha) = _decodeParams(twapTick, tickSpacing, useTwap, decodedLDFParams);
        uint256 numerator = alpha.rpow(abs(roundedTick - mu), FixedPointMathLib.WAD);
        uint256 alphaPowTickSpacing = alpha.rpow(uint256(int256(tickSpacing)), FixedPointMathLib.WAD);
        uint256 denominator = _totalDensity(alphaPowTickSpacing);
        return numerator.divWadDown(denominator);
    }

    function _totalDensity(uint256 alphaPowTickSpacing) internal pure returns (uint256) {
        uint256 numerator = FixedPointMathLib.WAD + alphaPowTickSpacing;
        uint256 denominator = FixedPointMathLib.WAD - alphaPowTickSpacing;
        return numerator.divWadDown(denominator);
    }

    /// @return mu Center of the distribution
    /// @return alpha Parameter of the discrete laplace distribution, 18 decimals
    function _decodeParams(int24 twapTick, int24 tickSpacing, bool useTwap, bytes11 decodedLDFParams)
        internal
        pure
        returns (int24 mu, uint256 alpha)
    {
        if (useTwap) {
            // use rounded TWAP value as mu
            // | alpha - 8 bytes |
            (mu,) = roundTick(twapTick, tickSpacing);
            alpha = uint256(uint64(bytes8(decodedLDFParams)));
        } else {
            // static mu set in params
            // | mu - 3 bytes | alpha - 8 bytes |
            mu = int24(uint24(bytes3(decodedLDFParams)));
            if (mu % tickSpacing != 0) revert DiscreteLaplaceDistribution__InvalidMu(mu);
            alpha = uint256(uint64(bytes8(decodedLDFParams << 24)));
        }
        if (alpha < MIN_ALPHA || alpha > MAX_ALPHA) revert DiscreteLaplaceDistribution__InvalidAlpha(alpha);
    }
}
