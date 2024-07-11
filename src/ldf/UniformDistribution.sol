// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import "./ShiftMode.sol";
import {LibUniformDistribution} from "./LibUniformDistribution.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

/// @title UniformDistribution
/// @author zefram.eth
/// @notice Uniform distribution between two ticks, equivalent to a basic Uniswap v3 position.
/// Can shift using TWAP.
contract UniformDistribution is ILiquidityDensityFunction {
    uint32 internal constant INITIALIZED_STATE = 1 << 24;

    /// @inheritdoc ILiquidityDensityFunction
    function query(
        PoolKey calldata key,
        int24 roundedTick,
        int24 twapTick,
        int24, /* spotPriceTick */
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
            bytes32 newLdfState,
            bool shouldSurge
        )
    {
        (int24 tickLower, int24 tickUpper, ShiftMode shiftMode) =
            LibUniformDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastTickLower) = _decodeState(ldfState);
        if (initialized) {
            int24 tickLength = tickUpper - tickLower;
            tickLower = enforceShiftMode(tickLower, lastTickLower, shiftMode);
            tickUpper = tickLower + tickLength;
            shouldSurge = tickLower != lastTickLower;
        }

        (liquidityDensityX96_, cumulativeAmount0DensityX96, cumulativeAmount1DensityX96) =
            LibUniformDistribution.query(roundedTick, key.tickSpacing, tickLower, tickUpper);
        newLdfState = _encodeState(tickLower);
    }

    /// @inheritdoc ILiquidityDensityFunction
    function computeSwap(
        PoolKey calldata key,
        uint256 inverseCumulativeAmountInput,
        uint256 totalLiquidity,
        bool zeroForOne,
        bool exactIn,
        int24 twapTick,
        int24, /* spotPriceTick */
        bytes32 ldfParams,
        bytes32 ldfState
    )
        external
        pure
        override
        returns (bool success, int24 roundedTick, uint256 cumulativeAmount, uint256 swapLiquidity)
    {
        (int24 tickLower, int24 tickUpper, ShiftMode shiftMode) =
            LibUniformDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastTickLower) = _decodeState(ldfState);
        if (initialized) {
            int24 tickLength = tickUpper - tickLower;
            tickLower = enforceShiftMode(tickLower, lastTickLower, shiftMode);
            tickUpper = tickLower + tickLength;
        }

        return LibUniformDistribution.computeSwap(
            inverseCumulativeAmountInput, totalLiquidity, zeroForOne, exactIn, key.tickSpacing, tickLower, tickUpper
        );
    }

    /// @inheritdoc ILiquidityDensityFunction
    function cumulativeAmount0(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 twapTick,
        int24, /* spotPriceTick */
        bytes32 ldfParams,
        bytes32 ldfState
    ) external pure override returns (uint256) {
        (int24 tickLower, int24 tickUpper, ShiftMode shiftMode) =
            LibUniformDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastTickLower) = _decodeState(ldfState);
        if (initialized) {
            int24 tickLength = tickUpper - tickLower;
            tickLower = enforceShiftMode(tickLower, lastTickLower, shiftMode);
            tickUpper = tickLower + tickLength;
        }

        return
            LibUniformDistribution.cumulativeAmount0(roundedTick, totalLiquidity, key.tickSpacing, tickLower, tickUpper);
    }

    /// @inheritdoc ILiquidityDensityFunction
    function cumulativeAmount1(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 twapTick,
        int24, /* spotPriceTick */
        bytes32 ldfParams,
        bytes32 ldfState
    ) external pure override returns (uint256) {
        (int24 tickLower, int24 tickUpper, ShiftMode shiftMode) =
            LibUniformDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastTickLower) = _decodeState(ldfState);
        if (initialized) {
            int24 tickLength = tickUpper - tickLower;
            tickLower = enforceShiftMode(tickLower, lastTickLower, shiftMode);
            tickUpper = tickLower + tickLength;
        }

        return
            LibUniformDistribution.cumulativeAmount1(roundedTick, totalLiquidity, key.tickSpacing, tickLower, tickUpper);
    }

    /// @inheritdoc ILiquidityDensityFunction
    function isValidParams(PoolKey calldata key, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        return LibUniformDistribution.isValidParams(key.tickSpacing, twapSecondsAgo, ldfParams);
    }

    function _decodeState(bytes32 ldfState) internal pure returns (bool initialized, int24 lastTickLower) {
        // | initialized - 1 byte | lastTickLower - 3 bytes |
        initialized = uint8(bytes1(ldfState)) == 1;
        lastTickLower = int24(uint24(bytes3(ldfState << 8)));
    }

    function _encodeState(int24 lastTickLower) internal pure returns (bytes32 ldfState) {
        // | initialized - 1 byte | lastTickLower - 3 bytes |
        ldfState = bytes32(bytes4(INITIALIZED_STATE + uint32(uint24(lastTickLower))));
    }
}
