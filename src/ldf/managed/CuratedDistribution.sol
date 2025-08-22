// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";

import {LibMulticaller} from "multicaller/LibMulticaller.sol";

import "../ShiftMode.sol";
import {Q96} from "../../base/Constants.sol";
import {Guarded} from "../../base/Guarded.sol";
import {LDFType} from "../../types/LDFType.sol";
import {queryTwap} from "../../lib/QueryTWAP.sol";
import {roundTickSingle} from "../../lib/Math.sol";
import {IBunniHub} from "../../interfaces/IBunniHub.sol";
import {IBunniHook} from "../../interfaces/IBunniHook.sol";
import {BunniStateLibrary} from "../../lib/BunniStateLibrary.sol";
import {LibUniformDistribution} from "../LibUniformDistribution.sol";
import {LibGeometricDistribution} from "../LibGeometricDistribution.sol";
import {LibDoubleGeometricDistribution} from "../LibDoubleGeometricDistribution.sol";
import {ILiquidityDensityFunction} from "../../interfaces/ILiquidityDensityFunction.sol";
import {LibCarpetedGeometricDistribution} from "../LibCarpetedGeometricDistribution.sol";
import {LibCarpetedDoubleGeometricDistribution} from "../LibCarpetedDoubleGeometricDistribution.sol";

enum DistributionType {
    NULL, // exists so that if ldfParams is bytes32(0) we know it's not overridden
    UNIFORM,
    CARPETED_GEOMETRIC,
    CARPETED_DOUBLE_GEOMETRIC
}

