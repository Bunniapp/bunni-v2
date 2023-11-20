// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

interface IBaseHook is IHooks {
    error NotPoolManager();
    error NotSelf();
    error InvalidPool();
    error LockFailure();
    error HookNotImplemented();

    function poolManager() external view returns (IPoolManager);

    function getHooksCalls() external view returns (Hooks.Calls memory);
}
