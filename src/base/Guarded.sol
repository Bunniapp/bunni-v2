// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {CustomRevert} from "@uniswap/v4-core/src/libraries/CustomRevert.sol";

abstract contract Guarded {
    using CustomRevert for bytes4;

    error GuardedCall();

    /// @dev The original address of this contract
    address private immutable original;

    address private immutable hub;
    address private immutable hook;
    address private immutable quoter;

    function _guardedCheck() private view {
        if (
            (msg.sender != hub && msg.sender != hook && msg.sender != quoter && msg.sender != address(0))
                || address(this) != original
        ) {
            GuardedCall.selector.revertWith();
        }
    }

    modifier guarded() {
        _guardedCheck();
        _;
    }

    constructor(address hub_, address hook_, address quoter_) {
        // Immutables are computed in the init code of the contract, and then inlined into the deployed bytecode.
        // In other words, this variable won't change when it's checked at runtime.
        original = address(this);

        // Record permitted addresses
        hub = hub_;
        hook = hook_;
        quoter = quoter_;
    }
}
