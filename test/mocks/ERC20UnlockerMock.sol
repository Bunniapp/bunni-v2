// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {IERC20Unlocker} from "../../src/interfaces/IERC20Unlocker.sol";
import {IERC20Lockable} from "../../src/interfaces/IERC20Lockable.sol";

contract ERC20UnlockerMock is IERC20Unlocker {
    mapping(address => uint256) public lockedBalances;
    mapping(address => bytes) public lockDatas;

    IERC20Lockable public immutable token;

    constructor(IERC20Lockable _token) {
        token = _token;
    }

    function lockCallback(address account, uint256 balance, bytes calldata data) external override {
        lockedBalances[account] = balance;
        lockDatas[account] = data;
    }

    function lockedUserReceiveCallback(address account, uint256 receiveAmount) external override {
        lockedBalances[account] += receiveAmount;
    }

    function unlock(address account) external {
        delete lockedBalances[account];
        delete lockDatas[account];

        token.unlock(account);
    }
}
