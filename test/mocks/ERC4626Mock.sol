// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.15;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

import {IERC20} from "../../src/interfaces/IERC20.sol";

contract ERC4626Mock is ERC4626 {
    constructor(IERC20 _asset, string memory _name, string memory _symbol)
        ERC4626(ERC20(address(_asset)), _name, _symbol)
    {}

    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }
}
