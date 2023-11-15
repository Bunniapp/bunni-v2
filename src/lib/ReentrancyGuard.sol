// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

abstract contract ReentrancyGuard {
    error ReentrancyGuard__ReentrantCall();

    uint256 private constant STATUS_SLOT = uint256(keccak256("STATUS")) - 1;
    uint256 private constant NOT_ENTERED = 0;
    uint256 private constant ENTERED = 1;

    modifier nonReentrant() {
        uint256 statusSlot = STATUS_SLOT;
        uint256 status;
        assembly {
            status := tload(statusSlot)
        }
        if (status == ENTERED) revert ReentrancyGuard__ReentrantCall();

        uint256 entered = ENTERED;
        uint256 notEntered = NOT_ENTERED;
        assembly {
            tstore(statusSlot, entered)
        }
        _;
        assembly {
            tstore(statusSlot, notEntered)
        }
    }
}
