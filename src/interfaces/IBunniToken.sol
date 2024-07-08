// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;

import "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";

import {IERC20} from "./IERC20.sol";
import {IOwnable} from "./IOwnable.sol";
import {IBunniHub} from "./IBunniHub.sol";
import {IERC20Referrer} from "./IERC20Referrer.sol";
import {IERC20Lockable} from "./IERC20Lockable.sol";

/// @title BunniToken
/// @author zefram.eth
/// @notice ERC20 token that represents a user's LP position
interface IBunniToken is IERC20, IERC20Referrer, IERC20Lockable, IOwnable, IUnlockCallback {
    event SetMetadataURI(string newURI);

    function hub() external view returns (IBunniHub);

    function token0() external view returns (Currency);

    function token1() external view returns (Currency);

    function poolManager() external view returns (IPoolManager);

    function mint(address to, uint256 amount, uint24 referrer) external;

    function burn(address from, uint256 amount) external;

    function burn(uint256 amount) external;

    function initialize(address owner_, string calldata metadataURI_) external;

    function metadataURI() external view returns (string memory);

    function setMetadataURI(string calldata metadataURI_) external;

    /// @notice Distributes referral rewards to all referrers. Usually called by the hook but can be called by anyone.
    /// The referral rewards should be in the form of PoolManager ERC6909 claim tokens.
    /// @dev Does not early return if the reward amount is 0, so the caller is responsible for not calling this function
    /// if amount is indeed 0.
    /// @param isToken0 Whether the rewards are in token0 or token1
    /// @param amount The amount of rewards to distribute.
    function distributeReferralRewards(bool isToken0, uint256 amount) external;

    /// @notice Claims referral rewards for a given referrer ID. Can be called by anyone.
    /// Reverts if the referrer ID has not been registered in the hub.
    /// @param referrer The referrer ID to claim rewards for
    /// @return reward0 The amount of token0 rewards claimed
    /// @return reward1 The amount of token1 rewards claimed
    function claimReferralRewards(uint24 referrer) external returns (uint256 reward0, uint256 reward1);

    /// @notice Returns the amount of referral rewards claimable by a given referrer ID.
    /// @param referrer The referrer ID to check rewards for
    /// @return reward0 The amount of token0 rewards claimable
    /// @return reward1 The amount of token1 rewards claimable
    function getClaimableReferralRewards(uint24 referrer) external view returns (uint256 reward0, uint256 reward1);
}
