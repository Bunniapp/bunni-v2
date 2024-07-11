// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import "./ShiftMode.sol";
import {LibCarpetedDoubleGeometricDistribution} from "./LibCarpetedDoubleGeometricDistribution.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

/// @title CarpetedDoubleGeometricDistribution
/// @author zefram.eth
/// @notice Double geometric distribution with a "carpet" of uniform liquidity outside of the main range.
/// Should be used in production when TWAP is enabled, since we always have some liquidity in all ticks.
contract CarpetedDoubleGeometricDistribution is ILiquidityDensityFunction {
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
        LibCarpetedDoubleGeometricDistribution.Params memory params =
            LibCarpetedDoubleGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            params.minTick = enforceShiftMode(params.minTick, lastMinTick, params.shiftMode);
            shouldSurge = params.minTick != lastMinTick;
        }

        (liquidityDensityX96_, cumulativeAmount0DensityX96, cumulativeAmount1DensityX96) =
            LibCarpetedDoubleGeometricDistribution.query(roundedTick, key.tickSpacing, params);
        newLdfState = _encodeState(params.minTick);
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
        LibCarpetedDoubleGeometricDistribution.Params memory params =
            LibCarpetedDoubleGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            params.minTick = enforceShiftMode(params.minTick, lastMinTick, params.shiftMode);
        }

        return LibCarpetedDoubleGeometricDistribution.computeSwap(
            inverseCumulativeAmountInput, totalLiquidity, zeroForOne, exactIn, key.tickSpacing, params
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
        LibCarpetedDoubleGeometricDistribution.Params memory params =
            LibCarpetedDoubleGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            params.minTick = enforceShiftMode(params.minTick, lastMinTick, params.shiftMode);
        }

        return LibCarpetedDoubleGeometricDistribution.cumulativeAmount0(
            roundedTick, totalLiquidity, key.tickSpacing, params
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
        LibCarpetedDoubleGeometricDistribution.Params memory params =
            LibCarpetedDoubleGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            params.minTick = enforceShiftMode(params.minTick, lastMinTick, params.shiftMode);
        }

        return LibCarpetedDoubleGeometricDistribution.cumulativeAmount1(
            roundedTick, totalLiquidity, key.tickSpacing, params
        );
    }

    /// @inheritdoc ILiquidityDensityFunction
    function isValidParams(PoolKey calldata key, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        return LibCarpetedDoubleGeometricDistribution.isValidParams(key.tickSpacing, twapSecondsAgo, ldfParams);
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
