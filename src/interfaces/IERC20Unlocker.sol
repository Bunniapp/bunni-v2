// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

/// @title IERC20Unlocker - Interface for an unlocker contract for `IERC20Lockable`.
/// @notice An unlocker contract is able to unlock accounts that have been locked by a `IERC20Lockable` contract.
/// The unlocker contract is expected to implement the `IERC20Unlocker` interface.
interface IERC20Unlocker {
    /// @notice Called when an account calls `IERC20Lockable.lock()` and specifies this contract as the unlocker.
    /// @param account The account that called `IERC20Lockable.lock()`.
    /// @param balance The balance of the account after the lock.
    /// @param data The data passed to `IERC20Lockable.lock()`.
    function lockCallback(address account, uint256 balance, bytes calldata data) external;

    /// @notice Called when a locked account with this contract as the unlocker receives tokens.
    /// @param account The account that received tokens.
    /// @param receiveAmount The amount of tokens received.
    function lockedUserReceiveCallback(address account, uint256 receiveAmount) external;
}
