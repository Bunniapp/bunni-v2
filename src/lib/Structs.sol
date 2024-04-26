// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import {PoolId, PoolKey, BalanceDelta, Currency} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {ERC4626} from "solady/tokens/ERC4626.sol";

import {IBunniToken} from "../interfaces/IBunniToken.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

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

enum LockCallbackType {
    SWAP,
    DEPOSIT,
    WITHDRAW,
    INITIALIZE_POOL
}

enum HookLockCallbackType {
    BURN_AND_TAKE,
    SETTLE_AND_MINT,
    CLAIM_FEES
}

enum BoolOverride {
    UNSET,
    TRUE,
    FALSE
}
