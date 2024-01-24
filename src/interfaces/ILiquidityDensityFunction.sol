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

    function cumulativeAmount0(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 twapTick,
        int24 spotPriceTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external view returns (uint256 amount0);

    function cumulativeAmount1(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 twapTick,
        int24 spotPriceTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external view returns (uint256 amount1);

    function inverseCumulativeAmount0(
        PoolKey calldata key,
        uint256 cumulativeAmount0,
        uint256 totalLiquidity,
        int24 twapTick,
        int24 spotPriceTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState,
        bool roundUp
    ) external view returns (bool success, int24 roundedTick);

    function inverseCumulativeAmount1(
        PoolKey calldata key,
        uint256 cumulativeAmount1,
        uint256 totalLiquidity,
        int24 twapTick,
        int24 spotPriceTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState,
        bool roundUp
    ) external view returns (bool success, int24 roundedTick);

    function liquidityDensityX96(
        PoolKey calldata key,
        int24 roundedTick,
        int24 twapTick,
        int24 spotPriceTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external view returns (uint256);

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams) external view returns (bool);
}
