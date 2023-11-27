// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.15;

import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {ILockCallback} from "@uniswap/v4-core/src/interfaces/callback/ILockCallback.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/src/types/BalanceDelta.sol";

import {IERC20} from "../../src/interfaces/IERC20.sol";
import {SafeTransferLib} from "../../src/lib/SafeTransferLib.sol";

contract Uniswapper is ILockCallback {
    using SafeTransferLib for IERC20;
    using SafeTransferLib for address;
    using CurrencyLibrary for Currency;
    using BalanceDeltaLibrary for BalanceDelta;

    IPoolManager internal immutable poolManager;

    constructor(IPoolManager poolManager_) {
        poolManager = poolManager_;
    }

    function swap(PoolKey calldata key, IPoolManager.SwapParams calldata params)
        external
        payable
        returns (BalanceDelta delta)
    {
        delta = abi.decode(poolManager.lock(abi.encode(key, params, msg.sender)), (BalanceDelta));

        // refund ETH
        if (address(this).balance > 0) {
            msg.sender.safeTransferETH(address(this).balance);
        }
    }

    function lockAcquired(bytes calldata data) external override returns (bytes memory) {
        require(msg.sender == address(poolManager), "Not poolManager");

        (PoolKey memory key, IPoolManager.SwapParams memory params, address sender) =
            abi.decode(data, (PoolKey, IPoolManager.SwapParams, address));
        BalanceDelta delta = poolManager.swap(key, params, bytes(""));

        (Currency inputToken, uint256 inputAmount, Currency outputToken, uint256 outputAmount) = delta.amount0() > 0
            ? (key.currency0, uint128(delta.amount0()), key.currency1, uint128(-delta.amount1()))
            : (key.currency1, uint128(delta.amount1()), key.currency0, uint128(-delta.amount0()));

        // transfer input tokens to pool manager
        _pay(inputToken, sender, address(poolManager), inputAmount);

        // take output tokens from manager
        poolManager.take(outputToken, sender, outputAmount);

        // settle
        poolManager.settle(inputToken);

        return abi.encode(delta);
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function _pay(Currency token, address payer, address recipient, uint256 value) internal {
        if (token.isNative()) {
            recipient.safeTransferETH(value);
        } else {
            IERC20(Currency.unwrap(token)).safeTransferFrom(payer, recipient, value);
        }
    }
}
