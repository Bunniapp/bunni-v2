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
            bytes32 newLdfState,
            bool shouldSurge
        );

    function computeSwap(
        PoolKey calldata key,
        uint256 inverseCumulativeAmountInput,
        uint256 totalLiquidity,
        bool zeroForOne,
        bool exactIn,
        int24 twapTick,
        int24 spotPriceTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external view returns (bool success, int24 roundedTick, uint256 cumulativeAmount, uint128 swapLiquidity);

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams) external view returns (bool);

    function cumulativeAmount0(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 twapTick,
        int24 spotPriceTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external view returns (uint256);

    function cumulativeAmount1(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 twapTick,
        int24 spotPriceTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external view returns (uint256);
}
