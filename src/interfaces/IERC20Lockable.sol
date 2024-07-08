// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./IERC20Unlocker.sol";

/// @title IERC20Lockable - Interface for a lockable token account.
/// @notice A token holder can lock their account, preventing any transfers from the account.
/// An unlocker contract is able to unlock the account. The unlocker contract is expected to
/// implement the `IERC20Unlocker` interface.
/// Used mainly for staking contracts that don't require transferring the token into the contract.
interface IERC20Lockable {
    event Lock(address indexed account, IERC20Unlocker indexed unlocker);
    event Unlock(address indexed account, IERC20Unlocker indexed unlocker);

    /// @dev Error when calling lock() and the account is already locked.
    error AlreadyLocked();

    /// @dev Error when calling unlock() and the account is already unlocked.
    error AlreadyUnlocked();

    /// @dev Error when the caller is not the unlocker of the account.
    error NotUnlocker();

    /// @dev Error when trasferring tokens from a locked account.
    error AccountLocked();

    /// @notice Called by a token holder to lock their account. Once locked an account
    /// can no longer transfer tokens until it's been unlocked. Only `unlocker` has the
    /// ability to unlock the account. Reverts if the account is already locked.
    /// @dev `unlocker` will receive the data via a `lockCallback()` call from this contract.
    /// @param unlocker The address that will be able to unlock the account.
    /// @param data Additional data with no specified format.
    function lock(IERC20Unlocker unlocker, bytes calldata data) external;

    /// @notice Called by an unlocker contract to unlock an account.
    /// Reverts if the caller is not the unlocker of the account, or if
    /// the account is not locked.
    /// @param account The account to unlock.
    function unlock(address account) external;

    /// @notice Returns true if the account is locked, false otherwise.
    /// @param account The account to check.
    /// @return True if the account is locked, false otherwise.
    function isLocked(address account) external view returns (bool);

    /// @notice Returns the unlocker of the account. Be aware that the unlocker
    /// is not set to 0 after the account has been unlocked, so the caller should
    /// use this function in combination with `isLocked()`.
    /// @param account The account whose unlocker is to be returned.
    /// @return unlocker The unlocker of the account.
    function unlockerOf(address account) external view returns (IERC20Unlocker unlocker);
}
