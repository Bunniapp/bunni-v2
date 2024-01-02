// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;

import {IERC20} from "./IERC20.sol";
import {IBunniHub} from "./IBunniHub.sol";

/// @title BunniToken
/// @author zefram.eth
/// @notice ERC20 token that represents a user's LP position
interface IBunniToken is IERC20 {
    function hub() external view returns (IBunniHub);

    function token0() external view returns (IERC20);

    function token1() external view returns (IERC20);

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;
}
