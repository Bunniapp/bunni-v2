// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

/// @title AmAmm
/// @author zefram.eth
/// @notice Implements the auction mechanism from the am-AMM paper (https://arxiv.org/abs/2403.03367)
abstract contract AmAmm {
    /// -----------------------------------------------------------------------
    /// Library usage
    /// -----------------------------------------------------------------------

    using SafeCastLib for *;
    using FixedPointMathLib for *;

    /// -----------------------------------------------------------------------
    /// Constants
    /// -----------------------------------------------------------------------

    uint96 internal constant K = 24; // 24 windows (hours)
    uint256 internal constant EPOCH_SIZE = 1 hours;
    uint256 internal constant MIN_BID_MULTIPLIER = 1.1e18; // 10%

    /// -----------------------------------------------------------------------
    /// Structs
    /// -----------------------------------------------------------------------

    struct Bid {
        address manager;
        uint96 epoch; // epoch when the bid was created / last charged rent
        uint128 rent; // rent per hour
        uint128 deposit; // rent deposit amount
    }

    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    mapping(PoolId id => Bid) internal _topBids;
    mapping(PoolId id => Bid) internal _nextBids;
    mapping(address manager => mapping(PoolId id => uint256)) internal _refunds;
    mapping(address manager => mapping(Currency currency => uint256)) internal _fees;

    /// -----------------------------------------------------------------------
    /// Errors
    /// -----------------------------------------------------------------------

    error AmAmm__BidLocked();
    error AmAmm__InvalidBid();
    error AmAmm__NotEnabled();
    error AmAmm__Unauthorized();
    error AmAmm__InvalidDepositAmount();

    /// -----------------------------------------------------------------------
    /// Bidder actions
    /// -----------------------------------------------------------------------

    /// @notice Places a bid to become the manager of a pool
    /// @param id The pool id
    /// @param manager The address of the manager
    /// @param rent The rent per epoch
    /// @param deposit The deposit amount, must be a multiple of rent and cover rent for >=K epochs
    function bid(PoolId id, address manager, uint128 rent, uint128 deposit) external virtual {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (!_amAmmEnabled(id)) {
            revert AmAmm__NotEnabled();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // update state machine
        _updateAmAmm(id);

        // ensure bid is valid
        // - manager can't be zero address
        // - bid needs to be greater than top bid and next bid
        // - deposit needs to cover the rent for K hours
        // - deposit needs to be a multiple of rent
        if (
            manager == address(0) || rent <= _topBids[id].rent.mulWad(MIN_BID_MULTIPLIER)
                || rent <= _nextBids[id].rent.mulWad(MIN_BID_MULTIPLIER) || deposit < rent * K || deposit % rent != 0
        ) {
            revert AmAmm__InvalidBid();
        }

        // refund deposit of the previous next bid
        _refunds[_nextBids[id].manager][id] += _nextBids[id].deposit;

        // update next bid
        _nextBids[id] = Bid(manager, _getEpoch(block.timestamp), rent, deposit);

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // transfer deposit from msg.sender to this contract
        _transferBidToken(id, msg.sender, address(this), deposit);
    }

    /// @notice Withdraws from the deposit of the top bid. Only callable by topBids[id].manager. Reverts if D_top / R_top < K.
    /// @param id The pool id
    /// @param amount The amount to withdraw, must be a multiple of rent and leave D_top / R_top >= K
    function withdrawTopBid(PoolId id, uint128 amount) external virtual {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (!_amAmmEnabled(id)) {
            revert AmAmm__NotEnabled();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // update state machine
        _updateAmAmm(id);

        Bid memory topBid = _topBids[id];

        // only the top bid manager can withdraw from the top bid
        if (msg.sender != topBid.manager) {
            revert AmAmm__Unauthorized();
        }

        // ensure amount is a multiple of rent
        if (amount % topBid.rent != 0) {
            revert AmAmm__InvalidDepositAmount();
        }

        // require D_top / R_top >= K
        if ((topBid.deposit - amount) / topBid.rent < K) {
            revert AmAmm__BidLocked();
        }

        // deduct amount from top bid deposit
        _topBids[id].deposit = topBid.deposit - amount;

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // transfer amount to msg.sender
        _transferBidToken(id, address(this), msg.sender, amount);
    }

    /// @notice Withdraws from the deposit of the next bid. Only callable by nextBids[id].manager. Reverts if D_next / R_top < K.
    /// @param id The pool id
    /// @param amount The amount to withdraw, must be a multiple of rent and leave D_next / R_next >= K
    function withdrawNextBid(PoolId id, uint128 amount) external virtual {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (!_amAmmEnabled(id)) {
            revert AmAmm__NotEnabled();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // update state machine
        _updateAmAmm(id);

        Bid memory nextBid = _nextBids[id];

        // only the next bid manager can withdraw from the next bid
        if (msg.sender != nextBid.manager) {
            revert AmAmm__Unauthorized();
        }

        // ensure amount is a multiple of rent
        if (amount % nextBid.rent != 0) {
            revert AmAmm__InvalidDepositAmount();
        }

        // require D_next / R_next >= K
        if ((nextBid.deposit - amount) / nextBid.rent < K) {
            revert AmAmm__BidLocked();
        }

        // deduct amount from next bid deposit
        _nextBids[id].deposit = nextBid.deposit - amount;

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // transfer amount to msg.sender
        _transferBidToken(id, address(this), msg.sender, amount);
    }

    /// @notice Cancels the next bid. Only callable by nextBids[id].manager. Reverts if D_top / R_top < K.
    /// @param id The pool id
    function cancelNextBid(PoolId id) external virtual {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (!_amAmmEnabled(id)) {
            revert AmAmm__NotEnabled();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // update state machine
        _updateAmAmm(id);

        Bid memory nextBid = _nextBids[id];

        // only the next bid manager can withdraw from the next bid
        if (msg.sender != nextBid.manager) {
            revert AmAmm__Unauthorized();
        }

        Bid memory topBid = _topBids[id];

        // require D_top / R_top >= K
        if (topBid.deposit / topBid.rent < K) {
            revert AmAmm__BidLocked();
        }

        // delete next bid from storage
        delete _nextBids[id];

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // transfer nextBid.deposit to msg.sender
        _transferBidToken(id, address(this), msg.sender, nextBid.deposit);
    }

    /// @notice Claims the refundable deposit of a manager
    /// @param id The pool id
    /// @param manager The address of the manager
    function claimRefund(PoolId id, address manager) external virtual {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (!_amAmmEnabled(id)) {
            revert AmAmm__NotEnabled();
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // update state machine
        _updateAmAmm(id);

        uint256 refund = _refunds[manager][id];
        if (refund == 0) {
            return;
        }
        delete _refunds[manager][id];

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // transfer refund to manager
        _transferBidToken(id, address(this), manager, refund);
    }

    /// -----------------------------------------------------------------------
    /// Virtual functions
    /// -----------------------------------------------------------------------

    /// @dev Returns whether the am-AMM is enabled for a given pool
    function _amAmmEnabled(PoolId id) internal virtual returns (bool);

    /// @dev Burns bid tokens
    function _burnBidToken(PoolId id, uint256 amount) internal virtual;

    /// @dev Transfers bid tokens
    function _transferBidToken(PoolId id, address from, address to, uint256 amount) internal virtual;

    /// @dev Accrues swap fees to the manager
    function _accrueFees(address manager, Currency currency, uint256 amount) internal virtual {
        _fees[manager][currency] += amount;
    }

    /// -----------------------------------------------------------------------
    /// Internal helpers
    /// -----------------------------------------------------------------------

    /// @dev Charges rent and updates the top and next bids for a given pool
    function _updateAmAmm(PoolId id) internal virtual returns (address manager) {
        Bid memory topBid = _topBids[id];
        Bid memory nextBid = _nextBids[id];
        bool updatedTopBid;
        bool updatedNextBid;
        uint256 rentCharged;

        // run state machine
        uint96 currentEpoch = _getEpoch(block.timestamp);
        {
            bool stepHasUpdatedTopBid;
            bool stepHasUpdatedNextBid;
            uint256 stepRentCharged;
            while (true) {
                (topBid, nextBid, stepHasUpdatedTopBid, stepHasUpdatedNextBid, stepRentCharged) =
                    _stateTransition(currentEpoch, id, topBid, nextBid);

                if (!stepHasUpdatedTopBid && !stepHasUpdatedNextBid) {
                    break;
                }

                updatedTopBid = updatedTopBid || stepHasUpdatedTopBid;
                updatedNextBid = updatedNextBid || stepHasUpdatedNextBid;
                rentCharged += stepRentCharged;
            }
        }

        // update top and next bids
        if (updatedTopBid) {
            _topBids[id] = topBid;
        }
        if (updatedNextBid) {
            _nextBids[id] = nextBid;
        }

        // burn rent charged
        if (rentCharged != 0) {
            _burnBidToken(id, rentCharged);
        }

        return topBid.manager;
    }

    /// @dev Returns the updated top and next bids after a single state transition
    /// State diagram is as follows:
    ///                                          after
    ///                 ┌───────────────────────deposit ───────────────────┐
    ///                 │                       depletes                   │
    ///                 ▼                                                  │
    ///    ┌────────────────────────┐                         ┌────────────────────────┐
    ///    │                        │                         │                        │
    ///    │        State A         │                         │        State B         │
    ///    │      Manager: nil      │            ┌───────────▶│      Manager: r0       │◀─┐
    ///    │       Next: nil        │            │            │       Next: nil        │  │
    ///    │                        │            │            │                        │  │
    ///    └────────────────────────┘            │            └────────────────────────┘  │
    ///                 │                        │                         │              │
    ///                 │                        │                         │              │
    ///                 │                        │                         │              │
    ///                 │                        │                         │           after K
    ///              bid(r)                  after K                    bid(r)        blocks or
    ///                 │                     blocks                       │            after
    ///                 │                        │                         │           deposit
    ///                 │                        │                         │          depletes
    ///                 │                        │                         │              │
    ///                 │                        │                         │              │
    ///                 │                        │                         │              │
    ///                 ▼                        │                         ▼              │
    ///    ┌────────────────────────┐            │            ┌────────────────────────┐  │
    ///    │                        │            │            │                        │  │
    ///    │        State C         │            │            │        State D         │  │
    /// ┌─▶│      Manager: nil      │────────────┘         ┌─▶│      Manager: r0       │──┘
    /// │  │        Next: r         │                      │  │        Next: r         │
    /// │  │                        │                      │  │                        │
    /// │  └────────────────────────┘                      │  └────────────────────────┘
    /// │               │                                  │               │
    /// │               │                                  │               │
    /// └─────bid(r)────┘                                  └─────bid(r)────┘
    function _stateTransition(uint96 currentEpoch, PoolId id, Bid memory topBid, Bid memory nextBid)
        internal
        virtual
        returns (Bid memory, Bid memory, bool updatedTopBid, bool updatedNextBid, uint256 rentCharged)
    {
        if (nextBid.manager == address(0)) {
            if (topBid.manager != address(0)) {
                // State B
                // charge rent from top bid
                uint96 epochsPassed;
                unchecked {
                    // unchecked so that if epoch ever overflows, we simply wrap around
                    epochsPassed = currentEpoch - topBid.epoch;
                }
                uint256 rentOwed = epochsPassed * topBid.rent;
                if (rentOwed >= topBid.deposit) {
                    // State B -> State A
                    // the top bid's deposit has been depleted
                    rentCharged = topBid.deposit;

                    topBid = Bid(address(0), 0, 0, 0);

                    updatedTopBid = true;
                } else if (rentOwed != 0) {
                    // State B
                    // charge rent from top bid
                    rentCharged = rentOwed;

                    topBid.deposit -= rentOwed.toUint128();
                    topBid.epoch = uint96(currentEpoch);

                    updatedTopBid = true;
                }
            }
        } else {
            if (topBid.manager == address(0)) {
                // State C
                // check if K epochs have passed since the next bid was submitted
                // if so, promote next bid to top bid
                uint96 nextBidStartEpoch;
                unchecked {
                    // unchecked so that if epoch ever overflows, we simply wrap around
                    nextBidStartEpoch = nextBid.epoch + K;
                }
                if (currentEpoch >= nextBidStartEpoch) {
                    // State C -> State B
                    // promote next bid to top bid
                    topBid = nextBid;
                    topBid.epoch = nextBidStartEpoch;
                    nextBid = Bid(address(0), 0, 0, 0);

                    updatedTopBid = true;
                    updatedNextBid = true;
                }
            } else {
                // State D
                // we charge rent from the top bid only until K epochs after the next bid was submitted
                uint96 epochsPassed;
                unchecked {
                    // unchecked so that if epoch ever overflows, we simply wrap around
                    epochsPassed =
                        uint96(FixedPointMathLib.min(currentEpoch - topBid.epoch, nextBid.epoch + K - topBid.epoch));
                }
                uint256 rentOwed = epochsPassed * topBid.rent;
                if (rentOwed >= topBid.deposit) {
                    // State D -> State B
                    // top bid has insufficient deposit
                    // next bid becomes active after top bid depletes its deposit
                    rentCharged = topBid.deposit;

                    topBid = nextBid;
                    unchecked {
                        // unchecked so that if epoch ever overflows, we simply wrap around
                        topBid.epoch = uint96(topBid.deposit / topBid.rent) + topBid.epoch;
                    }
                    nextBid = Bid(address(0), 0, 0, 0);

                    updatedTopBid = true;
                    updatedNextBid = true;
                } else {
                    // State D
                    // top bid has sufficient deposit
                    // charge rent from top bid
                    if (rentOwed != 0) {
                        rentCharged = rentOwed;

                        topBid.deposit -= rentOwed.toUint128();
                        topBid.epoch = currentEpoch;

                        updatedTopBid = true;
                    }

                    // check if K epochs have passed since the next bid was submitted
                    // if so, promote next bid to top bid
                    uint96 nextBidStartEpoch;
                    unchecked {
                        // unchecked so that if epoch ever overflows, we simply wrap around
                        nextBidStartEpoch = nextBid.epoch + K;
                    }
                    if (currentEpoch >= nextBidStartEpoch) {
                        // State D -> State B
                        // refund remaining deposit to top bid manager
                        _refunds[topBid.manager][id] += topBid.deposit;

                        // promote next bid to top bid
                        topBid = nextBid;
                        topBid.epoch = nextBidStartEpoch;
                        nextBid = Bid(address(0), 0, 0, 0);

                        updatedTopBid = true;
                        updatedNextBid = true;
                    }
                }
            }
        }

        return (topBid, nextBid, updatedTopBid, updatedNextBid, rentCharged);
    }

    function _getEpoch(uint256 timestamp) internal pure returns (uint96) {
        return uint96(timestamp / EPOCH_SIZE);
    }
}
