// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {LibUniformDistribution} from "./LibUniformDistribution.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract UniformDistribution is ILiquidityDensityFunction {
    function query(
        PoolKey calldata key,
        int24 roundedTick,
        int24, /* twapTick */
        int24, /* spotPriceTick */
        bool, /* useTwap */
        bytes32 ldfParams,
        bytes32 /* ldfState */
    )
        external
        pure
        override
        returns (
            uint256 liquidityDensityX96_,
            uint256 cumulativeAmount0DensityX96,
            uint256 cumulativeAmount1DensityX96,
            bytes32 newLdfState,
            bool shouldSurge
        )
    {
        (int24 tickLower, int24 tickUpper) = LibUniformDistribution.decodeParams(ldfParams);
        (liquidityDensityX96_, cumulativeAmount0DensityX96, cumulativeAmount1DensityX96) =
            LibUniformDistribution.query(roundedTick, key.tickSpacing, tickLower, tickUpper);
        newLdfState = bytes32(0);
        shouldSurge = false;
    }

    function computeSwap(
        PoolKey calldata key,
        uint256 inverseCumulativeAmountInput,
        uint256 totalLiquidity,
        bool zeroForOne,
        bool exactIn,
        int24, /* twapTick */
        int24, /* spotPriceTick */
        bool, /* useTwap */
        bytes32 ldfParams,
        bytes32 /* ldfState */
    )
        external
        pure
        override
        returns (bool success, int24 roundedTick, uint256 cumulativeAmount, uint128 swapLiquidity)
    {
        (int24 tickLower, int24 tickUpper) = LibUniformDistribution.decodeParams(ldfParams);

        return LibUniformDistribution.computeSwap(
            inverseCumulativeAmountInput, totalLiquidity, zeroForOne, exactIn, key.tickSpacing, tickLower, tickUpper
        );
    }

    function isValidParams(int24 tickSpacing, uint24, /* twapSecondsAgo */ bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        return LibUniformDistribution.isValidParams(tickSpacing, ldfParams);
    }

    function cumulativeAmount0(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24, /* twapTick */
        int24, /* spotPriceTick */
        bool, /* useTwap */
        bytes32 ldfParams,
        bytes32 /* ldfState */
    ) external pure override returns (uint256) {
        (int24 tickLower, int24 tickUpper) = LibUniformDistribution.decodeParams(ldfParams);

        return
            LibUniformDistribution.cumulativeAmount0(roundedTick, totalLiquidity, key.tickSpacing, tickLower, tickUpper);
    }

    function cumulativeAmount1(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24, /* twapTick */
        int24, /* spotPriceTick */
        bool, /* useTwap */
        bytes32 ldfParams,
        bytes32 /* ldfState */
    ) external pure override returns (uint256) {
        (int24 tickLower, int24 tickUpper) = LibUniformDistribution.decodeParams(ldfParams);

        return
            LibUniformDistribution.cumulativeAmount1(roundedTick, totalLiquidity, key.tickSpacing, tickLower, tickUpper);
    }
}
