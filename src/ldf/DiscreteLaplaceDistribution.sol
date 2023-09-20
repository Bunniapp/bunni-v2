// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "forge-std/console2.sol";

import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/contracts/libraries/FullMath.sol";

import "../lib/Math.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract DiscreteLaplaceDistribution is ILiquidityDensityFunction {
    using TickMath for int24;
    using SafeCastLib for int256;
    using FixedPointMathLib for uint160;
    using FixedPointMathLib for uint256;
    using FullMath for uint160;
    using FullMath for uint256;

    uint256 internal constant MIN_ALPHA = 1e14;
    uint256 internal constant MAX_ALPHA = 0.9e18;
    uint256 internal constant WAD = 1e18;
    uint256 internal constant Q96 = 0x1000000000000000000000000;

    error DiscreteLaplaceDistribution__InvalidMu(int24 mu);
    error DiscreteLaplaceDistribution__InvalidAlpha(uint256 alpha);

    function query(int24 roundedTick, int24 twapTick, int24 tickSpacing, bool useTwap, bytes11 decodedLDFParams)
        external
        pure
        override
        returns (uint256 liquidityDensity_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        (int24 mu, uint256 alpha) = _decodeParams(twapTick, tickSpacing, useTwap, decodedLDFParams);
        uint256 alphaX96 = alpha.mulDivDown(Q96, WAD);
        uint256 totalDensity = _totalDensity(
            alpha, mu, TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing), tickSpacing
        );

        // compute liquidityDensity
        liquidityDensity_ = alpha.rpow(abs((roundedTick - mu) / tickSpacing), WAD).divWadDown(totalDensity);

        // compute cumulativeAmount0DensityX96 for the rounded tick to the right of the rounded current tick
        {
            uint256 sqrtRatioNegTickSpacing = (-tickSpacing).getSqrtRatioAtTick();
            uint256 c = Q96 - sqrtRatioNegTickSpacing;
            int24 roundedTickRight = roundedTick + tickSpacing;
            if (roundedTick < mu) {
                uint256 sqrtRatioNegMu = (-mu).getSqrtRatioAtTick();
                uint256 tmp1 = (-roundedTickRight).getSqrtRatioAtTick().mulWadDown(
                    alpha.rpow(uint256(int256((mu - roundedTickRight) / tickSpacing)) + 1, WAD)
                );
                uint256 tmp2 = sqrtRatioNegMu.mulWadDown(alpha);
                if (alphaX96 > sqrtRatioNegTickSpacing) {
                    if (tmp1 > tmp2) {
                        cumulativeAmount0DensityX96 = c.mulDiv(
                            (tmp1 - tmp2).mulDiv(WAD, alphaX96 - sqrtRatioNegTickSpacing)
                                + sqrtRatioNegMu.mulDiv(WAD, Q96 - sqrtRatioNegTickSpacing.mulDiv(alpha, WAD)),
                            totalDensity
                        );
                    } else {
                        uint256 a = sqrtRatioNegMu.mulDiv(WAD, Q96 - sqrtRatioNegTickSpacing.mulDiv(alpha, WAD));
                        uint256 b = (tmp2 - tmp1).mulDiv(WAD, alphaX96 - sqrtRatioNegTickSpacing);
                        if (a > b) {
                            cumulativeAmount0DensityX96 = c.mulDiv(a - b, totalDensity);
                        }
                    }
                } else {
                    if (tmp2 > tmp1) {
                        cumulativeAmount0DensityX96 = c.mulDiv(
                            FullMath.mulDiv(tmp2 - tmp1, WAD, sqrtRatioNegTickSpacing - alphaX96)
                                + sqrtRatioNegMu.divWadDown(Q96 - sqrtRatioNegTickSpacing.mulWadDown(alpha)),
                            totalDensity
                        );
                    } else {
                        cumulativeAmount0DensityX96 = c.mulDiv(
                            sqrtRatioNegMu.divWadDown(Q96 - sqrtRatioNegTickSpacing.mulWadDown(alpha))
                                - FullMath.mulDiv(tmp1 - tmp2, WAD, sqrtRatioNegTickSpacing - alphaX96),
                            totalDensity
                        );
                    }
                }
            } else {
                uint256 numerator = _getSqrtRatioAtTick(-roundedTickRight).mulDivDown(
                    alpha.rpow(uint256(int256((roundedTickRight - mu) / tickSpacing)), WAD), totalDensity
                );
                uint256 denominator = Q96 - sqrtRatioNegTickSpacing.mulWadDown(alpha);
                cumulativeAmount0DensityX96 = FullMath.mulDiv(c, numerator, denominator);
            }
        }

        // compute cumulativeAmount1DensityX96 for the rounded tick to the left of the rounded current tick
        {
            uint256 sqrtRatioTickSpacing = tickSpacing.getSqrtRatioAtTick();
            uint256 c = sqrtRatioTickSpacing - Q96;
            int24 roundedTickLeft = roundedTick - tickSpacing;
            if (roundedTickLeft < mu) {
                uint256 term1 = roundedTick.getSqrtRatioAtTick().mulWadDown(
                    alpha.rpow(uint256(int256((mu - roundedTickLeft) / tickSpacing)), WAD)
                ).divWadDown(sqrtRatioTickSpacing - alphaX96);
                cumulativeAmount1DensityX96 = c.mulDivDown(term1, totalDensity);
            } else {
                uint256 sqrtRatioMu = mu.getSqrtRatioAtTick();
                uint256 tmp = sqrtRatioTickSpacing.mulWadDown(alpha);
                if (Q96 > tmp) {
                    cumulativeAmount1DensityX96 = c.mulDiv(
                        FullMath.mulDiv(alpha, sqrtRatioMu, sqrtRatioTickSpacing - alphaX96)
                            + (
                                sqrtRatioMu
                                    - roundedTick.getSqrtRatioAtTick().mulWadDown(
                                        alpha.rpow(uint256(int256((roundedTick - mu) / tickSpacing)), WAD)
                                    )
                            ).divWadDown(Q96 - tmp),
                        totalDensity
                    );
                } else {
                    uint256 x = FullMath.mulDiv(alpha, sqrtRatioMu, sqrtRatioTickSpacing - alphaX96);
                    uint256 y = sqrtRatioMu.divWadDown(tmp - Q96);
                    uint256 z = roundedTick.getSqrtRatioAtTick().mulWadDown(
                        alpha.rpow(uint256(int256((roundedTick - mu) / tickSpacing)), WAD)
                    ).divWadDown(tmp - Q96);
                    if (x + z > y) {
                        cumulativeAmount1DensityX96 = c.mulDiv(x + z - y, totalDensity);
                    }
                }
            }
        }
    }

    function liquidityDensity(
        int24 roundedTick,
        int24 twapTick,
        int24 tickSpacing,
        bool useTwap,
        bytes11 decodedLDFParams
    ) external pure override returns (uint256) {
        (int24 mu, uint256 alpha) = _decodeParams(twapTick, tickSpacing, useTwap, decodedLDFParams);
        uint256 totalDensity = _totalDensity(
            alpha, mu, TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing), tickSpacing
        );
        return alpha.rpow(abs((roundedTick - mu) / tickSpacing), WAD).divWadDown(totalDensity);
    }

    function _totalDensity(uint256 alpha, int24 mu, int24 minTick, int24 maxTick, int24 tickSpacing)
        internal
        pure
        returns (uint256)
    {
        return (
            alpha.mulWadDown(
                WAD + WAD.divWadDown(alpha) - alpha.rpow(uint256(int256((mu - minTick) / tickSpacing)), WAD)
                    - alpha.rpow(uint256(int256((maxTick - mu) / tickSpacing)), WAD)
            )
        ).divWadDown(WAD - alpha);
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
            mu = roundTickSingle(twapTick, tickSpacing);
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

    function _getSqrtRatioAtTick(int24 tick) internal pure returns (uint160) {
        if (tick < TickMath.MIN_TICK) return 0;
        if (tick > TickMath.MAX_TICK) return TickMath.MAX_SQRT_RATIO;
        return tick.getSqrtRatioAtTick();
    }
}
