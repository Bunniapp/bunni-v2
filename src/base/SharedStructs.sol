// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import {PoolId, PoolKey, BalanceDelta, Currency} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {ERC4626} from "solady/tokens/ERC4626.sol";

import "./Constants.sol";
import {Oracle} from "../lib/Oracle.sol";
import {IBunniHook} from "../interfaces/IBunniHook.sol";
import {IBunniToken} from "../interfaces/IBunniToken.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

/// @title Contains structs shared between multiple contracts

struct PoolState {
    ILiquidityDensityFunction liquidityDensityFunction;
    IBunniToken bunniToken;
    uint24 twapSecondsAgo;
    bytes32 ldfParams;
    bytes32 hookParams;
    ERC4626 vault0;
    ERC4626 vault1;
    bool statefulLdf;
    uint24 minRawTokenRatio0;
    uint24 targetRawTokenRatio0;
    uint24 maxRawTokenRatio0;
    uint24 minRawTokenRatio1;
    uint24 targetRawTokenRatio1;
    uint24 maxRawTokenRatio1;
    bool amAmmEnabled;
    uint256 rawBalance0;
    uint256 rawBalance1;
    uint256 reserve0;
    uint256 reserve1;
}

struct RawPoolState {
    address immutableParamsPointer;
    uint256 rawBalance0;
    uint256 rawBalance1;
}

/// @notice The decoded hook params for a given pool
/// @member feeMin The minimum swap fee, 6 decimals
/// @member feeMax The maximum swap fee (may be exceeded if surge fee is active), 6 decimals
/// @member feeQuadraticMultiplier The quadratic multiplier for the dynamic swap fee formula, 6 decimals
/// @member feeTwapSecondsAgo The time window for the TWAP used by the dynamic swap fee formula
/// @member surgeFee The max surge swap fee, 6 decimals
/// @member surgeFeeHalfLife The half-life of the surge fee in seconds. The surge fee decays exponentially, and the half-life is the time it takes for the surge fee to decay to half its value.
/// @member surgeFeeAutostartThreshold Time after a swap when the surge fee exponential decay autostarts, in seconds. The autostart avoids the pool being stuck on a high fee.
/// @member vaultSurgeThreshold0 The threshold for the vault0 share price change to trigger the surge fee. Only used if both vaults are set.
///         1 / vaultSurgeThreshold is the minimum percentage change in the vault share price to trigger the surge fee.
/// @member vaultSurgeThreshold1 The threshold for the vault1 share price change to trigger the surge fee. Only used if both vaults are set.
///         1 / vaultSurgeThreshold is the minimum percentage change in the vault share price to trigger the surge fee.
/// @member rebalanceThreshold The threshold for triggering a rebalance from excess liquidity.
///         1 / rebalanceThreshold is the minimum ratio of excess liquidity to total liquidity to trigger a rebalance.
///         When set to 0, rebalancing is disabled.
/// @member rebalanceMaxSlippage The maximum slippage (vs TWAP) allowed during rebalancing, 5 decimals.
/// @member rebalanceTwapSecondsAgo The time window for the TWAP used during rebalancing
/// @member rebalanceOrderTTL The time-to-live for a rebalance order, in seconds
/// @member amAmmEnabled Whether the am-AMM is enabled for this pool
struct DecodedHookParams {
    uint24 feeMin;
    uint24 feeMax;
    uint24 feeQuadraticMultiplier;
    uint24 feeTwapSecondsAgo;
    uint24 surgeFee;
    uint16 surgeFeeHalfLife;
    uint16 surgeFeeAutostartThreshold;
    uint16 vaultSurgeThreshold0;
    uint16 vaultSurgeThreshold1;
    uint16 rebalanceThreshold;
    uint16 rebalanceMaxSlippage;
    uint16 rebalanceTwapSecondsAgo;
    uint16 rebalanceOrderTTL;
    bool amAmmEnabled;
}

/// @notice Contains mappings used by both BunniHook and BunniLogic. Makes passing
/// mappings to BunniHookLogic easier & cheaper.
/// @member observations The list of observations for a given pool ID
/// @member states The current TWAP oracle state for a given pool ID
/// @member rebalanceOrderHash The hash of the currently active rebalance order
/// @member rebalanceOrderDeadline The deadline for the currently active rebalance order
/// @member rebalanceOrderHookArgsHash The hash of the hook args for the currently active rebalance order
/// @member vaultSharePricesAtLastSwap The share prices of the vaults used by the pool at the last swap
/// @member ldfStates The LDF state for a given pool ID
/// @member slot0s The slot0 state for a given pool ID
struct HookStorage {
    mapping(PoolId => Oracle.Observation[MAX_CARDINALITY]) observations;
    mapping(PoolId => IBunniHook.ObservationState) states;
    mapping(PoolId id => bytes32) rebalanceOrderHash;
    mapping(PoolId id => uint256) rebalanceOrderDeadline;
    mapping(PoolId id => bytes32) rebalanceOrderHookArgsHash;
    mapping(PoolId => VaultSharePrices) vaultSharePricesAtLastSwap;
    mapping(PoolId => bytes32) ldfStates;
    mapping(PoolId => Slot0) slot0s;
}

/// @notice The slot0 state of a given pool
/// @member sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (currency1/currency0)
/// @member tick The log base 1.0001 of the ratio of the two assets (currency1/currency0)
/// @member lastSwapTimestamp The timestamp of the last swap (or rebalance execution)
/// @member lastSurgeTimestamp The timestamp of the last surge
struct Slot0 {
    uint160 sqrtPriceX96;
    int24 tick;
    uint32 lastSwapTimestamp;
    uint32 lastSurgeTimestamp;
}

/// @notice Tracks the share prices of vaults used by a pool using vaults for both currencies. Used for computing surges.
/// @member initialized True if the share prices have been initialized
/// @member sharePrice0 The underlying assets each share of vault0 represents, scaled by 1e18
/// @member sharePrice1 The underlying assets each share of vault1 represents, scaled by 1e18
struct VaultSharePrices {
    bool initialized;
    uint120 sharePrice0;
    uint120 sharePrice1;
}

enum LockCallbackType {
    SWAP,
    DEPOSIT,
    WITHDRAW,
    INITIALIZE_POOL
}

struct HookHandleSwapCallbackInputData {
    PoolKey key;
    bool zeroForOne;
    uint256 inputAmount;
    uint256 outputAmount;
}

struct DepositCallbackInputData {
    address user;
    PoolKey poolKey;
    uint256 msgValue;
    uint256 rawAmount0;
    uint256 rawAmount1;
    uint256 tax0;
    uint256 tax1;
}

struct WithdrawCallbackInputData {
    address user;
    PoolKey poolKey;
    uint256 rawAmount0;
    uint256 rawAmount1;
}

struct InitializePoolCallbackInputData {
    PoolKey poolKey;
    uint160 sqrtPriceX96;
    uint24 twapSecondsAgo;
    bytes32 hookParams;
}
