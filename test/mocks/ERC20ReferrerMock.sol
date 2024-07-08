// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {ERC20Referrer} from "../../src/base/ERC20Referrer.sol";

contract ERC20ReferrerMock is ERC20Referrer {
    function mint(address to, uint256 amount, uint24 referrer) public {
        _mint(to, amount, referrer);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function name() public pure override returns (string memory) {
        return "MockERC20";
    }

    function symbol() public pure override returns (string memory) {
        return "MOCK-ERC20";
    }
}
