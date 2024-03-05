// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.15;

import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {ILockCallback} from "@uniswap/v4-core/src/interfaces/callback/ILockCallback.sol";

import {IERC20} from "../../src/interfaces/IERC20.sol";

contract Uniswapper is ILockCallback {
    using SafeTransferLib for address;
    using CurrencyLibrary for Currency;

    IPoolManager internal immutable poolManager;

    constructor(IPoolManager poolManager_) {
        poolManager = poolManager_;
    }

    function lockAcquired(address lockCaller, bytes calldata data) external override returns (bytes memory) {
        require(msg.sender == address(poolManager), "Not poolManager");

        (PoolKey memory key, IPoolManager.SwapParams memory params, uint256 maxInput, uint256 minOutput) =
            abi.decode(data, (PoolKey, IPoolManager.SwapParams, uint256, uint256));
        if (key.currency0.isNative()) {
            poolManager.settle(key.currency0); // ensure we get the delta from ETH sent via lock()
        } else if (key.currency1.isNative()) {
            poolManager.settle(key.currency1); // ensure we get the delta from ETH sent via lock()
        }
        poolManager.swap(key, params, bytes(""));
        (int256 amount0, int256 amount1) = (
            poolManager.currencyDelta(address(this), key.currency0),
            poolManager.currencyDelta(address(this), key.currency1)
        );
        if (params.zeroForOne) {
            require(uint256(amount0) <= maxInput, "Required input too much");
            require(uint256(-amount1) >= minOutput, "Received output too little");
        } else {
            require(uint256(amount1) <= maxInput, "Required input too much");
            require(uint256(-amount0) >= minOutput, "Received output too little");
        }

        _settleCurrency(lockCaller, key.currency0, amount0);
        _settleCurrency(lockCaller, key.currency1, amount1);
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function _pay(Currency token, address payer, address recipient, uint256 value) internal {
        if (token.isNative()) {
            // already gave ETH to pool manager, take remainder instead
            poolManager.take(token, payer, uint256(-poolManager.currencyDelta(address(this), token)));
        } else {
            Currency.unwrap(token).safeTransferFrom(payer, recipient, value);
        }
    }

    function _settleCurrency(address user, Currency currency, int256 amount) internal {
        if (amount > 0) {
            if (currency.isNative()) {
                address(poolManager).safeTransferETH(uint256(amount));
            } else {
                Currency.unwrap(currency).safeTransferFrom(user, address(poolManager), uint256(amount));
            }
            poolManager.settle(currency);
        } else if (amount < 0) {
            poolManager.take(currency, user, uint256(-amount));
        }
    }
}
