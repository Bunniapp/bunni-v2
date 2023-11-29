// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

interface IPermit2Enabled {
    function permit(address owner, IPermit2.PermitSingle calldata permitSingle, bytes calldata signature) external;

    function permit(address owner, IPermit2.PermitBatch calldata permitBatch, bytes calldata signature) external;
}
