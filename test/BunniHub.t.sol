// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {GasSnapshot} from "forge-gas-snapshot/GasSnapshot.sol";

import {IFloodPlain} from "flood-contracts/src/interfaces/IFloodPlain.sol";
import {IOnChainOrders} from "flood-contracts/src/interfaces/IOnChainOrders.sol";

import {LibMulticaller} from "multicaller/LibMulticaller.sol";
import {MulticallerEtcher} from "multicaller/MulticallerEtcher.sol";
import {MulticallerWithSender} from "multicaller/MulticallerWithSender.sol";
import {MulticallerWithSigner} from "multicaller/MulticallerWithSigner.sol";

import {IEIP712} from "permit2/src/interfaces/IEIP712.sol";
import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";
import {IERC1271} from "permit2/src/interfaces/IERC1271.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {PoolManager} from "@uniswap/v4-core/src/PoolManager.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {WETH} from "solady/tokens/WETH.sol";
import {ERC4626} from "solady/tokens/ERC4626.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "../src/lib/Math.sol";
import "../src/base/Errors.sol";
import "../src/types/LDFType.sol";
import "../src/ldf/ShiftMode.sol";
import "../src/base/SharedStructs.sol";
import {MockLDF} from "./mocks/MockLDF.sol";
import {BunniHub} from "../src/BunniHub.sol";
import {BunniZone} from "../src/BunniZone.sol";
import {BunniHook} from "../src/BunniHook.sol";
import {BunniLens} from "./utils/BunniLens.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {BunniToken} from "../src/BunniToken.sol";
import {Uniswapper} from "./mocks/Uniswapper.sol";
import {HookletMock} from "./mocks/HookletMock.sol";
import {ERC4626Mock} from "./mocks/ERC4626Mock.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {PoolState} from "../src/types/PoolState.sol";
import {HookletLib} from "../src/lib/HookletLib.sol";
import {FloodDeployer} from "./utils/FloodDeployer.sol";
import {IHooklet} from "../src/interfaces/IHooklet.sol";
import {IBunniHub} from "../src/interfaces/IBunniHub.sol";
import {IBunniHook} from "../src/interfaces/IBunniHook.sol";
import {Permit2Deployer} from "./utils/Permit2Deployer.sol";
import {BunniHookLogic} from "../src/lib/BunniHookLogic.sol";
import {BunniQuoter} from "../src/periphery/BunniQuoter.sol";
import {IBunniToken} from "../src/interfaces/IBunniToken.sol";
import {OrderHashMemory} from "../src/lib/OrderHashMemory.sol";
import {ReentrancyGuard} from "../src/base/ReentrancyGuard.sol";
import {ERC4626WithFeeMock} from "./mocks/ERC4626WithFeeMock.sol";
import {GeometricDistribution} from "../src/ldf/GeometricDistribution.sol";
import {DoubleGeometricDistribution} from "../src/ldf/DoubleGeometricDistribution.sol";
import {ILiquidityDensityFunction} from "../src/interfaces/ILiquidityDensityFunction.sol";

