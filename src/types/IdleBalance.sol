// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import {subReLU} from "../lib/Math.sol";

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
    using FixedPointMathLib for uint256;
    using IdleBalanceLibrary for uint256;

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

    function computeIdleBalance(uint256 activeBalance0, uint256 activeBalance1, uint256 balance0, uint256 balance1)
        internal
        pure
        returns (IdleBalance)
    {
        (uint256 extraBalance0, uint256 extraBalance1) =
            (subReLU(balance0, activeBalance0), subReLU(balance1, activeBalance1));
        (uint256 extraBalanceProportion0, uint256 extraBalanceProportion1) =
            (balance0 == 0 ? 0 : extraBalance0.divWad(balance0), balance1 == 0 ? 0 : extraBalance1.divWad(balance1));
        bool isToken0 = extraBalanceProportion0 >= extraBalanceProportion1;
        return (isToken0 ? extraBalance0 : extraBalance1).toIdleBalance(isToken0);
    }
}
