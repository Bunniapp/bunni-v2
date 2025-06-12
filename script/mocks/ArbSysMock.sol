// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

contract ArbSysMock {
    function arbBlockNumber() external view returns (uint256) {
        return block.number;
    }
}
