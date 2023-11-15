// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {PoolManager} from "@uniswap/v4-core/src/PoolManager.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import "../src/lib/Math.sol";
import "../src/lib/Structs.sol";
import {BunniHub} from "../src/BunniHub.sol";
import {BunniHook} from "../src/BunniHook.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {Uniswapper} from "./mocks/Uniswapper.sol";
import {IBunniHub} from "../src/interfaces/IBunniHub.sol";
import {IBunniToken} from "../src/interfaces/IBunniToken.sol";
import {DiscreteLaplaceDistribution} from "../src/ldf/DiscreteLaplaceDistribution.sol";

contract BunniHubTest is Test {
    using PoolIdLibrary for PoolKey;

    uint256 internal constant PRECISION = 10 ** 18;
    uint8 internal constant DECIMALS = 18;
    int24 internal constant TICK_SPACING = 10;
    uint256 internal constant MIN_INITIAL_SHARES = 1e3;
    uint24 internal constant HOOK_SWAP_FEE = 0x208000; // 12.5% in either direction
    uint64 internal constant ALPHA = 0.7e18;
    uint256 internal constant MAX_ERROR = 1e9;
    uint24 internal constant FEE_MIN = 0.0001e6;
    uint24 internal constant FEE_MAX = 0.1e6;
    uint24 internal constant FEE_QUADRATIC_MULTIPLIER = 0.5e6;
    uint24 internal constant FEE_TWAP_SECONDS_AGO = 30 minutes;
    address internal constant HOOK_FEES_RECIPIENT = address(0xfee);

    IPoolManager internal poolManager;
    ERC20Mock internal token0;
    ERC20Mock internal token1;
    IBunniHub internal hub;
    IBunniToken internal bunniToken;
    PoolKey internal key;
    BunniHook internal constant bunniHook = BunniHook(
        address(
            uint160(
                Hooks.AFTER_INITIALIZE_FLAG + Hooks.BEFORE_MODIFY_POSITION_FLAG + Hooks.BEFORE_SWAP_FLAG
                    + Hooks.AFTER_SWAP_FLAG
            )
        )
    );
    DiscreteLaplaceDistribution internal ldf;
    Uniswapper internal swapper;

    function setUp() public {
        // initialize uniswap
        token0 = new ERC20Mock();
        token1 = new ERC20Mock();
        if (address(token0) >= address(token1)) {
            (token0, token1) = (token1, token0);
        }
        poolManager = new PoolManager(1e7);

        // deploy swapper
        swapper = new Uniswapper(poolManager);

        // initialize bunni hub
        hub = new BunniHub(poolManager);

        // initialize bunni hook
        deployCodeTo(
            "BunniHook.sol",
            abi.encode(poolManager, hub, address(this), HOOK_FEES_RECIPIENT, HOOK_SWAP_FEE),
            address(bunniHook)
        );
        vm.label(address(bunniHook), "BunniHook");

        // initialize LDF
        ldf = new DiscreteLaplaceDistribution();

        // initialize bunni
        (bunniToken, key) = hub.deployBunniToken(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            TICK_SPACING,
            0,
            ldf,
            bytes32(abi.encodePacked(int24(0), ALPHA)),
            bunniHook,
            bytes32(abi.encodePacked(uint8(100), FEE_MIN, FEE_MAX, FEE_QUADRATIC_MULTIPLIER, FEE_TWAP_SECONDS_AGO)),
            TickMath.getSqrtRatioAtTick(4)
        );

        // increase oracle cardinality
        bunniHook.increaseCardinalityNext(key, 100);

        // approve tokens
        token0.approve(address(hub), type(uint256).max);
        token0.approve(address(swapper), type(uint256).max);
        token1.approve(address(hub), type(uint256).max);
        token1.approve(address(swapper), type(uint256).max);

        // make initial deposit to avoid accounting for MIN_INITIAL_SHARES
        uint256 depositAmount0 = PRECISION;
        uint256 depositAmount1 = PRECISION;
        vm.startPrank(address(0x6969));
        token0.approve(address(hub), type(uint256).max);
        token1.approve(address(hub), type(uint256).max);
        vm.stopPrank();
        _makeDeposit(depositAmount0, depositAmount1, address(0x6969));

        // skip a bit to initialize oracle
        skip(1 days);
    }

    function test_deposit(uint256 depositAmount0, uint256 depositAmount1) public {
        depositAmount0 = bound(depositAmount0, 1e3, type(uint64).max);
        depositAmount1 = bound(depositAmount1, 1e3, type(uint64).max);

        // make deposit
        (uint256 shares,, uint256 amount0, uint256 amount1) = _makeDeposit(depositAmount0, depositAmount1);
        uint256 actualDepositedAmount0 = depositAmount0 - token0.balanceOf(address(this));
        uint256 actualDepositedAmount1 = depositAmount1 - token1.balanceOf(address(this));

        // check return values
        assertEqDecimal(amount0, actualDepositedAmount0, DECIMALS);
        assertEqDecimal(amount1, actualDepositedAmount1, DECIMALS);
        assertEqDecimal(shares, bunniToken.balanceOf(address(this)), DECIMALS);
    }

    function test_withdraw(uint256 depositAmount0, uint256 depositAmount1) public {
        depositAmount0 = bound(depositAmount0, 1e3, type(uint64).max);
        depositAmount1 = bound(depositAmount1, 1e3, type(uint64).max);

        // make deposit
        (uint256 shares,, uint256 amount0, uint256 amount1) = _makeDeposit(depositAmount0, depositAmount1);

        // withdraw
        IBunniHub.WithdrawParams memory withdrawParams = IBunniHub.WithdrawParams({
            poolKey: key,
            recipient: address(this),
            shares: shares,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });
        (, uint256 withdrawAmount0, uint256 withdrawAmount1) = hub.withdraw(withdrawParams);

        // check return values
        // withdraw amount less than original due to rounding
        assertApproxEqAbs(withdrawAmount0, amount0, 10, "withdrawAmount0 incorrect");
        assertApproxEqAbs(withdrawAmount1, amount1, 10, "withdrawAmount1 incorrect");

        // check token balances
        assertApproxEqAbs(token0.balanceOf(address(this)), depositAmount0, 10, "token0 balance incorrect");
        assertApproxEqAbs(token1.balanceOf(address(this)), depositAmount1, 10, "token1 balance incorrect");
        assertEqDecimal(bunniToken.balanceOf(address(this)), 0, DECIMALS, "didn't burn shares");
    }

    function test_swap_zeroForOne_noTickCrossing() public {
        uint256 inputAmount = PRECISION / 10;

        token0.mint(address(this), inputAmount);

        swapper.swap(
            key,
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: int256(inputAmount),
                sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(3)
            })
        );
    }

    function test_swap_zeroForOne_oneTickCrossing() public {
        uint256 inputAmount = PRECISION * 2;

        token0.mint(address(this), inputAmount);

        (, int24 currentTick,,) = poolManager.getSlot0(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        swapper.swap(
            key,
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: int256(inputAmount),
                sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(-9)
            })
        );
        (, currentTick,,) = poolManager.getSlot0(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick - key.tickSpacing, "didn't cross one tick");
    }

    function test_swap_zeroForOne_twoTickCrossing() public {
        uint256 inputAmount = PRECISION * 2;

        token0.mint(address(this), inputAmount);

        (, int24 currentTick,,) = poolManager.getSlot0(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        swapper.swap(
            key,
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: int256(inputAmount),
                sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(-19)
            })
        );
        (, currentTick,,) = poolManager.getSlot0(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick - key.tickSpacing * 2, "didn't cross two ticks");
    }

    function test_swap_zeroForOne_boundaryCondition() public {
        // when swapping from token0 to token1, it's possible for the updated tick to exceed the tick
        // specified by sqrtPriceLimitX96, so we need to handle this edge case properly by adding
        // liquidity to the actual rounded tick

        uint256 inputAmount = PRECISION * 2;

        token0.mint(address(this), inputAmount);

        (, int24 currentTick,,) = poolManager.getSlot0(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        swapper.swap(
            key,
            IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: int256(inputAmount),
                sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(-10) // limit tick is -10 but we'll end up at -11
            })
        );
        (, currentTick,,) = poolManager.getSlot0(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick - key.tickSpacing * 2, "didn't cross two ticks");
    }

    function test_swap_oneForZero_noTickCrossing() public {
        uint256 inputAmount = PRECISION / 10;

        token1.mint(address(this), inputAmount);

        swapper.swap(
            key,
            IPoolManager.SwapParams({
                zeroForOne: false,
                amountSpecified: int256(inputAmount),
                sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(9)
            })
        );
    }

    function test_swap_oneForZero_oneTickCrossing() public {
        uint256 inputAmount = PRECISION * 2;

        token1.mint(address(this), inputAmount);

        (, int24 currentTick,,) = poolManager.getSlot0(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        swapper.swap(
            key,
            IPoolManager.SwapParams({
                zeroForOne: false,
                amountSpecified: int256(inputAmount),
                sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(19)
            })
        );
        (, currentTick,,) = poolManager.getSlot0(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick + key.tickSpacing, "didn't cross one tick");
    }

    function test_swap_oneForZero_twoTickCrossing() public {
        uint256 inputAmount = PRECISION * 2;

        token1.mint(address(this), inputAmount);

        (, int24 currentTick,,) = poolManager.getSlot0(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        swapper.swap(
            key,
            IPoolManager.SwapParams({
                zeroForOne: false,
                amountSpecified: int256(inputAmount),
                sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(29)
            })
        );
        (, currentTick,,) = poolManager.getSlot0(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick + key.tickSpacing * 2, "didn't cross two ticks");
    }

    /*
    function test_pricePerFullShare() public {
        // make deposit
        uint256 depositAmount0 = PRECISION;
        uint256 depositAmount1 = PRECISION;
        (uint256 shares, uint128 newLiquidity, uint256 newAmount0, uint256 newAmount1) =
            _makeDeposit(depositAmount0, depositAmount1);

        (uint128 liquidity, uint256 amount0, uint256 amount1) = lens.pricePerFullShare(key);

        assertEqDecimal(liquidity, (newLiquidity * PRECISION) / shares, DECIMALS);
        assertEqDecimal(amount0, (newAmount0 * PRECISION) / shares, DECIMALS);
        assertEqDecimal(amount1, (newAmount1 * PRECISION) / shares, DECIMALS);
    }*/

    function _makeDeposit(uint256 depositAmount0, uint256 depositAmount1)
        internal
        returns (uint256 shares, uint128 newLiquidity, uint256 amount0, uint256 amount1)
    {
        return _makeDeposit(depositAmount0, depositAmount1, address(this));
    }

    function _makeDeposit(uint256 depositAmount0, uint256 depositAmount1, address recipient)
        internal
        returns (uint256 shares, uint128 newLiquidity, uint256 amount0, uint256 amount1)
    {
        // mint tokens
        token0.mint(recipient, depositAmount0);
        token1.mint(recipient, depositAmount1);

        // deposit tokens
        IBunniHub.DepositParams memory depositParams = IBunniHub.DepositParams({
            poolKey: key,
            amount0Desired: depositAmount0,
            amount1Desired: depositAmount1,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            recipient: recipient
        });
        vm.prank(recipient);
        return hub.deposit(depositParams);
    }

    function _decodeHookFee(uint8 fee, bool zeroForOne) internal pure returns (uint8) {
        return zeroForOne ? (fee % 16) : (fee >> 4);
    }
}
