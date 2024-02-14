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

    error BunniHook__InvalidSwap();
    error BunniHook__Unauthorized();
    error BunniHook__NoAddLiquidity();

    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    /// @notice Emitted for swaps between currency0 and currency1
    /// @param id The abi encoded hash of the pool key struct for the pool that was modified
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param zeroForOne True if swapping token0 for token1, false otherwise
    /// @param inputAmount The input token amount
    /// @param outputAmount The output token amount
    /// @param sqrtPriceX96 The sqrt(price) of the pool after the swap, as a Q64.96
    /// @param tick The log base 1.0001 of the price of the pool after the swap
    /// @param fee The swap fee rate charged, 6 decimals
    /// @param totalLiquidity The total virtual liquidity of the pool during and after the swap
    event Swap(
        PoolId indexed id,
        address indexed sender,
        bool zeroForOne,
        uint256 inputAmount,
        uint256 outputAmount,
        uint160 sqrtPriceX96,
        int24 tick,
        uint24 fee,
        uint256 totalLiquidity
    );
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

    struct Slot0 {
        uint160 sqrtPriceX96;
        int24 tick;
        uint32 lastSwapTimestamp;
        uint32 lastSurgeTimestamp;
    }

    struct VaultSharePrices {
        bool initialized;
        uint120 sharePrice0;
        uint120 sharePrice1;
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

    function ldfStates(PoolId id) external view returns (bytes32);

    function slot0s(PoolId id)
        external
        view
        returns (uint160 sqrtPriceX96, int24 tick, uint32 lastSwapTimestamp, uint32 lastSurgeTimestamp);

    function vaultSharePricesAtLastSwap(PoolId id)
        external
        view
        returns (bool initialized, uint120 sharePrice0, uint120 sharePrice1);

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

    /// @notice Update the LDF state of the given pool. Only callable by BunniHub.
    /// @param id The pool id
    /// @param newState The new LDF state
    function updateLdfState(PoolId id, bytes32 newState) external;

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    /// @notice Set the hook fees params. Only callable by the owner.
    /// @param newModifier The new fee modifier
    /// @param newRecipient The new recipient
    function setHookFeesParams(uint96 newModifier, address newRecipient) external;
}
