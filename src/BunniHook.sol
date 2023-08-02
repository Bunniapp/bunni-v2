// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {IHookFeeManager} from "@uniswap/v4-core/contracts/interfaces/IHookFeeManager.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {IDynamicFeeManager} from "@uniswap/v4-core/contracts/interfaces/IDynamicFeeManager.sol";

import {BaseHook} from "@uniswap/v4-periphery/contracts/BaseHook.sol";
import {Oracle} from "@uniswap/v4-periphery/contracts/libraries/Oracle.sol";

import {IBunniHub, BunniTokenState} from "./interfaces/IBunniHub.sol";

/// @notice Bunni Hook
contract BunniHook is BaseHook, IHookFeeManager, IDynamicFeeManager {
    using Oracle for Oracle.Observation[65535];
    using PoolIdLibrary for PoolKey;

    error BunniHook__BunniTokenNotInitialized();

    IBunniHub public immutable hub;

    /// @member index The index of the last written observation for the pool
    /// @member cardinality The cardinality of the observations array for the pool
    /// @member cardinalityNext The cardinality target of the observations array for the pool, which will replace cardinality when enough observations are written
    struct ObservationState {
        uint16 index;
        uint16 cardinality;
        uint16 cardinalityNext;
    }

    /// @notice The list of observations for a given pool ID
    mapping(PoolId => Oracle.Observation[65535]) public observations;
    /// @notice The current observation array state for the given pool ID
    mapping(PoolId => ObservationState) public states;

    constructor(IPoolManager _poolManager, IBunniHub hub_) BaseHook(_poolManager) {
        hub = hub_;
    }

    /// -----------------------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------------------

    /// @notice Increase the cardinality target for the given pool
    function increaseCardinalityNext(PoolKey calldata key, uint16 cardinalityNext)
        external
        returns (uint16 cardinalityNextOld, uint16 cardinalityNextNew)
    {
        PoolId id = PoolId.wrap(keccak256(abi.encode(key)));

        ObservationState storage state = states[id];

        cardinalityNextOld = state.cardinalityNext;
        cardinalityNextNew = observations[id].grow(cardinalityNextOld, cardinalityNext);
        state.cardinalityNext = cardinalityNextNew;
    }

    /// -----------------------------------------------------------------------
    /// View functions
    /// -----------------------------------------------------------------------

    /// @notice Returns the observation for the given pool key and observation index
    function getObservation(PoolKey calldata key, uint256 index)
        external
        view
        returns (Oracle.Observation memory observation)
    {
        observation = observations[PoolId.wrap(keccak256(abi.encode(key)))][index];
    }

    /// @notice Returns the state for the given pool key
    function getState(PoolKey calldata key) external view returns (ObservationState memory state) {
        state = states[PoolId.wrap(keccak256(abi.encode(key)))];
    }

    /// @notice Observe the given pool for the timestamps
    function observe(PoolKey calldata key, uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s)
    {
        PoolId id = key.toId();

        ObservationState memory state = states[id];

        (, int24 tick,,,,) = poolManager.getSlot0(id);

        uint128 liquidity = poolManager.getLiquidity(id);

        return observations[id].observe(_blockTimestamp(), secondsAgos, tick, state.index, liquidity, state.cardinality);
    }

    /// -----------------------------------------------------------------------
    /// Hooks
    /// -----------------------------------------------------------------------

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: true,
            beforeModifyPosition: true,
            afterModifyPosition: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }

    /// @inheritdoc IDynamicFeeManager
    function getFee(PoolKey calldata key) external pure override returns (uint24) {
        return 100; // TODO
    }

    /// @inheritdoc IHookFeeManager
    function getHookSwapFee(PoolKey calldata key) external view override returns (uint8) {
        return 100; // TODO
    }

    /// @inheritdoc IHookFeeManager
    function getHookWithdrawFee(PoolKey calldata key) external view override returns (uint8) {
        return 0;
    }

    /// @inheritdoc IHooks
    function afterInitialize(address, PoolKey calldata key, uint160, int24)
        external
        override
        poolManagerOnly
        returns (bytes4)
    {
        PoolId id = key.toId();
        (states[id].cardinality, states[id].cardinalityNext) = observations[id].initialize(_blockTimestamp());
        return BunniHook.afterInitialize.selector;
    }

    /// @inheritdoc IHooks
    function beforeModifyPosition(address, PoolKey calldata key, IPoolManager.ModifyPositionParams calldata)
        external
        override
        poolManagerOnly
        returns (bytes4)
    {
        _updatePool(key, false);
        return BunniHook.beforeModifyPosition.selector;
    }

    /// @inheritdoc IHooks
    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata)
        external
        override
        poolManagerOnly
        returns (bytes4)
    {
        _updatePool(key, true);
        return BunniHook.beforeSwap.selector;
    }

    /// -----------------------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------------------

    /// @dev For mocking
    function _blockTimestamp() internal view virtual returns (uint32) {
        return uint32(block.timestamp);
    }

    /// @dev Called before any action that potentially modifies pool price or liquidity, such as swap or modify position
    function _updatePool(PoolKey calldata key, bool shiftPosition) private {
        PoolId id = key.toId();
        (, int24 tick,,,,) = poolManager.getSlot0(id);
        uint128 liquidity = poolManager.getLiquidity(id);

        // update TWAP oracle
        (states[id].index, states[id].cardinality) = observations[id].write(
            states[id].index, _blockTimestamp(), tick, liquidity, states[id].cardinality, states[id].cardinalityNext
        );

        if (shiftPosition) {
            // shift position if:
            // 1) spot price is out of range
            // 2) TWAP is out of range
            // shift next to the nearest of spot price & TWAP

            // query TWAP value
            int24 arithmeticMeanTick;
            BunniTokenState memory bunniState;
            {
                bunniState = hub.bunniTokenState(hub.bunniTokenOfPool(id));
                if (!bunniState.initialized) revert BunniHook__BunniTokenNotInitialized();

                ObservationState memory state = states[id];
                uint32[] memory secondsAgos = new uint32[](2);
                secondsAgos[0] = bunniState.twapSecondsAgo;
                secondsAgos[1] = 0;
                (int56[] memory tickCumulatives,) = observations[id].observe(
                    _blockTimestamp(), secondsAgos, tick, state.index, liquidity, state.cardinality
                );
                int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
                arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(bunniState.twapSecondsAgo)));
            }

            int24 tickLowerBoundary = bunniState.tickLower - key.tickSpacing;
            if (tick < tickLowerBoundary && arithmeticMeanTick < tickLowerBoundary && uint8(bunniState.mode) % 2 == 1) {
                // shift left
                // shift values are negative
                int24 twapShift = (arithmeticMeanTick - bunniState.tickLower) / key.tickSpacing * key.tickSpacing;
                int24 spotShift = tick - bunniState.tickLower;
                // use the minimum absolute shift (maximum negative shift)
                hub.hookShiftPosition(key, twapShift > spotShift ? twapShift : spotShift);
            } else if (
                tick > bunniState.tickUpper && arithmeticMeanTick > bunniState.tickUpper && uint8(bunniState.mode) >= 2
            ) {
                // shift right
                // shift values are positive
                int24 twapShift = (arithmeticMeanTick - bunniState.tickUpper) / key.tickSpacing * key.tickSpacing;
                int24 spotShift = tick - bunniState.tickUpper;
                // use the minimum absolute shift (minimum positive shift)
                hub.hookShiftPosition(key, twapShift < spotShift ? twapShift : spotShift);
            }
        }
    }
}
