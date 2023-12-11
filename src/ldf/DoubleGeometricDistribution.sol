// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import "../lib/Math.sol";
import {LibGeometricDistribution} from "./LibGeometricDistribution.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract DoubleGeometricDistribution is ILiquidityDensityFunction {
    function query(
        PoolKey calldata, /* key */
        int24 roundedTick,
        int24 twapTick,
        int24, /* spotPriceTick */
        int24 tickSpacing,
        bool useTwap,
        bytes32 ldfParams
    )
        external
        pure
        override
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        // decode params for each distribution
        (uint256 weight0, uint256 weight1, bytes32 ldfParams0, bytes32 ldfParams1) = decodeDoubleParams(ldfParams);

        // query each distribution
        (uint256 liquidityDensityX96_0, uint256 cumulativeAmount0DensityX96_0, uint256 cumulativeAmount1DensityX96_0) =
            (0, 0, 0);
        (uint256 liquidityDensityX96_1, uint256 cumulativeAmount0DensityX96_1, uint256 cumulativeAmount1DensityX96_1) =
            (0, 0, 0);
        {
            (int24 minTick, int24 length, uint256 alphaX96) =
                LibGeometricDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams0);
            (liquidityDensityX96_0, cumulativeAmount0DensityX96_0, cumulativeAmount1DensityX96_0) =
                LibGeometricDistribution.query(roundedTick, tickSpacing, minTick, length, alphaX96);
        }
        {
            (int24 minTick, int24 length, uint256 alphaX96) =
                LibGeometricDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams1);
            (liquidityDensityX96_1, cumulativeAmount0DensityX96_1, cumulativeAmount1DensityX96_1) =
                LibGeometricDistribution.query(roundedTick, tickSpacing, minTick, length, alphaX96);
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
    }

    function liquidityDensityX96(
        PoolKey calldata, /* key */
        int24 roundedTick,
        int24 twapTick,
        int24, /* spotPriceTick */
        int24 tickSpacing,
        bool useTwap,
        bytes32 ldfParams
    ) external pure override returns (uint256) {
        // decode params for each distribution
        (uint256 weight0, uint256 weight1, bytes32 ldfParams0, bytes32 ldfParams1) = decodeDoubleParams(ldfParams);

        // query each distribution
        uint256 liquidityDensityX96_0;
        uint256 liquidityDensityX96_1;
        {
            (int24 minTick, int24 length, uint256 alphaX96) =
                LibGeometricDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams0);
            liquidityDensityX96_0 =
                LibGeometricDistribution.liquidityDensityX96(roundedTick, tickSpacing, minTick, length, alphaX96);
        }
        {
            (int24 minTick, int24 length, uint256 alphaX96) =
                LibGeometricDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams1);
            liquidityDensityX96_1 =
                LibGeometricDistribution.liquidityDensityX96(roundedTick, tickSpacing, minTick, length, alphaX96);
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
        bool useTwap = twapSecondsAgo != 0;
        (int24 minTick0, int24 length0,) = LibGeometricDistribution.decodeParams(0, tickSpacing, useTwap, ldfParams0);
        (int24 minTick1, int24 length1,) = LibGeometricDistribution.decodeParams(0, tickSpacing, useTwap, ldfParams1);

        return minTick0 <= minTick1 + length1 * tickSpacing && minTick1 <= minTick0 + length0 * tickSpacing;
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
}
