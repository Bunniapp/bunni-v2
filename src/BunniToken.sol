// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.15;

import {Clone} from "clones-with-immutable-args/Clone.sol";

import "./base/Errors.sol";
import {ERC20} from "./base/ERC20.sol";
import {Ownable} from "./base/Ownable.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IBunniHub} from "./interfaces/IBunniHub.sol";
import {IBunniToken} from "./interfaces/IBunniToken.sol";
import {ERC20Multicallable} from "./base/ERC20Multicallable.sol";

/// @title BunniToken
/// @author zefram.eth
/// @notice ERC20 token that represents a user's LP position
contract BunniToken is IBunniToken, ERC20Multicallable, Clone, Ownable {
    string public metadataURI;

    function hub() public pure override returns (IBunniHub) {
        return IBunniHub(_getArgAddress(0));
    }

    function token0() public pure override returns (IERC20) {
        return IERC20(_getArgAddress(20));
    }

    function token1() public pure override returns (IERC20) {
        return IERC20(_getArgAddress(40));
    }

    function name() public pure override(ERC20, IERC20) returns (string memory) {
        return string(abi.encodePacked(_getArgUint256(60)));
    }

    function symbol() public pure override(ERC20, IERC20) returns (string memory) {
        return string(abi.encodePacked(_getArgUint256(92)));
    }

    function initialize(address owner_, string calldata metadataURI_) external override {
        if (msg.sender != address(hub())) revert BunniToken__NotBunniHub();
        _initializeOwner(owner_);
        metadataURI = metadataURI_;
        emit SetMetadataURI(metadataURI_);
    }

    function mint(address to, uint256 amount) external override {
        if (msg.sender != address(hub())) revert BunniToken__NotBunniHub();

        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external override {
        if (msg.sender != address(hub())) revert BunniToken__NotBunniHub();

        _burn(from, amount);
    }

    function burn(uint256 amount) external override {
        _burn(msg.sender, amount);
    }

    function setMetadataURI(string calldata metadataURI_) external override onlyOwner {
        metadataURI = metadataURI_;
        emit SetMetadataURI(metadataURI_);
    }
}
