// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

import "./mocks/AmAmmMock.sol";
import "./mocks/ERC20Mock.sol";

contract AmAmmTest is Test {
    PoolId constant POOL_0 = PoolId.wrap(bytes32(0));

    uint72 internal constant K = 24; // 24 windows (hours)
    uint256 internal constant EPOCH_SIZE = 1 hours;
    uint256 internal constant MIN_BID_MULTIPLIER = 1.1e18; // 10%

    AmAmmMock amAmm;

    function setUp() external {
        amAmm = new AmAmmMock(new ERC20Mock(), new ERC20Mock(), new ERC20Mock());
        amAmm.bidToken().approve(address(amAmm), type(uint256).max);
        amAmm.setEnabled(POOL_0, true);
        amAmm.setMaxSwapFee(POOL_0, 0.1e6);
    }

    function test_stateTransition_AC() external {
        // mint bid tokens
        amAmm.bidToken().mint(address(this), K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 1e18, deposit: K * 1e18});

        // verify state
        IAmAmm.Bid memory bid = amAmm.getNextBid(POOL_0);
        assertEq(amAmm.bidToken().balanceOf(address(this)), 0, "didn't take bid tokens");
        assertEq(amAmm.bidToken().balanceOf(address(amAmm)), K * 1e18, "didn't give bid tokens");
        assertEq(bid.manager, address(this), "manager incorrect");
        assertEq(bid.swapFee, 0.01e6, "swapFee incorrect");
        assertEq(bid.rent, 1e18, "rent incorrect");
        assertEq(bid.deposit, K * 1e18, "deposit incorrect");
        assertEq(bid.epoch, _getEpoch(block.timestamp), "epoch incorrect");
    }

    function test_stateTransition_CC() external {
        // mint bid tokens
        amAmm.bidToken().mint(address(this), K * 1e18 + 30e18);

        // make first bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 1e18, deposit: K * 1e18});

        // make second bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 1.2e18, deposit: 30e18});

        // verify state
        IAmAmm.Bid memory bid = amAmm.getNextBid(POOL_0);
        assertEq(amAmm.bidToken().balanceOf(address(this)), 0, "didn't take bid tokens");
        assertEq(amAmm.bidToken().balanceOf(address(amAmm)), K * 1e18 + 30e18, "didn't give bid tokens");
        assertEq(amAmm.getRefund(address(this), POOL_0), K * 1e18, "didn't refund first bid");
        assertEq(bid.manager, address(this), "manager incorrect");
        assertEq(bid.swapFee, 0.01e6, "swapFee incorrect");
        assertEq(bid.rent, 1.2e18, "rent incorrect");
        assertEq(bid.deposit, 30e18, "deposit incorrect");
        assertEq(bid.epoch, _getEpoch(block.timestamp), "epoch incorrect");
    }

    function test_stateTransition_CB() external {
        // mint bid tokens
        amAmm.bidToken().mint(address(this), K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 1e18, deposit: K * 1e18});

        // wait K epochs
        skip(K * EPOCH_SIZE);

        // verify state
        IAmAmm.Bid memory bid = amAmm.getTopBidWrite(POOL_0);
        assertEq(bid.manager, address(this), "manager incorrect");
        assertEq(bid.swapFee, 0.01e6, "swapFee incorrect");
        assertEq(bid.rent, 1e18, "rent incorrect");
        assertEq(bid.deposit, K * 1e18, "deposit incorrect");
        assertEq(bid.epoch, _getEpoch(block.timestamp), "epoch incorrect");
    }

    function test_stateTransition_BB() external {
        // mint bid tokens
        amAmm.bidToken().mint(address(this), K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 1e18, deposit: K * 1e18});

        // wait K + 3 epochs
        skip((K + 3) * EPOCH_SIZE);

        // verify state
        IAmAmm.Bid memory bid = amAmm.getTopBidWrite(POOL_0);
        assertEq(bid.manager, address(this), "manager incorrect");
        assertEq(bid.swapFee, 0.01e6, "swapFee incorrect");
        assertEq(bid.rent, 1e18, "rent incorrect");
        assertEq(bid.deposit, (K - 3) * 1e18, "deposit incorrect");
        assertEq(bid.epoch, _getEpoch(block.timestamp), "epoch incorrect");
        assertEq(amAmm.bidToken().balanceOf(address(amAmm)), bid.deposit, "didn't burn rent");
    }

    function test_stateTransition_BA() external {
        // mint bid tokens
        amAmm.bidToken().mint(address(this), K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 1e18, deposit: K * 1e18});

        // wait 2K epochs
        skip(2 * K * EPOCH_SIZE);

        // verify state
        IAmAmm.Bid memory bid = amAmm.getTopBidWrite(POOL_0);
        assertEq(bid.manager, address(0), "manager incorrect");
        assertEq(bid.swapFee, 0, "swapFee incorrect");
        assertEq(bid.rent, 0, "rent incorrect");
        assertEq(bid.deposit, 0, "deposit incorrect");
        assertEq(bid.epoch, 0, "epoch incorrect");
        assertEq(amAmm.bidToken().balanceOf(address(amAmm)), bid.deposit, "didn't burn rent");
    }

    function test_stateTransition_BD() external {
        // mint bid tokens
        amAmm.bidToken().mint(address(this), K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 1e18, deposit: K * 1e18});

        // wait K epochs
        skip(K * EPOCH_SIZE);

        // mint bid tokens
        amAmm.bidToken().mint(address(this), 2 * K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 2e18, deposit: 2 * K * 1e18});

        // verify top bid state
        IAmAmm.Bid memory bid = amAmm.getTopBid(POOL_0);
        assertEq(bid.manager, address(this), "manager incorrect");
        assertEq(bid.swapFee, 0.01e6, "swapFee incorrect");
        assertEq(bid.rent, 1e18, "rent incorrect");
        assertEq(bid.deposit, K * 1e18, "deposit incorrect");
        assertEq(bid.epoch, _getEpoch(block.timestamp), "epoch incorrect");

        // verify next bid state
        bid = amAmm.getNextBid(POOL_0);
        assertEq(bid.manager, address(this), "manager incorrect");
        assertEq(bid.swapFee, 0.01e6, "swapFee incorrect");
        assertEq(bid.rent, 2e18, "rent incorrect");
        assertEq(bid.deposit, 2 * K * 1e18, "deposit incorrect");
        assertEq(bid.epoch, _getEpoch(block.timestamp), "epoch incorrect");
    }

    function test_stateTransition_DD() external {
        // mint bid tokens
        amAmm.bidToken().mint(address(this), K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 1e18, deposit: K * 1e18});

        // wait K epochs
        skip(K * EPOCH_SIZE);

        // mint bid tokens
        amAmm.bidToken().mint(address(this), 2 * K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 2e18, deposit: 2 * K * 1e18});

        // mint bid tokens
        amAmm.bidToken().mint(address(this), 3 * K * 1e18);

        // make higher bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 3e18, deposit: 3 * K * 1e18});

        // wait 3 epochs
        skip(3 * EPOCH_SIZE);

        // verify top bid state
        IAmAmm.Bid memory bid = amAmm.getTopBidWrite(POOL_0);
        assertEq(bid.manager, address(this), "top bid manager incorrect");
        assertEq(bid.swapFee, 0.01e6, "top bid swapFee incorrect");
        assertEq(bid.rent, 1e18, "top bid rent incorrect");
        assertEq(bid.deposit, (K - 3) * 1e18, "top bid deposit incorrect");
        assertEq(bid.epoch, _getEpoch(block.timestamp), "top bid epoch incorrect");

        // verify next bid state
        bid = amAmm.getNextBid(POOL_0);
        assertEq(bid.manager, address(this), "next bid manager incorrect");
        assertEq(bid.swapFee, 0.01e6, "next bid swapFee incorrect");
        assertEq(bid.rent, 3e18, "next bid rent incorrect");
        assertEq(bid.deposit, 3 * K * 1e18, "next bid deposit incorrect");
        assertEq(bid.epoch, _getEpoch(block.timestamp) - 3, "next bid epoch incorrect");

        // verify bid token balance
        assertEq(amAmm.bidToken().balanceOf(address(amAmm)), (6 * K - 3) * 1e18, "bid token balance incorrect");
    }

    function test_stateTransition_DB_afterKEpochs() external {
        // mint bid tokens
        amAmm.bidToken().mint(address(this), K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 1e18, deposit: K * 1e18});

        // wait K epochs
        skip(K * EPOCH_SIZE);

        // mint bid tokens
        amAmm.bidToken().mint(address(this), 2 * K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.05e6, rent: 2e18, deposit: 2 * K * 1e18});

        // wait K epochs
        skip(K * EPOCH_SIZE);

        // verify top bid state
        IAmAmm.Bid memory bid = amAmm.getTopBidWrite(POOL_0);
        assertEq(bid.manager, address(this), "top bid manager incorrect");
        assertEq(bid.swapFee, 0.05e6, "top bid swapFee incorrect");
        assertEq(bid.rent, 2e18, "top bid rent incorrect");
        assertEq(bid.deposit, 2 * K * 1e18, "top bid deposit incorrect");
        assertEq(bid.epoch, _getEpoch(block.timestamp), "top bid epoch incorrect");

        // verify next bid state
        bid = amAmm.getNextBid(POOL_0);
        assertEq(bid.manager, address(0), "next bid manager incorrect");
        assertEq(bid.swapFee, 0, "next bid swapFee incorrect");
        assertEq(bid.rent, 0, "next bid rent incorrect");
        assertEq(bid.deposit, 0, "next bid deposit incorrect");
        assertEq(bid.epoch, 0, "next bid epoch incorrect");

        // verify bid token balance
        assertEq(amAmm.bidToken().balanceOf(address(amAmm)), 2 * K * 1e18, "bid token balance incorrect");
    }

    function test_stateTransition_DB_afterDepositDepletes() external {
        // mint bid tokens
        amAmm.bidToken().mint(address(this), K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.01e6, rent: 1e18, deposit: K * 1e18});

        // wait 2 * K - 3 epochs
        skip((2 * K - 3) * EPOCH_SIZE);

        // mint bid tokens
        amAmm.bidToken().mint(address(this), 2 * K * 1e18);

        // make bid
        amAmm.bid({id: POOL_0, manager: address(this), swapFee: 0.05e6, rent: 2e18, deposit: 2 * K * 1e18});

        // wait 3 epochs
        skip(3 * EPOCH_SIZE);

        // verify top bid state
        IAmAmm.Bid memory bid = amAmm.getTopBidWrite(POOL_0);
        assertEq(bid.manager, address(this), "top bid manager incorrect");
        assertEq(bid.swapFee, 0.05e6, "top bid swapFee incorrect");
        assertEq(bid.rent, 2e18, "top bid rent incorrect");
        assertEq(bid.deposit, 2 * K * 1e18, "top bid deposit incorrect");
        assertEq(bid.epoch, _getEpoch(block.timestamp), "top bid epoch incorrect");

        // verify next bid state
        bid = amAmm.getNextBid(POOL_0);
        assertEq(bid.manager, address(0), "next bid manager incorrect");
        assertEq(bid.swapFee, 0, "next bid swapFee incorrect");
        assertEq(bid.rent, 0, "next bid rent incorrect");
        assertEq(bid.deposit, 0, "next bid deposit incorrect");
        assertEq(bid.epoch, 0, "next bid epoch incorrect");

        // verify bid token balance
        assertEq(amAmm.bidToken().balanceOf(address(amAmm)), 2 * K * 1e18, "bid token balance incorrect");
    }

    function _getEpoch(uint256 timestamp) internal pure returns (uint72) {
        return uint72(timestamp / EPOCH_SIZE);
    }
}
