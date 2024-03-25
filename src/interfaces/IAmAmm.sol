// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

interface IAmAmm {
    error AmAmm__BidLocked();
    error AmAmm__InvalidBid();
    error AmAmm__NotEnabled();
    error AmAmm__Unauthorized();
    error AmAmm__InvalidDepositAmount();

    /// @notice Places a bid to become the manager of a pool
    /// @param id The pool id
    /// @param manager The address of the manager
    /// @param rent The rent per epoch
    /// @param deposit The deposit amount, must be a multiple of rent and cover rent for >=K epochs
    function bid(PoolId id, address manager, uint128 rent, uint128 deposit) external;

    /// @notice Withdraws from the deposit of the top bid. Only callable by topBids[id].manager. Reverts if D_top / R_top < K.
    /// @param id The pool id
    /// @param amount The amount to withdraw, must be a multiple of rent and leave D_top / R_top >= K
    /// @param recipient The address of the recipient
    function withdrawFromTopBid(PoolId id, uint128 amount, address recipient) external;

    /// @notice Withdraws from the deposit of the next bid. Only callable by nextBids[id].manager. Reverts if D_next / R_top < K.
    /// @param id The pool id
    /// @param amount The amount to withdraw, must be a multiple of rent and leave D_next / R_next >= K
    /// @param recipient The address of the recipient
    function withdrawFromNextBid(PoolId id, uint128 amount, address recipient) external;

    /// @notice Cancels the next bid. Only callable by nextBids[id].manager. Reverts if D_top / R_top < K.
    /// @param id The pool id
    /// @param recipient The address of the recipient
    /// @return refund The amount of refund claimed
    function cancelNextBid(PoolId id, address recipient) external returns (uint256 refund);

    /// @notice Claims the refundable deposit of a manager
    /// @param id The pool id
    /// @param manager The address of the manager
    /// @return refund The amount of refund claimed
    function claimRefund(PoolId id, address manager) external returns (uint256 refund);

    /// @notice Claims the accrued fees of a manager. Only callable by the manager.
    /// @param manager The address of the manager
    /// @param currency The currency of the fees
    /// @param recipient The address of the recipient
    /// @return fees The amount of fees claimed
    function claimFees(address manager, Currency currency, address recipient) external returns (uint256 fees);
}
