// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";

import {Ownable} from "solady/auth/Ownable.sol";

import {roundTickSingle} from "../../lib/Math.sol";
import {IOracle} from "./IOracle.sol";
import {Guarded} from "../../base/Guarded.sol";
import {LibOracleUniGeoDistribution} from "./LibOracleUniGeoDistribution.sol";
import {ILiquidityDensityFunction} from "../../interfaces/ILiquidityDensityFunction.sol";

/// @title OracleUniGeoDistribution
/// @author zefram.eth
/// @notice A Uniform distribution where one side is bounded by an oracle-determined rick. It is managed
/// by an owner who can switch the distribution to a geometric distribution or back to a uniform distribution.
/// The alpha of the geometric distribution can also be set by the owner.
contract OracleUniGeoDistribution is ILiquidityDensityFunction, Guarded, Ownable {
    using TickMath for *;
    using PoolIdLibrary for PoolKey;

    uint256 internal constant INITIALIZED_STATE = 1 << 248;

    IOracle public immutable oracle;

    mapping(PoolId => uint256) public lastParamUpdateBlockOfPool;

    constructor(address hub_, address hook_, address quoter_, address initialOwner_, IOracle oracle_)
        Guarded(hub_, hook_, quoter_)
    {
        _initializeOwner(initialOwner_);
        oracle = oracle_;
    }

    /// @inheritdoc ILiquidityDensityFunction
    function query(
        PoolKey calldata key,
        int24 roundedTick,
        int24, /* twapTick */
        int24, /* spotPriceTick */
        bytes32 ldfParams,
        bytes32 ldfState
    )
        external
        view
        override
        guarded
        returns (
            uint256 liquidityDensityX96_,
            uint256 cumulativeAmount0DensityX96,
            uint256 cumulativeAmount1DensityX96,
            bytes32 newLdfState,
            bool shouldSurge
        )
    {
        int24 oracleRick = floorPriceToRick(oracle.getFloorPrice(), key.tickSpacing);
        (
            int24 tickLower,
            int24 tickUpper,
            uint256 alphaX96,
            LibOracleUniGeoDistribution.DistributionType distributionType
        ) = LibOracleUniGeoDistribution.decodeParams({
            ldfParams: ldfParams,
            oracleTick: oracleRick,
            tickSpacing: key.tickSpacing
        });
        (bool initialized, int24 lastOracleRick, uint256 lastParamUpdateBlock) = _decodeState(ldfState);
        uint256 newLastParamUpdateBlock = 0; // init to 0 if uninitialized since lastParamUpdateBlockOfPool would be 0
        if (initialized) {
            // should surge if param was updated or oracle rick has updated
            newLastParamUpdateBlock = lastParamUpdateBlockOfPool[key.toId()];
            shouldSurge = lastParamUpdateBlock != newLastParamUpdateBlock || oracleRick != lastOracleRick;
        }

        (liquidityDensityX96_, cumulativeAmount0DensityX96, cumulativeAmount1DensityX96) = LibOracleUniGeoDistribution
            .query({
            roundedTick: roundedTick,
            tickSpacing: key.tickSpacing,
            tickLower: tickLower,
            tickUpper: tickUpper,
            alphaX96: alphaX96,
            distributionType: distributionType
        });
        newLdfState = _encodeState(oracleRick, newLastParamUpdateBlock);
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
        view
        override
        guarded
        returns (
            bool success,
            int24 roundedTick,
            uint256 cumulativeAmount0_,
            uint256 cumulativeAmount1_,
            uint256 swapLiquidity
        )
    {
        int24 oracleRick = floorPriceToRick(oracle.getFloorPrice(), key.tickSpacing);
        (
            int24 tickLower,
            int24 tickUpper,
            uint256 alphaX96,
            LibOracleUniGeoDistribution.DistributionType distributionType
        ) = LibOracleUniGeoDistribution.decodeParams({
            ldfParams: ldfParams,
            oracleTick: oracleRick,
            tickSpacing: key.tickSpacing
        });

        return LibOracleUniGeoDistribution.computeSwap({
            inverseCumulativeAmountInput: inverseCumulativeAmountInput,
            totalLiquidity: totalLiquidity,
            zeroForOne: zeroForOne,
            exactIn: exactIn,
            tickSpacing: key.tickSpacing,
            tickLower: tickLower,
            tickUpper: tickUpper,
            alphaX96: alphaX96,
            distributionType: distributionType
        });
    }

    /// @inheritdoc ILiquidityDensityFunction
    function cumulativeAmount0(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24, /* twapTick */
        int24, /* spotPriceTick */
        bytes32 ldfParams,
        bytes32 /* ldfState */
    ) external view override guarded returns (uint256) {
        int24 oracleRick = floorPriceToRick(oracle.getFloorPrice(), key.tickSpacing);
        (
            int24 tickLower,
            int24 tickUpper,
            uint256 alphaX96,
            LibOracleUniGeoDistribution.DistributionType distributionType
        ) = LibOracleUniGeoDistribution.decodeParams({
            ldfParams: ldfParams,
            oracleTick: oracleRick,
            tickSpacing: key.tickSpacing
        });

        return LibOracleUniGeoDistribution.cumulativeAmount0({
            roundedTick: roundedTick,
            totalLiquidity: totalLiquidity,
            tickSpacing: key.tickSpacing,
            tickLower: tickLower,
            tickUpper: tickUpper,
            alphaX96: alphaX96,
            distributionType: distributionType
        });
    }

    /// @inheritdoc ILiquidityDensityFunction
    function cumulativeAmount1(
        PoolKey calldata key,
        int24 roundedTick,
        uint256 totalLiquidity,
        int24, /* twapTick */
        int24, /* spotPriceTick */
        bytes32 ldfParams,
        bytes32 /* ldfState */
    ) external view override guarded returns (uint256) {
        int24 oracleRick = floorPriceToRick(oracle.getFloorPrice(), key.tickSpacing);
        (
            int24 tickLower,
            int24 tickUpper,
            uint256 alphaX96,
            LibOracleUniGeoDistribution.DistributionType distributionType
        ) = LibOracleUniGeoDistribution.decodeParams({
            ldfParams: ldfParams,
            oracleTick: oracleRick,
            tickSpacing: key.tickSpacing
        });

        return LibOracleUniGeoDistribution.cumulativeAmount1({
            roundedTick: roundedTick,
            totalLiquidity: totalLiquidity,
            tickSpacing: key.tickSpacing,
            tickLower: tickLower,
            tickUpper: tickUpper,
            alphaX96: alphaX96,
            distributionType: distributionType
        });
    }

    /// @inheritdoc ILiquidityDensityFunction
    function isValidParams(PoolKey calldata key, uint24 twapSecondsAgo, bytes32 ldfParams)
        external
        view
        override
        returns (bool)
    {
        return LibOracleUniGeoDistribution.isValidParams(
            key.tickSpacing, ldfParams, floorPriceToRick(oracle.getFloorPrice(), key.tickSpacing)
        );
    }

    function setDistribution(PoolKey calldata key, LibOracleUniGeoDistribution.DistributionType distributionType)
        external
        onlyOwner
    {
        // TODO
    }

    function setAlpha(PoolKey calldata key, uint32 alpha) external onlyOwner {
        // TODO
    }

    function setLdfParams(PoolKey calldata key, bytes32 ldfParams) external onlyOwner {
        // TODO
    }

    function floorPriceToRick(uint256 floorPriceWad, int24 tickSpacing) public pure returns (int24 rick) {
        // convert floor price to sqrt price
        uint160 sqrtPriceX96; // TODO

        // convert sqrt price to rick
        rick = roundTickSingle(sqrtPriceX96.getTickAtSqrtPrice(), tickSpacing);
    }

    function _decodeState(bytes32 ldfState)
        internal
        pure
        returns (bool initialized, int24 lastOracleRick, uint256 lastParamUpdateBlock)
    {
        // | initialized - 1 byte | lastOracleRick - 3 bytes | lastParamUpdateBlock - 28 bytes |
        initialized = uint8(bytes1(ldfState)) == 1;
        lastOracleRick = int24(uint24(bytes3(ldfState << 8)));
        lastParamUpdateBlock = uint224(bytes28(ldfState << 32));
    }

    function _encodeState(int24 lastOracleRick, uint256 lastParamUpdateBlock)
        internal
        pure
        returns (bytes32 ldfState)
    {
        // unsafe cast of lastParamUpdateBlock to uint224, we only use it for comparison so it's fine
        // plus it will take millions of years to overflow
        // | initialized - 1 byte | lastOracleRick - 3 bytes | lastParamUpdateBlock - 28 bytes |
        ldfState =
            bytes32(INITIALIZED_STATE + uint256(uint24(lastOracleRick)) << 224 + uint256(uint224(lastParamUpdateBlock)));
    }
}
