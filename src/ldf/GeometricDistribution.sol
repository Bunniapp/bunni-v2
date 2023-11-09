// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/contracts/libraries/FullMath.sol";

import "../lib/Math.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract GeometricDistribution is ILiquidityDensityFunction {
    using TickMath for int24;
    using FixedPointMathLib for uint160;
    using FixedPointMathLib for uint256;
    using FullMath for uint256;

    uint256 internal constant ALPHA_BASE = 1e8; // alpha uses 8 decimals in decodedLDFParams
    uint256 internal constant MIN_ALPHA = 1e3;
    uint256 internal constant Q96 = 0x1000000000000000000000000;

    function query(int24 roundedTick, int24 twapTick, int24 tickSpacing, bool useTwap, bytes11 decodedLDFParams)
        external
        pure
        override
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        (int24 minTick, int24 length, uint256 alphaX96) =
            _decodeParams(twapTick, tickSpacing, useTwap, decodedLDFParams);

        // compute liquidityDensityX96
        liquidityDensityX96_ = _liquidityDensityX96(minTick, length, alphaX96, roundedTick, tickSpacing);

        // x is the index of the roundedTick in the distribution
        // should be in the range [0, length)
        uint256 x;
        if (roundedTick < minTick) {
            // roundedTick is to the left of the distribution
            // set x = 0
            x = 0;
        } else if (roundedTick >= minTick + length * tickSpacing) {
            // roundedTick is to the right of the distribution
            // set x = length - 1
            x = uint24(length - 1);
        } else {
            // roundedTick is in the distribution
            x = uint24((roundedTick - minTick) / tickSpacing);
        }

        uint256 sqrtRatioTickSpacing = tickSpacing.getSqrtRatioAtTick();
        uint256 sqrtRatioNegTickSpacing = (-tickSpacing).getSqrtRatioAtTick();
        uint256 sqrtRatioMinTick = minTick.getSqrtRatioAtTick();
        uint256 sqrtRatioNegMinTick = (-minTick).getSqrtRatioAtTick();

        if (alphaX96 > Q96) {
            // alpha > 1
            // need to make sure that alpha^x doesn't overflow by using alpha^-1 during exponentiation
            uint256 alphaInvX96 = Q96.mulDivDown(Q96, alphaX96);

            // compute cumulativeAmount0DensityX96 for the rounded tick to the right of the rounded current tick
            if (x >= uint24(length) - 1) {
                // roundedTick is the last tick in the distribution
                // cumulativeAmount0DensityX96 is just 0
                cumulativeAmount0DensityX96 = 0;
            } else {
                uint256 xPlus1 = x + 1; // the rounded tick to the right of the current rounded tick
                uint256 alphaInvPowXX96 = alphaInvX96.rpow(xPlus1, Q96);
                uint256 alphaInvPowXPlusLengthX96 = alphaInvX96.rpow(xPlus1 + uint24(length), Q96);

                uint256 numerator = absDiffSimple(
                    alphaInvX96.rpow(uint24(length), Q96),
                    alphaInvPowXX96.mulDivDown(
                        (-tickSpacing * (length - int24(uint24(xPlus1)))).getSqrtRatioAtTick(), Q96
                    )
                ) * (-tickSpacing * int24(uint24(xPlus1))).getSqrtRatioAtTick();
                uint256 denominator = absDiffSimple(Q96, alphaX96.mulDivDown(sqrtRatioNegTickSpacing, Q96))
                    * (alphaInvPowXX96 - alphaInvPowXPlusLengthX96);
                cumulativeAmount0DensityX96 = (Q96 - sqrtRatioNegTickSpacing).mulDiv(numerator, denominator).mulDivDown(
                    alphaX96 - Q96, sqrtRatioMinTick
                );
            }

            // compute cumulativeAmount1DensityX96 for the rounded tick to the left of the rounded current tick
            if (x == 0) {
                // roundedTick is the first tick in the distribution
                // cumulativeAmount1DensityX96 is just 0
                cumulativeAmount1DensityX96 = 0;
            } else {
                uint256 alphaInvPowLengthX96 = alphaInvX96.rpow(uint24(length), Q96);

                uint256 baseX96 = alphaX96.mulDivDown(sqrtRatioTickSpacing, Q96);
                uint256 numerator1 = alphaX96 - Q96;
                uint256 denominator1 = baseX96 - Q96;
                uint256 numerator2 = alphaInvX96.rpow(uint24(length) - x, Q96).mulDivDown(
                    (int24(uint24(x)) * tickSpacing).getSqrtRatioAtTick(), Q96
                ) - alphaInvPowLengthX96;

                uint256 denominator2 = Q96 - alphaInvPowLengthX96;
                cumulativeAmount1DensityX96 = Q96.mulDivDown(numerator1, denominator1).mulDivDown(
                    numerator2, denominator2
                ).mulDivDown(sqrtRatioTickSpacing - Q96, sqrtRatioNegMinTick);
            }
        } else {
            // alpha <= 1
            // will revert if alpha == 1 but that's ok

            // compute cumulativeAmount0DensityX96 for the rounded tick to the right of the rounded current tick
            if (x >= uint24(length) - 1) {
                // roundedTick is the last tick in the distribution
                // cumulativeAmount0DensityX96 is just 0
                cumulativeAmount0DensityX96 = 0;
            } else {
                uint256 baseX96 = alphaX96.mulDivDown(sqrtRatioNegTickSpacing, Q96);
                uint256 numerator = (Q96 - alphaX96) * (baseX96.rpow(x + 1, Q96) - baseX96.rpow(uint24(length), Q96));
                uint256 denominator = (Q96 - alphaX96.rpow(uint24(length), Q96)) * (Q96 - baseX96);
                cumulativeAmount0DensityX96 =
                    (Q96 - sqrtRatioNegTickSpacing).mulDiv(numerator, denominator).mulDivDown(Q96, sqrtRatioMinTick);
            }

            // compute cumulativeAmount1DensityX96 for the rounded tick to the left of the rounded current tick
            if (x == 0) {
                // roundedTick is the first tick in the distribution
                // cumulativeAmount1DensityX96 is just 0
                cumulativeAmount1DensityX96 = 0;
            } else {
                uint256 baseX96 = alphaX96.mulDivDown(sqrtRatioTickSpacing, Q96);
                uint256 numerator = absDiffSimple(Q96, baseX96.rpow(x, Q96)) * (Q96 - alphaX96);
                uint256 denominator = absDiffSimple(Q96, baseX96) * (Q96 - alphaX96.rpow(uint24(length), Q96));
                cumulativeAmount1DensityX96 =
                    (sqrtRatioTickSpacing - Q96).mulDiv(numerator, denominator).mulDivDown(sqrtRatioMinTick, Q96);
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
        (int24 minTick, int24 length, uint256 alphaX96) =
            _decodeParams(twapTick, tickSpacing, useTwap, decodedLDFParams);
        return _liquidityDensityX96(minTick, length, alphaX96, roundedTick, tickSpacing);
    }

    function _liquidityDensityX96(int24 minTick, int24 length, uint256 alphaX96, int24 roundedTick, int24 tickSpacing)
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
            uint256 alphaInvX96 = Q96.mulDivDown(Q96, alphaX96);
            return alphaInvX96.rpow(uint24(length) - x, Q96).mulDiv(
                alphaX96 - Q96, Q96 - alphaInvX96.rpow(uint24(length), Q96)
            );
        } else {
            // alpha <= 1
            // will revert if alpha == 1 but that's ok
            return (Q96 - alphaX96).mulDivDown(alphaX96.rpow(x, Q96), Q96 - alphaX96.rpow(uint24(length), Q96));
        }
    }

    /// @return minTick The minimum rounded tick of the distribution
    /// @return length The length of the distribution in number of rounded ticks (i.e. the number of ticks / tickSpacing)
    /// @return alphaX96 Parameter of the discrete laplace distribution, FixedPoint96
    function _decodeParams(int24 twapTick, int24 tickSpacing, bool useTwap, bytes11 decodedLDFParams)
        internal
        pure
        returns (int24 minTick, int24 length, uint256 alphaX96)
    {
        uint256 alpha;
        if (useTwap) {
            // use rounded TWAP value + offset as minTick
            // | offset - 2 bytes | length - 2 bytes | alpha - 4 bytes |
            int24 offset = int24(int16(uint16(bytes2(decodedLDFParams)))); // the offset applied to the twap tick to get the minTick
            minTick = roundTickSingle(twapTick + offset, tickSpacing);
            length = int24(int16(uint16(bytes2(decodedLDFParams << 16))));
            alpha = uint32(bytes4(decodedLDFParams << 32));
        } else {
            // static minTick set in params
            // | minTick - 3 bytes | length - 2 bytes | alpha - 4 bytes | 0 - 2 bytes |
            minTick = int24(uint24(bytes3(decodedLDFParams))); // must be aligned to tickSpacing
            length = int24(int16(uint16(bytes2(decodedLDFParams << 24))));
            alpha = uint32(bytes4(decodedLDFParams << 40));
        }
        alphaX96 = alpha.mulDivDown(Q96, ALPHA_BASE);

        // bound distribution to be within the range of usable ticks
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        if (minTick < minUsableTick) {
            minTick = minUsableTick;
        } else if (minTick + length * tickSpacing > maxUsableTick) {
            minTick = maxUsableTick - length * tickSpacing;
        }
    }
}
