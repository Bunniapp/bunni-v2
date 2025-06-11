// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "./BaseTest.sol";
import "./mocks/BasicBunniRebalancer.sol";

import "flood-contracts/src/interfaces/IFloodPlain.sol";

import "src/types/IdleBalance.sol";

contract RebalanceWithBunniLiqTest is BaseTest {
    using IdleBalanceLibrary for IdleBalance;

    BasicBunniRebalancer public rebalancer;
    ERC20Mock public token2;

    mapping(PoolId => IBunniToken) public idToBunniToken;

    function setUp() public override {
        super.setUp();

        rebalancer = new BasicBunniRebalancer(poolManager, floodPlain);
        zone.setIsWhitelisted(address(rebalancer), true);

        token2 = new ERC20Mock();
        token2.approve(address(PERMIT2), type(uint256).max);
        token2.approve(address(swapper), type(uint256).max);
        token2.approve(address(floodPlain), type(uint256).max);
        PERMIT2.approve(address(token2), address(hub), type(uint160).max, type(uint48).max);
        vm.startPrank(address(0x6969));
        token2.approve(address(PERMIT2), type(uint256).max);
        token2.approve(address(swapper), type(uint256).max);
        token2.approve(address(floodPlain), type(uint256).max);
        PERMIT2.approve(address(token2), address(hub), type(uint160).max, type(uint48).max);
        vm.stopPrank();

        // bubble sort token0, token1, token2
        if (address(token0) > address(token1)) {
            (token0, token1) = (token1, token0);
        }
        if (address(token1) > address(token2)) {
            (token1, token2) = (token2, token1);
        }
        if (address(token0) > address(token1)) {
            (token0, token1) = (token1, token0);
        }

        vm.startPrank(address(0x6969));
        token2.approve(address(PERMIT2), type(uint256).max);
        token2.approve(address(swapper), type(uint256).max);
        token2.approve(address(floodPlain), type(uint256).max);
        PERMIT2.approve(address(token2), address(hub), type(uint160).max, type(uint48).max);
        vm.stopPrank();
    }

    function test_rebalance_withBunniLiq() public {
        MockLDF ldf_ = new MockLDF(address(hub), address(bunniHook), address(quoter));
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), ALPHA));
        ldf_.setMinTick(-30);

        (IBunniToken btA, PoolKey memory keyA) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
            IHooklet(address(0)),
            ldfParams,
            abi.encodePacked(
                FEE_MIN,
                FEE_MAX,
                FEE_QUADRATIC_MULTIPLIER,
                FEE_TWAP_SECONDS_AGO,
                POOL_MAX_AMAMM_FEE,
                SURGE_HALFLIFE,
                SURGE_AUTOSTART_TIME,
                VAULT_SURGE_THRESHOLD_0,
                VAULT_SURGE_THRESHOLD_1,
                REBALANCE_THRESHOLD,
                REBALANCE_MAX_SLIPPAGE,
                REBALANCE_TWAP_SECONDS_AGO,
                REBALANCE_ORDER_TTL,
                true, // amAmmEnabled
                ORACLE_MIN_INTERVAL,
                MIN_RENT_MULTIPLIER
            ),
            bytes32(0)
        );

        (IBunniToken btB, PoolKey memory keyB) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token2)),
            ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
            IHooklet(address(0)),
            ldfParams,
            abi.encodePacked(
                FEE_MIN,
                FEE_MAX,
                FEE_QUADRATIC_MULTIPLIER,
                FEE_TWAP_SECONDS_AGO,
                POOL_MAX_AMAMM_FEE,
                SURGE_HALFLIFE,
                SURGE_AUTOSTART_TIME,
                VAULT_SURGE_THRESHOLD_0,
                VAULT_SURGE_THRESHOLD_1,
                REBALANCE_THRESHOLD,
                REBALANCE_MAX_SLIPPAGE,
                REBALANCE_TWAP_SECONDS_AGO,
                REBALANCE_ORDER_TTL,
                true, // amAmmEnabled
                ORACLE_MIN_INTERVAL,
                MIN_RENT_MULTIPLIER
            ),
            bytes32("1")
        );

        (IBunniToken btC, PoolKey memory keyC) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token1)),
            Currency.wrap(address(token2)),
            ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
            IHooklet(address(0)),
            ldfParams,
            abi.encodePacked(
                FEE_MIN,
                FEE_MAX,
                FEE_QUADRATIC_MULTIPLIER,
                FEE_TWAP_SECONDS_AGO,
                POOL_MAX_AMAMM_FEE,
                SURGE_HALFLIFE,
                SURGE_AUTOSTART_TIME,
                VAULT_SURGE_THRESHOLD_0,
                VAULT_SURGE_THRESHOLD_1,
                REBALANCE_THRESHOLD,
                REBALANCE_MAX_SLIPPAGE,
                REBALANCE_TWAP_SECONDS_AGO,
                REBALANCE_ORDER_TTL,
                true, // amAmmEnabled
                ORACLE_MIN_INTERVAL,
                MIN_RENT_MULTIPLIER
            ),
            bytes32("2")
        );

        idToBunniToken[keyA.toId()] = btA;
        idToBunniToken[keyB.toId()] = btB;
        idToBunniToken[keyC.toId()] = btC;

        // shift liquidity to the right
        // the LDF will demand more token0, so we'll have too much of token1
        ldf_.setMinTick(-20);

        // add JIT liquidity to inflate the idle balance
        (uint256 jitSharesA, uint256 jitAmount0A, uint256 jitAmount1A) =
            _makeDeposit(keyA, 1e18, 1e18, address(this), ""); // order amount token1 3.827e17 vs 1.913e17
        idToBunniToken[keyA.toId()].transfer(address(rebalancer), jitSharesA);

        // make swap to trigger rebalance
        uint256 swapAmount = 1e6;
        _mint(keyA.currency0, address(this), swapAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });
        vm.recordLogs();
        _swap(keyA, params, 0, "");

        IdleBalance idleBalanceBefore = hub.idleBalance(keyA.toId());
        (uint256 balanceBefore, bool isToken0Before) = idleBalanceBefore.fromIdleBalance();
        assertGt(balanceBefore, 0, "idle balance should be non-zero");
        assertFalse(isToken0Before, "idle balance should be in token1");

        // obtain the order from the logs
        Vm.Log[] memory logs_ = vm.getRecordedLogs();
        Vm.Log memory orderEtchedLog;
        for (uint256 i = 0; i < logs_.length; i++) {
            if (logs_[i].emitter == address(floodPlain) && logs_[i].topics[0] == IOnChainOrders.OrderEtched.selector) {
                orderEtchedLog = logs_[i];
                break;
            }
        }
        IFloodPlain.SignedOrder memory signedOrder = abi.decode(orderEtchedLog.data, (IFloodPlain.SignedOrder));

        // wait for the surge fee to go down
        skip(9 minutes);

        // need to add JIT liquidity to pool B (token0, token2) for swap to succeed
        (uint256 jitSharesB, uint256 jitAmount0B, uint256 jitAmount1B) =
            _makeDeposit(keyB, 1e18, 1e18, address(this), "");
        idToBunniToken[keyB.toId()].transfer(address(rebalancer), jitSharesB);

        // fulfill order using rebalancer
        vm.recordLogs();
        rebalancer.rebalance(
            signedOrder,
            keyA,
            keyB,
            keyC,
            jitSharesA,
            jitAmount0A,
            jitAmount1A,
            jitSharesB,
            jitAmount0B,
            jitAmount1B,
            address(hub)
        );
        // obtain any additional order from the logs
        Vm.Log[] memory logs_rebalance = vm.getRecordedLogs();
        Vm.Log[3] memory orderEtchedLogs;
        uint256 index;
        for (uint256 i = 0; i < logs_rebalance.length; i++) {
            if (
                logs_rebalance[i].emitter == address(floodPlain)
                    && logs_rebalance[i].topics[0] == IOnChainOrders.OrderEtched.selector
            ) {
                orderEtchedLogs[index++] = logs_rebalance[i];
                break;
            }
        }

        // should have 1 rebalance order etched with excess token1 in pool B
        for (uint256 i; i < orderEtchedLogs.length; i++) {
            if (orderEtchedLogs[i].emitter == address(0)) continue; // skip empty logs
            console2.log("Order etched log:", i);
            IFloodPlain.SignedOrder memory package = abi.decode(orderEtchedLog.data, (IFloodPlain.SignedOrder));
            console2.log("Rebalance order created for token: %s", package.order.offer[0].token);
            console2.log("Rebalance order offer amount:", package.order.offer[0].amount);
            console2.log("Rebalance order consideration token:", package.order.consideration.token);
            console2.log("Rebalance order consideration amount:", package.order.consideration.amount);
        }

        console2.log("Token0 balance after rebalance:", token0.balanceOf(address(rebalancer)));
        console2.log("Token1 balance after rebalance:", token1.balanceOf(address(rebalancer)));
        console2.log("Token2 balance after rebalance:", token2.balanceOf(address(rebalancer)));

        // withdraw liquidity to check profitability (we have to mock transient storage being reset)
        /* bunniHook.setWithdrawalUnblocked(keyB.toId(), true);
        rebalancer.withdrawJitLiquidity(
            keyA, jitSharesA, jitAmount0A, jitAmount1A, keyB, jitSharesB, jitAmount0B, jitAmount1B, address(hub)
        );

        console2.log("Token0 balance after withdraw:", token0.balanceOf(address(rebalancer)));
        console2.log("Token1 balance after withdraw:", token1.balanceOf(address(rebalancer)));
        console2.log("Token2 balance after withdraw:", token2.balanceOf(address(rebalancer)));

        // rebalancer should have profits in token1
        assertGt(token1.balanceOf(address(rebalancer)), 0, "rebalancer should have profits");

        (uint256 rawBalanceA, bool idleAIsToken0) = hub.idleBalance(keyA.toId()).fromIdleBalance();
        (uint256 rawBalanceB, bool idleBIsToken0) = hub.idleBalance(keyB.toId()).fromIdleBalance();
        (uint256 rawBalanceC, bool idleCIsToken0) = hub.idleBalance(keyC.toId()).fromIdleBalance();

        console2.log("Idle A is Token0:", idleAIsToken0);
        console2.log("Raw Balance A:", rawBalanceA);
        console2.log("Idle B is Token0:", idleBIsToken0);
        console2.log("Raw Balance B:", rawBalanceB);
        console2.log("Idle C is Token0:", idleCIsToken0);
        console2.log("Raw Balance C:", rawBalanceC); */
    }

    function test_outputExcessiveBidTokensDuringRebalanceAndRefund() public {
        // Step 1: Create a new pool
        (IBunniToken bt1, PoolKey memory poolKey1) = _deployPoolAndInitLiquidity();

        // Step 2: Send bids and rent tokens (BT1) to BunniHook
        uint128 minRent = uint128(bt1.totalSupply() * MIN_RENT_MULTIPLIER / 1e18);
        uint128 bidAmount = minRent * 10 days;
        address alice = makeAddr("Alice");
        deal(address(bt1), address(this), bidAmount);
        bt1.approve(address(bunniHook), bidAmount);
        bunniHook.bid(
            poolKey1.toId(), address(alice), bytes6(abi.encodePacked(uint24(1e3), uint24(2e3))), minRent, bidAmount
        );

        // Step 3: Create a new pool with BT1 and token2
        MockLDF mockLDF = new MockLDF(address(hub), address(bunniHook), address(quoter));
        mockLDF.setMinTick(-30); // minTick of MockLDFs need initialization

        // approve tokens
        vm.startPrank(address(0x6969));
        bt1.approve(address(PERMIT2), type(uint256).max);
        PERMIT2.approve(address(bt1), address(hub), type(uint160).max, type(uint48).max);
        PERMIT2.approve(address(token2), address(hub), type(uint160).max, type(uint48).max);
        vm.stopPrank();

        (Currency currency0, Currency currency1) = address(bt1) < address(token2)
            ? (Currency.wrap(address(bt1)), Currency.wrap(address(token2)))
            : (Currency.wrap(address(token2)), Currency.wrap(address(bt1)));
        (, PoolKey memory poolKey2) = _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            ERC4626(address(0)),
            ERC4626(address(0)),
            mockLDF,
            IHooklet(address(0)),
            bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), ALPHA)),
            abi.encodePacked(
                FEE_MIN,
                FEE_MAX,
                FEE_QUADRATIC_MULTIPLIER,
                FEE_TWAP_SECONDS_AGO,
                POOL_MAX_AMAMM_FEE,
                SURGE_HALFLIFE,
                SURGE_AUTOSTART_TIME,
                VAULT_SURGE_THRESHOLD_0,
                VAULT_SURGE_THRESHOLD_1,
                REBALANCE_THRESHOLD,
                REBALANCE_MAX_SLIPPAGE,
                REBALANCE_TWAP_SECONDS_AGO,
                REBALANCE_ORDER_TTL,
                true, // amAmmEnabled
                ORACLE_MIN_INTERVAL,
                MIN_RENT_MULTIPLIER
            ),
            bytes32(uint256(1))
        );

        // Step 4: Trigger a rebalance for the recursive pool
        // Shift liquidity to create an imbalance such that we need to swap token2 into bt1
        // Shift right if bt1 is token0, shift left if bt1 is token1
        mockLDF.setMinTick(address(bt1) < address(token2) ? -20 : -40);

        // Make a small swap to trigger rebalance
        uint256 swapAmount = 1e6;
        deal(address(bt1), address(this), swapAmount);
        bt1.approve(address(swapper), swapAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: address(bt1) < address(token2),
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: address(bt1) < address(token2) ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
        });

        // Record logs to capture the OrderEtched event
        vm.recordLogs();
        swapper.swap(poolKey2, params, type(uint256).max, 0);

        // Find the OrderEtched event
        Vm.Log[] memory logs_ = vm.getRecordedLogs();
        Vm.Log memory orderEtchedLog;
        for (uint256 i = 0; i < logs_.length; i++) {
            if (logs_[i].emitter == address(floodPlain) && logs_[i].topics[0] == IOnChainOrders.OrderEtched.selector) {
                orderEtchedLog = logs_[i];
                break;
            }
        }
        require(orderEtchedLog.emitter == address(floodPlain), "OrderEtched event not found");

        // Decode the order from the event
        IFloodPlain.SignedOrder memory signedOrder = abi.decode(orderEtchedLog.data, (IFloodPlain.SignedOrder));
        IFloodPlain.Order memory order = signedOrder.order;
        assertEq(order.offer[0].token, address(token2), "Order offer token should be token2");
        assertEq(order.consideration.token, address(bt1), "Order consideration token should be BT1");

        // Step 5: Prepare to fulfill order and slightly increase bid during source consideration
        uint256 bunniHookBalanceBefore = bt1.balanceOf(address(bunniHook));
        console2.log("BunniHook BT1 balance before rebalance:", bt1.balanceOf(address(bunniHook)));
        console2.log(
            "BunniHub BT1 6909 balance before rebalance:",
            poolManager.balanceOf(address(hub), Currency.wrap(address(bt1)).toId())
        );

        console2.log("BunniHook token2 balance before rebalance:", token2.balanceOf(address(bunniHook)));
        console2.log(
            "BunniHub token2 6909 balance before rebalance:",
            poolManager.balanceOf(address(hub), Currency.wrap(address(token2)).toId())
        );

        // slightly exceed the bid amount
        uint128 minRent1 = minRent * 1.11e18 / 1e18;
        uint128 bidAmount1 = minRent1 * 10 days;
        assertEq(bidAmount1 % minRent1, 0, "bidAmount1 should be a multiple of minRent");
        deal(address(bt1), address(this), order.consideration.amount + bidAmount1);
        bt1.approve(address(floodPlain), order.consideration.amount);
        bt1.approve(address(bunniHook), bidAmount1);

        console2.log("address(this) bt1 balance before rebalance:", bt1.balanceOf(address(this)));

        // Fulfill the rebalance order
        vm.expectRevert(BunniHook__RebalanceInProgress.selector);
        floodPlain.fulfillOrder(signedOrder, address(this), abi.encode(true, bunniHook, poolKey1, minRent1, bidAmount1));

        // alice exceeds the bid amount again
        /* uint128 mintRent2 = minRent1 * 1.11e18 / 1e18;
        uint128 bidAmount2 = mintRent2 * 10 days;
        deal(address(bt1), address(this), bidAmount2);
        bt1.approve(address(bunniHook), bidAmount2);
        bunniHook.bid(poolKey1.toId(), alice, bytes6(abi.encodePacked(uint24(1e3), uint24(2e3))), mintRent2, bidAmount2);

        // make a claim
        bunniHook.claimRefund(poolKey1.toId(), address(this));

        console2.log("BunniHook BT1 balance after rebalance and refund:", bt1.balanceOf(address(bunniHook)));
        console2.log("BunniHook token2 balance after rebalance and refund:", token2.balanceOf(address(bunniHook)));

        console2.log(
            "BunniHub BT1 6909 balance after rebalance and refund:",
            poolManager.balanceOf(address(hub), Currency.wrap(address(bt1)).toId())
        );
        console2.log(
            "BunniHub token2 6909 balance after rebalance and refund:",
            poolManager.balanceOf(address(hub), Currency.wrap(address(token2)).toId())
        );

        console2.log("address(this) BT1 balance after refund:", bt1.balanceOf(address(this)));
        console2.log("address(this) token2 balance after refund:", token2.balanceOf(address(this)));

        console2.log(
            "address(this) gained BT1 balance after rebalance and refund:",
            bt1.balanceOf(address(address(this))) - bidAmount1
        ); // consideration amount was swapped for token2
        console2.log(
            "BunniHook gained BT1 balance after rebalance and refund:",
            bt1.balanceOf(address(bunniHook)) - bunniHookBalanceBefore
        ); */
    }

    // Implementation of IFulfiller interface
    function sourceConsideration(
        bytes28, /* selectorExtension */
        IFloodPlain.Order calldata order,
        address, /* caller */
        bytes calldata data
    ) external returns (uint256) {
        bool isFirst = abi.decode(data[:32], (bool));
        bytes memory context = data[32:];

        if (isFirst) {
            (BunniHook bunniHook, PoolKey memory poolKey1, uint128 rent, uint128 bid) =
                abi.decode(context, (BunniHook, PoolKey, uint128, uint128));

            console2.log(
                "BunniHook BT1 balance before bid in sourceConsideration:",
                ERC20Mock(order.consideration.token).balanceOf(address(bunniHook))
            );

            bunniHook.bid(poolKey1.toId(), address(this), bytes6(abi.encodePacked(uint24(1e3), uint24(2e3))), rent, bid);

            console2.log(
                "BunniHook BT1 balance after bid in sourceConsideration:",
                ERC20Mock(order.consideration.token).balanceOf(address(bunniHook))
            );
        } else {
            (bytes32 poolId, address bunniToken) = abi.decode(context, (bytes32, address));
            IERC20(order.consideration.token).approve(msg.sender, order.consideration.amount);
            uint128 minRent = uint128(IERC20(bunniToken).totalSupply() * 1e10 / 1e18);
            uint128 deposit = uint128(7200 * minRent);
            IERC20(order.consideration.token).approve(address(bunniHook), uint256(deposit));
            bunniHook.bid(PoolId.wrap(poolId), address(this), bytes6(0), minRent, deposit);
            return order.consideration.amount;
        }

        return order.consideration.amount;
    }

    function test_normalBidding() external {
        (IBunniToken bt1, PoolKey memory poolKey1) =
            _deployPoolAndInitLiquidity(Currency.wrap(address(token0)), Currency.wrap(address(token1)));
        deal(address(bt1), address(this), 100e18);
        uint128 minRent = uint128(IERC20(bt1).totalSupply() * 1e10 / 1e18);
        uint128 deposit = uint128(7200 * minRent);
        IERC20(address(bt1)).approve(address(bunniHook), uint256(deposit));
        bunniHook.bid(poolKey1.toId(), address(this), bytes6(0), minRent, deposit);
    }

    function test_doubleBunniTokenAccounting() external {
        // swapAmount = bound(swapAmount, 1e6, 1e9);
        // feeMin = uint24(bound(feeMin, 2e5, 1e6 - 1));
        // feeMax = uint24(bound(feeMax, feeMin, 1e6 - 1));
        // alpha = uint32(bound(alpha, 1e3, 12e8));
        uint256 swapAmount = 496578468;
        uint24 feeMin = 800071;
        uint24 feeMax = 996693;
        uint32 alpha = 61123954;
        bool zeroForOne = true;
        uint24 feeQuadraticMultiplier = 18;

        uint256 counter;
        IBunniToken bt1 = IBunniToken(address(0));
        PoolKey memory poolKey1;
        while (address(bt1) < address(token0)) {
            (bt1, poolKey1) = _deployPoolAndInitLiquidity(
                Currency.wrap(address(token0)),
                Currency.wrap(address(token1)),
                bytes32(keccak256(abi.encode(counter++)))
            );
        }

        MockLDF ldf_ = new MockLDF(address(hub), address(bunniHook), address(quoter));
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), alpha));
        {
            PoolKey memory key_;
            key_.tickSpacing = TICK_SPACING;
            vm.assume(ldf_.isValidParams(key_, TWAP_SECONDS_AGO, ldfParams, LDFType.DYNAMIC_AND_STATEFUL));
        }
        ldf_.setMinTick(-30); // minTick of MockLDFs need initialization
        vm.startPrank(address(0x6969));
        IERC20(address(bt1)).approve(address(hub), type(uint256).max);
        IERC20(address(token0)).approve(address(hub), type(uint256).max);
        vm.stopPrank();
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(bt1)),
            ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
            IHooklet(address(0)),
            ldfParams,
            abi.encodePacked(
                feeMin,
                feeMax,
                feeQuadraticMultiplier,
                FEE_TWAP_SECONDS_AGO,
                POOL_MAX_AMAMM_FEE,
                SURGE_HALFLIFE,
                SURGE_AUTOSTART_TIME,
                VAULT_SURGE_THRESHOLD_0,
                VAULT_SURGE_THRESHOLD_1,
                REBALANCE_THRESHOLD,
                REBALANCE_MAX_SLIPPAGE,
                REBALANCE_TWAP_SECONDS_AGO,
                REBALANCE_ORDER_TTL,
                true, // amAmmEnabled
                ORACLE_MIN_INTERVAL,
                MIN_RENT_MULTIPLIER
            ),
            bytes32(keccak256("random")) // salt
        );

        // shift liquidity based on direction
        // for zeroForOne: shift left, LDF will demand more token1, so we'll have too much of token0
        // for oneForZero: shift right, LDF will demand more token0, so we'll have too much of token1
        ldf_.setMinTick(zeroForOne ? -40 : -20);

        // Define currencyIn and currencyOut based on direction
        Currency currencyIn = zeroForOne ? key.currency0 : key.currency1;
        Currency currencyOut = zeroForOne ? key.currency1 : key.currency0;
        Currency currencyInRaw = zeroForOne ? key.currency0 : key.currency1;
        Currency currencyOutRaw = zeroForOne ? key.currency1 : key.currency0;

        // make small swap to trigger rebalance
        _mint(key.currency0, address(this), swapAmount);
        vm.prank(address(this));
        IERC20(Currency.unwrap(key.currency0)).approve(address(swapper), type(uint256).max);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });
        vm.recordLogs();
        _swap(key, params, 0, "");

        // validate etched order
        Vm.Log[] memory logs = vm.getRecordedLogs();
        Vm.Log memory orderEtchedLog;
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].emitter == address(floodPlain) && logs[i].topics[0] == IOnChainOrders.OrderEtched.selector) {
                orderEtchedLog = logs[i];
                break;
            }
        }
        IFloodPlain.SignedOrder memory signedOrder = abi.decode(orderEtchedLog.data, (IFloodPlain.SignedOrder));
        IFloodPlain.Order memory order = signedOrder.order;

        // if there is no weth held in the contract, the rebalancing succeeds
        _mint(currencyOut, address(this), order.consideration.amount * 2);
        vm.expectRevert(BunniHook__RebalanceInProgress.selector);
        floodPlain.fulfillOrder(signedOrder, address(this), abi.encode(false, poolKey1.toId(), address(bt1)));
        /* vm.roll(vm.getBlockNumber() + 7200);
        bunniHook.getBidWrite(poolKey1.toId(), true);
        vm.roll(vm.getBlockNumber() + 7200);
        vm.expectRevert();
        bunniHook.getBidWrite(poolKey1.toId(), true); */
    }
}
