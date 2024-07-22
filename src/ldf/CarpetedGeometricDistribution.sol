// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import "./ShiftMode.sol";
import {LibCarpetedGeometricDistribution} from "./LibCarpetedGeometricDistribution.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

/// @title CarpetedGeometricDistribution
/// @author zefram.eth
/// @notice Geometric distribution with a "carpet" of uniform liquidity outside of the main range.
/// Should be used in production when TWAP is enabled, since we always have some liquidity in all ticks.
contract CarpetedGeometricDistribution is ILiquidityDensityFunction {
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
        (int24 minTick, int24 length, uint256 alphaX96, uint256 weightCarpet, ShiftMode shiftMode) =
            LibCarpetedGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
            shouldSurge = minTick != lastMinTick;
        }

        (liquidityDensityX96_, cumulativeAmount0DensityX96, cumulativeAmount1DensityX96) =
        LibCarpetedGeometricDistribution.query(roundedTick, key.tickSpacing, minTick, length, alphaX96, weightCarpet);
        newLdfState = _encodeState(minTick);
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
        (int24 minTick, int24 length, uint256 alphaX96, uint256 weightCarpet, ShiftMode shiftMode) =
            LibCarpetedGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
        }

        return LibCarpetedGeometricDistribution.computeSwap(
            inverseCumulativeAmountInput,
            totalLiquidity,
            zeroForOne,
            exactIn,
            key.tickSpacing,
            minTick,
            length,
            alphaX96,
            weightCarpet
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
        (int24 minTick, int24 length, uint256 alphaX96, uint256 weightCarpet, ShiftMode shiftMode) =
            LibCarpetedGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
        }

        return LibCarpetedGeometricDistribution.cumulativeAmount0(
            roundedTick, totalLiquidity, key.tickSpacing, minTick, length, alphaX96, weightCarpet
        );
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
        (int24 minTick, int24 length, uint256 alphaX96, uint256 weightCarpet, ShiftMode shiftMode) =
            LibCarpetedGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
        }

        return LibCarpetedGeometricDistribution.cumulativeAmount1(
            roundedTick, totalLiquidity, key.tickSpacing, minTick, length, alphaX96, weightCarpet
        );
    }

    /// @inheritdoc ILiquidityDensityFunction
    function isValidParams(PoolKey calldata key, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        return LibCarpetedGeometricDistribution.isValidParams(key.tickSpacing, twapSecondsAgo, ldfParams);
    }

    function _decodeState(bytes32 ldfState) internal pure returns (bool initialized, int24 lastMinTick) {
        // | initialized - 1 byte | lastMinTick - 3 bytes |
        initialized = uint8(bytes1(ldfState)) == 1;
        lastMinTick = int24(uint24(bytes3(ldfState << 8)));
    }

    function _encodeState(int24 lastMinTick) internal pure returns (bytes32 ldfState) {
        // | initialized - 1 byte | lastMinTick - 3 bytes |
        ldfState = bytes32(bytes4(INITIALIZED_STATE + uint32(uint24(lastMinTick))));
    }
}
