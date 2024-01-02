// SPDX-License-Identifier: AGPL-3.0

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
    IERC20 public immutable override token0;
    IERC20 public immutable override token1;

    error BunniToken__NotBunniHub();

    constructor(IBunniHub hub_, IERC20 token0_, IERC20 token1_) {
        hub = hub_;
        token0 = token0_;
        token1 = token1_;
    }

    function mint(address to, uint256 amount) external override {
        if (msg.sender != address(hub)) revert BunniToken__NotBunniHub();

        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external override {
        if (msg.sender != address(hub)) revert BunniToken__NotBunniHub();

        _burn(from, amount);
    }

    function name() public view override(ERC20, IERC20) returns (string memory) {
        return string(abi.encodePacked("Bunni ", _symbol(token0), "/", _symbol(token1), " LP"));
    }

    function symbol() public view override(ERC20, IERC20) returns (string memory) {
        return string(abi.encodePacked("BUNNI-", _symbol(token0), "-", _symbol(token1), "-LP"));
    }

    function _symbol(IERC20 token) internal view returns (string memory) {
        if (address(token) == address(0)) return "ETH";
        return token.symbol();
    }
}
