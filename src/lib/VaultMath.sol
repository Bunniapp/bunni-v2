pragma solidity ^0.8.20;

import {ERC4626} from "solady/tokens/ERC4626.sol";

function getReservesInUnderlying(uint256 reserveAmount, ERC4626 vault) view returns (uint256) {
    return address(vault) == address(0) ? reserveAmount : vault.previewRedeem(reserveAmount);
}
