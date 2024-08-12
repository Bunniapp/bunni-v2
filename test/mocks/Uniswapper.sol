// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.15;

import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {TransientStateLibrary} from "@uniswap/v4-core/src/libraries/TransientStateLibrary.sol";

import {IERC20} from "../../src/interfaces/IERC20.sol";

contract Uniswapper is IUnlockCallback {
    using SafeTransferLib for address;
    using CurrencyLibrary for Currency;
    using TransientStateLibrary for IPoolManager;

    IPoolManager internal immutable poolManager;

    constructor(IPoolManager poolManager_) {
        poolManager = poolManager_;
    }

    function swap(PoolKey memory key, IPoolManager.SwapParams memory params, uint256 maxInput, uint256 minOutput)
        external
        payable
    {
        poolManager.unlock(abi.encode(msg.sender, key, params, maxInput, minOutput));
    }

    function unlockCallback(bytes calldata data) external override returns (bytes memory) {
        require(msg.sender == address(poolManager), "Not poolManager");

        (address sender, PoolKey memory key, IPoolManager.SwapParams memory params, uint256 maxInput, uint256 minOutput)
        = abi.decode(data, (address, PoolKey, IPoolManager.SwapParams, uint256, uint256));
        poolManager.swap(key, params, bytes(""));
        (int256 amount0, int256 amount1) = (
            poolManager.currencyDelta(address(this), key.currency0),
            poolManager.currencyDelta(address(this), key.currency1)
        );
        if (params.zeroForOne) {
            require(uint256(-amount0) <= maxInput, "Required input too much");
            require(uint256(amount1) >= minOutput, "Received output too little");
        } else {
            require(uint256(-amount1) <= maxInput, "Required input too much");
            require(uint256(amount0) >= minOutput, "Received output too little");
        }

        _settleCurrency(sender, key.currency0, amount0);
        _settleCurrency(sender, key.currency1, amount1);
        return bytes("");
    }

    function _settleCurrency(address user, Currency currency, int256 amount) internal {
        if (amount < 0) {
            poolManager.sync(currency);
            if (!currency.isNative()) {
                Currency.unwrap(currency).safeTransferFrom(user, address(poolManager), uint256(-amount));
            }
            poolManager.settle{value: currency.isNative() ? uint256(-amount) : 0}();
        } else if (amount > 0) {
            poolManager.take(currency, user, uint256(amount));
        }
    }
}
