// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {LibGeometricDistribution} from "./LibGeometricDistribution.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract GeometricDistribution is ILiquidityDensityFunction {
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
        (int24 minTick, int24 length, uint256 alphaX96) =
            LibGeometricDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams);
        return LibGeometricDistribution.query(roundedTick, tickSpacing, minTick, length, alphaX96);
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
        (int24 minTick, int24 length, uint256 alphaX96) =
            LibGeometricDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams);
        return LibGeometricDistribution.liquidityDensityX96(roundedTick, tickSpacing, minTick, length, alphaX96);
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        return LibGeometricDistribution.isValidParams(tickSpacing, twapSecondsAgo, ldfParams);
    }
}
