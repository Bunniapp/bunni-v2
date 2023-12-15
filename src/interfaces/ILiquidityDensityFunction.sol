// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

interface ILiquidityDensityFunction {
    function query(
        PoolKey calldata key,
        int24 roundedTick,
        int24 twapTick,
        int24 spotPriceTick,
        int24 tickSpacing,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    )
        external
        view
        returns (
            uint256 liquidityDensityX96,
            uint256 cumulativeAmount0DensityX96,
            uint256 cumulativeAmount1DensityX96,
            bytes32 newLdfState
        );

    function liquidityDensityX96(
        PoolKey calldata key,
        int24 roundedTick,
        int24 twapTick,
        int24 spotPriceTick,
        int24 tickSpacing,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external view returns (uint256);

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParamss) external view returns (bool);
}
