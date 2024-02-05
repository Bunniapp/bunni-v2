// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.15;

import {ERC20} from "solady/tokens/ERC20.sol";
import {ERC4626} from "solady/tokens/ERC4626.sol";

import {IERC20} from "../../src/interfaces/IERC20.sol";

contract ERC4626Mock is ERC4626 {
    address internal immutable _asset;

    constructor(IERC20 asset_) {
        _asset = address(asset_);
    }

    function asset() public view override returns (address) {
        return _asset;
    }

    function name() public pure override returns (string memory) {
        return "MockERC4626";
    }

    function symbol() public pure override returns (string memory) {
        return "MOCK-ERC4626";
    }
}
