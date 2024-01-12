// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import {PoolId, PoolKey, BalanceDelta, Currency} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {ERC4626} from "solady/src/tokens/ERC4626.sol";

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
    bool poolCredit0Set;
    bool poolCredit1Set;
    uint256 rawBalance0;
    uint256 rawBalance1;
    uint256 reserve0;
    uint256 reserve1;
}

struct RawPoolState {
    address immutableParamsPointer;
    bool poolCredit0Set;
    bool poolCredit1Set;
    uint256 rawBalance0;
    uint256 rawBalance1;
    uint256 reserve0;
    uint256 reserve1;
}

struct WithdrawPoolCreditInputData {
    PoolId poolId;
    Currency currency;
    uint256 currencyIdx;
    uint256 poolCreditAmount;
    address recipient;
}

struct InitializePoolCallbackInputData {
    PoolKey poolKey;
    uint160 sqrtPriceX96;
    uint24 twapSecondsAgo;
    bytes32 hookParams;
}

enum LockCallbackType {
    WITHDRAW_POOL_CREDIT,
    CLEAR_POOL_CREDITS,
    INITIALIZE_POOL
}
