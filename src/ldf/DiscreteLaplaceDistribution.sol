// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import "./ShiftMode.sol";
import {LibDiscreteLaplaceDistribution} from "./LibDiscreteLaplaceDistribution.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract DiscreteLaplaceDistribution is ILiquidityDensityFunction {
    uint32 internal constant INITIALIZED_STATE = 1 << 24;

    function query(
        PoolKey calldata key,
        int24 roundedTick,
        int24 twapTick,
        int24, /* spotPriceTick */
        bool useTwap,
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
            bytes32 newLdfState
        )
    {
        (int24 mu, uint256 alphaX96, ShiftMode shiftMode) =
            LibDiscreteLaplaceDistribution.decodeParams(twapTick, key.tickSpacing, useTwap, ldfParams);
        (bool initialized, int24 lastMu) = _decodeState(ldfState);
        if (initialized) {
            mu = enforceShiftMode(mu, lastMu, shiftMode);
        }

        (liquidityDensityX96_, cumulativeAmount0DensityX96, cumulativeAmount1DensityX96) =
            LibDiscreteLaplaceDistribution.query(roundedTick, key.tickSpacing, mu, alphaX96);
        newLdfState = _encodeState(mu);
    }

    function inverseCumulativeAmount0(
        uint256 cumulativeAmount0,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 twapTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external pure override returns (uint160 sqrtPriceX96) {
        (int24 mu, uint256 alphaX96, ShiftMode shiftMode) =
            LibDiscreteLaplaceDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams);
        (bool initialized, int24 lastMu) = _decodeState(ldfState);
        if (initialized) {
            mu = enforceShiftMode(mu, lastMu, shiftMode);
        }

        return LibDiscreteLaplaceDistribution.inverseCumulativeAmount0(
            cumulativeAmount0, totalLiquidity, tickSpacing, mu, alphaX96
        );
    }

    function inverseCumulativeAmount1(
        uint256 cumulativeAmount1,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 twapTick,
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external pure override returns (uint160 sqrtPriceX96) {
        (int24 mu, uint256 alphaX96, ShiftMode shiftMode) =
            LibDiscreteLaplaceDistribution.decodeParams(twapTick, tickSpacing, useTwap, ldfParams);
        (bool initialized, int24 lastMu) = _decodeState(ldfState);
        if (initialized) {
            mu = enforceShiftMode(mu, lastMu, shiftMode);
        }

        return LibDiscreteLaplaceDistribution.inverseCumulativeAmount1(
            cumulativeAmount1, totalLiquidity, tickSpacing, mu, alphaX96
        );
    }

    function liquidityDensityX96(
        PoolKey calldata key,
        int24 roundedTick,
        int24 twapTick,
        int24, /* spotPriceTick */
        bool useTwap,
        bytes32 ldfParams,
        bytes32 ldfState
    ) external pure override returns (uint256) {
        (int24 mu, uint256 alphaX96, ShiftMode shiftMode) =
            LibDiscreteLaplaceDistribution.decodeParams(twapTick, key.tickSpacing, useTwap, ldfParams);
        (bool initialized, int24 lastMu) = _decodeState(ldfState);
        if (initialized) {
            mu = enforceShiftMode(mu, lastMu, shiftMode);
        }

        return LibDiscreteLaplaceDistribution.liquidityDensityX96(roundedTick, key.tickSpacing, mu, alphaX96);
    }

    function isValidParams(int24 tickSpacing, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        return LibDiscreteLaplaceDistribution.isValidParams(tickSpacing, twapSecondsAgo, ldfParams);
    }

    function _decodeState(bytes32 ldfState) internal pure returns (bool initialized, int24 lastMu) {
        // | initialized - 1 byte | lastMu - 3 bytes |
        initialized = uint8(bytes1(ldfState)) == 1;
        lastMu = int24(uint24(bytes3(ldfState << 8)));
    }

    function _encodeState(int24 lastMu) internal pure returns (bytes32 ldfState) {
        // | initialized - 1 byte | lastMu - 3 bytes |
        ldfState = bytes32(bytes4(INITIALIZED_STATE + uint32(uint24(lastMu))));
    }
}
