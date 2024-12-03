// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

type IdleBalance is bytes32;

using {equals as ==, notEqual as !=} for IdleBalance global;
using IdleBalanceLibrary for IdleBalance global;

function equals(IdleBalance bal, IdleBalance other) pure returns (bool) {
    return IdleBalance.unwrap(bal) == IdleBalance.unwrap(other);
}

function notEqual(IdleBalance bal, IdleBalance other) pure returns (bool) {
    return IdleBalance.unwrap(bal) != IdleBalance.unwrap(other);
}

library IdleBalanceLibrary {
    uint256 private constant _BALANCE_MASK = 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    /// @dev Set isToken0 to true in ZERO to keep storage slots dirty
    IdleBalance internal constant ZERO =
        IdleBalance.wrap(bytes32(0x8000000000000000000000000000000000000000000000000000000000000000));

    error IdleBalanceLibrary__BalanceOverflow();

    function fromIdleBalance(IdleBalance idleBalance) internal pure returns (uint256 rawBalance, bool isToken0) {
        uint256 mask = _BALANCE_MASK;
        assembly ("memory-safe") {
            isToken0 := shr(255, idleBalance)
            rawBalance := and(mask, idleBalance)
        }
    }

    function toIdleBalance(uint256 rawBalance, bool isToken0) internal pure returns (IdleBalance) {
        // revert if balance overflows 255 bits
        if (rawBalance > _BALANCE_MASK) revert IdleBalanceLibrary__BalanceOverflow();

        // pack isToken0 and balance into a single uint256
        bytes32 packed;
        assembly ("memory-safe") {
            packed := or(shl(255, isToken0), rawBalance)
        }

        return IdleBalance.wrap(packed);
    }
}
