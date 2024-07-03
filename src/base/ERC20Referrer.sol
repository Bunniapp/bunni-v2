// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.4;

import {LibMulticaller} from "multicaller/LibMulticaller.sol";

import {ERC20} from "./ERC20.sol";
import {IERC20Referrer} from "../interfaces/IERC20Referrer.sol";

/// @title ERC20Referrer
/// @notice An ERC20 token with referrer tracking and Multicaller support. Tracks
/// the score of each referrer, which is the sum of all balances of accounts that
/// have the referrer as their referrer.
/// @dev Balances are stored as uint240 instead of uint256 since the upper 16 bits
/// of the storage slot are used to store the referrer. Referrer 0 should be reserved for
/// the protocol since it's the default referrer of accounts.
abstract contract ERC20Referrer is ERC20, IERC20Referrer {
    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    /// @dev Error when the balance overflows uint240.
    error BalanceOverflow();

    /// -----------------------------------------------------------------------
    /// Constants
    /// -----------------------------------------------------------------------

    /// @dev Mask for extracting referrer from balance slot. Upper 16 bits.
    bytes32 internal constant _REFERRER_MASK = 0xffff000000000000000000000000000000000000000000000000000000000000;

    /// @dev Mask for extracting balance from balance slot. Lower 240 bits.
    bytes32 internal constant _BALANCE_MASK = 0x0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    /// @dev Max balance for an account.
    uint256 internal constant _MAX_BALANCE = 0x0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    /// -----------------------------------------------------------------------
    /// Storage
    /// -----------------------------------------------------------------------

    /// @dev The score slot of `referrer` is given by:
    /// ```
    ///     mstore(0x00, or(referrer, _SCORE_SLOT_SEED))
    ///     let scoreSlot := keccak256(0x00, 0x20)
    /// ```
    /// The uint16 referrer value must be in the most significant 16 bits of `referrer`, so a shl(240, referrer) is needed
    /// if `referrer` is initially a Solidity uint16 value.
    /// The bytes being hashed are | referrer - 2 bytes | 0 - 26 bytes | seed - 4 bytes |.
    uint256 internal constant _SCORE_SLOT_SEED = 0xea0f192f;

    /// -----------------------------------------------------------------------
    /// Referrer functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IERC20Referrer
    function scoreOf(uint16 referrer) public view override returns (uint256 score) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, or(shl(240, referrer), _SCORE_SLOT_SEED))
            score := sload(keccak256(0x00, 0x20))
        }
    }

    /// @inheritdoc IERC20Referrer
    function referrerOf(address account) public view override returns (uint16 referrer) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, account)
            referrer := shr(240, sload(keccak256(0x0c, 0x20)))
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
    /// @dev Uses upper 16 bits of balance slot for referrer. Updates referrer scores.
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address msgSender = LibMulticaller.senderOrSigner();
        _beforeTokenTransfer(msgSender, to, amount);
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the balance slot and load its value.
            mstore(0x0c, _BALANCE_SLOT_SEED)
            mstore(0x00, msgSender)
            let fromBalanceSlot := keccak256(0x0c, 0x20)
            let fromBalance := sload(fromBalanceSlot)
            let fromReferrer := and(fromBalance, _REFERRER_MASK)
            fromBalance := and(fromBalance, _BALANCE_MASK)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, or(fromReferrer, sub(fromBalance, amount)))
            // Compute the balance slot of `to`.
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x20)
            // Add and store the updated balance of `to`.
            let toBalance := sload(toBalanceSlot)
            let toReferrer := and(toBalance, _REFERRER_MASK)
            toBalance := add(and(toBalance, _BALANCE_MASK), amount)
            // Revert if updated balance overflows uint240
            if gt(toBalance, _MAX_BALANCE) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, or(toReferrer, toBalance))
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
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, msgSender, shr(96, mload(0x0c)))
        }
        _afterTokenTransfer(msgSender, to, amount);
        return true;
    }

    /// @inheritdoc ERC20
    /// @dev Uses upper 16 bits of balance slot for referrer. Updates referrer scores.
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address msgSender = LibMulticaller.senderOrSigner();
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
            let fromReferrer := and(fromBalance, _REFERRER_MASK)
            fromBalance := and(fromBalance, _BALANCE_MASK)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, or(fromReferrer, sub(fromBalance, amount)))
            // Compute the balance slot of `to`.
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x20)
            // Add and store the updated balance of `to`.
            let toBalance := sload(toBalanceSlot)
            let toReferrer := and(toBalance, _REFERRER_MASK)
            toBalance := add(and(toBalance, _BALANCE_MASK), amount)
            // Revert if updated balance overflows uint240
            if gt(toBalance, _MAX_BALANCE) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, or(toReferrer, toBalance))
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
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, shr(96, from_), shr(96, mload(0x0c)))
        }
        _afterTokenTransfer(from, to, amount);
        return true;
    }

    /// @inheritdoc ERC20
    /// @dev Uses upper 16 bits of balance slot for referrer. Updates referrer scores.
    /// Uses the existing referrer of the `to` address.
    function _mint(address to, uint256 amount) internal virtual override {
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
            let toReferrer := and(toBalance, _REFERRER_MASK)
            toBalance := add(and(toBalance, _BALANCE_MASK), amount)
            // Revert if updated balance overflows uint240
            if gt(toBalance, _MAX_BALANCE) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, or(toReferrer, toBalance))
            // Update referrer score.
            // Compute the score slot of `toReferrer`.
            mstore(0x00, or(toReferrer, _SCORE_SLOT_SEED))
            let toScoreSlot := keccak256(0x00, 0x20)
            // Add and store the updated score of `toReferrer`.
            sstore(toScoreSlot, add(sload(toScoreSlot), amount))
            // Emit the {Transfer} event.
            mstore(0x20, amount)
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, 0, shr(96, mload(0x0c)))
        }
        _afterTokenTransfer(address(0), to, amount);
    }

    /// @dev Uses upper 16 bits of balance slot for referrer. Updates referrer scores.
    /// Updates the referrer of `to` to `referrer`.
    function _mint(address to, uint256 amount, uint16 referrer) internal virtual {
        _beforeTokenTransfer(address(0), to, amount);
        /// @solidity memory-safe-assembly
        assembly {
            referrer := shl(240, referrer) // storage mapping uses most significant 16 bits as key
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
            let toReferrer := and(toBalance, _REFERRER_MASK)
            toBalance := and(toBalance, _BALANCE_MASK)
            let updatedToBalance := add(toBalance, amount)
            // Revert if updated balance overflows uint240
            if gt(updatedToBalance, _MAX_BALANCE) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, or(referrer, updatedToBalance))
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
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, 0, shr(96, mload(0x0c)))
        }
        _afterTokenTransfer(address(0), to, amount);
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
            let fromReferrer := and(fromBalance, _REFERRER_MASK)
            fromBalance := and(fromBalance, _BALANCE_MASK)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
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
            log3(0x00, 0x20, _TRANSFER_EVENT_SIGNATURE, shr(96, shl(96, from)), 0)
        }
        _afterTokenTransfer(from, address(0), amount);
    }

    /// @dev Moves `amount` of tokens from `from` to `to`.
    function _transfer(address from, address to, uint256 amount) internal virtual override {
        _beforeTokenTransfer(from, to, amount);
        /// @solidity memory-safe-assembly
        assembly {
            let from_ := shl(96, from)
            // Compute the balance slot and load its value.
            mstore(0x0c, or(from_, _BALANCE_SLOT_SEED))
            let fromBalanceSlot := keccak256(0x0c, 0x20)
            let fromBalance := sload(fromBalanceSlot)
            let fromReferrer := and(fromBalance, _REFERRER_MASK)
            fromBalance := and(fromBalance, _BALANCE_MASK)
            // Revert if insufficient balance.
            if gt(amount, fromBalance) {
                mstore(0x00, 0xf4d678b8) // `InsufficientBalance()`.
                revert(0x1c, 0x04)
            }
            // Subtract and store the updated balance.
            sstore(fromBalanceSlot, or(fromReferrer, sub(fromBalance, amount)))
            // Compute the balance slot of `to`.
            mstore(0x00, to)
            let toBalanceSlot := keccak256(0x0c, 0x20)
            let toBalance := sload(toBalanceSlot)
            let toReferrer := and(toBalance, _REFERRER_MASK)
            // Add and store the updated balance of `to`.
            // Revert if updated balance overflows uint240
            toBalance := add(and(toBalance, _BALANCE_MASK), amount)
            if gt(toBalance, _MAX_BALANCE) {
                mstore(0x00, 0x89560ca1) // `BalanceOverflow()`.
                revert(0x1c, 0x04)
            }
            sstore(toBalanceSlot, or(toReferrer, toBalance))
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
            log3(0x20, 0x20, _TRANSFER_EVENT_SIGNATURE, shr(96, from_), shr(96, mload(0x0c)))
        }
        _afterTokenTransfer(from, to, amount);
    }
}
