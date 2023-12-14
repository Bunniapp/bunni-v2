// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {ILiquidityDensityFunction} from "../../src/interfaces/ILiquidityDensityFunction.sol";
import {LibDiscreteLaplaceDistribution} from "../../src/ldf/LibDiscreteLaplaceDistribution.sol";

/// @dev DiscreteLaplaceDistribution with a modifiable mu for testing
contract MockLDF is ILiquidityDensityFunction {
    int24 internal _mu;

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
        view
        override
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        (, uint256 alphaX96) = LibDiscreteLaplaceDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams);
        return LibDiscreteLaplaceDistribution.query(roundedTick, tickSpacing, _mu, alphaX96);
    }

    function liquidityDensityX96(
        PoolKey calldata, /* key */
        int24 roundedTick,
        int24 twapTick,
        int24, /* spotPriceTick */
        int24 tickSpacing,
        bool useTwap,
        bytes32 ldfParams
    ) external view override returns (uint256) {
        (, uint256 alphaX96) = LibDiscreteLaplaceDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams);
        return LibDiscreteLaplaceDistribution.liquidityDensityX96(roundedTick, tickSpacing, _mu, alphaX96);
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        return LibDiscreteLaplaceDistribution.isValidParams(tickSpacing, twapSecondsAgo, ldfParams);
    }

    function setMu(int24 mu) external {
        _mu = mu;
    }
}
