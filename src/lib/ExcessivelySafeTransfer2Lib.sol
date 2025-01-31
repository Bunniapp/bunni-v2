// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

import {IERC20} from "../interfaces/IERC20.sol";

library ExcessivelySafeTransfer2Lib {
    using SafeTransferLib for address;

    function excessivelySafeTransferFrom2(address token, address from, address to, uint256 amount) internal {
        // check allowance
        uint256 allowance = IERC20(token).allowance(from, address(this));
        if (allowance < amount) {
            // regular safe transfer from will fail
            // use permit2 to transfer from
            token.permit2TransferFrom(from, to, amount);
        } else {
            // regular safe transfer from will work
            token.safeTransferFrom(from, to, amount);
        }
    }
}
