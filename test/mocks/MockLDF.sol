// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "forge-std/console.sol";

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import "../../src/ldf/ShiftMode.sol";
import {ILiquidityDensityFunction} from "../../src/interfaces/ILiquidityDensityFunction.sol";
import {LibGeometricDistribution} from "../../src/ldf/LibGeometricDistribution.sol";

/// @dev DiscreteLaplaceDistribution with a modifiable mu for testing
contract MockLDF is ILiquidityDensityFunction {
    int24 internal _minTick;

    uint32 internal constant INITIALIZED_STATE = 1 << 24;

    function query(
        PoolKey calldata key,
        int24 roundedTick,
        int24 twapTick,
        int24, /* spotPriceTick */
        bytes32 ldfParams,
        bytes32 ldfState
    )
        external
        view
        override
        returns (
            uint256 liquidityDensityX96_,
            uint256 cumulativeAmount0DensityX96,
            uint256 cumulativeAmount1DensityX96,
            bytes32 newLdfState,
            bool shouldSurge
        )
    {
        (int24 minTick, int24 length, uint256 alphaX96, ShiftMode shiftMode) =
            LibGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        minTick = _minTick;
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
            shouldSurge = minTick != lastMinTick;
        }

        (liquidityDensityX96_, cumulativeAmount0DensityX96, cumulativeAmount1DensityX96) =
            LibGeometricDistribution.query(roundedTick, key.tickSpacing, minTick, length, alphaX96);
        newLdfState = _encodeState(minTick);
    }

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
        view
        override
        returns (bool success, int24 roundedTick, uint256 cumulativeAmount, uint256 swapLiquidity)
    {
        (int24 minTick, int24 length, uint256 alphaX96, ShiftMode shiftMode) =
            LibGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        minTick = _minTick;
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
        }

        return LibGeometricDistribution.computeSwap(
            inverseCumulativeAmountInput,
            totalLiquidity,
            zeroForOne,
            exactIn,
            key.tickSpacing,
            minTick,
            length,
            alphaX96
        );
    }

    function cumulativeAmount0(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 twapTick,
        int24, /* spotPriceTick */
        bytes32 ldfParams,
        bytes32 ldfState
    ) external view override returns (uint256) {
        (int24 minTick, int24 length, uint256 alphaX96, ShiftMode shiftMode) =
            LibGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        minTick = _minTick;
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
        }

        return LibGeometricDistribution.cumulativeAmount0(
            roundedTick, totalLiquidity, key.tickSpacing, minTick, length, alphaX96
        );
    }

    function cumulativeAmount1(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 twapTick,
        int24, /* spotPriceTick */
        bytes32 ldfParams,
        bytes32 ldfState
    ) external view override returns (uint256) {
        (int24 minTick, int24 length, uint256 alphaX96, ShiftMode shiftMode) =
            LibGeometricDistribution.decodeParams(twapTick, key.tickSpacing, ldfParams);
        minTick = _minTick;
        (bool initialized, int24 lastMinTick) = _decodeState(ldfState);
        if (initialized) {
            minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
        }

        return LibGeometricDistribution.cumulativeAmount1(
            roundedTick, totalLiquidity, key.tickSpacing, minTick, length, alphaX96
        );
    }

    function isValidParams(PoolKey calldata key, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        return LibGeometricDistribution.isValidParams(key.tickSpacing, twapSecondsAgo, ldfParams);
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

    function setMinTick(int24 minTick) external {
        _minTick = minTick;
    }
}
