// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import "./ShiftMode.sol";
import "../lib/Math.sol";
import {LibGeometricDistribution} from "./LibGeometricDistribution.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract DoubleGeometricDistribution is ILiquidityDensityFunction {
    using TickMath for int24;
    using FixedPointMathLib for uint256;

    uint56 internal constant INITIALIZED_STATE = 1 << 48;

    function query(
        PoolKey calldata key,
        int24 roundedTick,
        int24 twapTick,
        int24, /* spotPriceTick */
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    )
        external
        pure
        override
        returns (
            uint256 liquidityDensityX96_,
            uint256 cumulativeAmount0DensityX96,
            uint256 cumulativeAmount1DensityX96,
            bytes32 newLdfState
        )
    {
        // decode params for each distribution
        (uint256 weight0, uint256 weight1, bytes32 ldfParams0, bytes32 ldfParams1) = decodeDoubleParams(ldfParams);
        (bool initialized, int24 lastMinTick0, int24 lastMinTick1) = _decodeState(ldfState);

        // query each distribution
        (uint256 liquidityDensityX96_0, uint256 cumulativeAmount0DensityX96_0, uint256 cumulativeAmount1DensityX96_0) =
            (0, 0, 0);
        (uint256 liquidityDensityX96_1, uint256 cumulativeAmount0DensityX96_1, uint256 cumulativeAmount1DensityX96_1) =
            (0, 0, 0);
        (int24 minTick0, int24 minTick1) = (0, 0);
        {
            (int24 minTick, int24 length, uint256 alphaX96, ShiftMode shiftMode) =
                LibGeometricDistribution.decodeParams(twapTick, key.tickSpacing, useTwap, ldfParams0);
            if (initialized) {
                minTick = enforceShiftMode(minTick, lastMinTick0, shiftMode);
            }

            (liquidityDensityX96_0, cumulativeAmount0DensityX96_0, cumulativeAmount1DensityX96_0) =
                LibGeometricDistribution.query(roundedTick, key.tickSpacing, minTick, length, alphaX96);
            minTick0 = minTick;
        }
        {
            (int24 minTick, int24 length, uint256 alphaX96, ShiftMode shiftMode) =
                LibGeometricDistribution.decodeParams(twapTick, key.tickSpacing, useTwap, ldfParams1);
            if (initialized) {
                minTick = enforceShiftMode(minTick, lastMinTick1, shiftMode);
            }

            (liquidityDensityX96_1, cumulativeAmount0DensityX96_1, cumulativeAmount1DensityX96_1) =
                LibGeometricDistribution.query(roundedTick, key.tickSpacing, minTick, length, alphaX96);
            minTick1 = minTick;
        }

        // combine results
        liquidityDensityX96_ = weightedSum({
            value0: liquidityDensityX96_0,
            weight0: weight0,
            value1: liquidityDensityX96_1,
            weight1: weight1
        });
        cumulativeAmount0DensityX96 = weightedSum({
            value0: cumulativeAmount0DensityX96_0,
            weight0: weight0,
            value1: cumulativeAmount0DensityX96_1,
            weight1: weight1
        });
        cumulativeAmount1DensityX96 = weightedSum({
            value0: cumulativeAmount1DensityX96_0,
            weight0: weight0,
            value1: cumulativeAmount1DensityX96_1,
            weight1: weight1
        });
        newLdfState = _encodeState(minTick0, minTick1);
    }

    function inverseCumulativeAmount0(
        uint256 cumulativeAmount0,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 twapTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external pure override returns (uint160 sqrtPriceX96) {
        // decode params for each distribution
        (uint256 weight0, uint256 weight1, bytes32 ldfParams0, bytes32 ldfParams1) = decodeDoubleParams(ldfParams);
        (bool initialized, int24 lastMinTick0, int24 lastMinTick1) = _decodeState(ldfState);

        // query LDF0
        (int24 minTick0, int24 length0, uint256 alpha0X96, ShiftMode shiftMode0) =
            LibGeometricDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams0);
        if (initialized) {
            minTick0 = enforceShiftMode(minTick0, lastMinTick0, shiftMode0);
        }

        uint256 totalLiquidity0 = totalLiquidity.mulDiv(weight0, weight0 + weight1);
        sqrtPriceX96 = LibGeometricDistribution.inverseCumulativeAmount0(
            cumulativeAmount0, totalLiquidity0, tickSpacing, minTick0, length0, alpha0X96
        );

        uint160 sqrtRatioMinTick0 = minTick0.getSqrtRatioAtTick();
        if (sqrtPriceX96 < sqrtRatioMinTick0) {
            // result outside of LDF0's domain, query LDF1
            (int24 minTick1, int24 length1, uint256 alpha1X96, ShiftMode shiftMode1) =
                LibGeometricDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams1);
            if (initialized) {
                minTick1 = enforceShiftMode(minTick1, lastMinTick1, shiftMode1);
            }

            // deduct cumulativeAmount0 of LDF0 from cumulativeAmount0
            cumulativeAmount0 -= LibGeometricDistribution.cumulativeAmount0(
                minTick0, totalLiquidity0, tickSpacing, minTick0, length0, alpha0X96
            );

            uint256 totalLiquidity1 = totalLiquidity.mulDiv(weight1, weight0 + weight1);
            sqrtPriceX96 = LibGeometricDistribution.inverseCumulativeAmount0(
                cumulativeAmount0, totalLiquidity1, tickSpacing, minTick1, length1, alpha1X96
            );
        }
    }

    function inverseCumulativeAmount1(
        uint256 cumulativeAmount1,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 twapTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external pure override returns (uint160 sqrtPriceX96) {
        // decode params for each distribution
        (uint256 weight0, uint256 weight1, bytes32 ldfParams0, bytes32 ldfParams1) = decodeDoubleParams(ldfParams);
        (bool initialized, int24 lastMinTick0, int24 lastMinTick1) = _decodeState(ldfState);

        // query LDF1
        (int24 minTick1, int24 length1, uint256 alpha1X96, ShiftMode shiftMode1) =
            LibGeometricDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams1);
        if (initialized) {
            minTick1 = enforceShiftMode(minTick1, lastMinTick1, shiftMode1);
        }

        uint256 totalLiquidity1 = totalLiquidity.mulDiv(weight1, weight0 + weight1);
        sqrtPriceX96 = LibGeometricDistribution.inverseCumulativeAmount1(
            cumulativeAmount1, totalLiquidity1, tickSpacing, minTick1, length1, alpha1X96
        );

        uint160 sqrtRatioMinTick0 = (minTick1 + length1 * tickSpacing).getSqrtRatioAtTick();
        if (sqrtPriceX96 >= sqrtRatioMinTick0) {
            // result outside of LDF1's domain, query LDF0
            (int24 minTick0, int24 length0, uint256 alpha0X96, ShiftMode shiftMode0) =
                LibGeometricDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams0);
            if (initialized) {
                minTick0 = enforceShiftMode(minTick0, lastMinTick0, shiftMode0);
            }

            // deduct cumulativeAmount1 of LDF1 from cumulativeAmount1
            cumulativeAmount1 -= LibGeometricDistribution.cumulativeAmount1(
                minTick0 - tickSpacing, totalLiquidity1, tickSpacing, minTick1, length1, alpha1X96
            );

            uint256 totalLiquidity0 = totalLiquidity.mulDiv(weight0, weight0 + weight1);
            sqrtPriceX96 = LibGeometricDistribution.inverseCumulativeAmount1(
                cumulativeAmount1, totalLiquidity0, tickSpacing, minTick0, length0, alpha0X96
            );
        }
    }

    function liquidityDensityX96(
        PoolKey calldata key,
        int24 roundedTick,
        int24 twapTick,
        int24, /* spotPriceTick */
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external pure override returns (uint256) {
        // decode params for each distribution
        (uint256 weight0, uint256 weight1, bytes32 ldfParams0, bytes32 ldfParams1) = decodeDoubleParams(ldfParams);
        (bool initialized, int24 lastMinTick0, int24 lastMinTick1) = _decodeState(ldfState);

        // query each distribution
        uint256 liquidityDensityX96_0;
        uint256 liquidityDensityX96_1;
        {
            (int24 minTick, int24 length, uint256 alphaX96, ShiftMode shiftMode) =
                LibGeometricDistribution.decodeParams(twapTick, key.tickSpacing, useTwap, ldfParams0);
            if (initialized) {
                minTick = enforceShiftMode(minTick, lastMinTick0, shiftMode);
            }

            liquidityDensityX96_0 =
                LibGeometricDistribution.liquidityDensityX96(roundedTick, key.tickSpacing, minTick, length, alphaX96);
        }
        {
            (int24 minTick, int24 length, uint256 alphaX96, ShiftMode shiftMode) =
                LibGeometricDistribution.decodeParams(twapTick, key.tickSpacing, useTwap, ldfParams1);
            if (initialized) {
                minTick = enforceShiftMode(minTick, lastMinTick1, shiftMode);
            }

            liquidityDensityX96_1 =
                LibGeometricDistribution.liquidityDensityX96(roundedTick, key.tickSpacing, minTick, length, alphaX96);
        }

        // combine results
        return weightedSum({
            value0: liquidityDensityX96_0,
            weight0: weight0,
            value1: liquidityDensityX96_1,
            weight1: weight1
        });
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        // decode params for each distribution
        (uint256 weight0, uint256 weight1, bytes32 ldfParams0, bytes32 ldfParams1) = decodeDoubleParams(ldfParams);
        if (weight0 == 0 || weight1 == 0) return false;

        // validate params for each distribution
        if (
            !LibGeometricDistribution.isValidParams(tickSpacing, twapSecondsAgo, ldfParams0)
                || !LibGeometricDistribution.isValidParams(tickSpacing, twapSecondsAgo, ldfParams1)
        ) return false;

        // ensure the two distributions meet and form one continuous distribution
        // LDF1 must be to the left of LDF0 and adjacent to it
        bool useTwap = twapSecondsAgo != 0;
        (int24 minTick0, int24 length0,,) = LibGeometricDistribution.decodeParams(0, tickSpacing, useTwap, ldfParams0);
        (int24 minTick1, int24 length1,,) = LibGeometricDistribution.decodeParams(0, tickSpacing, useTwap, ldfParams1);

        return minTick0 == minTick1 + length1 * tickSpacing;
    }

    function decodeDoubleParams(bytes32 ldfParams)
        internal
        pure
        returns (uint256 weight0, uint256 weight1, bytes32 ldfParams0, bytes32 ldfParams1)
    {
        // | weight0 - 4 bytes | weight1 - 4 bytes | ldfParams0 - 9 bytes | ldfParams1 - 9 bytes |
        weight0 = uint32(bytes4(ldfParams));
        weight1 = uint32(bytes4(ldfParams << 32));
        ldfParams0 = bytes9(ldfParams << 64);
        ldfParams1 = bytes9(ldfParams << 136);
    }

    function _decodeState(bytes32 ldfState)
        internal
        pure
        returns (bool initialized, int24 lastMinTick0, int24 lastMinTick1)
    {
        // | initialized - 1 byte | lastMinTick0 - 3 bytes | lastMinTick1 - 3 bytes |
        initialized = uint8(bytes1(ldfState)) == 1;
        lastMinTick0 = int24(uint24(bytes3(ldfState << 8)));
        lastMinTick1 = int24(uint24(bytes3(ldfState << 32)));
    }

    function _encodeState(int24 lastMinTick0, int24 lastMinTick1) internal pure returns (bytes32 ldfState) {
        // | initialized - 1 byte | lastMinTick0 - 3 bytes | lastMinTick1 - 3 bytes |
        ldfState =
            bytes32(bytes7(INITIALIZED_STATE + (uint56(uint24(lastMinTick0)) << 24) + uint56(uint24(lastMinTick1))));
    }
}
