// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import {ReentrancyGuard} from "./ReentrancyGuard.sol";
import {IPermit2Enabled} from "../interfaces/IPermit2Enabled.sol";

abstract contract Permit2Enabled is IPermit2Enabled, ReentrancyGuard {
    IPermit2 internal immutable permit2;

    constructor(IPermit2 permit2_) {
        permit2 = permit2_;
    }

    function permit(address owner, IPermit2.PermitSingle calldata permitSingle, bytes calldata signature)
        external
        override
        nonReentrant
    {
        permit2.permit(owner, permitSingle, signature);
    }

    function permit(address owner, IPermit2.PermitBatch calldata permitBatch, bytes calldata signature)
        external
        override
        nonReentrant
    {
        permit2.permit(owner, permitBatch, signature);
    }
}
