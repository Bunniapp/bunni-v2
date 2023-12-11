// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {LibDiscreteLaplaceDistribution} from "./LibDiscreteLaplaceDistribution.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract DiscreteLaplaceDistribution is ILiquidityDensityFunction {
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
        (int24 mu, uint256 alphaX96) =
            LibDiscreteLaplaceDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams);
        return LibDiscreteLaplaceDistribution.query(roundedTick, tickSpacing, mu, alphaX96);
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
        (int24 mu, uint256 alphaX96) =
            LibDiscreteLaplaceDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams);
        return LibDiscreteLaplaceDistribution.liquidityDensityX96(roundedTick, tickSpacing, mu, alphaX96);
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        return LibDiscreteLaplaceDistribution.isValidParams(tickSpacing, twapSecondsAgo, ldfParams);
    }
}
