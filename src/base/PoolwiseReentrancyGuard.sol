// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {LibTransient} from "solady/utils/LibTransient.sol";
import {EfficientHashLib} from "solady/utils/EfficientHashLib.sol";

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

import {ReentrancyGuard} from "./ReentrancyGuard.sol";

/// @dev Supports pool-wise reentrancy guard. Has the following behavior:
/// - Locking one pool locks all other pools.
/// - Unlocking one pool does not unlock other locked pools, only unlocks pools that weren't explicitly locked.
/// - Regular nonReentrant modifier still locks all pools as expected.
abstract contract PoolwiseReentrancyGuard is ReentrancyGuard {
    using LibTransient for *;

    /// @dev Equal to uint256(keccak256("STATUS")) - 1
    bytes32 private constant STATUS_SLOT = 0x99d6ee9363d15a40a5ab48bebc5e3e7dd2c4e190c950f55fe724fad94b380d7e;
    /// @dev Equal to uint256(keccak256("POOL_STATUS_SLOT_SEED")) - 1
    bytes32 private constant POOL_STATUS_SLOT_SEED = 0xfac6d2c0a3bce7d29ecf3323c308c6b79ed20d2cae222f310de54c9969f4a35f;

    uint256 private constant NOT_ENTERED = 0;
    uint256 private constant ENTERED = 1;

    modifier poolwiseNonReentrant(PoolId id) {
        _poolwiseNonReentrantBefore(id);
        _;
        _poolwiseNonReentrantAfter(id);
    }

    function _poolwiseNonReentrantBefore(PoolId id) internal {
        // check global lock status
        bytes32 statusSlot = STATUS_SLOT;
        uint256 status;
        /// @solidity memory-safe-assembly
        assembly {
            status := tload(statusSlot)
        }
        if (status == ENTERED) revert ReentrancyGuard__ReentrantCall();

        // check pool lock status
        bytes32 poolStatusSlotSeed = POOL_STATUS_SLOT_SEED;
        bytes32 poolStatusSlot = EfficientHashLib.hash(poolStatusSlotSeed, PoolId.unwrap(id));
        /// @solidity memory-safe-assembly
        assembly {
            status := tload(poolStatusSlot)
        }
        if (status == ENTERED) revert ReentrancyGuard__ReentrantCall();

        uint256 entered = ENTERED;
        /// @solidity memory-safe-assembly
        assembly {
            tstore(statusSlot, entered)
            tstore(poolStatusSlot, entered)
        }
    }

    function _poolwiseNonReentrantAfter(PoolId id) internal {
        bytes32 statusSlot = STATUS_SLOT;
        bytes32 poolStatusSlotSeed = POOL_STATUS_SLOT_SEED;
        bytes32 poolStatusSlot = EfficientHashLib.hash(poolStatusSlotSeed, PoolId.unwrap(id));

        uint256 notEntered = NOT_ENTERED;
        /// @solidity memory-safe-assembly
        assembly {
            tstore(statusSlot, notEntered)
            tstore(poolStatusSlot, notEntered)
        }
    }
}
