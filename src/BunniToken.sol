// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.15;

import {ERC20} from "./lib/ERC20.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IBunniHub} from "./interfaces/IBunniHub.sol";
import {IBunniToken} from "./interfaces/IBunniToken.sol";

/// @title BunniToken
/// @author zefram.eth
/// @notice ERC20 token that represents a user's LP position
contract BunniToken is IBunniToken, ERC20 {
    IBunniHub public immutable override hub;

    constructor(IBunniHub hub_, IERC20 token0, IERC20 token1)
        ERC20(string(abi.encodePacked("Bunni ", token0.symbol(), "/", token1.symbol(), " LP")), "BUNNI-LP", 18)
    {
        hub = hub_;
    }

    function mint(address to, uint256 amount) external override {
        require(msg.sender == address(hub), "WHO");

        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external override {
        require(msg.sender == address(hub), "WHO");

        _burn(from, amount);
    }
}
