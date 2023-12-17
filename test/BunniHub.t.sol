// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {GasSnapshot} from "forge-gas-snapshot/GasSnapshot.sol";

import {LibMulticaller} from "multicaller/LibMulticaller.sol";
import {MulticallerEtcher} from "multicaller/MulticallerEtcher.sol";
import {MulticallerWithSender} from "multicaller/MulticallerWithSender.sol";
import {MulticallerWithSigner} from "multicaller/MulticallerWithSigner.sol";

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {PoolManager} from "@uniswap/v4-core/src/PoolManager.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {WETH} from "solmate/tokens/WETH.sol";
import {ERC4626} from "solmate/mixins/ERC4626.sol";

import "../src/lib/Math.sol";
import "../src/lib/Structs.sol";
import "../src/ldf/ShiftMode.sol";
import {MockLDF} from "./mocks/MockLDF.sol";
import {BunniHub} from "../src/BunniHub.sol";
import {BunniHook} from "../src/BunniHook.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {Uniswapper} from "./mocks/Uniswapper.sol";
import {ERC4626Mock} from "./mocks/ERC4626Mock.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IBunniHub} from "../src/interfaces/IBunniHub.sol";
import {Permit2Deployer} from "./mocks/Permit2Deployer.sol";
import {IBunniToken} from "../src/interfaces/IBunniToken.sol";
import {DiscreteLaplaceDistribution} from "../src/ldf/DiscreteLaplaceDistribution.sol";
import {ILiquidityDensityFunction} from "../src/interfaces/ILiquidityDensityFunction.sol";