/// @title CuratedDistribution
/// @author zefram.eth
/// @notice LDF managed by a curator who can switch between multiple basic LDFs & change LDF parameters
/// @dev The baseLdfParams of each base LDF cannot exceed 28 bytes. This is satisfied since the max
/// is 28 bytes which is used by the carpeted double geometric LDF.
contract CuratedDistribution is ILiquidityDensityFunction, Guarded {
    using BunniStateLibrary for IBunniHook;

    mapping(PoolId => bytes32) public ldfParamsOverride;

    /// @dev Minimum LDF density at the spot price after updating ldfParams. Prevents the curator
    /// from extracting value by shifting the liquidity out-of-range.
    uint256 internal constant MIN_LIQ_DENSITY_X96 = Q96 / 1000; // 0.1%

    bytes32 internal constant BASE_LDF_PARAMS_MASK = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000;

    // masks for sanitizing params
    // shift mode is removed since when only the shift mode is modified the state should not be cleared
    bytes28 internal constant UNIFORM_LDF_PARAMS_MASK = 0x00ffffffffffff000000000000000000000000000000000000000000;
    bytes28 internal constant GEOMETRIC_LDF_PARAMS_MASK = 0x00ffffffffffffffffffffffffff0000000000000000000000000000;
    bytes28 internal constant DOUBLE_GEOMETRIC_LDF_PARAMS_MASK =
        0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    event SetLdfParamsOverride(
        PoolId indexed id,
        DistributionType indexed distributionType,
        bytes32 indexed baseLdfParams,
        uint24 twapSecondsAgo
    );

    error Unauthorized();
    error InvalidLdfParams();
    error LiquidityDensityAtSpotPriceTooLow(uint256 liquidityDensityX96_);

    constructor(address hub_, address hook_, address quoter_) Guarded(hub_, hook_, quoter_) {}

    /// @inheritdoc ILiquidityDensityFunction
    function query(
        PoolKey calldata key,
        int24 roundedTick,
        int24 twapTick,
        int24 spotPriceTick,
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
        // override ldf params if needed
        PoolId id = key.toId();
        bytes32 ldfParamsOverride_ = ldfParamsOverride[id];
        ldfParams = ldfParamsOverride_ == bytes32(0) ? ldfParams : ldfParamsOverride_;

        // decode ldf params and check surge
        (DistributionType distro, uint24 twapSecondsAgo, bytes28 baseLdfParams) = _decodeLdfParams(ldfParams);
        if (twapSecondsAgo != 0) {
            twapTick = queryTwap(key, twapSecondsAgo);
        }
        (bool initialized, int24 lastMinTick, DistributionType lastDistributionType, bytes28 lastBaseLdfParams) =
            _decodeState(ldfState);
        if (initialized) {
            // should surge if param was updated
            // if param was updated, the ldfState should be cleared since state for the previous config
            // may affect the new config unnecessarily
            // for example, if the previous LDF was uniform with range [0, 10] and STATIC shift mode and the new
            // config is uniform with range [-100, -90] and RIGHT shift mode, if the state wasn't cleared then
            // the LDF will still be [0, 10] when it should really be [-100, -90].
            if (
                lastDistributionType != distro
                    || _sanitizeBaseLdfParams(lastDistributionType, lastBaseLdfParams)
                        != _sanitizeBaseLdfParams(distro, baseLdfParams)
            ) {
                shouldSurge = true;
                initialized = false; // this tells the later logic to ignore the state
            }
        }

        // compute results based on distribution type
        if (distro == DistributionType.UNIFORM) {
            (int24 tickLower, int24 tickUpper, ShiftMode shiftMode) =
                LibUniformDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);

            if (initialized) {
                (tickLower, tickUpper) =
                    _enforceUniformShiftMode(tickLower, tickUpper, shiftMode, lastMinTick, key.tickSpacing);
                shouldSurge = shouldSurge || tickLower != lastMinTick;
            }

            (liquidityDensityX96_, cumulativeAmount0DensityX96, cumulativeAmount1DensityX96) = LibUniformDistribution
                .query({roundedTick: roundedTick, tickSpacing: key.tickSpacing, tickLower: tickLower, tickUpper: tickUpper});

            // update ldf state
            newLdfState = _encodeState(tickLower, distro, baseLdfParams);
        } else if (distro == DistributionType.CARPETED_GEOMETRIC) {
            (int24 minTick, int24 length, uint256 alphaX96, uint256 weightCarpet, ShiftMode shiftMode) =
                LibCarpetedGeometricDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);
            if (initialized) {
                minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
                shouldSurge = shouldSurge || minTick != lastMinTick;
            }

            (liquidityDensityX96_, cumulativeAmount0DensityX96, cumulativeAmount1DensityX96) =
            LibCarpetedGeometricDistribution.query({
                roundedTick: roundedTick,
                tickSpacing: key.tickSpacing,
                minTick: minTick,
                length: length,
                alphaX96: alphaX96,
                weightCarpet: weightCarpet
            });

            // update ldf state
            newLdfState = _encodeState(minTick, distro, baseLdfParams);
        } else {
            LibCarpetedDoubleGeometricDistribution.Params memory params =
                LibCarpetedDoubleGeometricDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);
            if (initialized) {
                params.minTick = enforceShiftMode(params.minTick, lastMinTick, params.shiftMode);
                shouldSurge = shouldSurge || params.minTick != lastMinTick;
            }

            (liquidityDensityX96_, cumulativeAmount0DensityX96, cumulativeAmount1DensityX96) =
            LibCarpetedDoubleGeometricDistribution.query({
                roundedTick: roundedTick,
                tickSpacing: key.tickSpacing,
                params: params
            });

            // update ldf state
            newLdfState = _encodeState(params.minTick, distro, baseLdfParams);
        }
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
        // override ldf params if needed
        PoolId id = key.toId();
        bytes32 ldfParamsOverride_ = ldfParamsOverride[id];
        ldfParams = ldfParamsOverride_ == bytes32(0) ? ldfParams : ldfParamsOverride_;

        // decode ldf params
        (DistributionType distro, uint24 twapSecondsAgo, bytes28 baseLdfParams) = _decodeLdfParams(ldfParams);
        if (twapSecondsAgo != 0) {
            twapTick = queryTwap(key, twapSecondsAgo);
        }
        (bool initialized, int24 lastMinTick, DistributionType lastDistributionType, bytes28 lastBaseLdfParams) =
            _decodeState(ldfState);
        if (initialized) {
            // if param was updated, the ldfState should be cleared since state for the previous config
            // may affect the new config unnecessarily
            // for example, if the previous LDF was uniform with range [0, 10] and STATIC shift mode and the new
            // config is uniform with range [-100, -90] and RIGHT shift mode, if the state wasn't cleared then
            // the LDF will still be [0, 10] when it should really be [-100, -90].
            if (lastBaseLdfParams != baseLdfParams || lastDistributionType != distro) {
                initialized = false; // this tells the later logic to ignore the state
            }
        }

        if (distro == DistributionType.UNIFORM) {
            (int24 tickLower, int24 tickUpper, ShiftMode shiftMode) =
                LibUniformDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);

            if (initialized) {
                (tickLower, tickUpper) =
                    _enforceUniformShiftMode(tickLower, tickUpper, shiftMode, lastMinTick, key.tickSpacing);
            }

            return LibUniformDistribution.computeSwap({
                inverseCumulativeAmountInput: inverseCumulativeAmountInput,
                totalLiquidity: totalLiquidity,
                zeroForOne: zeroForOne,
                exactIn: exactIn,
                tickSpacing: key.tickSpacing,
                tickLower: tickLower,
                tickUpper: tickUpper
            });
        } else if (distro == DistributionType.CARPETED_GEOMETRIC) {
            (int24 minTick, int24 length, uint256 alphaX96, uint256 weightCarpet, ShiftMode shiftMode) =
                LibCarpetedGeometricDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);

            if (initialized) {
                minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
            }

            return LibCarpetedGeometricDistribution.computeSwap({
                inverseCumulativeAmountInput: inverseCumulativeAmountInput,
                totalLiquidity: totalLiquidity,
                zeroForOne: zeroForOne,
                exactIn: exactIn,
                tickSpacing: key.tickSpacing,
                minTick: minTick,
                length: length,
                alphaX96: alphaX96,
                weightCarpet: weightCarpet
            });
        } else {
            LibCarpetedDoubleGeometricDistribution.Params memory params =
                LibCarpetedDoubleGeometricDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);
            if (initialized) {
                params.minTick = enforceShiftMode(params.minTick, lastMinTick, params.shiftMode);
            }

            return LibCarpetedDoubleGeometricDistribution.computeSwap({
                inverseCumulativeAmountInput: inverseCumulativeAmountInput,
                totalLiquidity: totalLiquidity,
                zeroForOne: zeroForOne,
                exactIn: exactIn,
                tickSpacing: key.tickSpacing,
                params: params
            });
        }
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
    ) external view override guarded returns (uint256) {
        // override ldf params if needed
        PoolId id = key.toId();
        bytes32 ldfParamsOverride_ = ldfParamsOverride[id];
        ldfParams = ldfParamsOverride_ == bytes32(0) ? ldfParams : ldfParamsOverride_;

        // decode ldf params
        (DistributionType distro, uint24 twapSecondsAgo, bytes28 baseLdfParams) = _decodeLdfParams(ldfParams);
        if (twapSecondsAgo != 0) {
            twapTick = queryTwap(key, twapSecondsAgo);
        }
        (bool initialized, int24 lastMinTick, DistributionType lastDistributionType, bytes28 lastBaseLdfParams) =
            _decodeState(ldfState);
        if (initialized) {
            // if param was updated, the ldfState should be cleared since state for the previous config
            // may affect the new config unnecessarily
            // for example, if the previous LDF was uniform with range [0, 10] and STATIC shift mode and the new
            // config is uniform with range [-100, -90] and RIGHT shift mode, if the state wasn't cleared then
            // the LDF will still be [0, 10] when it should really be [-100, -90].
            if (lastBaseLdfParams != baseLdfParams || lastDistributionType != distro) {
                initialized = false; // this tells the later logic to ignore the state
            }
        }

        if (distro == DistributionType.UNIFORM) {
            (int24 tickLower, int24 tickUpper, ShiftMode shiftMode) =
                LibUniformDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);

            if (initialized) {
                (tickLower, tickUpper) =
                    _enforceUniformShiftMode(tickLower, tickUpper, shiftMode, lastMinTick, key.tickSpacing);
            }

            return LibUniformDistribution.cumulativeAmount0(
                roundedTick, totalLiquidity, key.tickSpacing, tickLower, tickUpper, false
            );
        } else if (distro == DistributionType.CARPETED_GEOMETRIC) {
            (int24 minTick, int24 length, uint256 alphaX96, uint256 weightCarpet, ShiftMode shiftMode) =
                LibCarpetedGeometricDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);

            if (initialized) {
                minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
            }

            return LibCarpetedGeometricDistribution.cumulativeAmount0({
                roundedTick: roundedTick,
                totalLiquidity: totalLiquidity,
                tickSpacing: key.tickSpacing,
                minTick: minTick,
                length: length,
                alphaX96: alphaX96,
                weightCarpet: weightCarpet
            });
        } else {
            LibCarpetedDoubleGeometricDistribution.Params memory params =
                LibCarpetedDoubleGeometricDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);
            if (initialized) {
                params.minTick = enforceShiftMode(params.minTick, lastMinTick, params.shiftMode);
            }

            return LibCarpetedDoubleGeometricDistribution.cumulativeAmount0({
                roundedTick: roundedTick,
                totalLiquidity: totalLiquidity,
                tickSpacing: key.tickSpacing,
                params: params
            });
        }
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
    ) external view override guarded returns (uint256) {
        // override ldf params if needed
        PoolId id = key.toId();
        bytes32 ldfParamsOverride_ = ldfParamsOverride[id];
        ldfParams = ldfParamsOverride_ == bytes32(0) ? ldfParams : ldfParamsOverride_;

        // decode ldf params
        (DistributionType distro, uint24 twapSecondsAgo, bytes28 baseLdfParams) = _decodeLdfParams(ldfParams);
        if (twapSecondsAgo != 0) {
            twapTick = queryTwap(key, twapSecondsAgo);
        }
        (bool initialized, int24 lastMinTick, DistributionType lastDistributionType, bytes28 lastBaseLdfParams) =
            _decodeState(ldfState);
        if (initialized) {
            // if param was updated, the ldfState should be cleared since state for the previous config
            // may affect the new config unnecessarily
            // for example, if the previous LDF was uniform with range [0, 10] and STATIC shift mode and the new
            // config is uniform with range [-100, -90] and RIGHT shift mode, if the state wasn't cleared then
            // the LDF will still be [0, 10] when it should really be [-100, -90].
            if (lastBaseLdfParams != baseLdfParams || lastDistributionType != distro) {
                initialized = false; // this tells the later logic to ignore the state
            }
        }

        if (distro == DistributionType.UNIFORM) {
            (int24 tickLower, int24 tickUpper, ShiftMode shiftMode) =
                LibUniformDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);

            if (initialized) {
                (tickLower, tickUpper) =
                    _enforceUniformShiftMode(tickLower, tickUpper, shiftMode, lastMinTick, key.tickSpacing);
            }

            return LibUniformDistribution.cumulativeAmount1(
                roundedTick, totalLiquidity, key.tickSpacing, tickLower, tickUpper, false
            );
        } else if (distro == DistributionType.CARPETED_GEOMETRIC) {
            (int24 minTick, int24 length, uint256 alphaX96, uint256 weightCarpet, ShiftMode shiftMode) =
                LibCarpetedGeometricDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);

            if (initialized) {
                minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
            }

            return LibCarpetedGeometricDistribution.cumulativeAmount1({
                roundedTick: roundedTick,
                totalLiquidity: totalLiquidity,
                tickSpacing: key.tickSpacing,
                minTick: minTick,
                length: length,
                alphaX96: alphaX96,
                weightCarpet: weightCarpet
            });
        } else {
            LibCarpetedDoubleGeometricDistribution.Params memory params =
                LibCarpetedDoubleGeometricDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);
            if (initialized) {
                params.minTick = enforceShiftMode(params.minTick, lastMinTick, params.shiftMode);
            }

            return LibCarpetedDoubleGeometricDistribution.cumulativeAmount1({
                roundedTick: roundedTick,
                totalLiquidity: totalLiquidity,
                tickSpacing: key.tickSpacing,
                params: params
            });
        }
    }

    /// @inheritdoc ILiquidityDensityFunction
    function isValidParams(PoolKey calldata key, uint24 twapSecondsAgo, bytes32 ldfParams, LDFType ldfType)
        external
        pure
        override
        returns (bool)
    {
        // force the twapSecondsAgo in hookParams to 0 because this LDF will override it
        if (twapSecondsAgo != 0) {
            return false;
        }

        return _isValidParams(key, ldfParams, ldfType);
    }

    /// @notice Sets the ldf params for the given pool. Only callable by the owner.
    /// @param key The PoolKey of the Uniswap v4 pool
    /// @param distributionType The distribution type specifying the base LDF (e.g. Geometric)
    /// @param baseLdfParams The ldf params of the base LDF. Limited to bytes28 since that's the max supported size.
    /// @param twapSecondsAgo The twapSecondsAgo to use for the LDF
    function setLdfParams(
        PoolKey calldata key,
        DistributionType distributionType,
        bytes28 baseLdfParams,
        uint24 twapSecondsAgo
    ) external {
        // can only be called by BunniToken owner
        PoolId id = key.toId();
        IBunniHub hub_ = IBunniHub(hub);
        address msgSender = LibMulticaller.senderOrSigner();
        if (msgSender != hub_.bunniTokenOfPool(id).owner()) {
            revert Unauthorized();
        }

        // ensure new params are valid
        // no need to check for ldfType since we always use DYNAMIC_AND_STATEFUL on init
        // distributionType is the last byte of ldfParams
        bytes32 ldfParams = bytes32(abi.encodePacked(baseLdfParams, twapSecondsAgo, distributionType));
        bool isValid = _isValidParams({key: key, ldfParams: ldfParams, ldfType: LDFType.DYNAMIC_AND_STATEFUL});
        if (!isValid) {
            revert InvalidLdfParams();
        }

        // ensure the liquidity density at the spot price rick is at least MIN_LIQ_DENSITY_X96
        IBunniHook bunniHook = IBunniHook(address(key.hooks));
        (, int24 tick,,) = bunniHook.slot0s(id);
        int24 roundedTick = roundTickSingle(tick, key.tickSpacing);
        bytes32 ldfState = bunniHook.ldfStates(id);
        int24 twapTick = twapSecondsAgo == 0 ? int24(0) : queryTwap(key, twapSecondsAgo);
        uint256 liquidityDensityX96_ = _liquidityDensity({
            key: key,
            roundedTick: roundedTick,
            twapTick: twapTick,
            spotPriceTick: tick,
            distro: distributionType,
            baseLdfParams: baseLdfParams,
            ldfState: ldfState
        });
        if (liquidityDensityX96_ < MIN_LIQ_DENSITY_X96) {
            revert LiquidityDensityAtSpotPriceTooLow(liquidityDensityX96_);
        }

        // override ldf params
        ldfParamsOverride[id] = ldfParams;
        emit SetLdfParamsOverride(id, distributionType, baseLdfParams, twapSecondsAgo);

        // increase cardinalityNext if the current observations array is not big enough
        bytes memory hookParams = hub_.hookParams(id);
        bytes32 secondWord;
        assembly ("memory-safe") {
            secondWord := mload(add(hookParams, 64))
        }
        uint32 oracleMinInterval = uint32(bytes4(secondWord));
        uint32 cardinalityNext = bunniHook.getCardinalityNext(id);
        uint32 cardinalityNextTarget = (twapSecondsAgo + (oracleMinInterval >> 1)) / oracleMinInterval + 1; // round up + 1
        if (cardinalityNextTarget > cardinalityNext) {
            bunniHook.increaseCardinalityNext(key, cardinalityNextTarget);
        }
    }

    function _isValidParams(PoolKey calldata key, bytes32 ldfParams, LDFType ldfType) internal pure returns (bool) {
        // ldfType needs to be DYNAMIC_AND_STATEFUL since we use ldfState to surge if params are updated
        if (ldfType != LDFType.DYNAMIC_AND_STATEFUL) {
            return false;
        }

        // decode ldf params
        // distribution type is always the last byte of ldfParams
        // | baseLdfParams - 31 bytes | distributionType - 1 byte |
        uint8 distributionTypeRaw = uint8(bytes1(ldfParams << 248));
        if (distributionTypeRaw == 0 || distributionTypeRaw > uint8(type(DistributionType).max)) {
            // invalid distribution type
            // can't be NULL or beyond max
            return false;
        }
        DistributionType distro = DistributionType(distributionTypeRaw);
        bytes32 baseLdfParams = ldfParams & BASE_LDF_PARAMS_MASK;
        uint8 shiftMode = uint8(bytes1(baseLdfParams)); // Use uint8 since we don't know if the value is in range yet. Due to the params format the first byte is always the shift mode.
        ldfType = shiftMode == uint8(ShiftMode.STATIC) ? LDFType.STATIC : LDFType.DYNAMIC_AND_STATEFUL; // need to fake ldfType to pass the base LDF checks since we always use DYNAMIC_AND_STATEFUL
        uint24 twapSecondsAgo = uint24(bytes3(ldfParams << 224));

        if (distro == DistributionType.UNIFORM) {
            return LibUniformDistribution.isValidParams({
                tickSpacing: key.tickSpacing,
                twapSecondsAgo: twapSecondsAgo,
                ldfParams: baseLdfParams,
                ldfType: ldfType
            });
        } else if (distro == DistributionType.CARPETED_GEOMETRIC) {
            return LibCarpetedGeometricDistribution.isValidParams({
                tickSpacing: key.tickSpacing,
                twapSecondsAgo: twapSecondsAgo,
                ldfParams: baseLdfParams,
                ldfType: ldfType
            });
        } else {
            return LibCarpetedDoubleGeometricDistribution.isValidParams({
                tickSpacing: key.tickSpacing,
                twapSecondsAgo: twapSecondsAgo,
                ldfParams: baseLdfParams,
                ldfType: ldfType
            });
        }
    }

    function _decodeLdfParams(bytes32 ldfParams)
        internal
        pure
        returns (DistributionType distributionType, uint24 twapSecondsAgo, bytes28 baseLdfParams)
    {
        // | baseLdfParams - 28 bytes | twapSecondsAgo - 3 bytes | distributionType - 1 byte |
        distributionType = DistributionType(uint8(bytes1(ldfParams << 248)));
        twapSecondsAgo = uint24(bytes3(ldfParams << 224));
        baseLdfParams = bytes28(ldfParams & BASE_LDF_PARAMS_MASK);
    }

    function _decodeState(bytes32 ldfState)
        internal
        pure
        returns (bool initialized, int24 lastMinTick, DistributionType lastDistributionType, bytes28 lastBaseLdfParams)
    {
        // | lastDistributionType - 1 byte | lastMinTick - 3 bytes | lastBaseLdfParams - 28 bytes |
        lastDistributionType = DistributionType(uint8(bytes1(ldfState)));
        lastMinTick = int24(uint24(bytes3(ldfState << 8)));
        lastBaseLdfParams = bytes28(ldfState << 32);
        initialized = lastDistributionType != DistributionType.NULL;
    }

    function _encodeState(int24 lastTwapTick, DistributionType lastDistributionType, bytes28 lastBaseLdfParams)
        internal
        pure
        returns (bytes32 ldfState)
    {
        // | lastDistributionType - 1 byte | lastTwapTick - 3 bytes | lastBaseLdfParams - 28 bytes |
        ldfState = bytes32(abi.encodePacked(lastDistributionType, lastTwapTick, lastBaseLdfParams));
    }

    function _enforceUniformShiftMode(
        int24 tickLower,
        int24 tickUpper,
        ShiftMode shiftMode,
        int24 lastMinTick,
        int24 tickSpacing
    ) internal pure returns (int24 tickLowerEnforced, int24 tickUpperEnforced) {
        int24 tickLength = tickUpper - tickLower;
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        tickLowerEnforced =
            int24(FixedPointMathLib.max(minUsableTick, enforceShiftMode(tickLower, lastMinTick, shiftMode)));
        tickUpperEnforced = int24(FixedPointMathLib.min(maxUsableTick, tickLowerEnforced + tickLength));
    }

    /// @dev Mask out irrelevant bytes when checking if the params are actually different.
    function _sanitizeBaseLdfParams(DistributionType distro, bytes28 baseLdfParams) internal pure returns (bytes28) {
        if (distro == DistributionType.UNIFORM) {
            return baseLdfParams & UNIFORM_LDF_PARAMS_MASK;
        } else if (distro == DistributionType.CARPETED_GEOMETRIC) {
            return baseLdfParams & GEOMETRIC_LDF_PARAMS_MASK;
        } else {
            return baseLdfParams & DOUBLE_GEOMETRIC_LDF_PARAMS_MASK;
        }
    }

    function _liquidityDensity(
        PoolKey calldata key,
        int24 roundedTick,
        int24 twapTick,
        int24 spotPriceTick,
        DistributionType distro,
        bytes28 baseLdfParams,
        bytes32 ldfState
    ) internal pure returns (uint256 liquidityDensityX96_) {
        (bool initialized, int24 lastMinTick, DistributionType lastDistributionType, bytes28 lastBaseLdfParams) =
            _decodeState(ldfState);
        if (initialized) {
            // should surge if param was updated
            // if param was updated, the ldfState should be cleared since state for the previous config
            // may affect the new config unnecessarily
            // for example, if the previous LDF was uniform with range [0, 10] and STATIC shift mode and the new
            // config is uniform with range [-100, -90] and RIGHT shift mode, if the state wasn't cleared then
            // the LDF will still be [0, 10] when it should really be [-100, -90].
            if (
                lastDistributionType != distro
                    || _sanitizeBaseLdfParams(lastDistributionType, lastBaseLdfParams)
                        != _sanitizeBaseLdfParams(distro, baseLdfParams)
            ) {
                initialized = false; // this tells the later logic to ignore the state
            }
        }

        // compute results based on distribution type
        if (distro == DistributionType.UNIFORM) {
            (int24 tickLower, int24 tickUpper, ShiftMode shiftMode) =
                LibUniformDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);

            if (initialized) {
                (tickLower, tickUpper) =
                    _enforceUniformShiftMode(tickLower, tickUpper, shiftMode, lastMinTick, key.tickSpacing);
            }

            liquidityDensityX96_ = LibUniformDistribution.liquidityDensityX96({
                roundedTick: roundedTick,
                tickSpacing: key.tickSpacing,
                tickLower: tickLower,
                tickUpper: tickUpper
            });
        } else if (distro == DistributionType.CARPETED_GEOMETRIC) {
            (int24 minTick, int24 length, uint256 alphaX96, uint256 weightCarpet, ShiftMode shiftMode) =
                LibCarpetedGeometricDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);
            if (initialized) {
                minTick = enforceShiftMode(minTick, lastMinTick, shiftMode);
            }

            liquidityDensityX96_ = LibCarpetedGeometricDistribution.liquidityDensityX96({
                roundedTick: roundedTick,
                tickSpacing: key.tickSpacing,
                minTick: minTick,
                length: length,
                alphaX96: alphaX96,
                weightCarpet: weightCarpet
            });
        } else {
            LibCarpetedDoubleGeometricDistribution.Params memory params =
                LibCarpetedDoubleGeometricDistribution.decodeParams(twapTick, key.tickSpacing, baseLdfParams);
            if (initialized) {
                params.minTick = enforceShiftMode(params.minTick, lastMinTick, params.shiftMode);
            }

            liquidityDensityX96_ = LibCarpetedDoubleGeometricDistribution.liquidityDensityX96({
                roundedTick: roundedTick,
                tickSpacing: key.tickSpacing,
                params: params
            });
        }
    }
}
