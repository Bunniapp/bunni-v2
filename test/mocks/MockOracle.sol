// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IOracle} from "../../src/ldf/managed/IOracle.sol";

contract MockOracle is IOracle {
    uint256 private floorPrice;

    function setFloorPrice(uint256 _floorPrice) external {
        floorPrice = _floorPrice;
    }

    /// @inheritdoc IOracle
    function getFloorPrice() external view returns (uint256) {
        return floorPrice;
    }
}