contract BunniHubTest is Test, GasSnapshot, Permit2Deployer {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;

    uint256 internal constant PRECISION = 10 ** 18;
    uint8 internal constant DECIMALS = 18;
    int24 internal constant TICK_SPACING = 10;
    uint256 internal constant MIN_INITIAL_SHARES = 1e3;
    uint96 internal constant HOOK_SWAP_FEE = 0.1e18;
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
    ERC4626Mock internal vault0;
    ERC4626Mock internal vault1;
    ERC4626Mock internal vaultWeth;
    IBunniHub internal hub;
    BunniHook internal constant bunniHook = BunniHook(
        address(
            uint160(
                Hooks.AFTER_INITIALIZE_FLAG + Hooks.BEFORE_MODIFY_POSITION_FLAG + Hooks.BEFORE_SWAP_FLAG
                    + Hooks.AFTER_SWAP_FLAG + Hooks.ACCESS_LOCK_FLAG
            )
        )
    );
    DiscreteLaplaceDistribution internal ldf;
    Uniswapper internal swapper;
    WETH internal weth;
    IPermit2 internal permit2;

    function setUp() public {
        vm.warp(443814060); // init block timestamp to reasonable value

        weth = new WETH();
        permit2 = _deployPermit2();
        MulticallerEtcher.multicallerWithSender();
        MulticallerEtcher.multicallerWithSigner();

        // initialize uniswap
        token0 = new ERC20Mock();
        token1 = new ERC20Mock();
        if (address(token0) >= address(token1)) {
            (token0, token1) = (token1, token0);
        }
        poolManager = new PoolManager(1e7);

        // deploy vaults
        vault0 = new ERC4626Mock(token0, "Vault0", "V0");
        vault1 = new ERC4626Mock(token1, "Vault1", "V1");
        vaultWeth = new ERC4626Mock(IERC20(address(weth)), "VaultWeth", "VWETH");

        // mint some initial tokens to the vaults to change the share price
        _mint(Currency.wrap(address(token0)), address(this), 1 ether);
        _mint(Currency.wrap(address(token1)), address(this), 1 ether);
        _mint(Currency.wrap(address(weth)), address(this), 1 ether);

        token0.approve(address(vault0), type(uint256).max);
        vault0.deposit(1 ether, address(this));
        _mint(Currency.wrap(address(token0)), address(vault0), 1 ether);

        token1.approve(address(vault1), type(uint256).max);
        vault1.deposit(1 ether, address(this));
        _mint(Currency.wrap(address(token1)), address(vault1), 1 ether);

        weth.approve(address(vaultWeth), type(uint256).max);
        vaultWeth.deposit(1 ether, address(this));
        _mint(Currency.wrap(address(weth)), address(vaultWeth), 1 ether);

        // deploy swapper
        swapper = new Uniswapper(poolManager);

        // initialize bunni hub
        hub = new BunniHub(poolManager, weth, permit2);

        // initialize bunni hook
        deployCodeTo(
            "BunniHook.sol",
            abi.encode(poolManager, hub, address(this), HOOK_FEES_RECIPIENT, HOOK_SWAP_FEE),
            address(bunniHook)
        );
        vm.label(address(bunniHook), "BunniHook");

        // initialize LDF
        ldf = new DiscreteLaplaceDistribution();

        // approve tokens
        token0.approve(address(permit2), type(uint256).max);
        token0.approve(address(swapper), type(uint256).max);
        token1.approve(address(permit2), type(uint256).max);
        token1.approve(address(swapper), type(uint256).max);
        weth.approve(address(permit2), type(uint256).max);
        weth.approve(address(swapper), type(uint256).max);

        // permit2 approve tokens to hub
        permit2.approve(address(token0), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(token1), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(weth), address(hub), type(uint160).max, type(uint48).max);
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
        (uint256 beforeBalance0, uint256 beforeBalance1) =
            (currency0.balanceOf(address(this)), currency1.balanceOf(address(this)));
        (uint256 shares,, uint256 amount0, uint256 amount1) =
            _makeDeposit(key, depositAmount0, depositAmount1, address(this), snapLabel);
        uint256 actualDepositedAmount0 = beforeBalance0 + depositAmount0 - currency0.balanceOf(address(this));
        uint256 actualDepositedAmount1 = beforeBalance1 + depositAmount1 - currency1.balanceOf(address(this));

        // check return values
        assertEqDecimal(amount0, actualDepositedAmount0, DECIMALS);
        assertEqDecimal(amount1, actualDepositedAmount1, DECIMALS);
        assertEqDecimal(shares, bunniToken.balanceOf(address(this)), DECIMALS);
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
        (uint256 shares,, uint256 amount0, uint256 amount1) = _makeDeposit(key, depositAmount0, depositAmount1);

        // withdraw
        IBunniHub.WithdrawParams memory withdrawParams = IBunniHub.WithdrawParams({
            poolKey: key,
            recipient: address(this),
            shares: shares,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });
        IBunniHub hub_ = hub;
        (uint256 beforeBalance0, uint256 beforeBalance1) =
            (key.currency0.balanceOf(address(this)), key.currency1.balanceOf(address(this)));
        snapStart(snapLabel);
        (, uint256 withdrawAmount0, uint256 withdrawAmount1) = hub_.withdraw(withdrawParams);
        snapEnd();

        // check return values
        // withdraw amount less than original due to rounding
        assertApproxEqAbs(withdrawAmount0, amount0, 10, "withdrawAmount0 incorrect");
        assertApproxEqAbs(withdrawAmount1, amount1, 10, "withdrawAmount1 incorrect");

        // check token balances
        assertApproxEqAbs(
            key.currency0.balanceOf(address(this)) - beforeBalance0, withdrawAmount0, 10, "token0 balance incorrect"
        );
        assertApproxEqAbs(
            key.currency1.balanceOf(address(this)) - beforeBalance1, withdrawAmount1, 10, "token1 balance incorrect"
        );
        assertEqDecimal(bunniToken.balanceOf(address(this)), 0, DECIMALS, "didn't burn shares");
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
        uint256 value = key.currency0.isNative() ? inputAmount : 0;

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(3)
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
        uint256 inputAmount = PRECISION / 100;
        uint256 value = key.currency0.isNative() ? inputAmount : 0;

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(0)
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

        uint256 inputAmount = PRECISION * 2;
        uint256 value = key.currency0.isNative() ? inputAmount : 0;

        _mint(key.currency0, address(this), inputAmount);

        (, int24 currentTick,) = poolManager.getSlot0(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(-9)
        });

        _swap(key, params, value, snapLabel);

        (, currentTick,) = poolManager.getSlot0(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick - key.tickSpacing, "didn't cross one tick");

        // ensure only current tick has liquidity
        _assertNoNeighboringLiquidity({
            id: key.toId(),
            currentTick: currentTick,
            startTick: -2 * key.tickSpacing,
            endTick: 2 * key.tickSpacing,
            tickSpacing: key.tickSpacing
        });
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
        uint256 value = key.currency0.isNative() ? inputAmount : 0;

        _mint(key.currency0, address(this), inputAmount);

        (, int24 currentTick,) = poolManager.getSlot0(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(-19)
        });

        _swap(key, params, value, snapLabel);

        (, currentTick,) = poolManager.getSlot0(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick - key.tickSpacing * 2, "didn't cross two ticks");

        // ensure only current tick has liquidity
        _assertNoNeighboringLiquidity({
            id: key.toId(),
            currentTick: currentTick,
            startTick: -2 * key.tickSpacing,
            endTick: 2 * key.tickSpacing,
            tickSpacing: key.tickSpacing
        });
    }

    function test_swap_zeroForOne_boundaryCondition() public {
        _execTestAcrossScenarios(_test_swap_zeroForOne_boundaryCondition, 0, 0, "swap zeroForOne boundaryCondition");
    }

    function _test_swap_zeroForOne_boundaryCondition(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        // when swapping from token0 to token1, it's possible for the updated tick to exceed the tick
        // specified by sqrtPriceLimitX96, so we need to handle this edge case properly by adding
        // liquidity to the actual rounded tick

        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        uint256 inputAmount = PRECISION * 20;
        uint256 value = key.currency0.isNative() ? inputAmount : 0;

        _mint(key.currency0, address(this), inputAmount);

        (, int24 currentTick,) = poolManager.getSlot0(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(-10) // limit tick is -10 but we'll end up at -11
        });

        _swap(key, params, value, snapLabel);

        (, currentTick,) = poolManager.getSlot0(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick - key.tickSpacing * 2, "didn't cross two ticks");

        // ensure only current tick has liquidity
        _assertNoNeighboringLiquidity({
            id: key.toId(),
            currentTick: currentTick,
            startTick: -2 * key.tickSpacing,
            endTick: 2 * key.tickSpacing,
            tickSpacing: key.tickSpacing
        });
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
        uint256 value = key.currency1.isNative() ? inputAmount : 0;

        _mint(key.currency1, address(this), inputAmount);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(9)
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
        uint256 inputAmount = PRECISION / 100;
        uint256 value = key.currency1.isNative() ? inputAmount : 0;

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(9)
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
        uint256 value = key.currency1.isNative() ? inputAmount : 0;

        _mint(key.currency1, address(this), inputAmount);

        (, int24 currentTick,) = poolManager.getSlot0(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(19)
        });

        _swap(key, params, value, snapLabel);

        (, currentTick,) = poolManager.getSlot0(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick + key.tickSpacing, "didn't cross one tick");

        // ensure only current tick has liquidity
        _assertNoNeighboringLiquidity({
            id: key.toId(),
            currentTick: currentTick,
            startTick: -2 * key.tickSpacing,
            endTick: 2 * key.tickSpacing,
            tickSpacing: key.tickSpacing
        });
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
        uint256 value = key.currency1.isNative() ? inputAmount : 0;

        _mint(key.currency1, address(this), inputAmount);

        (, int24 currentTick,) = poolManager.getSlot0(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(29)
        });

        _swap(key, params, value, snapLabel);

        (, currentTick,) = poolManager.getSlot0(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick + key.tickSpacing * 2, "didn't cross two ticks");

        // ensure only current tick has liquidity
        _assertNoNeighboringLiquidity({
            id: key.toId(),
            currentTick: currentTick,
            startTick: -2 * key.tickSpacing,
            endTick: 2 * key.tickSpacing,
            tickSpacing: key.tickSpacing
        });
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
        // create new bunni token with 0 compound threshold
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            vault0_,
            vault1_,
            bytes32(abi.encodePacked(ALPHA)),
            bytes32(abi.encodePacked(uint8(0), FEE_MIN, FEE_MAX, FEE_QUADRATIC_MULTIPLIER, FEE_TWAP_SECONDS_AGO))
        );

        uint256 inputAmount = PRECISION * 100;
        IPoolManager.SwapParams memory paramsZeroToOne = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(-9)
        });
        IPoolManager.SwapParams memory paramsOneToZero = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(9)
        });

        // make swaps to accumulate fees
        uint256 numSwaps = 10;
        for (uint256 i; i < numSwaps; i++) {
            // zero to one swap
            _mint(key.currency0, address(this), inputAmount);
            uint256 value = key.currency0.isNative() ? inputAmount : 0;
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
            value = key.currency1.isNative() ? inputAmount : 0;
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

        uint256 fee0 = poolManager.balanceOf(address(bunniHook), key.currency0);
        uint256 fee1 = poolManager.balanceOf(address(bunniHook), key.currency1);
        assertGt(fee0, 0, "protocol fee0 not accrued");
        assertGt(fee1, 0, "protocol fee1 not accrued");

        // collect fees
        Currency[] memory currencies = new Currency[](2);
        currencies[0] = key.currency0;
        currencies[1] = key.currency1;
        snapStart(string.concat("collect protocol fees", snapLabel));
        poolManager.lock(address(bunniHook), abi.encode(currencies));
        snapEnd();

        // check balances
        assertEq(key.currency0.balanceOf(HOOK_FEES_RECIPIENT), fee0, "protocol fee0 not collected");
        assertEq(key.currency1.balanceOf(HOOK_FEES_RECIPIENT), fee1, "protocol fee1 not collected");
    }

    function test_clearPoolCredits() public {
        _execTestAcrossScenarios(_test_clearPoolCredits, 0, 0, "clear pool credits");
    }

    function _test_clearPoolCredits(
        uint256,
        uint256,
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        string memory snapLabel
    ) internal {
        if (address(vault0_) == address(0) && address(vault1_) == address(0)) {
            return;
        }
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_);

        // swap and cross one tick
        if (address(vault0_) == address(0)) {
            // one to zero swap
            uint256 inputAmount = PRECISION * 2;
            uint256 value = key.currency1.isNative() ? inputAmount : 0;
            _mint(key.currency1, address(this), inputAmount);
            IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
                zeroForOne: false,
                amountSpecified: int256(inputAmount),
                sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(19)
            });
            _swap(key, params, value, "");
        } else {
            // zero to one swap
            uint256 inputAmount = PRECISION * 2;
            uint256 value = key.currency0.isNative() ? inputAmount : 0;
            _mint(key.currency0, address(this), inputAmount);
            IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
                zeroForOne: true,
                amountSpecified: int256(inputAmount),
                sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(-9)
            });
            _swap(key, params, value, "");
        }

        uint256 poolCredit0 = hub.poolCredit0(key.toId());
        uint256 poolCredit1 = hub.poolCredit1(key.toId());
        if (poolCredit0 == 0 && poolCredit1 == 0) {
            return;
        }

        // clear pool credits
        PoolKey[] memory keys = new PoolKey[](1);
        keys[0] = key;
        (uint256 beforeVault0Balance, uint256 beforeVault1Balance) =
            (_vaultBalanceOf(vault0_, address(hub)), _vaultBalanceOf(vault1_, address(hub)));
        snapStart(snapLabel);
        hub.clearPoolCredits(keys);
        snapEnd();
        (uint256 vault0BalanceIncrease, uint256 vault1BalanceIncrease) = (
            _vaultBalanceOf(vault0_, address(hub)) - beforeVault0Balance,
            _vaultBalanceOf(vault1_, address(hub)) - beforeVault1Balance
        );

        // check balances
        if (address(vault0_) != address(0)) {
            assertEq(poolManager.balanceOf(address(hub), key.currency0), 0, "pool credit0 not cleared");
            assertApproxEqRelDecimal(
                _vaultPreviewRedeem(vault0_, vault0BalanceIncrease),
                poolCredit0,
                100,
                18,
                "didn't increase vault0 reserves"
            );
        }
        if (address(vault1_) != address(0)) {
            assertEq(poolManager.balanceOf(address(hub), key.currency1), 0, "pool credit1 not cleared");
            assertApproxEqRelDecimal(
                _vaultPreviewRedeem(vault1_, vault1BalanceIncrease),
                poolCredit1,
                100,
                18,
                "didn't increase vault1 reserves"
            );
        }
    }

    function test_multicall() external {
        Currency currency0 = CurrencyLibrary.NATIVE;
        Currency currency1 = Currency.wrap(address(token0));
        (, PoolKey memory key) =
            _deployPoolAndInitLiquidity(currency0, currency1, ERC4626(address(0)), ERC4626(address(0)));

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
                refundETHRecipient: address(this)
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
                refundETHRecipient: address(this)
            })
        );

        uint256[] memory values = new uint256[](2);
        values[0] = 1 ether;
        values[1] = 2 ether;

        (uint256 beforeBalance0, uint256 beforeBalance1) =
            (currency0.balanceOf(address(this)), currency1.balanceOf(address(this)));
        bytes[] memory results = MulticallerWithSender(payable(LibMulticaller.MULTICALLER_WITH_SENDER))
            .aggregateWithSender{value: 3 ether}(targets, data, values);
        (,, uint256 amount0Call0, uint256 amount1Call0) = abi.decode(results[0], (uint256, uint128, uint256, uint256));
        (,, uint256 amount0Call1, uint256 amount1Call1) = abi.decode(results[1], (uint256, uint128, uint256, uint256));

        // tokens taken should match sum of returned values
        assertEq(
            beforeBalance0 - currency0.balanceOf(address(this)),
            amount0Call0 + amount0Call1,
            "amount0Call0 + amount0Call1 != amount taken"
        );
        assertEq(
            beforeBalance1 - currency1.balanceOf(address(this)),
            amount1Call0 + amount1Call1,
            "amount1Call0 + amount1Call1 != amount taken"
        );

        // hub should have 0 ETH balance
        assertEq(address(hub).balance, 0, "hub ETH balance not 0");

        // hub should have 0 token0 balance
        assertEq(token0.balanceOf(address(hub)), 0, "hub token0 balance not 0");
    }

    function test_hookHasInsufficientTokens() external {
        MockLDF ldf_ = new MockLDF();

        // set mu to be far to the left of rounded tick 0
        // so that the pool will have mostly token1
        ldf_.setMu(-100);

        // deploy pool and init liquidity
        Currency currency0 = CurrencyLibrary.NATIVE;
        Currency currency1 = Currency.wrap(address(token0));
        (, PoolKey memory key) =
            _deployPoolAndInitLiquidity(currency0, currency1, ERC4626(address(0)), ERC4626(address(0)), ldf_);

        // set mu to rounded tick 0
        // so that the pool has less token0 than the LDF suggests
        ldf_.setMu(0);

        // make a big swap from token1 to token0
        // such that the pool has insufficient tokens to output
        uint256 inputAmount = 100 * PRECISION;
        _mint(key.currency1, address(this), inputAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(100)
        });
        _swap(key, params, 0, "");
    }

    function test_shiftMode_enforceLeft_noRightShift() external {
        MockLDF ldf_ = new MockLDF();

        Currency currency0 = CurrencyLibrary.NATIVE;
        Currency currency1 = Currency.wrap(address(token0));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
            bytes32(abi.encodePacked(ALPHA, ShiftMode.LEFT)),
            bytes32(abi.encodePacked(uint8(100), FEE_MIN, FEE_MAX, FEE_QUADRATIC_MULTIPLIER, FEE_TWAP_SECONDS_AGO))
        );

        // shift mu to the right
        ldf_.setMu(10);

        // perform swap
        uint128 beforeLiquidity = poolManager.getLiquidity(key.toId());
        uint256 inputAmount = PRECISION;
        _mint(key.currency1, address(this), inputAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(9)
        });
        _swap(key, params, 0, "");

        // check that mu has not actually shifted
        assertEq(poolManager.getLiquidity(key.toId()), beforeLiquidity, "mu did shift");
    }

    function test_shiftMode_enforceLeft_allowLeftShift() external {
        MockLDF ldf_ = new MockLDF();

        Currency currency0 = CurrencyLibrary.NATIVE;
        Currency currency1 = Currency.wrap(address(token0));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
            bytes32(abi.encodePacked(ALPHA, ShiftMode.LEFT)),
            bytes32(abi.encodePacked(uint8(100), FEE_MIN, FEE_MAX, FEE_QUADRATIC_MULTIPLIER, FEE_TWAP_SECONDS_AGO))
        );

        // shift mu to the left
        ldf_.setMu(-10);

        // perform swap
        uint128 beforeLiquidity = poolManager.getLiquidity(key.toId());
        uint256 inputAmount = PRECISION;
        _mint(key.currency1, address(this), inputAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(9)
        });
        _swap(key, params, 0, "");

        // check that mu has actually shifted
        assertTrue(poolManager.getLiquidity(key.toId()) != beforeLiquidity, "mu did not shift");
    }

    function test_shiftMode_enforceRight_noLeftShift() external {
        MockLDF ldf_ = new MockLDF();

        Currency currency0 = CurrencyLibrary.NATIVE;
        Currency currency1 = Currency.wrap(address(token0));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
            bytes32(abi.encodePacked(ALPHA, ShiftMode.RIGHT)),
            bytes32(abi.encodePacked(uint8(100), FEE_MIN, FEE_MAX, FEE_QUADRATIC_MULTIPLIER, FEE_TWAP_SECONDS_AGO))
        );

        // shift mu to the left
        ldf_.setMu(-10);

        // perform swap
        uint128 beforeLiquidity = poolManager.getLiquidity(key.toId());
        uint256 inputAmount = PRECISION;
        _mint(key.currency1, address(this), inputAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(9)
        });
        _swap(key, params, 0, "");

        // check that mu has not actually shifted
        assertEq(poolManager.getLiquidity(key.toId()), beforeLiquidity, "mu did shift");
    }

    function test_shiftMode_enforceRight_allowRightShift() external {
        MockLDF ldf_ = new MockLDF();

        Currency currency0 = CurrencyLibrary.NATIVE;
        Currency currency1 = Currency.wrap(address(token0));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
            bytes32(abi.encodePacked(ALPHA, ShiftMode.RIGHT)),
            bytes32(abi.encodePacked(uint8(100), FEE_MIN, FEE_MAX, FEE_QUADRATIC_MULTIPLIER, FEE_TWAP_SECONDS_AGO))
        );

        // shift mu to the right
        ldf_.setMu(10);

        // perform swap
        uint128 beforeLiquidity = poolManager.getLiquidity(key.toId());
        uint256 inputAmount = PRECISION;
        _mint(key.currency1, address(this), inputAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(9)
        });
        _swap(key, params, 0, "");

        // check that mu has actually shifted
        assertTrue(poolManager.getLiquidity(key.toId()) != beforeLiquidity, "mu did not shift");
    }

    function test_shiftMode_both_allowLeftShift() external {
        MockLDF ldf_ = new MockLDF();

        Currency currency0 = CurrencyLibrary.NATIVE;
        Currency currency1 = Currency.wrap(address(token0));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
            bytes32(abi.encodePacked(ALPHA, ShiftMode.BOTH)),
            bytes32(abi.encodePacked(uint8(100), FEE_MIN, FEE_MAX, FEE_QUADRATIC_MULTIPLIER, FEE_TWAP_SECONDS_AGO))
        );

        // shift mu to the left
        ldf_.setMu(-10);

        // perform swap
        uint128 beforeLiquidity = poolManager.getLiquidity(key.toId());
        uint256 inputAmount = PRECISION;
        _mint(key.currency1, address(this), inputAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(9)
        });
        _swap(key, params, 0, "");

        // check that mu has actually shifted
        assertTrue(poolManager.getLiquidity(key.toId()) != beforeLiquidity, "mu did not shift");
    }

    function test_shiftMode_both_allowRightShift() external {
        MockLDF ldf_ = new MockLDF();

        Currency currency0 = CurrencyLibrary.NATIVE;
        Currency currency1 = Currency.wrap(address(token0));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
            bytes32(abi.encodePacked(ALPHA, ShiftMode.BOTH)),
            bytes32(abi.encodePacked(uint8(100), FEE_MIN, FEE_MAX, FEE_QUADRATIC_MULTIPLIER, FEE_TWAP_SECONDS_AGO))
        );

        // shift mu to the right
        ldf_.setMu(10);

        // perform swap
        uint128 beforeLiquidity = poolManager.getLiquidity(key.toId());
        uint256 inputAmount = PRECISION;
        _mint(key.currency1, address(this), inputAmount);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(9)
        });
        _swap(key, params, 0, "");

        // check that mu has actually shifted
        assertTrue(poolManager.getLiquidity(key.toId()) != beforeLiquidity, "mu did not shift");
    }

    function _makeDeposit(PoolKey memory key, uint256 depositAmount0, uint256 depositAmount1)
        internal
        returns (uint256 shares, uint128 newLiquidity, uint256 amount0, uint256 amount1)
    {
        return _makeDeposit(key, depositAmount0, depositAmount1, address(this), "");
    }

    function _makeDeposit(
        PoolKey memory key_,
        uint256 depositAmount0,
        uint256 depositAmount1,
        address depositor,
        string memory snapLabel
    ) internal returns (uint256 shares, uint128 newLiquidity, uint256 amount0, uint256 amount1) {
        // mint tokens
        uint256 value;
        if (key_.currency0.isNative()) {
            value = depositAmount0;
        } else if (key_.currency1.isNative()) {
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
            refundETHRecipient: depositor
        });
        IBunniHub hub_ = hub;
        vm.startPrank(depositor);
        if (bytes(snapLabel).length > 0) {
            snapStart(snapLabel);
        }
        (shares, newLiquidity, amount0, amount1) = hub_.deposit{value: value}(depositParams);
        if (bytes(snapLabel).length > 0) {
            snapEnd();
        }
        vm.stopPrank();
    }

    function _decodeHookFee(uint8 fee, bool zeroForOne) internal pure returns (uint8) {
        return zeroForOne ? (fee % 16) : (fee >> 4);
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
        if (currency.isNative()) {
            vm.deal(to, to.balance + amount);
        } else if (Currency.unwrap(currency) == address(weth)) {
            vm.deal(address(this), address(this).balance + amount);
            weth.deposit{value: amount}();
            weth.transfer(to, amount);
        } else {
            ERC20Mock(Currency.unwrap(currency)).mint(to, amount);
        }
    }

    function _deployPoolAndInitLiquidity(Currency currency0, Currency currency1, ERC4626 vault0_, ERC4626 vault1_)
        internal
        returns (IBunniToken bunniToken, PoolKey memory key)
    {
        return _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            vault0_,
            vault1_,
            ldf,
            bytes32(abi.encodePacked(ALPHA)),
            bytes32(abi.encodePacked(uint8(100), FEE_MIN, FEE_MAX, FEE_QUADRATIC_MULTIPLIER, FEE_TWAP_SECONDS_AGO))
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
            bytes32(abi.encodePacked(ALPHA)),
            bytes32(abi.encodePacked(uint8(100), FEE_MIN, FEE_MAX, FEE_QUADRATIC_MULTIPLIER, FEE_TWAP_SECONDS_AGO))
        );
    }

    function _deployPoolAndInitLiquidity(
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        bytes32 ldfParams,
        bytes32 hookParams
    ) internal returns (IBunniToken bunniToken, PoolKey memory key) {
        return _deployPoolAndInitLiquidity(currency0, currency1, vault0_, vault1_, ldf, ldfParams, hookParams);
    }

    function _deployPoolAndInitLiquidity(
        Currency currency0,
        Currency currency1,
        ERC4626 vault0_,
        ERC4626 vault1_,
        ILiquidityDensityFunction ldf_,
        bytes32 ldfParams,
        bytes32 hookParams
    ) internal returns (IBunniToken bunniToken, PoolKey memory key) {
        // initialize bunni
        (bunniToken, key) = hub.deployBunniToken(
            IBunniHub.DeployBunniTokenParams({
                currency0: currency0,
                currency1: currency1,
                tickSpacing: TICK_SPACING,
                twapSecondsAgo: 1 hours,
                liquidityDensityFunction: ldf_,
                statefulLdf: true,
                ldfParams: ldfParams,
                hooks: bunniHook,
                hookParams: hookParams,
                vault0: vault0_,
                vault1: vault1_,
                sqrtPriceX96: TickMath.getSqrtRatioAtTick(4),
                cardinalityNext: 100
            })
        );

        // make initial deposit to avoid accounting for MIN_INITIAL_SHARES
        uint256 depositAmount0 = PRECISION;
        uint256 depositAmount1 = PRECISION;
        vm.startPrank(address(0x6969));
        token0.approve(address(permit2), type(uint256).max);
        token1.approve(address(permit2), type(uint256).max);
        permit2.approve(address(token0), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(token1), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(weth), address(hub), type(uint160).max, type(uint48).max);
        vm.stopPrank();
        _makeDeposit(key, depositAmount0, depositAmount1, address(0x6969), "");
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
            CurrencyLibrary.NATIVE,
            Currency.wrap(address(token1)),
            ERC4626(address(0)),
            ERC4626(address(0)),
            string.concat(label, ", token0 yes native no vault, token1 no native no vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            CurrencyLibrary.NATIVE,
            Currency.wrap(address(token1)),
            ERC4626(address(0)),
            vault1,
            string.concat(label, ", token0 yes native no vault, token1 no native yes vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            CurrencyLibrary.NATIVE,
            Currency.wrap(address(token1)),
            vaultWeth,
            ERC4626(address(0)),
            string.concat(label, ", token0 yes native yes vault, token1 no native no vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            CurrencyLibrary.NATIVE,
            Currency.wrap(address(token1)),
            vaultWeth,
            vault1,
            string.concat(label, ", token0 yes native yes vault, token1 no native yes vault")
        );
        vm.revertTo(snapshotId);
    }

    receive() external payable {}

    function _swap(PoolKey memory key, IPoolManager.SwapParams memory params, uint256 value, string memory snapLabel)
        internal
    {
        Uniswapper swapper_ = swapper;
        bytes memory data = abi.encode(key, params);
        if (bytes(snapLabel).length > 0) {
            snapStart(snapLabel);
            poolManager.lock{value: value}(address(swapper_), data);
            snapEnd();
        } else {
            poolManager.lock{value: value}(address(swapper_), data);
        }
    }

    function _assertNoNeighboringLiquidity(
        PoolId id,
        int24 currentTick,
        int24 startTick,
        int24 endTick,
        int24 tickSpacing
    ) internal {
        uint128 liquidity;
        currentTick = roundTickSingle(currentTick, tickSpacing);
        for (int24 tick = startTick; tick <= endTick; tick += tickSpacing) {
            liquidity = poolManager.getLiquidity(id, address(hub), tick, tick + tickSpacing);
            if (tick == currentTick) {
                assertGt(liquidity, 0, "current tick has zero liquidity");
            } else {
                assertEq(liquidity, 0, "neighboring tick has non-zero liquidity");
            }
        }
    }
}