contract BunniHubTest is Test, GasSnapshot, Permit2Deployer, FloodDeployer {
    using SafeCastLib for *;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using FixedPointMathLib for uint256;

    /// @dev ERC-7751 error for wrapping bubbled up reverts
    error WrappedError(address target, bytes4 selector, bytes reason, bytes details);

    enum HookUnlockCallbackType {
        BURN_AND_TAKE,
        SETTLE_AND_MINT,
        CLAIM_FEES
    }

    uint256 internal constant PRECISION = 10 ** 18;
    uint8 internal constant DECIMALS = 18;
    int24 internal constant TICK_SPACING = 10;
    uint32 internal constant HOOK_FEE_MODIFIER = 0.1e6;
    uint32 internal constant REFERRAL_REWARD_MODIFIER = 0.1e6;
    uint32 internal constant ALPHA = 0.7e8;
    uint256 internal constant MAX_ERROR = 1e9;
    uint24 internal constant FEE_MIN = 0.0001e6;
    uint24 internal constant FEE_MAX = 0.1e6;
    uint24 internal constant FEE_QUADRATIC_MULTIPLIER = 0.5e6;
    uint24 internal constant FEE_TWAP_SECONDS_AGO = 30 minutes;
    address internal constant HOOK_FEE_RECIPIENT = address(0xfee);
    uint24 internal constant TWAP_SECONDS_AGO = 1 days;
    uint16 internal constant SURGE_HALFLIFE = 1 minutes;
    uint16 internal constant SURGE_AUTOSTART_TIME = 2 minutes;
    uint16 internal constant VAULT_SURGE_THRESHOLD_0 = 1e4; // 0.01% change in share price
    uint16 internal constant VAULT_SURGE_THRESHOLD_1 = 1e3; // 0.1% change in share price
    uint256 internal constant VAULT_FEE = 0.03e18;
    uint16 internal constant REBALANCE_THRESHOLD = 100; // 1 / 100 = 1%
    uint16 internal constant REBALANCE_MAX_SLIPPAGE = 1; // 5%
    uint16 internal constant REBALANCE_TWAP_SECONDS_AGO = 1 hours;
    uint16 internal constant REBALANCE_ORDER_TTL = 10 minutes;
    uint32 internal constant ORACLE_MIN_INTERVAL = 1 hours;
    uint24 internal constant POOL_MAX_AMAMM_FEE = 0.05e6; // 5%
    uint48 internal constant MIN_RENT_MULTIPLIER = 1e10;
    uint256 internal constant HOOK_FLAGS = Hooks.AFTER_INITIALIZE_FLAG + Hooks.BEFORE_ADD_LIQUIDITY_FLAG
        + Hooks.BEFORE_SWAP_FLAG + Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG;

    IPoolManager internal poolManager;
    ERC20Mock internal token0;
    ERC20Mock internal token1;
    ERC4626Mock internal vault0;
    ERC4626Mock internal vault1;
    ERC4626Mock internal vaultWeth;
    ERC4626WithFeeMock internal vault0WithFee;
    ERC4626WithFeeMock internal vault1WithFee;
    ERC4626WithFeeMock internal vaultWethWithFee;
    IBunniHub internal hub;
    BunniHook internal bunniHook = BunniHook(payable(address(uint160(HOOK_FLAGS))));
    BunniQuoter internal quoter;
    ILiquidityDensityFunction internal ldf;
    Uniswapper internal swapper;
    WETH internal weth;
    IPermit2 internal permit2;
    IFloodPlain internal floodPlain;
    BunniLens internal lens;
    BunniZone internal zone;
    uint256 deposit0;
    uint256 deposit1;

    function setUp() public {
        vm.warp(1e9); // init block timestamp to reasonable value

        weth = new WETH();
        permit2 = _deployPermit2();
        MulticallerEtcher.multicallerWithSender();
        MulticallerEtcher.multicallerWithSigner();

        floodPlain = _deployFlood(address(permit2));

        // initialize uniswap
        token0 = new ERC20Mock();
        token1 = new ERC20Mock();
        if (address(token0) >= address(token1)) {
            (token0, token1) = (token1, token0);
        }
        poolManager = new PoolManager(address(this));

        // deploy vaults
        vault0 = new ERC4626Mock(token0);
        vault1 = new ERC4626Mock(token1);
        vaultWeth = new ERC4626Mock(IERC20(address(weth)));
        vault0WithFee = new ERC4626WithFeeMock(token0);
        vault1WithFee = new ERC4626WithFeeMock(token1);
        vaultWethWithFee = new ERC4626WithFeeMock(IERC20(address(weth)));

        // mint some initial tokens to the vaults to change the share price
        _mint(Currency.wrap(address(token0)), address(this), 2 ether);
        _mint(Currency.wrap(address(token1)), address(this), 2 ether);
        _mint(Currency.wrap(address(weth)), address(this), 2 ether);

        token0.approve(address(vault0), type(uint256).max);
        vault0.deposit(1 ether, address(this));
        _mint(Currency.wrap(address(token0)), address(vault0), 1 ether);

        token1.approve(address(vault1), type(uint256).max);
        vault1.deposit(1 ether, address(this));
        _mint(Currency.wrap(address(token1)), address(vault1), 1 ether);

        weth.approve(address(vaultWeth), type(uint256).max);
        vaultWeth.deposit(1 ether, address(this));
        _mint(Currency.wrap(address(weth)), address(vaultWeth), 1 ether);

        token0.approve(address(vault0WithFee), type(uint256).max);
        vault0WithFee.deposit(1 ether, address(this));
        _mint(Currency.wrap(address(token0)), address(vault0WithFee), 1 ether);

        token1.approve(address(vault1WithFee), type(uint256).max);
        vault1WithFee.deposit(1 ether, address(this));
        _mint(Currency.wrap(address(token1)), address(vault1WithFee), 1 ether);

        weth.approve(address(vaultWethWithFee), type(uint256).max);
        vaultWethWithFee.deposit(1 ether, address(this));
        _mint(Currency.wrap(address(weth)), address(vaultWethWithFee), 1 ether);

        // deploy swapper
        swapper = new Uniswapper(poolManager);

        // initialize bunni hub
        hub = new BunniHub(poolManager, weth, permit2, new BunniToken(), address(this));

        // deploy zone
        zone = new BunniZone(address(this));

        // initialize bunni hook
        bytes32 hookSalt;
        unchecked {
            bytes memory hookCreationCode = abi.encodePacked(
                type(BunniHook).creationCode,
                abi.encode(
                    poolManager,
                    hub,
                    floodPlain,
                    weth,
                    zone,
                    address(this),
                    HOOK_FEE_RECIPIENT,
                    HOOK_FEE_MODIFIER,
                    REFERRAL_REWARD_MODIFIER
                )
            );
            for (uint256 offset; offset < 100000; offset++) {
                hookSalt = bytes32(offset);
                address hookDeployed = computeAddress(address(this), hookSalt, hookCreationCode);
                if (uint160(bytes20(hookDeployed)) & Hooks.ALL_HOOK_MASK == HOOK_FLAGS && hookDeployed.code.length == 0)
                {
                    break;
                }
            }
        }
        bunniHook = new BunniHook{salt: hookSalt}(
            poolManager,
            hub,
            floodPlain,
            weth,
            zone,
            address(this),
            HOOK_FEE_RECIPIENT,
            HOOK_FEE_MODIFIER,
            REFERRAL_REWARD_MODIFIER
        );
        vm.label(address(bunniHook), "BunniHook");

        // deploy quoter
        quoter = new BunniQuoter(hub);

        // deploy lens
        lens = new BunniLens(hub);

        // initialize LDF
        ldf = new GeometricDistribution();

        // approve tokens
        token0.approve(address(permit2), type(uint256).max);
        token0.approve(address(swapper), type(uint256).max);
        token0.approve(address(floodPlain), type(uint256).max);
        token1.approve(address(permit2), type(uint256).max);
        token1.approve(address(swapper), type(uint256).max);
        token1.approve(address(floodPlain), type(uint256).max);
        weth.approve(address(permit2), type(uint256).max);
        weth.approve(address(swapper), type(uint256).max);
        weth.approve(address(floodPlain), type(uint256).max);

        // permit2 approve tokens to hub
        permit2.approve(address(token0), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(token1), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(weth), address(hub), type(uint160).max, type(uint48).max);

        // whitelist address(this) as fulfiller
        zone.setIsWhitelisted(address(this), true);
    }

    function test_deposit(uint256 depositAmount0, uint256 depositAmount1) public {
        _execTestAcrossScenarios(_test_deposit, depositAmount0, depositAmount1, "deposit");
    }

    function _test_deposit(
        uint256 depositAmount0,
        uint256 depositAmount1,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        depositAmount0 = bound(depositAmount0, 1e3, type(uint64).max);
        depositAmount1 = bound(depositAmount1, 1e3, type(uint64).max);
        (IBunniToken bunniToken, PoolKey memory key) =
            _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        // make deposit
        (uint256 beforeBalance0, uint256 beforeBalance1) = hub.poolBalances(key.toId());
        (uint256 shares, uint256 amount0, uint256 amount1) =
            _makeDeposit(key, depositAmount0, depositAmount1, address(this), snapLabel);
        (uint256 afterBalance0, uint256 afterBalance1) = hub.poolBalances(key.toId());

        // check return values
        assertApproxEqAbsDecimal(amount0, afterBalance0 - beforeBalance0, 1, DECIMALS, "amount0 incorrect");
        assertApproxEqAbsDecimal(amount1, afterBalance1 - beforeBalance1, 1, DECIMALS, "amount1 incorrect");
        assertEqDecimal(shares, bunniToken.balanceOf(address(this)), DECIMALS, "shares incorrect");
    }

    function test_deposit_msgValueNonZeroWhenNoETH() public {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity();

        // make deposit with msg.value being non-zero
        // mint tokens
        uint256 depositAmount0 = 1 ether;
        uint256 depositAmount1 = 1 ether;
        _mint(key.currency0, address(this), depositAmount0);
        _mint(key.currency1, address(this), depositAmount1);

        // deposit tokens
        IBunniHub.DepositParams memory depositParams = IBunniHub.DepositParams({
            poolKey: key,
            amount0Desired: depositAmount0,
            amount1Desired: depositAmount1,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            recipient: address(this),
            refundRecipient: address(this),
            vaultFee0: 0,
            vaultFee1: 0,
            referrer: 0
        });
        vm.expectRevert(BunniHub__MsgValueNotZeroWhenPoolKeyHasNoNativeToken.selector);
        hub.deposit{value: 1 ether}(depositParams);
    }

    function test_withdraw(uint256 depositAmount0, uint256 depositAmount1) public {
        _execTestAcrossScenarios(_test_withdraw, depositAmount0, depositAmount1, "withdraw");
    }

    function _test_withdraw(
        uint256 depositAmount0,
        uint256 depositAmount1,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        depositAmount0 = bound(depositAmount0, 1e6, type(uint64).max);
        depositAmount1 = bound(depositAmount1, 1e6, type(uint64).max);
        (IBunniToken bunniToken, PoolKey memory key) =
            _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        // make deposit
        (uint256 shares, uint256 amount0, uint256 amount1) = _makeDepositWithFee({
            key_: key,
            depositAmount0: depositAmount0,
            depositAmount1: depositAmount1,
            depositor: address(this),
            vaultFee0: address(vault0_) == address(vault0WithFee) || address(vault0_) == address(vaultWethWithFee)
                ? 0.03e18
                : 0,
            vaultFee1: address(vault1_) == address(vault1WithFee) || address(vault1_) == address(vaultWethWithFee)
                ? 0.03e18
                : 0,
            snapLabel: ""
        });

        // withdraw
        IBunniHub.WithdrawParams memory withdrawParams = IBunniHub.WithdrawParams({
            poolKey: key,
            recipient: address(this),
            shares: shares,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            useQueuedWithdrawal: false
        });
        IBunniHub hub_ = hub;
        (uint256 beforeBalance0, uint256 beforeBalance1) =
            (key.currency0.balanceOf(address(this)), key.currency1.balanceOf(address(this)));
        snapStart(snapLabel);
        (uint256 withdrawAmount0, uint256 withdrawAmount1) = hub_.withdraw(withdrawParams);
        snapEnd();

        // check return values
        // withdraw amount less than original due to rounding
        assertApproxEqAbs(withdrawAmount0, amount0, 100, "withdrawAmount0 incorrect");
        assertApproxEqAbs(withdrawAmount1, amount1, 100, "withdrawAmount1 incorrect");

        // check token balances
        assertApproxEqAbs(
            key.currency0.balanceOf(address(this)) - beforeBalance0, withdrawAmount0, 10, "token0 balance incorrect"
        );
        assertApproxEqAbs(
            key.currency1.balanceOf(address(this)) - beforeBalance1, withdrawAmount1, 10, "token1 balance incorrect"
        );
        assertEqDecimal(bunniToken.balanceOf(address(this)), 0, DECIMALS, "didn't burn shares");
    }

    function test_withdraw_revertWhenRebalanceOrderIsActive() public {
        MockLDF ldf_ = new MockLDF();
        ldf_.setMinTick(-30);

        // deploy pool and init liquidity
        Currency currency0 = Currency.wrap(address(token0));
        Currency currency1 = Currency.wrap(address(token1));
        (IBunniToken bunniToken, PoolKey memory key) =
            _deployPoolAndInitLiquidity(currency0, currency1, ERC4626(address(0)), ERC4626(address(0)), ldf_);

        // shift liquidity to the right
        // the LDF will demand more token0, so we'll have too much of token1
        // the rebalance should swap from token1 to token0
        ldf_.setMinTick(-20);

        // make small swap to trigger rebalance
        uint256 swapAmount = 1e3;
        _mint(key.currency0, address(this), swapAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });
        _swap(key, params, 0, "");

        // try withdrawing liquidity
        IBunniHub.WithdrawParams memory withdrawParams = IBunniHub.WithdrawParams({
            poolKey: key,
            recipient: address(0x6969),
            shares: bunniToken.balanceOf(address(0x6969)),
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            useQueuedWithdrawal: false
        });
        vm.startPrank(address(0x6969));
        vm.expectRevert(BunniHub__WithdrawalPaused.selector);
        hub.withdraw(withdrawParams);
        vm.stopPrank();
    }

    function test_queueWithdraw_happyPath(uint256 depositAmount0, uint256 depositAmount1) public {
        depositAmount0 = bound(depositAmount0, 1e16, type(uint64).max);
        depositAmount1 = bound(depositAmount1, 1e16, type(uint64).max);
        (IBunniToken bunniToken, PoolKey memory key) = _deployPoolAndInitLiquidity();

        // make deposit
        (uint256 shares,,) = _makeDepositWithFee({
            key_: key,
            depositAmount0: depositAmount0,
            depositAmount1: depositAmount1,
            depositor: address(this),
            vaultFee0: 0,
            vaultFee1: 0,
            snapLabel: ""
        });

        // bid in am-AMM auction
        PoolId id = key.toId();
        bunniToken.approve(address(bunniHook), type(uint256).max);
        uint128 minRent = uint128(bunniToken.totalSupply() * MIN_RENT_MULTIPLIER / 1e18);
        uint128 rentDeposit = minRent * 2 days;
        bunniHook.bid(
            id, address(this), bytes7(abi.encodePacked(uint24(1e3), uint24(2e3), true)), minRent * 2, rentDeposit
        );
        shares -= rentDeposit;

        // wait until address(this) is the manager
        skip(24 hours);
        assertEq(bunniHook.getTopBid(id).manager, address(this), "not manager yet");

        // queue withdraw
        bunniToken.approve(address(hub), type(uint256).max);
        hub.queueWithdraw(IBunniHub.QueueWithdrawParams({poolKey: key, shares: shares.toUint200()}));
        assertEqDecimal(bunniToken.balanceOf(address(hub)), shares, DECIMALS, "didn't take shares");

        // wait a minute
        skip(1 minutes);

        // withdraw
        IBunniHub.WithdrawParams memory withdrawParams = IBunniHub.WithdrawParams({
            poolKey: key,
            recipient: address(this),
            shares: shares,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            useQueuedWithdrawal: true
        });
        hub.withdraw(withdrawParams);
        assertEqDecimal(bunniToken.balanceOf(address(hub)), 0, DECIMALS, "didn't burn shares");
    }

    function test_queueWithdraw_fail_didNotQueue(uint256 depositAmount0, uint256 depositAmount1) public {
        depositAmount0 = bound(depositAmount0, 1e16, type(uint64).max);
        depositAmount1 = bound(depositAmount1, 1e16, type(uint64).max);
        (IBunniToken bunniToken, PoolKey memory key) = _deployPoolAndInitLiquidity();

        // make deposit
        (uint256 shares,,) = _makeDepositWithFee({
            key_: key,
            depositAmount0: depositAmount0,
            depositAmount1: depositAmount1,
            depositor: address(this),
            vaultFee0: 0,
            vaultFee1: 0,
            snapLabel: ""
        });

        // bid in am-AMM auction
        PoolId id = key.toId();
        bunniToken.approve(address(bunniHook), type(uint256).max);
        uint128 minRent = uint128(bunniToken.totalSupply() * MIN_RENT_MULTIPLIER / 1e18);
        uint128 rentDeposit = minRent * 2 days;
        bunniHook.bid(
            id, address(this), bytes7(abi.encodePacked(uint24(1e3), uint24(2e3), true)), minRent * 2, rentDeposit
        );
        shares -= rentDeposit;

        // wait until address(this) is the manager
        skip(24 hours);
        assertEq(bunniHook.getTopBid(id).manager, address(this), "not manager yet");

        // withdraw
        IBunniHub.WithdrawParams memory withdrawParams = IBunniHub.WithdrawParams({
            poolKey: key,
            recipient: address(this),
            shares: shares,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            useQueuedWithdrawal: false
        });
        vm.expectRevert(BunniHub__NeedToUseQueuedWithdrawal.selector);
        hub.withdraw(withdrawParams);

        withdrawParams = IBunniHub.WithdrawParams({
            poolKey: key,
            recipient: address(this),
            shares: shares,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            useQueuedWithdrawal: true
        });
        vm.expectRevert(BunniHub__QueuedWithdrawalNonexistent.selector);
        hub.withdraw(withdrawParams);
    }

    function test_queueWithdraw_fail_notReady(uint256 depositAmount0, uint256 depositAmount1) public {
        depositAmount0 = bound(depositAmount0, 1e16, type(uint64).max);
        depositAmount1 = bound(depositAmount1, 1e16, type(uint64).max);
        (IBunniToken bunniToken, PoolKey memory key) = _deployPoolAndInitLiquidity();

        // make deposit
        (uint256 shares,,) = _makeDepositWithFee({
            key_: key,
            depositAmount0: depositAmount0,
            depositAmount1: depositAmount1,
            depositor: address(this),
            vaultFee0: 0,
            vaultFee1: 0,
            snapLabel: ""
        });

        // bid in am-AMM auction
        PoolId id = key.toId();
        bunniToken.approve(address(bunniHook), type(uint256).max);
        uint128 minRent = uint128(bunniToken.totalSupply() * MIN_RENT_MULTIPLIER / 1e18);
        uint128 rentDeposit = minRent * 2 days;
        bunniHook.bid(
            id, address(this), bytes7(abi.encodePacked(uint24(1e3), uint24(2e3), true)), minRent * 2, rentDeposit
        );
        shares -= rentDeposit;

        // wait until address(this) is the manager
        skip(24 hours);
        assertEq(bunniHook.getTopBid(id).manager, address(this), "not manager yet");

        // queue withdraw
        bunniToken.approve(address(hub), type(uint256).max);
        hub.queueWithdraw(IBunniHub.QueueWithdrawParams({poolKey: key, shares: shares.toUint200()}));
        assertEqDecimal(bunniToken.balanceOf(address(hub)), shares, DECIMALS, "didn't take shares");

        // withdraw
        IBunniHub.WithdrawParams memory withdrawParams = IBunniHub.WithdrawParams({
            poolKey: key,
            recipient: address(this),
            shares: shares,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            useQueuedWithdrawal: true
        });
        vm.expectRevert(BunniHub__QueuedWithdrawalNotReady.selector);
        hub.withdraw(withdrawParams);
    }

    function test_queueWithdraw_fail_gracePeriodExpired(uint256 depositAmount0, uint256 depositAmount1) public {
        depositAmount0 = bound(depositAmount0, 1e16, type(uint64).max);
        depositAmount1 = bound(depositAmount1, 1e16, type(uint64).max);
        (IBunniToken bunniToken, PoolKey memory key) = _deployPoolAndInitLiquidity();

        // make deposit
        (uint256 shares,,) = _makeDepositWithFee({
            key_: key,
            depositAmount0: depositAmount0,
            depositAmount1: depositAmount1,
            depositor: address(this),
            vaultFee0: 0,
            vaultFee1: 0,
            snapLabel: ""
        });

        // bid in am-AMM auction
        PoolId id = key.toId();
        bunniToken.approve(address(bunniHook), type(uint256).max);
        uint128 minRent = uint128(bunniToken.totalSupply() * MIN_RENT_MULTIPLIER / 1e18);
        uint128 rentDeposit = minRent * 2 days;
        bunniHook.bid(
            id, address(this), bytes7(abi.encodePacked(uint24(1e3), uint24(2e3), true)), minRent * 2, rentDeposit
        );
        shares -= rentDeposit;

        // wait until address(this) is the manager
        skip(24 hours);
        assertEq(bunniHook.getTopBid(id).manager, address(this), "not manager yet");

        // queue withdraw
        bunniToken.approve(address(hub), type(uint256).max);
        hub.queueWithdraw(IBunniHub.QueueWithdrawParams({poolKey: key, shares: shares.toUint200()}));
        assertEqDecimal(bunniToken.balanceOf(address(hub)), shares, DECIMALS, "didn't take shares");

        // wait an hour
        skip(1 hours);

        // withdraw
        IBunniHub.WithdrawParams memory withdrawParams = IBunniHub.WithdrawParams({
            poolKey: key,
            recipient: address(this),
            shares: shares,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp + 1 hours,
            useQueuedWithdrawal: true
        });
        vm.expectRevert(BunniHub__GracePeriodExpired.selector);
        hub.withdraw(withdrawParams);

        // queue withdraw again to refresh lock
        hub.queueWithdraw(IBunniHub.QueueWithdrawParams({poolKey: key, shares: 0}));

        // wait a minute
        skip(1 minutes);

        // withdraw
        hub.withdraw(withdrawParams);

        // check balances
        assertEqDecimal(bunniToken.balanceOf(address(hub)), 0, DECIMALS, "didn't burn shares");
    }

    function test_swap_zeroForOne_noTickCrossing() public {
        _execTestAcrossScenarios(
            _test_swap_zeroForOne_noTickCrossing, 0, 0, "swap zeroForOne noTickCrossing, first swap"
        );
    }

    function _test_swap_zeroForOne_noTickCrossing(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 inputAmount = PRECISION / 10;

        _mint(key.currency0, address(this), inputAmount);
        uint256 value = key.currency0.isAddressZero() ? inputAmount : 0;

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtPriceAtTick(3)
        });
        _swap(key, params, value, snapLabel);
    }

    function test_swap_zeroForOne_noTickCrossing_multiple() public {
        _execTestAcrossScenarios(
            _test_swap_zeroForOne_noTickCrossing_multiple, 0, 0, "swap zeroForOne noTickCrossing, subsequent swap"
        );
    }

    function _test_swap_zeroForOne_noTickCrossing_multiple(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 numSwaps = 10;
        uint256 inputAmount = PRECISION / 1000;
        uint256 value = key.currency0.isAddressZero() ? inputAmount : 0;

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtPriceAtTick(0)
        });

        for (uint256 i; i < numSwaps; i++) {
            _mint(key.currency0, address(this), inputAmount);

            if (i == numSwaps - 1) {
                _swap(key, params, value, snapLabel);
            } else {
                _swap(key, params, value, "");
            }
        }
    }

    function test_swap_zeroForOne_oneTickCrossing() public {
        _execTestAcrossScenarios(
            _test_swap_zeroForOne_oneTickCrossing, 0, 0, "swap zeroForOne oneTickCrossing, first swap"
        );
    }

    function _test_swap_zeroForOne_oneTickCrossing(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 inputAmount = 0.15e18;
        uint256 value = key.currency0.isAddressZero() ? inputAmount : 0;

        _mint(key.currency0, address(this), inputAmount);

        (, int24 currentTick,,) = bunniHook.slot0s(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtPriceAtTick(-9)
        });

        _swap(key, params, value, snapLabel);

        (, currentTick,,) = bunniHook.slot0s(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick - key.tickSpacing, "didn't cross one tick");
    }

    function test_swap_zeroForOne_twoTickCrossing() public {
        _execTestAcrossScenarios(
            _test_swap_zeroForOne_twoTickCrossing, 0, 0, "swap zeroForOne twoTickCrossing, first swap"
        );
    }

    function _test_swap_zeroForOne_twoTickCrossing(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 inputAmount = PRECISION * 2;
        uint256 value = key.currency0.isAddressZero() ? inputAmount : 0;

        _mint(key.currency0, address(this), inputAmount);

        (, int24 currentTick,,) = bunniHook.slot0s(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtPriceAtTick(-19)
        });

        _swap(key, params, value, snapLabel);

        (, currentTick,,) = bunniHook.slot0s(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick - key.tickSpacing * 2, "didn't cross two ticks");
    }

    function test_swap_zeroForOne_oneTickCrossing_limit() public {
        _execTestAcrossScenarios(
            _test_swap_zeroForOne_oneTickCrossing_limit, 0, 0, "swap zeroForOne oneTickCrossing, first swap, hit limit"
        );
    }

    function _test_swap_zeroForOne_oneTickCrossing_limit(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 inputAmount = 5.4e17;
        uint256 value = key.currency0.isAddressZero() ? inputAmount : 0;

        _mint(key.currency0, address(this), inputAmount);

        (, int24 currentTick,,) = bunniHook.slot0s(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        uint160 sqrtPriceLimitX96 = TickMath.getSqrtPriceAtTick(-9);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: sqrtPriceLimitX96
        });

        _swap(key, params, value, snapLabel);

        uint160 sqrtPriceX96;
        (sqrtPriceX96, currentTick,,) = bunniHook.slot0s(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick - key.tickSpacing, "didn't cross one tick");
        assertEq(sqrtPriceX96, sqrtPriceLimitX96, "didn't hit price limit");
    }

    function test_swap_oneForZero_noTickCrossing() public {
        _execTestAcrossScenarios(
            _test_swap_oneForZero_noTickCrossing, 0, 0, "swap oneForZero noTickCrossing, first swap"
        );
    }

    function _test_swap_oneForZero_noTickCrossing(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 inputAmount = PRECISION / 10;
        uint256 value = key.currency1.isAddressZero() ? inputAmount : 0;

        _mint(key.currency1, address(this), inputAmount);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtPriceAtTick(9)
        });

        _swap(key, params, value, snapLabel);
    }

    function test_swap_oneForZero_noTickCrossing_multiple() public {
        _execTestAcrossScenarios(
            _test_swap_oneForZero_noTickCrossing_multiple, 0, 0, "swap oneForZero noTickCrossing, subsequent swap"
        );
    }

    function _test_swap_oneForZero_noTickCrossing_multiple(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 numSwaps = 10;
        uint256 inputAmount = PRECISION / 1000;
        uint256 value = key.currency1.isAddressZero() ? inputAmount : 0;

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtPriceAtTick(9)
        });

        for (uint256 i; i < numSwaps; i++) {
            _mint(key.currency1, address(this), inputAmount);

            if (i == numSwaps - 1) {
                _swap(key, params, value, snapLabel);
            } else {
                _swap(key, params, value, "");
            }
        }
    }

    function test_swap_oneForZero_oneTickCrossing() public {
        _execTestAcrossScenarios(
            _test_swap_oneForZero_oneTickCrossing, 0, 0, "swap oneForZero oneTickCrossing, first swap"
        );
    }

    function _test_swap_oneForZero_oneTickCrossing(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 inputAmount = PRECISION * 2;
        uint256 value = key.currency1.isAddressZero() ? inputAmount : 0;

        _mint(key.currency1, address(this), inputAmount);

        (, int24 currentTick,,) = bunniHook.slot0s(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtPriceAtTick(19)
        });

        _swap(key, params, value, snapLabel);

        (, currentTick,,) = bunniHook.slot0s(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick + key.tickSpacing, "didn't cross one tick");
    }

    function test_swap_oneForZero_twoTickCrossing() public {
        _execTestAcrossScenarios(_test_swap_oneForZero_twoTickCrossing, 0, 0, "swap oneForZero twoTickCrossing");
    }

    function _test_swap_oneForZero_twoTickCrossing(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 inputAmount = PRECISION * 2;
        uint256 value = key.currency1.isAddressZero() ? inputAmount : 0;

        _mint(key.currency1, address(this), inputAmount);

        (, int24 currentTick,,) = bunniHook.slot0s(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtPriceAtTick(29)
        });

        _swap(key, params, value, snapLabel);

        (, currentTick,,) = bunniHook.slot0s(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick + key.tickSpacing * 2, "didn't cross two ticks");
    }

    function test_swap_oneForZero_oneTickCrossing_limit() public {
        _execTestAcrossScenarios(
            _test_swap_oneForZero_oneTickCrossing_limit, 0, 0, "swap oneForZero oneTickCrossing, first swap, hit limit"
        );
    }

    function _test_swap_oneForZero_oneTickCrossing_limit(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 inputAmount = 2.5e17;
        uint256 value = key.currency1.isAddressZero() ? inputAmount : 0;

        _mint(key.currency1, address(this), inputAmount);

        (, int24 currentTick,,) = bunniHook.slot0s(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        uint160 sqrtPriceLimitX96 = TickMath.getSqrtPriceAtTick(19);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: sqrtPriceLimitX96
        });

        _swap(key, params, value, snapLabel);

        uint160 sqrtPriceX96;
        (sqrtPriceX96, currentTick,,) = bunniHook.slot0s(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick + key.tickSpacing, "didn't cross one tick");
        assertEq(sqrtPriceX96, sqrtPriceLimitX96, "didn't hit price limit");
    }

    function test_collectProtocolFees() public {
        _execTestAcrossScenarios(_test_collectProtocolFees, 0, 0, "");
    }

    function _test_collectProtocolFees(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        // create new bunni token
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 inputAmount = PRECISION * 100;
        IPoolManager.SwapParams memory paramsZeroToOne = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtPriceAtTick(-9)
        });
        IPoolManager.SwapParams memory paramsOneToZero = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtPriceAtTick(9)
        });

        // make swaps to accumulate fees
        uint256 numSwaps = 10;
        for (uint256 i; i < numSwaps; i++) {
            // zero to one swap
            _mint(key.currency0, address(this), inputAmount);
            uint256 value = key.currency0.isAddressZero() ? inputAmount : 0;
            if (i == numSwaps - 1) {
                _swap(
                    key,
                    paramsZeroToOne,
                    value,
                    string.concat("swap zeroForOne oneTickCrossing, subsequent swap", snapLabel)
                );
            } else {
                _swap(key, paramsZeroToOne, value, "");
            }

            // one to zero swap
            _mint(key.currency1, address(this), inputAmount);
            value = key.currency1.isAddressZero() ? inputAmount : 0;
            if (i == numSwaps - 1) {
                _swap(
                    key,
                    paramsOneToZero,
                    value,
                    string.concat("swap oneForZero oneTickCrossing, subsequent swap", snapLabel)
                );
            } else {
                _swap(key, paramsOneToZero, value, "");
            }
        }

        uint256 fee0 = poolManager.balanceOf(address(bunniHook), key.currency0.toId());
        uint256 fee1 = poolManager.balanceOf(address(bunniHook), key.currency1.toId());
        assertGt(fee0, 0, "protocol fee0 not accrued");
        assertGt(fee1, 0, "protocol fee1 not accrued");

        // check claimable fees
        Currency[] memory currencies = new Currency[](2);
        currencies[0] = key.currency0;
        currencies[1] = key.currency1;
        uint256[] memory claimableAmounts = bunniHook.getClaimableHookFees(currencies);
        assertEq(claimableAmounts[0], fee0, "claimable fee0 amount incorrect");
        assertEq(claimableAmounts[1], fee1, "claimable fee1 amount incorrect");

        // collect fees
        snapStart(string.concat("collect protocol fees", snapLabel));
        bunniHook.claimProtocolFees(currencies);
        snapEnd();

        // check balances
        assertEq(
            key.currency0.isAddressZero()
                ? weth.balanceOf(HOOK_FEE_RECIPIENT)
                : key.currency0.balanceOf(HOOK_FEE_RECIPIENT),
            fee0,
            "protocol fee0 not collected"
        );
        assertEq(
            key.currency1.isAddressZero()
                ? weth.balanceOf(HOOK_FEE_RECIPIENT)
                : key.currency1.balanceOf(HOOK_FEE_RECIPIENT),
            fee1,
            "protocol fee1 not collected"
        );
    }

    function test_multicall() external {
        Currency currency0 = CurrencyLibrary.ADDRESS_ZERO;
        Currency currency1 = Currency.wrap(address(token0));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1);

        _mint(currency0, address(this), 3 ether);
        _mint(currency1, address(this), 3 ether);

        address[] memory targets = new address[](2);
        targets[0] = address(hub);
        targets[1] = address(hub);

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeWithSelector(
            IBunniHub.deposit.selector,
            IBunniHub.DepositParams({
                poolKey: key,
                amount0Desired: 1 ether,
                amount1Desired: 1 ether,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp,
                recipient: address(this),
                refundRecipient: address(this),
                vaultFee0: 0,
                vaultFee1: 0,
                referrer: 0
            })
        );
        data[1] = abi.encodeWithSelector(
            IBunniHub.deposit.selector,
            IBunniHub.DepositParams({
                poolKey: key,
                amount0Desired: 2 ether,
                amount1Desired: 2 ether,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp,
                recipient: address(this),
                refundRecipient: address(this),
                vaultFee0: 0,
                vaultFee1: 0,
                referrer: 0
            })
        );

        uint256[] memory values = new uint256[](2);
        values[0] = 1 ether;
        values[1] = 2 ether;

        (uint256 beforeBalance0, uint256 beforeBalance1) =
            (currency0.balanceOf(address(this)), currency1.balanceOf(address(this)));
        bytes[] memory results = MulticallerWithSender(payable(LibMulticaller.MULTICALLER_WITH_SENDER))
            .aggregateWithSender{value: 3 ether}(targets, data, values);
        (, uint256 amount0Call0, uint256 amount1Call0) = abi.decode(results[0], (uint256, uint256, uint256));
        (, uint256 amount0Call1, uint256 amount1Call1) = abi.decode(results[1], (uint256, uint256, uint256));

        // tokens taken should match sum of returned values
        assertEq(
            beforeBalance0,
            amount0Call0 + amount0Call1 + currency0.balanceOf(address(this)),
            "amount0Call0 + amount0Call1 != amount taken"
        );
        assertEq(
            beforeBalance1,
            amount1Call0 + amount1Call1 + currency1.balanceOf(address(this)),
            "amount1Call0 + amount1Call1 != amount taken"
        );
    }

    function test_deployMultiplePoolsInSameSubspace() external {
        for (uint256 i; i < 10; i++) {
            Currency currency0 = CurrencyLibrary.ADDRESS_ZERO;
            Currency currency1 = Currency.wrap(address(token0));
            (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, bytes32(i));
            assertEq(key.fee, i, "nonce not increasing");
        }
    }

    function test_deployBunniToken(
        string calldata name,
        string calldata symbol,
        address owner,
        string calldata metadataURI,
        IHooklet hooklet_
    ) external {
        vm.assume(
            bytes(name).length <= 32 && bytes(symbol).length <= 32
                && !HookletLib.hasPermission(hooklet_, HookletLib.BEFORE_INITIALIZE_FLAG)
                && !HookletLib.hasPermission(hooklet_, HookletLib.AFTER_INITIALIZE_FLAG)
        );

        Currency currency0 = Currency.wrap(address(token0));
        Currency currency1 = Currency.wrap(address(token1));
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), ALPHA));
        bytes memory hookParams = abi.encodePacked(
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
        );

        bytes32 name_ = bytes32(bytes(name));
        bytes32 symbol_ = bytes32(bytes(symbol));

        (IBunniToken bunniToken, PoolKey memory key) = hub.deployBunniToken(
            IBunniHub.DeployBunniTokenParams({
                currency0: currency0,
                currency1: currency1,
                tickSpacing: TICK_SPACING,
                twapSecondsAgo: TWAP_SECONDS_AGO,
                liquidityDensityFunction: ldf,
                hooklet: hooklet_,
                ldfType: LDFType.DYNAMIC_AND_STATEFUL,
                ldfParams: ldfParams,
                hooks: bunniHook,
                hookParams: hookParams,
                vault0: ERC4626(address(0)),
                vault1: ERC4626(address(0)),
                minRawTokenRatio0: 0.08e6,
                targetRawTokenRatio0: 0.1e6,
                maxRawTokenRatio0: 0.12e6,
                minRawTokenRatio1: 0.08e6,
                targetRawTokenRatio1: 0.1e6,
                maxRawTokenRatio1: 0.12e6,
                sqrtPriceX96: TickMath.getSqrtPriceAtTick(4),
                name: name_,
                symbol: symbol_,
                owner: owner,
                metadataURI: metadataURI,
                salt: bytes32(0)
            })
        );
        assertEq(bunniToken.owner(), owner, "owner not set");
        assertEq(bunniToken.name(), string(abi.encodePacked(name_)), "name not set");
        assertEq(bunniToken.symbol(), string(abi.encodePacked(symbol_)), "symbol not set");
        assertEq(bunniToken.metadataURI(), metadataURI, "metadataURI not set");
        assertEq(Currency.unwrap(key.currency0), Currency.unwrap(currency0), "currency0 not set");
        assertEq(Currency.unwrap(key.currency1), Currency.unwrap(currency1), "currency1 not set");
        assertEq(key.tickSpacing, TICK_SPACING, "tickSpacing not set");
        assertEq(address(key.hooks), address(bunniHook), "hooks not set");

        // verify pool state
        PoolId id = key.toId();
        PoolState memory state = hub.poolState(id);
        assertEq(address(state.liquidityDensityFunction), address(ldf), "ldf incorrect");
        assertEq(address(state.bunniToken), address(bunniToken), "bunniToken incorrect");
        assertEq(state.twapSecondsAgo, TWAP_SECONDS_AGO, "twapSecondsAgo incorrect");
        assertEq(state.ldfParams, ldfParams, "ldfParams incorrect");
        assertEq(state.hookParams, hookParams, "hookParams incorrect");
        assertEq(hub.hookParams(id), hookParams, "hub.hookParams() incorrect");
        assertEq(address(state.vault0), address(0), "vault0 incorrect");
        assertEq(address(state.vault1), address(0), "vault1 incorrect");
        assertEq(uint8(state.ldfType), uint8(LDFType.DYNAMIC_AND_STATEFUL), "ldfType incorrect");
        assertEq(state.minRawTokenRatio0, 0.08e6, "minRawTokenRatio0 incorrect");
        assertEq(state.targetRawTokenRatio0, 0.1e6, "targetRawTokenRatio0 incorrect");
        assertEq(state.maxRawTokenRatio0, 0.12e6, "maxRawTokenRatio0 incorrect");
        assertEq(state.minRawTokenRatio1, 0.08e6, "minRawTokenRatio1 incorrect");
        assertEq(state.targetRawTokenRatio1, 0.1e6, "targetRawTokenRatio1 incorrect");
        assertEq(state.maxRawTokenRatio1, 0.12e6, "maxRawTokenRatio1 incorrect");
        assertEq(address(state.hooklet), address(hooklet_), "hooklet incorrect");

        // verify decoded hookParams
        DecodedHookParams memory p = BunniHookLogic.decodeHookParams(hookParams);
        assertEq(p.feeMin, FEE_MIN, "feeMin incorrect");
        assertEq(p.feeMax, FEE_MAX, "feeMax incorrect");
        assertEq(p.feeQuadraticMultiplier, FEE_QUADRATIC_MULTIPLIER, "feeQuadraticMultiplier incorrect");
        assertEq(p.feeTwapSecondsAgo, FEE_TWAP_SECONDS_AGO, "feeTwapSecondsAgo incorrect");
        assertEq(p.surgeFeeHalfLife, SURGE_HALFLIFE, "surgeFeeHalfLife incorrect");
        assertEq(p.surgeFeeAutostartThreshold, SURGE_AUTOSTART_TIME, "surgeFeeAutostartThreshold incorrect");
        assertEq(p.vaultSurgeThreshold0, VAULT_SURGE_THRESHOLD_0, "vaultSurgeThreshold0 incorrect");
        assertEq(p.vaultSurgeThreshold1, VAULT_SURGE_THRESHOLD_1, "vaultSurgeThreshold1 incorrect");
        assertEq(p.rebalanceThreshold, REBALANCE_THRESHOLD, "rebalanceThreshold incorrect");
        assertEq(p.rebalanceMaxSlippage, REBALANCE_MAX_SLIPPAGE, "rebalanceMaxSlippage incorrect");
        assertEq(p.rebalanceTwapSecondsAgo, REBALANCE_TWAP_SECONDS_AGO, "rebalanceTwapSecondsAgo incorrect");
        assertEq(p.rebalanceOrderTTL, REBALANCE_ORDER_TTL, "rebalanceOrderTTL incorrect");
        assertTrue(p.amAmmEnabled, "amAmmEnabled incorrect");
        assertEq(p.oracleMinInterval, ORACLE_MIN_INTERVAL, "oracleMinInterval incorrect");
        assertEq(p.maxAmAmmFee, POOL_MAX_AMAMM_FEE, "maxAmAmmFee incorrect");
        assertEq(p.minRentMultiplier, MIN_RENT_MULTIPLIER, "minRentMultiplier incorrect");
    }

    function test_hookHasInsufficientTokens() external {
        MockLDF ldf_ = new MockLDF();

        // set mu to be far to the left of rounded tick 0
        // so that the pool will have mostly token1
        ldf_.setMinTick(-100);

        // deploy pool and init liquidity
        Currency currency0 = CurrencyLibrary.ADDRESS_ZERO;
        Currency currency1 = Currency.wrap(address(token0));
        (, PoolKey memory key) =
            _deployPoolAndInitLiquidity(currency0, currency1, ERC4626(address(0)), ERC4626(address(0)), ldf_);

        // set mu to rounded tick 0
        // so that the pool has less token0 than the LDF suggests
        ldf_.setMinTick(0);

        // make a big swap from token1 to token0
        // such that the pool has insufficient tokens to output
        // should revert
        uint256 inputAmount = 100 * PRECISION;
        _mint(key.currency1, address(this), inputAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: -int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtPriceAtTick(100)
        });
        vm.expectRevert(
            abi.encodeWithSelector(
                WrappedError.selector,
                address(bunniHook),
                IHooks.beforeSwap.selector,
                stdError.arithmeticError,
                abi.encodeWithSelector(Hooks.HookCallFailed.selector)
            )
        );
        swapper.swap(key, params, type(uint256).max, 0);
    }

    function test_fuzz_swapNoArb_exactIn(
        uint256 swapAmount,
        bool zeroForOneFirstSwap,
        bool useVault0,
        bool useVault1,
        uint256 waitTime,
        uint32 alpha,
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier
    ) external {
        swapAmount = bound(swapAmount, 1e6, 1e36);
        waitTime = bound(waitTime, 10, SURGE_AUTOSTART_TIME * 6);
        feeMin = uint24(bound(feeMin, 2e5, 1e6 - 1));
        feeMax = uint24(bound(feeMax, feeMin, 1e6 - 1));
        alpha = uint32(bound(alpha, 1e3, 12e8));

        GeometricDistribution ldf_ = new GeometricDistribution();
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), alpha));
        {
            PoolKey memory key_;
            key_.tickSpacing = TICK_SPACING;
            vm.assume(ldf_.isValidParams(key_, TWAP_SECONDS_AGO, ldfParams));
        }
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            ldf_,
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
            )
        );

        // execute first swap
        (Currency firstSwapInputToken, Currency firstSwapOutputToken) =
            zeroForOneFirstSwap ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        _mint(firstSwapInputToken, address(this), swapAmount * 2);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOneFirstSwap,
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: zeroForOneFirstSwap ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
        });
        uint256 firstSwapInputAmount;
        uint256 firstSwapOutputAmount;
        {
            uint256 beforeInputTokenBalance = firstSwapInputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = firstSwapOutputToken.balanceOfSelf();
            _swap(key, params, 0, "");
            firstSwapInputAmount = beforeInputTokenBalance - firstSwapInputToken.balanceOfSelf();
            firstSwapOutputAmount = firstSwapOutputToken.balanceOfSelf() - beforeOutputTokenBalance;
        }

        console2.log("firstSwapInputAmount", firstSwapInputAmount);
        console2.log("firstSwapOutputAmount", firstSwapOutputAmount);

        // wait for some time
        skip(waitTime);

        // execute second swap
        params = IPoolManager.SwapParams({
            zeroForOne: !zeroForOneFirstSwap,
            amountSpecified: -int256(firstSwapOutputAmount),
            sqrtPriceLimitX96: !zeroForOneFirstSwap ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
        });
        uint256 secondSwapInputAmount;
        uint256 secondSwapOutputAmount;
        {
            uint256 beforeInputTokenBalance = firstSwapOutputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = firstSwapInputToken.balanceOfSelf();
            _swap(key, params, 0, "");
            secondSwapInputAmount = beforeInputTokenBalance - firstSwapOutputToken.balanceOfSelf();
            secondSwapOutputAmount = firstSwapInputToken.balanceOfSelf() - beforeOutputTokenBalance;
        }

        console2.log("secondSwapInputAmount", secondSwapInputAmount);
        console2.log("secondSwapOutputAmount", secondSwapOutputAmount);

        // verify no profits
        assertLeDecimal(secondSwapOutputAmount, firstSwapInputAmount, 18, "arb has profit");
    }

    function test_fuzz_swapNoArb_exactOut(
        uint256 swapAmount,
        bool zeroForOneFirstSwap,
        bool useVault0,
        bool useVault1,
        uint256 waitTime,
        uint32 alpha,
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier
    ) external {
        swapAmount = bound(swapAmount, 1e6, 1e30);
        waitTime = bound(waitTime, 10, SURGE_AUTOSTART_TIME * 6);
        feeMin = uint24(bound(feeMin, 2e5, 1e6 - 1));
        feeMax = uint24(bound(feeMax, feeMin, 1e6 - 1));
        alpha = uint32(bound(alpha, 1e3, 12e8));

        GeometricDistribution ldf_ = new GeometricDistribution();
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), alpha));
        {
            PoolKey memory key_;
            key_.tickSpacing = TICK_SPACING;
            vm.assume(ldf_.isValidParams(key_, TWAP_SECONDS_AGO, ldfParams));
        }
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            swapAmount * 100,
            swapAmount * 100,
            ldf_,
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
            )
        );

        // execute first swap
        (Currency firstSwapInputToken, Currency firstSwapOutputToken) =
            zeroForOneFirstSwap ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOneFirstSwap,
            amountSpecified: int256(swapAmount),
            sqrtPriceLimitX96: zeroForOneFirstSwap ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
        });
        (,,, uint256 firstSwapInputAmount, uint256 firstSwapOutputAmount,,) =
            quoter.quoteSwap(address(this), key, params);
        if (firstSwapOutputToken.balanceOf(address(poolManager)) >= swapAmount) {
            assertApproxEqAbs(firstSwapOutputAmount, swapAmount, 10, "firstSwapOutputAmount incorrect");
        }
        _mint(firstSwapInputToken, address(this), firstSwapInputAmount);
        {
            uint256 beforeInputTokenBalance = firstSwapInputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = firstSwapOutputToken.balanceOfSelf();
            _swap(key, params, 0, "");
            firstSwapInputAmount = beforeInputTokenBalance - firstSwapInputToken.balanceOfSelf();
            firstSwapOutputAmount = firstSwapOutputToken.balanceOfSelf() - beforeOutputTokenBalance;
        }

        console2.log("firstSwapInputAmount", firstSwapInputAmount);
        console2.log("firstSwapOutputAmount", firstSwapOutputAmount);

        // wait for some time
        skip(waitTime);

        // execute second swap
        params = IPoolManager.SwapParams({
            zeroForOne: !zeroForOneFirstSwap,
            amountSpecified: -int256(firstSwapOutputAmount),
            sqrtPriceLimitX96: !zeroForOneFirstSwap ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
        });
        uint256 secondSwapInputAmount;
        uint256 secondSwapOutputAmount;
        {
            uint256 beforeInputTokenBalance = firstSwapOutputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = firstSwapInputToken.balanceOfSelf();
            _swap(key, params, 0, "");
            secondSwapInputAmount = beforeInputTokenBalance - firstSwapOutputToken.balanceOfSelf();
            secondSwapOutputAmount = firstSwapInputToken.balanceOfSelf() - beforeOutputTokenBalance;
        }

        console2.log("secondSwapInputAmount", secondSwapInputAmount);
        console2.log("secondSwapOutputAmount", secondSwapOutputAmount);

        // verify no profits
        assertLeDecimal(secondSwapOutputAmount, firstSwapInputAmount, 18, "arb has profit");
    }

    function test_fuzz_swapNoArb_double(
        uint256 swapAmount,
        bool zeroForOneFirstSwap,
        bool useVault0,
        bool useVault1,
        uint256 waitTime,
        uint32 alpha,
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier
    ) external {
        swapAmount = bound(swapAmount, 1e6, 1e36);
        waitTime = bound(waitTime, 10, SURGE_AUTOSTART_TIME * 3);
        feeMin = uint24(bound(feeMin, 0, 1e6 - 1));
        feeMax = uint24(bound(feeMax, feeMin, 1e6 - 1));
        alpha = uint32(bound(alpha, 1e3, 12e8));

        GeometricDistribution ldf_ = new GeometricDistribution();
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), alpha));
        {
            PoolKey memory key_;
            key_.tickSpacing = TICK_SPACING;
            vm.assume(ldf_.isValidParams(key_, TWAP_SECONDS_AGO, ldfParams));
        }
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            ldf_,
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
            )
        );

        // execute first swap
        (Currency firstSwapInputToken, Currency firstSwapOutputToken) =
            zeroForOneFirstSwap ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        _mint(firstSwapInputToken, address(this), swapAmount * 2);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOneFirstSwap,
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: zeroForOneFirstSwap ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
        });
        uint256 firstSwapInputAmount;
        uint256 firstSwapOutputAmount;
        {
            uint256 beforeInputTokenBalance = firstSwapInputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = firstSwapOutputToken.balanceOfSelf();
            _swap(key, params, 0, "");
            firstSwapInputAmount = beforeInputTokenBalance - firstSwapInputToken.balanceOfSelf();
            firstSwapOutputAmount = firstSwapOutputToken.balanceOfSelf() - beforeOutputTokenBalance;
        }

        console2.log("firstSwapInputAmount", firstSwapInputAmount);
        console2.log("firstSwapOutputAmount", firstSwapOutputAmount);

        // wait for some time
        skip(waitTime);

        // execute second swap
        vm.assume(firstSwapOutputAmount != 0);
        params = IPoolManager.SwapParams({
            zeroForOne: !zeroForOneFirstSwap,
            amountSpecified: -int256(firstSwapOutputAmount),
            sqrtPriceLimitX96: !zeroForOneFirstSwap ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
        });
        uint256 secondSwapInputAmount;
        uint256 secondSwapOutputAmount;
        {
            uint256 beforeInputTokenBalance = firstSwapOutputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = firstSwapInputToken.balanceOfSelf();
            _swap(key, params, 0, "");
            secondSwapInputAmount = beforeInputTokenBalance - firstSwapOutputToken.balanceOfSelf();
            secondSwapOutputAmount = firstSwapInputToken.balanceOfSelf() - beforeOutputTokenBalance;
        }

        console2.log("secondSwapInputAmount", secondSwapInputAmount);
        console2.log("secondSwapOutputAmount", secondSwapOutputAmount);

        // wait for some time
        skip(waitTime);

        // execute third swap
        vm.assume(secondSwapOutputAmount != 0);
        params = IPoolManager.SwapParams({
            zeroForOne: zeroForOneFirstSwap,
            amountSpecified: -int256(secondSwapOutputAmount),
            sqrtPriceLimitX96: zeroForOneFirstSwap ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
        });
        uint256 thirdSwapInputAmount;
        uint256 thirdSwapOutputAmount;
        {
            uint256 beforeInputTokenBalance = firstSwapInputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = firstSwapOutputToken.balanceOfSelf();
            _swap(key, params, 0, "");
            thirdSwapInputAmount = beforeInputTokenBalance - firstSwapInputToken.balanceOfSelf();
            thirdSwapOutputAmount = firstSwapOutputToken.balanceOfSelf() - beforeOutputTokenBalance;
        }

        console2.log("thirdSwapInputAmount", thirdSwapInputAmount);
        console2.log("thirdSwapOutputAmount", thirdSwapOutputAmount);

        // wait for some time
        skip(waitTime);

        // execute fourth swap
        vm.assume(thirdSwapOutputAmount != 0);
        params = IPoolManager.SwapParams({
            zeroForOne: !zeroForOneFirstSwap,
            amountSpecified: -int256(thirdSwapOutputAmount),
            sqrtPriceLimitX96: !zeroForOneFirstSwap ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
        });
        uint256 fourthSwapInputAmount;
        uint256 fourthSwapOutputAmount;
        {
            uint256 beforeInputTokenBalance = firstSwapOutputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = firstSwapInputToken.balanceOfSelf();
            _swap(key, params, 0, "");
            fourthSwapInputAmount = beforeInputTokenBalance - firstSwapOutputToken.balanceOfSelf();
            fourthSwapOutputAmount = firstSwapInputToken.balanceOfSelf() - beforeOutputTokenBalance;
        }

        console2.log("fourthSwapInputAmount", fourthSwapInputAmount);
        console2.log("fourthSwapOutputAmount", fourthSwapOutputAmount);

        // verify no profits
        assertLeDecimal(
            secondSwapOutputAmount + fourthSwapOutputAmount,
            firstSwapInputAmount + thirdSwapInputAmount,
            18,
            "arb has profit"
        );
    }

    function test_fuzz_quoter_quoteSwap(
        uint256 swapAmount,
        bool zeroForOne,
        bool useVault0,
        bool useVault1,
        uint32 alpha,
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier,
        bool amAmmEnabled
    ) external {
        swapAmount = bound(swapAmount, 1e6, 1e36);
        feeMin = uint24(bound(feeMin, 2e5, 1e6 - 1));
        feeMax = uint24(bound(feeMax, feeMin, 1e6 - 1));
        alpha = uint32(bound(alpha, 1e3, 12e8));

        GeometricDistribution ldf_ = new GeometricDistribution();
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), alpha));
        {
            PoolKey memory key_;
            key_.tickSpacing = TICK_SPACING;
            vm.assume(ldf_.isValidParams(key_, TWAP_SECONDS_AGO, ldfParams));
        }
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            ldf_,
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
                amAmmEnabled,
                ORACLE_MIN_INTERVAL,
                MIN_RENT_MULTIPLIER
            )
        );

        (Currency inputToken, Currency outputToken) =
            zeroForOne ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        _mint(inputToken, address(this), swapAmount * 2);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
        });

        // quote swap
        (bool success,,, uint256 inputAmount, uint256 outputAmount,,) = quoter.quoteSwap(address(this), key, params);
        assertTrue(success, "quoteSwap failed");

        // execute swap
        uint256 actualInputAmount;
        uint256 actualOutputAmount;
        {
            uint256 beforeInputTokenBalance = inputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = outputToken.balanceOfSelf();
            swapper.swap(key, params, type(uint256).max, 0);
            actualInputAmount = beforeInputTokenBalance - inputToken.balanceOfSelf();
            actualOutputAmount = outputToken.balanceOfSelf() - beforeOutputTokenBalance;
        }

        // check if actual amounts match quoted amounts
        assertEq(actualInputAmount, inputAmount, "actual input amount doesn't match quoted input amount");
        assertEq(actualOutputAmount, outputAmount, "actual output amount doesn't match quoted output amount");
    }

    function test_fuzz_quoter_quoteDeposit(
        uint256 depositAmount0,
        uint256 depositAmount1,
        bool useVault0,
        bool useVault1,
        uint32 alpha,
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier
    ) external {
        depositAmount0 = bound(depositAmount0, 1e9, 1e36);
        depositAmount1 = bound(depositAmount1, 1e9, 1e36);
        feeMin = uint24(bound(feeMin, 2e5, 1e6 - 1));
        feeMax = uint24(bound(feeMax, feeMin, 1e6 - 1));
        alpha = uint32(bound(alpha, 1e3, 12e8));

        GeometricDistribution ldf_ = new GeometricDistribution();
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), alpha));
        {
            PoolKey memory key_;
            key_.tickSpacing = TICK_SPACING;
            vm.assume(ldf_.isValidParams(key_, TWAP_SECONDS_AGO, ldfParams));
        }
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            ldf_,
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
            )
        );

        // quote deposit
        IBunniHub.DepositParams memory depositParams = IBunniHub.DepositParams({
            poolKey: key,
            amount0Desired: depositAmount0,
            amount1Desired: depositAmount1,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            recipient: address(this),
            refundRecipient: address(this),
            vaultFee0: 0,
            vaultFee1: 0,
            referrer: 0
        });
        (bool success, uint256 shares, uint256 amount0, uint256 amount1) =
            quoter.quoteDeposit(address(this), depositParams);
        assertTrue(success, "quoteDeposit failed");

        // deposit tokens
        (uint256 actualShares, uint256 actualAmount0, uint256 actualAmount1) =
            _makeDeposit(key, depositAmount0, depositAmount1, address(this), "");

        // check if actual amounts match quoted amounts
        assertApproxEqRel(actualShares, shares, 1e12, "actual shares doesn't match quoted shares");
        assertApproxEqAbs(actualAmount0, amount0, 1, "actual amount0 doesn't match quoted amount0");
        assertApproxEqAbs(actualAmount1, amount1, 1, "actual amount1 doesn't match quoted amount1");
    }

    function test_rebalance_basicOrderCreationAndFulfillment(
        uint256 swapAmount,
        bool useVault0,
        bool useVault1,
        uint32 alpha,
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier
    ) external {
        swapAmount = bound(swapAmount, 1e3, 1e6);
        feeMin = uint24(bound(feeMin, 2e5, 1e6 - 1));
        feeMax = uint24(bound(feeMax, feeMin, 1e6 - 1));
        alpha = uint32(bound(alpha, 1e3, 12e8));

        MockLDF ldf_ = new MockLDF();
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), alpha));
        {
            PoolKey memory key_;
            key_.tickSpacing = TICK_SPACING;
            vm.assume(ldf_.isValidParams(key_, TWAP_SECONDS_AGO, ldfParams));
        }
        ldf_.setMinTick(-30); // minTick of MockLDFs need initialization
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            ldf_,
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
            )
        );

        // shift liquidity to the right
        // the LDF will demand more token0, so we'll have too much of token1
        // the rebalance should swap from token1 to token0
        ldf_.setMinTick(-20);

        {
            // verify excess liquidity before the rebalance
            (uint256 excessLiquidity0, uint256 excessLiquidity1, uint256 totalLiquidity) = lens.getExcessLiquidity(key);
            bool shouldRebalance0 = excessLiquidity0 != 0 && excessLiquidity0 >= totalLiquidity / REBALANCE_THRESHOLD;
            bool shouldRebalance1 = excessLiquidity1 != 0 && excessLiquidity1 >= totalLiquidity / REBALANCE_THRESHOLD;
            assertFalse(shouldRebalance0, "shouldRebalance0 is true before rebalance");
            assertTrue(shouldRebalance1, "shouldRebalance1 is not true before rebalance");
        }

        // make small swap to trigger rebalance
        _mint(key.currency0, address(this), swapAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
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
        assertEq(orderEtchedLog.emitter, address(floodPlain), "emitter not floodPlain");
        assertEq(orderEtchedLog.topics[0], IOnChainOrders.OrderEtched.selector, "not OrderEtched event");
        IFloodPlain.SignedOrder memory signedOrder = abi.decode(orderEtchedLog.data, (IFloodPlain.SignedOrder));
        IFloodPlain.Order memory order = signedOrder.order;
        (, bytes32 permit2Hash) = _hashFloodOrder(order);
        assertEq(
            bunniHook.isValidSignature(permit2Hash, abi.encode(key.toId())),
            IERC1271.isValidSignature.selector,
            "order signature not valid"
        );
        assertEq(order.offerer, address(bunniHook), "offerer not bunniHook");
        assertEq(order.recipient, address(bunniHook), "recipient not bunniHook");
        assertEq(order.offer[0].token, Currency.unwrap(key.currency1), "offer token not token1");
        assertEq(order.consideration.token, Currency.unwrap(key.currency0), "consideration token not token0");
        assertEq(order.deadline, vm.getBlockTimestamp() + REBALANCE_ORDER_TTL, "deadline incorrect");
        assertEq(order.preHooks[0].target, address(bunniHook), "preHook target not bunniHook");
        IBunniHook.RebalanceOrderHookArgs memory expectedHookArgs = IBunniHook.RebalanceOrderHookArgs({
            key: key,
            preHookArgs: IBunniHook.RebalanceOrderPreHookArgs({currency: key.currency1, amount: order.offer[0].amount}),
            postHookArgs: IBunniHook.RebalanceOrderPostHookArgs({currency: key.currency0})
        });
        assertEq(
            order.preHooks[0].data,
            abi.encodeCall(IBunniHook.rebalanceOrderPreHook, (expectedHookArgs)),
            "preHook data incorrect"
        );
        assertEq(order.postHooks[0].target, address(bunniHook), "postHook target not bunniHook");
        assertEq(
            order.postHooks[0].data,
            abi.encodeCall(IBunniHook.rebalanceOrderPostHook, (expectedHookArgs)),
            "postHook data incorrect"
        );
        assertEq(signedOrder.signature, abi.encode(key.toId()), "signature incorrect");

        // fulfill order
        _mint(key.currency0, address(this), order.consideration.amount);
        (uint256 beforeBalance0, uint256 beforeBalance1) = hub.poolBalances(key.toId());
        uint256 beforeFulfillerBalance0 = key.currency0.balanceOfSelf();
        floodPlain.fulfillOrder(signedOrder);
        (uint256 afterBalance0, uint256 afterBalance1) = hub.poolBalances(key.toId());

        // verify balances
        assertEq(
            beforeFulfillerBalance0 - key.currency0.balanceOfSelf(),
            order.consideration.amount,
            "didn't take currency0 from fulfiller"
        );
        assertApproxEqAbs(
            beforeBalance1 - afterBalance1, order.offer[0].amount, 10, "offer tokens taken from hub incorrect"
        );
        assertApproxEqAbs(
            afterBalance0 - beforeBalance0,
            order.consideration.amount,
            10,
            "consideration tokens given to hub incorrect"
        );

        {
            // verify excess liquidity after the rebalance
            (uint256 excessLiquidity0, uint256 excessLiquidity1, uint256 totalLiquidity) = lens.getExcessLiquidity(key);
            bool shouldRebalance0 = excessLiquidity0 != 0 && excessLiquidity0 >= totalLiquidity / REBALANCE_THRESHOLD;
            bool shouldRebalance1 = excessLiquidity1 != 0 && excessLiquidity1 >= totalLiquidity / REBALANCE_THRESHOLD;
            assertFalse(shouldRebalance0, "shouldRebalance0 is still true after rebalance");
            assertFalse(shouldRebalance1, "shouldRebalance1 is still true after rebalance");
        }

        // verify surge fee is applied
        (,, uint32 lastSwapTimestamp, uint32 lastSurgeTImestamp) = bunniHook.slot0s(key.toId());
        assertEq(lastSwapTimestamp, uint32(vm.getBlockTimestamp()), "lastSwapTimestamp incorrect");
        assertEq(lastSurgeTImestamp, uint32(vm.getBlockTimestamp()), "lastSurgeTImestamp incorrect");
    }

    function test_bunniToken_multicall() external {
        (IBunniToken bunniToken, PoolKey memory key) = _deployPoolAndInitLiquidity();

        // make deposit
        (uint256 shares,,) = _makeDepositWithFee({
            key_: key,
            depositAmount0: 1 ether,
            depositAmount1: 1 ether,
            depositor: address(this),
            vaultFee0: 0,
            vaultFee1: 0,
            snapLabel: ""
        });

        // multitransfer
        uint256 N = 10;
        address[] memory targets = new address[](N);
        bytes[] memory data = new bytes[](N);
        uint256[] memory values = new uint256[](N);
        for (uint256 i; i < N; i++) {
            targets[i] = address(bunniToken);
            data[i] = abi.encodeCall(IERC20.transfer, (address(uint160(i + 1)), shares / N));
        }
        MulticallerWithSender(payable(LibMulticaller.MULTICALLER_WITH_SENDER)).aggregateWithSender(
            targets, data, values
        );
        for (uint256 i; i < N; i++) {
            assertEq(bunniToken.balanceOf(address(uint160(i + 1))), shares / N, "balance incorrect");
        }
    }

    function test_hooklet_basicHookletCalls() external {
        // deploy mock hooklet with all flags
        bytes32 salt;
        unchecked {
            bytes memory creationCode = type(HookletMock).creationCode;
            for (uint256 offset; offset < 100000; offset++) {
                salt = bytes32(offset);
                address deployed = computeAddress(address(this), salt, creationCode);
                if (
                    uint160(bytes20(deployed)) & HookletLib.ALL_FLAGS_MASK == HookletLib.ALL_FLAGS_MASK
                        && deployed.code.length == 0
                ) {
                    break;
                }
            }
        }
        HookletMock hooklet = new HookletMock{salt: salt}();

        // deploy pool with hooklet
        // this should trigger:
        // - before/afterInitialize
        // - before/afterDeposit
        (Currency currency0, Currency currency1) = (Currency.wrap(address(token0)), Currency.wrap(address(token1)));
        (IBunniToken bunniToken, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, hooklet);

        // withdraw liquidity
        // this should trigger:
        // - before/afterWithdraw
        vm.startPrank(address(0x6969));
        hub.withdraw(
            IBunniHub.WithdrawParams({
                poolKey: key,
                recipient: address(0x6969),
                shares: bunniToken.balanceOf(address(0x6969)),
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp,
                useQueuedWithdrawal: false
            })
        );
        vm.stopPrank();

        // make swap
        // this should trigger:
        // - before/afterSwap
        _mint(currency0, address(this), 1 ether);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(1 ether),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });
        _swap(key, params, 0, "");
    }

    // Implementation of IFulfiller interface
    function sourceConsideration(
        bytes28, /* selectorExtension */
        IFloodPlain.Order calldata order,
        address, /* caller */
        bytes calldata data
    ) external returns (uint256) {
        // deposit liquidity between rebalanceOrderPreHook and rebalanceOrderPostHook
        IBunniHub.DepositParams memory depositParams = abi.decode(data, (IBunniHub.DepositParams));
        (, deposit0, deposit1) = hub.deposit(depositParams);

        return order.consideration.amount;
    }

    function test_rebalance_arb() external {
        uint256 swapAmount = 1e6;
        uint32 alpha = 359541238;
        uint24 feeMin = 0.3e6;
        uint24 feeMax = 0.5e6;
        uint24 feeQuadraticMultiplier = 1e6;

        MockLDF ldf_ = new MockLDF();
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), alpha));
        ldf_.setMinTick(-30); // minTick of MockLDFs need initialization
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
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
            )
        );

        // shift liquidity to the right
        // the LDF will demand more token0, so we'll have too much of token1
        // the rebalance should swap from token1 to token0
        ldf_.setMinTick(-20);

        // make small swap to trigger rebalance
        _mint(key.currency0, address(this), swapAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });
        vm.recordLogs();
        _swap(key, params, 0, "");

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
        IFloodPlain.Order memory order = signedOrder.order;

        // prepare deposit data
        IBunniHub.DepositParams memory depositParams = IBunniHub.DepositParams({
            poolKey: key,
            amount0Desired: 1e18,
            amount1Desired: 1e18,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            recipient: address(this),
            refundRecipient: address(this),
            vaultFee0: 0,
            vaultFee1: 0,
            referrer: 0
        });
        _mint(key.currency0, address(this), depositParams.amount0Desired);
        _mint(key.currency1, address(this), depositParams.amount1Desired);

        // fulfill order
        // should revert due to reentrancy
        _mint(key.currency0, address(this), order.consideration.amount);
        bytes memory data = abi.encode(depositParams);
        vm.expectRevert(ReentrancyGuard.ReentrancyGuard__ReentrantCall.selector);
        floodPlain.fulfillOrder(signedOrder, address(this), data);
    }

    function test_avoidTransferringBidTokensDuringRebalance() public {
        // Step 1: Create a new pool
        (IBunniToken bt1, PoolKey memory poolKey1) = _deployPoolAndInitLiquidity();

        // Step 2: Send bids and rent tokens (BT1) to BunniHook
        uint128 minRent = uint128(bt1.totalSupply() * MIN_RENT_MULTIPLIER / 1e18);
        uint128 bidAmount = minRent * 10 days;
        deal(address(bt1), address(this), bidAmount);
        bt1.approve(address(bunniHook), bidAmount);
        bunniHook.bid(
            poolKey1.toId(),
            address(this),
            bytes7(abi.encodePacked(uint24(1e3), uint24(2e3), true)),
            minRent * 2,
            bidAmount
        );

        // Record the initial BT1 balance of BunniHook
        uint256 initialBT1Balance = bt1.balanceOf(address(bunniHook));
        assertEq(initialBT1Balance, bidAmount, "BunniHook should have BT1 balance");

        // Step 3: Create a new pool with BT1 and AttackerToken
        ERC20Mock attackerToken = new ERC20Mock();
        MockLDF mockLDF = new MockLDF();
        mockLDF.setMinTick(-30); // minTick of MockLDFs need initialization

        // approve tokens
        vm.startPrank(address(0x6969));
        bt1.approve(address(permit2), type(uint256).max);
        attackerToken.approve(address(permit2), type(uint256).max);
        permit2.approve(address(bt1), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(attackerToken), address(hub), type(uint160).max, type(uint48).max);
        vm.stopPrank();

        (Currency currency0, Currency currency1) = address(bt1) < address(attackerToken)
            ? (Currency.wrap(address(bt1)), Currency.wrap(address(attackerToken)))
            : (Currency.wrap(address(attackerToken)), Currency.wrap(address(bt1)));
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

        // Step 4: Trigger a rebalance for the attacker's pool
        // Shift liquidity to create an imbalance such that we need to swap attackerToken into bt1
        // Shift right if bt1 is token0, shift left if bt1 is token1
        mockLDF.setMinTick(address(bt1) < address(attackerToken) ? -20 : -40);

        // Make a small swap to trigger rebalance
        uint256 swapAmount = 1e6;
        deal(address(bt1), address(this), swapAmount);
        bt1.approve(address(swapper), swapAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: address(bt1) < address(attackerToken),
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: address(bt1) < address(attackerToken)
                ? TickMath.MIN_SQRT_PRICE + 1
                : TickMath.MAX_SQRT_PRICE - 1
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

        // Fulfill the rebalance order
        deal(address(bt1), address(this), order.consideration.amount);
        bt1.approve(address(floodPlain), order.consideration.amount);
        floodPlain.fulfillOrder(signedOrder);

        // Step 5: Verify that the BT1 balance of BunniHook is still bidAmount
        uint256 finalBT1Balance = bt1.balanceOf(address(bunniHook));
        assertEq(finalBT1Balance, bidAmount, "BT1 balance of BunniHook should not change after rebalance");
    }

    function test_DoS_pool() public {
        // Deployment data
        uint160 sqrtPriceX96 = TickMath.getSqrtPriceAtTick(0);
        Currency currency0 = Currency.wrap(address(token0));
        Currency currency1 = Currency.wrap(address(token1));
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), ALPHA));
        bytes memory hookParams = abi.encodePacked(
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
            true,
            ORACLE_MIN_INTERVAL,
            MIN_RENT_MULTIPLIER
        );
        bytes32 salt;
        unchecked {
            bytes memory creationCode = type(HookletMock).creationCode;
            for (uint256 offset; offset < 100000; offset++) {
                salt = bytes32(offset);
                address deployed = computeAddress(address(this), salt, creationCode);
                if (
                    uint160(bytes20(deployed)) & HookletLib.ALL_FLAGS_MASK == HookletLib.ALL_FLAGS_MASK
                        && deployed.code.length == 0
                ) {
                    break;
                }
            }
        }
        HookletMock hooklet = new HookletMock{salt: salt}();

        // Deploy BunniToken
        (, PoolKey memory key) = hub.deployBunniToken(
            IBunniHub.DeployBunniTokenParams({
                currency0: currency0,
                currency1: currency1,
                tickSpacing: TICK_SPACING,
                twapSecondsAgo: TWAP_SECONDS_AGO,
                liquidityDensityFunction: ldf,
                hooklet: hooklet,
                ldfType: LDFType.DYNAMIC_AND_STATEFUL,
                ldfParams: ldfParams,
                hooks: bunniHook,
                hookParams: hookParams,
                vault0: ERC4626(address(vault0)),
                vault1: ERC4626(address(vault1)),
                minRawTokenRatio0: 0.08e6,
                targetRawTokenRatio0: 0.1e6,
                maxRawTokenRatio0: 0.12e6,
                minRawTokenRatio1: 0.08e6,
                targetRawTokenRatio1: 0.1e6,
                maxRawTokenRatio1: 0.12e6,
                sqrtPriceX96: sqrtPriceX96,
                name: bytes32("BunniToken"),
                symbol: bytes32("BUNNI-LP"),
                owner: address(this),
                metadataURI: "metadataURI",
                salt: salt
            })
        );

        // Mint shares using 1 wei of each token
        // Should revert due to the amounts being too small
        _mint(currency0, address(this), 1);
        _mint(currency1, address(this), 1);
        vm.expectRevert(BunniHub__DepositAmountTooSmall.selector);
        hub.deposit(
            IBunniHub.DepositParams({
                poolKey: key,
                amount0Desired: 1,
                amount1Desired: 1,
                amount0Min: 0,
                amount1Min: 0,
                deadline: block.timestamp,
                recipient: address(this),
                refundRecipient: address(this),
                vaultFee0: 0,
                vaultFee1: 0,
                referrer: 0
            })
        );
    }

    function test_idleBalance_startAtZero() public {
        (, PoolKey memory key) = _deployPoolAndInitLiquidity();

        // idle balance should be 0
        IdleBalance idleBalance = hub.idleBalance(key.toId());
        (uint256 balance,) = idleBalance.fromIdleBalance();
        assertEq(balance, 0, "idle balance not zero at start");
    }

    function test_idleBalance_ldfShiftUpdatesIdleBalance() public {
        MockLDF ldf_ = new MockLDF();
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), ALPHA));
        ldf_.setMinTick(-30);

        (, PoolKey memory key) = _deployPoolAndInitLiquidity(ldf_, ldfParams);

        // shift liquidity to the right
        // the LDF will demand more token0, so we'll have too much of token1
        ldf_.setMinTick(-20);

        // make swap to update state
        uint256 swapAmount = 1e3;
        _mint(key.currency0, address(this), swapAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });
        _swap(key, params, 0, "");

        // idle balance should be non-zero and in token1
        IdleBalance idleBalance = hub.idleBalance(key.toId());
        (uint256 balance, bool isToken0) = idleBalance.fromIdleBalance();
        assertGt(balance, 0, "idle balance should be non-zero");
        assertFalse(isToken0, "idle balance should be in token1");
    }

    function test_idleBalance_rebalanceUpdatesIdleBalance() public {
        MockLDF ldf_ = new MockLDF();
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-3) * TICK_SPACING, int16(6), ALPHA));
        ldf_.setMinTick(-30);

        (, PoolKey memory key) = _deployPoolAndInitLiquidity(ldf_, ldfParams);

        // shift liquidity to the right
        // the LDF will demand more token0, so we'll have too much of token1
        ldf_.setMinTick(-20);

        // make swap to trigger rebalance
        uint256 swapAmount = 1e3;
        _mint(key.currency0, address(this), swapAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });
        vm.recordLogs();
        _swap(key, params, 0, "");

        IdleBalance idleBalanceBefore = hub.idleBalance(key.toId());
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
        IFloodPlain.Order memory order = signedOrder.order;

        // fulfill order
        _mint(key.currency0, address(this), order.consideration.amount);
        floodPlain.fulfillOrder(signedOrder);

        // idle balance should be reduced by order input
        IdleBalance idleBalanceAfter = hub.idleBalance(key.toId());
        (uint256 balanceAfter, bool isToken0After) = idleBalanceAfter.fromIdleBalance();
        assertEq(
            balanceAfter,
            balanceBefore - order.offer[0].amount,
            "idle balance should be reduced by rebalance order input"
        );
        assertFalse(isToken0After, "idle balance should still be in token1");
    }

    /// -----------------------------------------------------------------------
    /// Internal utils
    /// -----------------------------------------------------------------------

    function _makeDeposit(PoolKey memory key, uint256 depositAmount0, uint256 depositAmount1)
        internal
        returns (uint256 shares, uint256 amount0, uint256 amount1)
    {
        return _makeDeposit(key, depositAmount0, depositAmount1, address(this), "");
    }

    function _makeDeposit(
        PoolKey memory key_,
        uint256 depositAmount0,
        uint256 depositAmount1,
        address depositor,
        string memory snapLabel
    ) internal returns (uint256 shares, uint256 amount0, uint256 amount1) {
        // mint tokens
        uint256 value;
        if (key_.currency0.isAddressZero()) {
            value = depositAmount0;
        } else if (key_.currency1.isAddressZero()) {
            value = depositAmount1;
        }
        _mint(key_.currency0, depositor, depositAmount0);
        _mint(key_.currency1, depositor, depositAmount1);

        // deposit tokens
        IBunniHub.DepositParams memory depositParams = IBunniHub.DepositParams({
            poolKey: key_,
            amount0Desired: depositAmount0,
            amount1Desired: depositAmount1,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            recipient: depositor,
            refundRecipient: depositor,
            vaultFee0: 0,
            vaultFee1: 0,
            referrer: 0
        });
        IBunniHub hub_ = hub;
        vm.startPrank(depositor);
        if (bytes(snapLabel).length > 0) {
            snapStart(snapLabel);
        }
        (shares, amount0, amount1) = hub_.deposit{value: value}(depositParams);
        if (bytes(snapLabel).length > 0) {
            snapEnd();
        }
        vm.stopPrank();
    }

    function _makeDepositWithFee(
        PoolKey memory key_,
        uint256 depositAmount0,
        uint256 depositAmount1,
        address depositor,
        uint256 vaultFee0,
        uint256 vaultFee1,
        string memory snapLabel
    ) internal returns (uint256 shares, uint256 amount0, uint256 amount1) {
        // mint tokens
        uint256 value;
        if (key_.currency0.isAddressZero()) {
            value = depositAmount0.divWadUp(WAD - vaultFee0);
        } else if (key_.currency1.isAddressZero()) {
            value = depositAmount1.divWadUp(WAD - vaultFee1);
        }
        _mint(key_.currency0, depositor, depositAmount0.divWadUp(WAD - vaultFee0));
        _mint(key_.currency1, depositor, depositAmount1.divWadUp(WAD - vaultFee1));

        // deposit tokens
        IBunniHub.DepositParams memory depositParams = IBunniHub.DepositParams({
            poolKey: key_,
            amount0Desired: depositAmount0,
            amount1Desired: depositAmount1,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            recipient: depositor,
            refundRecipient: depositor,
            vaultFee0: vaultFee0,
            vaultFee1: vaultFee1,
            referrer: 0
        });
        IBunniHub hub_ = hub;
        vm.startPrank(depositor);
        if (bytes(snapLabel).length > 0) {
            snapStart(snapLabel);
        }
        (shares, amount0, amount1) = hub_.deposit{value: value}(depositParams);
        if (bytes(snapLabel).length > 0) {
            snapEnd();
        }
        vm.stopPrank();
    }

    function _vaultBalanceOf(ERC4626 vault, address account) internal view returns (uint256) {
        if (address(vault) == address(0)) return 0;
        return vault.balanceOf(account);
    }

    function _vaultPreviewRedeem(ERC4626 vault, uint256 amount) internal view returns (uint256) {
        if (address(vault) == address(0)) return 0;
        return vault.previewRedeem(amount);
    }

    function _mint(Currency currency, address to, uint256 amount) internal {
        if (currency.isAddressZero()) {
            vm.deal(to, to.balance + amount);
        } else if (Currency.unwrap(currency) == address(weth)) {
            vm.deal(address(this), address(this).balance + amount);
            weth.deposit{value: amount}();
            weth.transfer(to, amount);
        } else {
            deal(Currency.unwrap(currency), to, amount);
        }
    }

    function _deployPoolAndInitLiquidity() internal returns (IBunniToken bunniToken, PoolKey memory key) {
        return _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)), Currency.wrap(address(token1)), ERC4626(address(0)), ERC4626(address(0))
        );
    }

    function _deployPoolAndInitLiquidity(Currency currency0, Currency currency1)
        internal
        returns (IBunniToken bunniToken, PoolKey memory key)
    {
        return _deployPoolAndInitLiquidity(currency0, currency1, ERC4626(address(0)), ERC4626(address(0)));
    }

    function _deployPoolAndInitLiquidity(Currency currency0, Currency currency1, IHooklet hooklet)
        internal
        returns (IBunniToken bunniToken, PoolKey memory key)
    {
        return _deployPoolAndInitLiquidity(
            currency0, currency1, ERC4626(address(0)), ERC4626(address(0)), hooklet, bytes32(0)
        );
    }

    function _deployPoolAndInitLiquidity(Currency currency0, Currency currency1, bytes32 salt)
        internal
        returns (IBunniToken bunniToken, PoolKey memory key)
    {
        return _deployPoolAndInitLiquidity(
            currency0, currency1, ERC4626(address(0)), ERC4626(address(0)), IHooklet(address(0)), salt
        );
    }

    function _deployPoolAndInitLiquidity(Currency currency0, Currency currency1, ERC4626 vault0_, ERC4626 vault1_)
        internal
        returns (IBunniToken bunniToken, PoolKey memory key)
    {
        return _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_, IHooklet(address(0)), bytes32(0));
    }

    function _deployPoolAndInitLiquidity(
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        IHooklet hooklet,
        bytes32 salt
    ) internal returns (IBunniToken bunniToken, PoolKey memory key) {
        return _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            vault0_,
            vault1_,
            ldf,
            hooklet,
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
            salt
        );
    }

    function _deployPoolAndInitLiquidity(
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        ILiquidityDensityFunction ldf_
    ) internal returns (IBunniToken bunniToken, PoolKey memory key) {
        return _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            vault0_,
            vault1_,
            ldf_,
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
            bytes32(0)
        );
    }

    function _deployPoolAndInitLiquidity(ILiquidityDensityFunction ldf_, bytes32 ldfParams)
        internal
        returns (IBunniToken bunniToken, PoolKey memory key)
    {
        return _deployPoolAndInitLiquidity(
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
    }

    function _deployPoolAndInitLiquidity(
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        bytes32 ldfParams,
        bytes memory hookParams
    ) internal returns (IBunniToken bunniToken, PoolKey memory key) {
        return _deployPoolAndInitLiquidity(
            currency0, currency1, vault0_, vault1_, ldf, IHooklet(address(0)), ldfParams, hookParams, bytes32(0)
        );
    }

    function _deployPoolAndInitLiquidity(
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        ILiquidityDensityFunction ldf_,
        bytes32 ldfParams,
        bytes memory hookParams
    ) internal returns (IBunniToken bunniToken, PoolKey memory key) {
        return _deployPoolAndInitLiquidity(
            currency0, currency1, vault0_, vault1_, ldf_, IHooklet(address(0)), ldfParams, hookParams, bytes32(0)
        );
    }

    function _deployPoolAndInitLiquidity(
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        uint256 depositAmount0,
        uint256 depositAmount1,
        ILiquidityDensityFunction ldf_,
        bytes32 ldfParams,
        bytes memory hookParams
    ) internal returns (IBunniToken bunniToken, PoolKey memory key) {
        return _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            vault0_,
            vault1_,
            depositAmount0,
            depositAmount1,
            ldf_,
            IHooklet(address(0)),
            ldfParams,
            hookParams,
            bytes32(0)
        );
    }

    function _deployPoolAndInitLiquidity(
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        ILiquidityDensityFunction ldf_,
        IHooklet hooklet,
        bytes32 ldfParams,
        bytes memory hookParams,
        bytes32 salt
    ) internal returns (IBunniToken bunniToken, PoolKey memory key) {
        // initialize bunni
        (bunniToken, key) = hub.deployBunniToken(
            IBunniHub.DeployBunniTokenParams({
                currency0: currency0,
                currency1: currency1,
                tickSpacing: TICK_SPACING,
                twapSecondsAgo: TWAP_SECONDS_AGO,
                liquidityDensityFunction: ldf_,
                hooklet: hooklet,
                ldfType: LDFType.DYNAMIC_AND_STATEFUL,
                ldfParams: ldfParams,
                hooks: bunniHook,
                hookParams: hookParams,
                vault0: vault0_,
                vault1: vault1_,
                minRawTokenRatio0: 0.08e6,
                targetRawTokenRatio0: 0.1e6,
                maxRawTokenRatio0: 0.12e6,
                minRawTokenRatio1: 0.08e6,
                targetRawTokenRatio1: 0.1e6,
                maxRawTokenRatio1: 0.12e6,
                sqrtPriceX96: TickMath.getSqrtPriceAtTick(4),
                name: bytes32("BunniToken"),
                symbol: bytes32("BUNNI-LP"),
                owner: address(this),
                metadataURI: "metadataURI",
                salt: salt
            })
        );

        // make initial deposit to avoid accounting for MIN_INITIAL_SHARES
        uint256 depositAmount0 = PRECISION;
        uint256 depositAmount1 = PRECISION;
        vm.startPrank(address(0x6969));
        token0.approve(address(permit2), type(uint256).max);
        token1.approve(address(permit2), type(uint256).max);
        weth.approve(address(permit2), type(uint256).max);
        permit2.approve(address(token0), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(token1), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(weth), address(hub), type(uint160).max, type(uint48).max);
        vm.stopPrank();
        uint256 vaultFee0 = address(vault0_) == address(vault0WithFee) || address(vault0_) == address(vault1WithFee)
            || address(vault0_) == address(vaultWethWithFee) ? VAULT_FEE : 0;
        uint256 vaultFee1 = address(vault1_) == address(vault0WithFee) || address(vault1_) == address(vault1WithFee)
            || address(vault1_) == address(vaultWethWithFee) ? VAULT_FEE : 0;
        _makeDepositWithFee(key, depositAmount0, depositAmount1, address(0x6969), vaultFee0, vaultFee1, "");
    }

    function _deployPoolAndInitLiquidity(
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        uint256 depositAmount0,
        uint256 depositAmount1,
        ILiquidityDensityFunction ldf_,
        IHooklet hooklet,
        bytes32 ldfParams,
        bytes memory hookParams,
        bytes32 salt
    ) internal returns (IBunniToken bunniToken, PoolKey memory key) {
        // initialize bunni
        (bunniToken, key) = hub.deployBunniToken(
            IBunniHub.DeployBunniTokenParams({
                currency0: currency0,
                currency1: currency1,
                tickSpacing: TICK_SPACING,
                twapSecondsAgo: TWAP_SECONDS_AGO,
                liquidityDensityFunction: ldf_,
                hooklet: hooklet,
                ldfType: LDFType.DYNAMIC_AND_STATEFUL,
                ldfParams: ldfParams,
                hooks: bunniHook,
                hookParams: hookParams,
                vault0: vault0_,
                vault1: vault1_,
                minRawTokenRatio0: 0.08e6,
                targetRawTokenRatio0: 0.1e6,
                maxRawTokenRatio0: 0.12e6,
                minRawTokenRatio1: 0.08e6,
                targetRawTokenRatio1: 0.1e6,
                maxRawTokenRatio1: 0.12e6,
                sqrtPriceX96: TickMath.getSqrtPriceAtTick(4),
                name: bytes32("BunniToken"),
                symbol: bytes32("BUNNI-LP"),
                owner: address(this),
                metadataURI: "metadataURI",
                salt: salt
            })
        );

        // make initial deposit to avoid accounting for MIN_INITIAL_SHARES
        vm.startPrank(address(0x6969));
        token0.approve(address(permit2), type(uint256).max);
        token1.approve(address(permit2), type(uint256).max);
        weth.approve(address(permit2), type(uint256).max);
        permit2.approve(address(token0), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(token1), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(weth), address(hub), type(uint160).max, type(uint48).max);
        vm.stopPrank();
        uint256 vaultFee0 = address(vault0_) == address(vault0WithFee) || address(vault0_) == address(vault1WithFee)
            || address(vault0_) == address(vaultWethWithFee) ? VAULT_FEE : 0;
        uint256 vaultFee1 = address(vault1_) == address(vault0WithFee) || address(vault1_) == address(vault1WithFee)
            || address(vault1_) == address(vaultWethWithFee) ? VAULT_FEE : 0;
        _makeDepositWithFee(key, depositAmount0, depositAmount1, address(0x6969), vaultFee0, vaultFee1, "");
    }

    function _execTestAcrossScenarios(
        function (
        uint256,
        uint256,
        Currency,
        Currency,
        ERC4626,
        ERC4626,
        string memory
        ) fn,
        uint256 depositAmount0,
        uint256 depositAmount1,
        string memory label
    ) internal {
        uint256 snapshotId = vm.snapshot();

        fn(
            depositAmount0,
            depositAmount1,
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            ERC4626(address(0)),
            ERC4626(address(0)),
            string.concat(label, ", token0 no native no vault, token1 no native no vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            ERC4626(address(0)),
            vault1,
            string.concat(label, ", token0 no native no vault, token1 no native yes vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            vault0,
            vault1,
            string.concat(label, ", token0 no native yes vault, token1 no native yes vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            CurrencyLibrary.ADDRESS_ZERO,
            Currency.wrap(address(token1)),
            ERC4626(address(0)),
            ERC4626(address(0)),
            string.concat(label, ", token0 yes native no vault, token1 no native no vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            CurrencyLibrary.ADDRESS_ZERO,
            Currency.wrap(address(token1)),
            ERC4626(address(0)),
            vault1,
            string.concat(label, ", token0 yes native no vault, token1 no native yes vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            CurrencyLibrary.ADDRESS_ZERO,
            Currency.wrap(address(token1)),
            vaultWeth,
            ERC4626(address(0)),
            string.concat(label, ", token0 yes native yes vault, token1 no native no vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            CurrencyLibrary.ADDRESS_ZERO,
            Currency.wrap(address(token1)),
            vaultWeth,
            vault1,
            string.concat(label, ", token0 yes native yes vault, token1 no native yes vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            vault0WithFee,
            vault1WithFee,
            string.concat(label, ", token0 no native yes vault with fee, token1 no native yes vault with fee")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            ERC4626(address(0)),
            vault1WithFee,
            string.concat(label, ", token0 no native no vault, token1 no native yes vault with fee")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            CurrencyLibrary.ADDRESS_ZERO,
            Currency.wrap(address(token1)),
            vaultWethWithFee,
            ERC4626(address(0)),
            string.concat(label, ", token0 yes native yes vault with fee, token1 no native no vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            CurrencyLibrary.ADDRESS_ZERO,
            Currency.wrap(address(token1)),
            vaultWethWithFee,
            vault1WithFee,
            string.concat(label, ", token0 yes native yes vault with fee, token1 no native yes vault with fee")
        );
        vm.revertTo(snapshotId);
    }

    receive() external payable {}

    function _swap(PoolKey memory key, IPoolManager.SwapParams memory params, uint256 value, string memory snapLabel)
        internal
    {
        Uniswapper swapper_ = swapper;
        if (bytes(snapLabel).length > 0) {
            snapStart(snapLabel);
            swapper_.swap{value: value}(key, params, type(uint256).max, 0);
            snapEnd();
        } else {
            swapper_.swap{value: value}(key, params, type(uint256).max, 0);
        }
    }

    /// @dev The hash that Permit2 uses when verifying the order's signature.
    /// See https://github.com/Uniswap/permit2/blob/cc56ad0f3439c502c246fc5cfcc3db92bb8b7219/src/SignatureTransfer.sol#L65
    /// Always calls permit2 for the domain separator to maintain cross-chain replay protection in the event of a fork
    /// Also returns the Flood order hash
    function _hashFloodOrder(IFloodPlain.Order memory order)
        internal
        view
        returns (bytes32 orderHash, bytes32 permit2Hash)
    {
        (orderHash, permit2Hash) = OrderHashMemory.hashAsWitness(order, address(floodPlain));
        permit2Hash = keccak256(abi.encodePacked("\x19\x01", IEIP712(permit2).DOMAIN_SEPARATOR(), permit2Hash));
    }

    /// @notice Precompute a contract address deployed via CREATE2
    /// @param deployer The address that will deploy the hook. In `forge test`, this will be the test contract `address(this)` or the pranking address
    ///                 In `forge script`, this should be `0x4e59b44847b379578588920cA78FbF26c0B4956C` (CREATE2 Deployer Proxy)
    /// @param salt The salt used to deploy the hook
    /// @param creationCode The creation code of a hook contract
    function computeAddress(address deployer, bytes32 salt, bytes memory creationCode)
        public
        pure
        returns (address hookAddress)
    {
        return address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xFF), deployer, salt, keccak256(creationCode)))))
        );
    }
}
