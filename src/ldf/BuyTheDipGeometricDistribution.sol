// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {LibBuyTheDipGeometricDistribution} from "./LibBuyTheDipGeometricDistribution.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

/// @title BuyTheDipGeometricDistribution
/// @author zefram.eth
/// @notice Geometric distribution that switches to a different alpha value when the TWAP
/// tick reaches a certain threshold. Does not shift. Does not have carpet liquidity.
contract BuyTheDipGeometricDistribution is ILiquidityDensityFunction {
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
        (
            int24 minTick,
            int24 length,
            uint256 alphaX96,
            uint256 altAlphaX96,
            int24 altThreshold,
            bool altThresholdDirection
        ) = LibBuyTheDipGeometricDistribution.decodeParams(ldfParams);
        (bool initialized, int24 lastTwapTick) = _decodeState(ldfState);
        if (initialized) {
            // should surge if switched from one alpha to another
            shouldSurge = LibBuyTheDipGeometricDistribution.shouldUseAltAlpha(
                twapTick, altThreshold, altThresholdDirection
            ) != LibBuyTheDipGeometricDistribution.shouldUseAltAlpha(lastTwapTick, altThreshold, altThresholdDirection);
        }

        (liquidityDensityX96_, cumulativeAmount0DensityX96, cumulativeAmount1DensityX96) =
        LibBuyTheDipGeometricDistribution.query(
            roundedTick,
            key.tickSpacing,
            twapTick,
            minTick,
            length,
            alphaX96,
            altAlphaX96,
            altThreshold,
            altThresholdDirection
        );
        newLdfState = _encodeState(twapTick);
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
        bytes32 /* ldfState */
    )
        external
        pure
        override
        returns (bool success, int24 roundedTick, uint256 cumulativeAmount, uint256 swapLiquidity)
    {
        (
            int24 minTick,
            int24 length,
            uint256 alphaX96,
            uint256 altAlphaX96,
            int24 altThreshold,
            bool altThresholdDirection
        ) = LibBuyTheDipGeometricDistribution.decodeParams(ldfParams);

        return LibBuyTheDipGeometricDistribution.computeSwap(
            inverseCumulativeAmountInput,
            totalLiquidity,
            zeroForOne,
            exactIn,
            key.tickSpacing,
            twapTick,
            minTick,
            length,
            alphaX96,
            altAlphaX96,
            altThreshold,
            altThresholdDirection
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
        bytes32 /* ldfState */
    ) external pure override returns (uint256) {
        (
            int24 minTick,
            int24 length,
            uint256 alphaX96,
            uint256 altAlphaX96,
            int24 altThreshold,
            bool altThresholdDirection
        ) = LibBuyTheDipGeometricDistribution.decodeParams(ldfParams);

        return LibBuyTheDipGeometricDistribution.cumulativeAmount0(
            roundedTick,
            totalLiquidity,
            key.tickSpacing,
            twapTick,
            minTick,
            length,
            alphaX96,
            altAlphaX96,
            altThreshold,
            altThresholdDirection
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
        bytes32 /* ldfState */
    ) external pure override returns (uint256) {
        (
            int24 minTick,
            int24 length,
            uint256 alphaX96,
            uint256 altAlphaX96,
            int24 altThreshold,
            bool altThresholdDirection
        ) = LibBuyTheDipGeometricDistribution.decodeParams(ldfParams);

        return LibBuyTheDipGeometricDistribution.cumulativeAmount1(
            roundedTick,
            totalLiquidity,
            key.tickSpacing,
            twapTick,
            minTick,
            length,
            alphaX96,
            altAlphaX96,
            altThreshold,
            altThresholdDirection
        );
    }

    /// @inheritdoc ILiquidityDensityFunction
    function isValidParams(PoolKey calldata key, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        pure
        override
        returns (bool)
    {
        return LibBuyTheDipGeometricDistribution.isValidParams(key.tickSpacing, twapSecondsAgo, ldfParams);
    }

    function _decodeState(bytes32 ldfState) internal pure returns (bool initialized, int24 lastTwapTick) {
        // | initialized - 1 byte | lastTwapTick - 3 bytes |
        initialized = uint8(bytes1(ldfState)) == 1;
        lastTwapTick = int24(uint24(bytes3(ldfState << 8)));
    }

    function _encodeState(int24 lastTwapTick) internal pure returns (bytes32 ldfState) {
        // | initialized - 1 byte | lastTwapTick - 3 bytes |
        ldfState = bytes32(bytes4(INITIALIZED_STATE + uint32(uint24(lastTwapTick))));
    }
}
