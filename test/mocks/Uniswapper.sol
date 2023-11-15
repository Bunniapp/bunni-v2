// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.15;

import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {ILockCallback} from "@uniswap/v4-core/src/interfaces/callback/ILockCallback.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/src/types/BalanceDelta.sol";

import {IERC20} from "../../src/interfaces/IERC20.sol";
import {SafeTransferLib} from "../../src/lib/SafeTransferLib.sol";

contract Uniswapper is ILockCallback {
    using SafeTransferLib for IERC20;
    using BalanceDeltaLibrary for BalanceDelta;

    IPoolManager internal immutable poolManager;

    constructor(IPoolManager poolManager_) {
        poolManager = poolManager_;
    }

    function swap(PoolKey calldata key, IPoolManager.SwapParams calldata params)
        external
        returns (BalanceDelta delta)
    {
        return abi.decode(poolManager.lock(abi.encode(key, params, msg.sender)), (BalanceDelta));
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
        IERC20(Currency.unwrap(inputToken)).safeTransferFrom(sender, address(poolManager), inputAmount);

        // take output tokens from manager
        poolManager.take(outputToken, sender, outputAmount);

        // settle
        poolManager.settle(inputToken);

        return abi.encode(delta);
    }
}
