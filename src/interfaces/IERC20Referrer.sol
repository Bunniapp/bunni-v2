// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IERC20Referrer {
    /// @notice Returns the score of a referrer. The score is the sum of all
    /// balances of accounts that have the referrer as their referrer.
    /// @param referrer The referrer whose score is to be returned.
    /// @return score The score of the referrer.
    function scoreOf(uint24 referrer) external view returns (uint256 score);

    /// @notice Returns the referrer of an account. Default referrer is 0.
    /// @param account The account whose referrer is to be returned.
    /// @return referrer The referrer of the account.
    function referrerOf(address account) external view returns (uint24 referrer);
}
