// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import "flood-contracts/src/interfaces/IZone.sol";

import "./IOwnable.sol";

interface IBunniZone is IZone, IOwnable {
    event SetIsWhitelisted(address indexed account, bool indexed isWhitelisted);

    function isWhitelisted(address fulfiller) external view returns (bool);

    function setIsWhitelisted(address account, bool isWhitelisted_) external;
}
