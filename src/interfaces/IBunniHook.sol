// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {ILockCallback} from "@uniswap/v4-core/src/interfaces/callback/ILockCallback.sol";
import {IDynamicFeeManager} from "@uniswap/v4-core/src/interfaces/IDynamicFeeManager.sol";

import {IOwnable} from "./IOwnable.sol";
import {Oracle} from "../lib/Oracle.sol";
import {IBunniHub} from "./IBunniHub.sol";
import {IBaseHook} from "./IBaseHook.sol";

interface IBunniHook is IBaseHook, IDynamicFeeManager, IOwnable, ILockCallback {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error BunniHook__Unauthorized();
    error BunniHook__SwapAlreadyInProgress();

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event SetHookFeesParams(uint96 indexed newModifier, address indexed newRecipient);

    /// -----------------------------------------------------------------------
    /// Structs
    /// -----------------------------------------------------------------------

    /// @member index The index of the last written observation for the pool
    /// @member cardinality The cardinality of the observations array for the pool
    /// @member cardinalityNext The cardinality target of the observations array for the pool, which will replace cardinality when enough observations are written
    struct ObservationState {
        uint16 index;
        uint16 cardinality;
        uint16 cardinalityNext;
    }

    /// -----------------------------------------------------------------------
    /// View functions
    /// -----------------------------------------------------------------------

    /// @notice Returns hook fees params
    function getHookFeesParams() external view returns (uint96 modifierVal, address recipient);

    /// @notice Returns the observation for the given pool key and observation index
    /// @param key The pool key
    /// @param index The observation index
    /// @return observation The observation struct
    function getObservation(PoolKey calldata key, uint256 index)
        external
        view
        returns (Oracle.Observation memory observation);

    /// @notice Returns the TWAP oracle observation state for the given pool key
    /// @param key The pool key
    /// @return state The state struct
    function getState(PoolKey calldata key) external view returns (ObservationState memory state);

    /// @notice Observe the given pool for the timestamps
    /// @param key The pool key
    /// @param secondsAgos The timestamps to observe
    /// @return tickCumulatives The tick cumulatives for the given timestamps
    function observe(PoolKey calldata key, uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives);

    /// @notice Validates if the given hook params are valid
    /// @param hookParams The hook params
    /// @return isValid True if the hook params are valid
    function isValidParams(bytes32 hookParams) external view returns (bool);

    /// -----------------------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------------------

    /// @notice Increase the cardinality target for the given pool
    /// @param key The pool key
    /// @param cardinalityNext The new cardinality target
    /// @return cardinalityNextOld The old cardinality target
    /// @return cardinalityNextNew The new cardinality target
    function increaseCardinalityNext(PoolKey calldata key, uint16 cardinalityNext)
        external
        returns (uint16 cardinalityNextOld, uint16 cardinalityNextNew);

    /// -----------------------------------------------------------------------
    /// BunniHub functions
    /// -----------------------------------------------------------------------

    /// @notice Update the TWAP oracle for the given pool. Only callable by BunniHub.
    /// @param id The pool id
    /// @param tick The current tick
    /// @param twapSecondsAgo The time window for the TWAP observed
    /// @return arithmeticMeanTick The TWAP tick. 0 if `twapSecondsAgo` is 0.
    function updateOracleAndObserve(PoolId id, int24 tick, uint24 twapSecondsAgo)
        external
        returns (int24 arithmeticMeanTick);

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    /// @notice Set the hook fees params. Only callable by the owner.
    /// @param newModifier The new fee modifier
    /// @param newRecipient The new recipient
    function setHookFeesParams(uint96 newModifier, address newRecipient) external;
}
