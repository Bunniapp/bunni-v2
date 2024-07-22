// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.4;

import {LibMulticaller} from "multicaller/LibMulticaller.sol";

import "./Constants.sol";
import {ERC20} from "./ERC20.sol";
import {IERC20Lockable} from "../interfaces/IERC20Lockable.sol";
import {IERC20Unlocker} from "../interfaces/IERC20Unlocker.sol";
import {IERC20Referrer} from "../interfaces/IERC20Referrer.sol";

/// @title ERC20Referrer
/// @notice An ERC20 token with referrer tracking and Multicaller support. Tracks
/// the score of each referrer, which is the sum of all balances of accounts that
/// have the referrer as their referrer. Supports locking accounts which enables
/// transfer-less staking contracts that don't disrupt the referrer tracking.
/// @dev Balances are stored as uint232 instead of uint256 since the upper 24 bits
/// of the storage slot are used to store the lock flag & referrer.
/// Referrer 0 should be reserved for the protocol since it's the default referrer.
abstract contract ERC20Referrer is ERC20, IERC20Referrer, IERC20Lockable {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    /// @dev Error when the balance overflows uint232.
    error BalanceOverflow();

    /// -----------------------------------------------------------------------
    /// Constants
    /// -----------------------------------------------------------------------

    /// @dev Mask for extracting the locked flag from balance slot. Bit 0.
    bytes32 internal constant _LOCKED_MASK = 0x8000000000000000000000000000000000000000000000000000000000000000;

    /// @dev Mask for extracting referrer from balance slot. Bits [1, 23].
    bytes32 internal constant _REFERRER_MASK = 0x7fffff0000000000000000000000000000000000000000000000000000000000;

    /// @dev Mask for extracting locked flag & referrer from balance slot.
    bytes32 internal constant _EXTRA_DATA_MASK = 0xffffff0000000000000000000000000000000000000000000000000000000000;

    /// @dev Mask for extracting balance from balance slot. Bits [24, 255].
    bytes32 internal constant _BALANCE_MASK = 0x000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    /// @dev Max balance for an account.
    uint256 internal constant _MAX_BALANCE = 0x000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    /// @dev The size of a user's balance in bits.
    uint256 internal constant _BALANCE_SIZE = 232;

    /// -----------------------------------------------------------------------
    /// Storage
    /// -----------------------------------------------------------------------

    /// @dev The score slot of `referrer` is given by:
    /// ```
    ///     mstore(0x00, or(referrer, _SCORE_SLOT_SEED))
    ///     let scoreSlot := keccak256(0x00, 0x20)
    /// ```
    /// The uint24 referrer value must be in the most significant 24 bits of `referrer`, so a shl(232, referrer) is needed
    /// if `referrer` is initially a Solidity uint24 value.
    /// The bytes being hashed are | referrer - 3 bytes | 0 - 25 bytes | seed - 4 bytes |.
    uint256 internal constant _SCORE_SLOT_SEED = 0xea0f192f;

    /// @dev The unlocker slot of `account` is given by:
    /// ```
    ///     mstore(0x0c, _UNLOCKER_SLOT_SEED)
    ///     mstore(0x00, account)
    ///     let unlockerSlot := keccak256(0x0c, 0x20)
    /// ```
    uint256 internal constant _UNLOCKER_SLOT_SEED = 0x1816035a;

    /// -----------------------------------------------------------------------
    /// IERC20Lockable functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IERC20Lockable
    function lock(IERC20Unlocker unlocker, bytes calldata data) external override {
        address account = LibMulticaller.senderOrSigner();
        uint256 accountBalance;

        /// @solidity memory-safe-assembly
        assembly {
            /// -----------------------------------------------------------------------
            /// Validation
            /// -----------------------------------------------------------------------

            // load balance slot
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, account)
            let balanceSlot := keccak256(0x0c, 0x20)
            let balanceSlotValue := sload(balanceSlot)
            accountBalance := and(balanceSlotValue, _BALANCE_MASK)

            // ensure account is not already locked
            if and(balanceSlotValue, _LOCKED_MASK) {
                mstore(0x00, 0x5f0ccd7c) // `AlreadyLocked()`.
                revert(0x1c, 0x04)
            }

            /// -----------------------------------------------------------------------
            /// Storage updates
            /// -----------------------------------------------------------------------

            // set account as locked
            sstore(balanceSlot, or(balanceSlotValue, _LOCKED_MASK))

            // update unlocker
            mstore(0x0c, _UNLOCKER_SLOT_SEED)
            mstore(0x00, account)
            let unlockerSlot := keccak256(0x0c, 0x20)
            sstore(unlockerSlot, unlocker)
        }

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        unlocker.lockCallback(account, accountBalance, data);

        emit Lock(account, unlocker);
    }

    /// @inheritdoc IERC20Lockable
    function unlock(address account) external override {
        IERC20Unlocker unlocker;

        /// @solidity memory-safe-assembly
        assembly {
            /// -----------------------------------------------------------------------
            /// Validation
            /// -----------------------------------------------------------------------

            // load balance slot
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, account)
            let balanceSlot := keccak256(0x0c, 0x20)
            let balanceSlotValue := sload(balanceSlot)

            // ensure account is locked
            if iszero(and(balanceSlotValue, _LOCKED_MASK)) {
                mstore(0x00, 0x5090d6c6) // `AlreadyUnlocked()`.
                revert(0x1c, 0x04)
            }

            // ensure sender is the unlocker
            mstore(0x0c, _UNLOCKER_SLOT_SEED)
            mstore(0x00, account)
            let unlockerSlot := keccak256(0x0c, 0x20)
            unlocker := sload(unlockerSlot)
            if iszero(eq(unlocker, caller())) {
                mstore(0x00, 0x746db0ff) // `NotUnlocker()`.
                revert(0x1c, 0x04)
            }

            /// -----------------------------------------------------------------------
            /// Storage updates
            /// -----------------------------------------------------------------------

            // set account as unlocked
            sstore(balanceSlot, sub(balanceSlotValue, _LOCKED_MASK))
        }

        emit Unlock(account, unlocker);
    }

    /// @inheritdoc IERC20Lockable
    function isLocked(address account) public view override returns (bool locked) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, account)
            let balanceSlot := keccak256(0x0c, 0x20)
            let balanceSlotValue := sload(balanceSlot)
            locked := shr(255, and(balanceSlotValue, _LOCKED_MASK))
        }
    }

    /// @inheritdoc IERC20Lockable
    function unlockerOf(address account) public view override returns (IERC20Unlocker unlocker) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x0c, _UNLOCKER_SLOT_SEED)
            mstore(0x00, account)
            let unlockerSlot := keccak256(0x0c, 0x20)
            unlocker := sload(unlockerSlot)
        }
    }

    /// -----------------------------------------------------------------------
    /// Referrer functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IERC20Referrer
    function scoreOf(uint24 referrer) public view override returns (uint256 score) {
        if (referrer > MAX_REFERRER) {
            return 0;
        }
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, or(shl(_BALANCE_SIZE, referrer), _SCORE_SLOT_SEED))
            score := sload(keccak256(0x00, 0x20))
        }
    }

    /// @inheritdoc IERC20Referrer
    function referrerOf(address account) public view override returns (uint24 referrer) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, account)
            referrer := shr(_BALANCE_SIZE, and(sload(keccak256(0x0c, 0x20)), _REFERRER_MASK))
        }
    }

    /// -----------------------------------------------------------------------
    /// ERC20 overrides
    /// -----------------------------------------------------------------------

    /// @inheritdoc ERC20
    function balanceOf(address owner) public view virtual override returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, owner)
            result := sload(keccak256(0x0c, 0x20))
            result := and(result, _BALANCE_MASK)
        }
    }

    /// @inheritdoc ERC20
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address msgSender = LibMulticaller.senderOrSigner();
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the allowance slot and store the amount.
            mstore(0x20, spender)
            mstore(0x0c, _ALLOWANCE_SLOT_SEED)
            mstore(0x00, msgSender)
            sstore(keccak256(0x0c, 0x34), amount)
            // Emit the {Approval} event.
            mstore(0x00, amount)
            log3(0x00, 0x20, _APPROVAL_EVENT_SIGNATURE, msgSender, shr(96, mload(0x2c)))
        }
        return true;
    }

    /// @inheritdoc ERC20
    /// @dev Uses upper 24 bits of balance slot for referrer. Updates referrer scores.
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address msgSender = LibMulticaller.senderOrSigner();
        bool toLocked;

        _beforeTokenTransfer(msgSender, to, amount);
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the balance slot and load its value.
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, msgSender)
            let fromBalanceSlot := keccak256(0x0c, 0x20)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if the sender is locked.
            if and(fromBalance, _LOCKED_MASK) {
                mstore(0x00, 0x6315bfbb) // `AccountLocked()`.
                revert(0x1c, 0x04)
            }
            let fromReferrer := and(fromBalance, _REFERRER_MASK)
            fromBalance := and(fromBalance, _BALANCE_MASK)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            // We know `from` is not locked so no need to store the flag.
            sstore(fromBalanceSlot, or(fromReferrer, sub(fromBalance, amount)))
            // Compute the balance slot of `to`.
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x20)
            // Add and store the updated balance of `to`.
            let toBalance := sload(toBalanceSlot)
            toLocked := and(toBalance, _LOCKED_MASK)
            let toReferrer := and(toBalance, _REFERRER_MASK)
            toBalance := add(and(toBalance, _BALANCE_MASK), amount)
            // Revert if updated balance overflows uint232
            if gt(toBalance, _MAX_BALANCE) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, or(toLocked, or(toReferrer, toBalance)))
            // Shift `toLocked` to fit into a bool.
            toLocked := shr(255, toLocked)
            // Update referrer scores if referrers are different.
            if iszero(eq(fromReferrer, toReferrer)) {
                // Compute the score slot of `fromReferrer`.
                mstore(0x00, or(fromReferrer, _SCORE_SLOT_SEED))
                let fromScoreSlot := keccak256(0x00, 0x20)
                // Subtract and store the updated score of `fromReferrer`.
                sstore(fromScoreSlot, sub(sload(fromScoreSlot), amount))
                // Compute the score slot of `toReferrer`.
                mstore(0x00, or(toReferrer, _SCORE_SLOT_SEED))
                let toScoreSlot := keccak256(0x00, 0x20)
                // Add and store the updated score of `toReferrer`.
                sstore(toScoreSlot, add(sload(toScoreSlot), amount))
            }
            // Emit the {Transfer} event.
            mstore(0x20, amount)
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, msgSender, to)
        }
        _afterTokenTransfer(msgSender, to, amount);

        // Unlocker callback if `to` is locked.
        if (toLocked) {
            IERC20Unlocker unlocker = unlockerOf(to);
            unlocker.lockedUserReceiveCallback(to, amount);
        }

        return true;
    }

    /// @inheritdoc ERC20
    /// @dev Uses upper 24 bits of balance slot for referrer. Updates referrer scores.
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address msgSender = LibMulticaller.senderOrSigner();
        bool toLocked;

        _beforeTokenTransfer(from, to, amount);
        /// @solidity memory-safe-assembly
        assembly {
            let from_ := shl(96, from)
            // Compute the allowance slot and load its value.
            mstore(0x20, msgSender)
            mstore(0x0c, or(from_, _ALLOWANCE_SLOT_SEED))
            let allowanceSlot := keccak256(0x0c, 0x34)
            let allowance_ := sload(allowanceSlot)
            // If the allowance is not the maximum uint256 value.
            if add(allowance_, 1) {
                // Revert if the amount to be transferred exceeds the allowance.
                if gt(amount, allowance_) {
                    mstore(0x00, 0x13be252b) // `InsufficientAllowance()`.
                    revert(0x1c, 0x04)
                }
                // Subtract and store the updated allowance.
                sstore(allowanceSlot, sub(allowance_, amount))
            }
            // Compute the balance slot and load its value.
            mstore(0x0c, or(from_, _BALANCE_SLOT_SEED))
            let fromBalanceSlot := keccak256(0x0c, 0x20)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if `from` is locked.
            if and(fromBalance, _LOCKED_MASK) {
                mstore(0x00, 0x6315bfbb) // `AccountLocked()`.
                revert(0x1c, 0x04)
            }
            let fromReferrer := and(fromBalance, _REFERRER_MASK)
            fromBalance := and(fromBalance, _BALANCE_MASK)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            // We know `from` is not locked so no need to store the flag.
            sstore(fromBalanceSlot, or(fromReferrer, sub(fromBalance, amount)))
            // Compute the balance slot of `to`.
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x20)
            // Add and store the updated balance of `to`.
            let toBalance := sload(toBalanceSlot)
            toLocked := and(toBalance, _LOCKED_MASK)
            let toReferrer := and(toBalance, _REFERRER_MASK)
            toBalance := add(and(toBalance, _BALANCE_MASK), amount)
            // Revert if updated balance overflows uint232
            if gt(toBalance, _MAX_BALANCE) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, or(toLocked, or(toReferrer, toBalance)))
            // Shift `toLocked` to fit into a bool.
            toLocked := shr(255, toLocked)
            // Update referrer scores if referrers are different.
            if iszero(eq(fromReferrer, toReferrer)) {
                // Compute the score slot of `fromReferrer`.
                mstore(0x00, or(fromReferrer, _SCORE_SLOT_SEED))
                let fromScoreSlot := keccak256(0x00, 0x20)
                // Subtract and store the updated score of `fromReferrer`.
                sstore(fromScoreSlot, sub(sload(fromScoreSlot), amount))
                // Compute the score slot of `toReferrer`.
                mstore(0x00, or(toReferrer, _SCORE_SLOT_SEED))
                let toScoreSlot := keccak256(0x00, 0x20)
                // Add and store the updated score of `toReferrer`.
                sstore(toScoreSlot, add(sload(toScoreSlot), amount))
            }
            // Emit the {Transfer} event.
            mstore(0x20, amount)
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, from, to)
        }
        _afterTokenTransfer(from, to, amount);

        // Unlocker callback if `to` is locked.
        if (toLocked) {
            IERC20Unlocker unlocker = unlockerOf(to);
            unlocker.lockedUserReceiveCallback(to, amount);
        }

        return true;
    }

    /// @inheritdoc ERC20
    /// @dev Uses upper 24 bits of balance slot for referrer. Updates referrer scores.
    /// Uses the existing referrer of the `to` address.
    function _mint(address to, uint256 amount) internal virtual override {
        bool toLocked;

        _beforeTokenTransfer(address(0), to, amount);
        /// @solidity memory-safe-assembly
        assembly {
            let totalSupplyBefore := sload(_TOTAL_SUPPLY_SLOT)
            let totalSupplyAfter := add(totalSupplyBefore, amount)
            // Revert if the total supply overflows.
            if lt(totalSupplyAfter, totalSupplyBefore) {
                mstore(0x00, 0xe5cfe957) // `TotalSupplyOverflow()`.
                revert(0x1c, 0x04)
            }
            // Store the updated total supply.
            sstore(_TOTAL_SUPPLY_SLOT, totalSupplyAfter)
            // Compute the balance slot and load its value.
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x20)
            // Add and store the updated balance.
            let toBalance := sload(toBalanceSlot)
            toLocked := and(toBalance, _LOCKED_MASK)
            let toReferrer := and(toBalance, _REFERRER_MASK)
            toBalance := add(and(toBalance, _BALANCE_MASK), amount)
            // Revert if updated balance overflows uint232
            if gt(toBalance, _MAX_BALANCE) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, or(toLocked, or(toReferrer, toBalance)))
            // Shift `toLocked` to fit into a bool.
            toLocked := shr(255, toLocked)
            // Update referrer score.
            // Compute the score slot of `toReferrer`.
            mstore(0x00, or(toReferrer, _SCORE_SLOT_SEED))
            let toScoreSlot := keccak256(0x00, 0x20)
            // Add and store the updated score of `toReferrer`.
            sstore(toScoreSlot, add(sload(toScoreSlot), amount))
            // Emit the {Transfer} event.
            mstore(0x20, amount)
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, 0, to)
        }
        _afterTokenTransfer(address(0), to, amount);

        // Unlocker callback if `to` is locked.
        if (toLocked) {
            IERC20Unlocker unlocker = unlockerOf(to);
            unlocker.lockedUserReceiveCallback(to, amount);
        }
    }

    /// @dev Uses upper 24 bits of balance slot for referrer. Updates referrer scores.
    /// Updates the referrer of `to` to `referrer`.
    function _mint(address to, uint256 amount, uint24 referrer) internal virtual {
        bool toLocked;

        _beforeTokenTransfer(address(0), to, amount);
        /// @solidity memory-safe-assembly
        assembly {
            if gt(referrer, MAX_REFERRER) { referrer := 0 } // referrer can't exceed max value
            referrer := shl(_BALANCE_SIZE, referrer) // storage mapping uses most significant 24 bits as key
            let totalSupplyBefore := sload(_TOTAL_SUPPLY_SLOT)
            let totalSupplyAfter := add(totalSupplyBefore, amount)
            // Revert if the total supply overflows.
            if lt(totalSupplyAfter, totalSupplyBefore) {
                mstore(0x00, 0xe5cfe957) // `TotalSupplyOverflow()`.
                revert(0x1c, 0x04)
            }
            // Store the updated total supply.
            sstore(_TOTAL_SUPPLY_SLOT, totalSupplyAfter)
            // Compute the balance slot and load its value.
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x20)
            // Add and store the updated balance.
            let toBalance := sload(toBalanceSlot)
            toLocked := and(toBalance, _LOCKED_MASK)
            let toReferrer := and(toBalance, _REFERRER_MASK)
            toBalance := and(toBalance, _BALANCE_MASK)
            let updatedToBalance := add(toBalance, amount)
            // Revert if updated balance overflows uint232
            if gt(updatedToBalance, _MAX_BALANCE) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, or(toLocked, or(referrer, updatedToBalance)))
            // Shift `toLocked` to fit into a bool.
            toLocked := shr(255, toLocked)
            // Update referrer scores.
            switch eq(toReferrer, referrer)
            case 0 {
                // Referrers are different.
                // Need to subtract `toBalance` from the original referrer's score
                // and give `toBalance + amount` to the new referrer.
                if toBalance {
                    // Compute the score slot of `toReferrer`.
                    mstore(0x00, or(toReferrer, _SCORE_SLOT_SEED))
                    let toScoreSlot := keccak256(0x00, 0x20)
                    // Subtract and store the updated score of `toReferrer`.
                    sstore(toScoreSlot, sub(sload(toScoreSlot), toBalance))
                }
                // Compute the score slot of `referrer`.
                mstore(0x00, or(referrer, _SCORE_SLOT_SEED))
                let newReferrerScoreSlot := keccak256(0x00, 0x20)
                // Add and store the updated score of `referrer`.
                sstore(newReferrerScoreSlot, add(sload(newReferrerScoreSlot), updatedToBalance))
            }
            default {
                // Same referrer as before.
                // Simply add `amount` to the score of the referrer.
                // Compute the score slot of `toReferrer`.
                mstore(0x00, or(toReferrer, _SCORE_SLOT_SEED))
                let toScoreSlot := keccak256(0x00, 0x20)
                // Add and store the updated score of `toReferrer`.
                sstore(toScoreSlot, add(sload(toScoreSlot), amount))
            }
            // Emit the {Transfer} event.
            mstore(0x20, amount)
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, 0, to)
        }
        _afterTokenTransfer(address(0), to, amount);

        // Unlocker callback if `to` is locked.
        if (toLocked) {
            IERC20Unlocker unlocker = unlockerOf(to);
            unlocker.lockedUserReceiveCallback(to, amount);
        }
    }

    /// @dev Burns `amount` tokens from `from`, reducing the total supply.
    ///
    /// Emits a {Transfer} event.
    function _burn(address from, uint256 amount) internal virtual override {
        _beforeTokenTransfer(from, address(0), amount);
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the balance slot and load its value.
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, from)
            let fromBalanceSlot := keccak256(0x0c, 0x20)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if `from` is locked.
            if and(fromBalance, _LOCKED_MASK) {
                mstore(0x00, 0x6315bfbb) // `AccountLocked()`.
                revert(0x1c, 0x04)
            }
            let fromReferrer := and(fromBalance, _REFERRER_MASK)
            fromBalance := and(fromBalance, _BALANCE_MASK)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            // We know `from` is not locked so no need to store the flag.
            sstore(fromBalanceSlot, or(fromReferrer, sub(fromBalance, amount)))
            // Subtract and store the updated total supply.
            sstore(_TOTAL_SUPPLY_SLOT, sub(sload(_TOTAL_SUPPLY_SLOT), amount))
            // Update referrer score.
            // Compute the score slot of `fromReferrer`.
            mstore(0x00, or(fromReferrer, _SCORE_SLOT_SEED))
            let fromScoreSlot := keccak256(0x00, 0x20)
            // Subtract and store the updated score of `fromReferrer`.
            sstore(fromScoreSlot, sub(sload(fromScoreSlot), amount))
            // Emit the {Transfer} event.
            mstore(0x00, amount)
            log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, from, 0)
        }
        _afterTokenTransfer(from, address(0), amount);
    }

    /// @dev Moves `amount` of tokens from `from` to `to`.
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        bool toLocked;

        _beforeTokenTransfer(from, to, amount);
        /// @solidity memory-safe-assembly
        assembly {
            let from_ := shl(96, from)
            // Compute the balance slot and load its value.
            mstore(0x0c, or(from_, _BALANCE_SLOT_SEED))
            let fromBalanceSlot := keccak256(0x0c, 0x20)
            let fromBalance := sload(fromBalanceSlot)
            // Revert if `from` is locked.
            if and(fromBalance, _LOCKED_MASK) {
                mstore(0x00, 0x6315bfbb) // `AccountLocked()`.
                revert(0x1c, 0x04)
            }
            let fromReferrer := and(fromBalance, _REFERRER_MASK)
            fromBalance := and(fromBalance, _BALANCE_MASK)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            // We know `from` is not locked so no need to store the flag.
            sstore(fromBalanceSlot, or(fromReferrer, sub(fromBalance, amount)))
            // Compute the balance slot of `to`.
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x20)
            let toBalance := sload(toBalanceSlot)
            toLocked := and(toBalance, _LOCKED_MASK)
            let toReferrer := and(toBalance, _REFERRER_MASK)
            // Add and store the updated balance of `to`.
            // Revert if updated balance overflows uint232
            toBalance := add(and(toBalance, _BALANCE_MASK), amount)
            if gt(toBalance, _MAX_BALANCE) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, or(toLocked, or(toReferrer, toBalance)))
            // Shift `toLocked` to fit into a bool.
            toLocked := shr(255, toLocked)
            // Update referrer scores if referrers are different.
            if iszero(eq(fromReferrer, toReferrer)) {
                // Compute the score slot of `fromReferrer`.
                mstore(0x00, or(fromReferrer, _SCORE_SLOT_SEED))
                let fromScoreSlot := keccak256(0x00, 0x20)
                // Subtract and store the updated score of `fromReferrer`.
                sstore(fromScoreSlot, sub(sload(fromScoreSlot), amount))
                // Compute the score slot of `toReferrer`.
                mstore(0x00, or(toReferrer, _SCORE_SLOT_SEED))
                let toScoreSlot := keccak256(0x00, 0x20)
                // Add and store the updated score of `toReferrer`.
                sstore(toScoreSlot, add(sload(toScoreSlot), amount))
            }
            // Emit the {Transfer} event.
            mstore(0x20, amount)
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, from, to)
        }
        _afterTokenTransfer(from, to, amount);

        // Unlocker callback if `to` is locked.
        if (toLocked) {
            IERC20Unlocker unlocker = unlockerOf(to);
            unlocker.lockedUserReceiveCallback(to, amount);
        }
    }
}
