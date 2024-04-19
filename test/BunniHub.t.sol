// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {GasSnapshot} from "forge-gas-snapshot/GasSnapshot.sol";

import {IFloodPlain} from "flood-contracts/src/interfaces/IFloodPlain.sol";

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

import {WETH} from "solady/tokens/WETH.sol";
import {ERC4626} from "solady/tokens/ERC4626.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "../src/lib/Math.sol";
import "../src/lib/Structs.sol";
import "../src/ldf/ShiftMode.sol";
import {MockLDF} from "./mocks/MockLDF.sol";
import {BunniHub} from "../src/BunniHub.sol";
import {BunniHook} from "../src/BunniHook.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {BunniToken} from "../src/BunniToken.sol";
import {Uniswapper} from "./mocks/Uniswapper.sol";
import {ERC4626Mock} from "./mocks/ERC4626Mock.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {ERC20TaxMock} from "./mocks/ERC20TaxMock.sol";
import {UniswapperTax} from "./mocks/UniswapperTax.sol";
import {FloodDeployer} from "./utils/FloodDeployer.sol";
import {IBunniHub} from "../src/interfaces/IBunniHub.sol";
import {Permit2Deployer} from "./utils/Permit2Deployer.sol";
import {BunniQuoter} from "../src/periphery/BunniQuoter.sol";
import {IBunniToken} from "../src/interfaces/IBunniToken.sol";
import {ERC4626WithFeeMock} from "./mocks/ERC4626WithFeeMock.sol";
import {GeometricDistribution} from "../src/ldf/GeometricDistribution.sol";
import {DoubleGeometricDistribution} from "../src/ldf/DoubleGeometricDistribution.sol";
import {ILiquidityDensityFunction} from "../src/interfaces/ILiquidityDensityFunction.sol";

contract BunniHubTest is Test, GasSnapshot, Permit2Deployer, FloodDeployer {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using FixedPointMathLib for uint256;

    uint256 internal constant PRECISION = 10 ** 18;
    uint8 internal constant DECIMALS = 18;
    int24 internal constant TICK_SPACING = 10;
    uint96 internal constant HOOK_SWAP_FEE = 0.1e18;
    uint32 internal constant ALPHA = 0.7e8;
    uint256 internal constant MAX_ERROR = 1e9;
    uint24 internal constant FEE_MIN = 0.0001e6;
    uint24 internal constant FEE_MAX = 0.1e6;
    uint24 internal constant FEE_QUADRATIC_MULTIPLIER = 0.5e6;
    uint24 internal constant FEE_TWAP_SECONDS_AGO = 30 minutes;
    address internal constant HOOK_FEES_RECIPIENT = address(0xfee);
    uint24 internal constant TWAP_SECONDS_AGO = 7 days;
    uint24 internal constant SURGE_FEE = 0.5e6;
    uint16 internal constant SURGE_HALFLIFE = 2 minutes;
    uint16 internal constant SURGE_AUTOSTART_TIME = 5 minutes;
    uint16 internal constant VAULT_SURGE_THRESHOLD_0 = 1e4; // 0.01% change in share price
    uint16 internal constant VAULT_SURGE_THRESHOLD_1 = 1e3; // 0.1% change in share price
    uint256 internal constant TOKEN_TAX = 0.05e18;
    uint256 internal constant VAULT_FEE = 0.03e18;

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
    BunniHook internal constant bunniHook = BunniHook(
        payable(
            address(
                uint160(
                    Hooks.AFTER_INITIALIZE_FLAG + Hooks.BEFORE_ADD_LIQUIDITY_FLAG + Hooks.BEFORE_SWAP_FLAG
                        + Hooks.ACCESS_LOCK_FLAG + Hooks.NO_OP_FLAG
                )
            )
        )
    );
    BunniQuoter internal quoter;
    ILiquidityDensityFunction internal ldf;
    Uniswapper internal swapper;
    UniswapperTax internal swapperWithTax;
    WETH internal weth;
    IPermit2 internal permit2;
    ERC20TaxMock internal tokenWithTax;
    IFloodPlain internal floodPlain;

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
        tokenWithTax = new ERC20TaxMock();
        poolManager = new PoolManager(1e7);

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
        swapperWithTax = new UniswapperTax(poolManager);

        // initialize bunni hub
        hub = new BunniHub(poolManager, weth, permit2, new BunniToken());

        // initialize bunni hook
        deployCodeTo(
            "BunniHook.sol",
            abi.encode(poolManager, hub, floodPlain, weth, address(this), HOOK_FEES_RECIPIENT, HOOK_SWAP_FEE),
            address(bunniHook)
        );
        vm.label(address(bunniHook), "BunniHook");

        // deploy quoter
        quoter = new BunniQuoter(hub);

        // initialize LDF
        ldf = new GeometricDistribution();

        // approve tokens
        token0.approve(address(permit2), type(uint256).max);
        token0.approve(address(swapper), type(uint256).max);
        token1.approve(address(permit2), type(uint256).max);
        token1.approve(address(swapper), type(uint256).max);
        weth.approve(address(permit2), type(uint256).max);
        weth.approve(address(swapper), type(uint256).max);
        tokenWithTax.approve(address(permit2), type(uint256).max);
        tokenWithTax.approve(address(swapperWithTax), type(uint256).max);

        // permit2 approve tokens to hub
        permit2.approve(address(token0), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(token1), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(weth), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(tokenWithTax), address(hub), type(uint160).max, type(uint48).max);
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
        (uint256 shares, uint256 amount0, uint256 amount1) =
            _makeDeposit(key, depositAmount0, depositAmount1, address(this), snapLabel);
        uint256 actualDepositedAmount0 = beforeBalance0 + depositAmount0 - currency0.balanceOf(address(this));
        uint256 actualDepositedAmount1 = beforeBalance1 + depositAmount1 - currency1.balanceOf(address(this));

        // check return values
        assertEqDecimal(amount0, actualDepositedAmount0, DECIMALS, "amount0 incorrect");
        assertEqDecimal(amount1, actualDepositedAmount1, DECIMALS, "amount1 incorrect");
        assertEqDecimal(shares, bunniToken.balanceOf(address(this)), DECIMALS, "shares incorrect");
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
        (uint256 shares, uint256 amount0, uint256 amount1) = _makeDepositWithTax({
            key_: key,
            depositAmount0: depositAmount0,
            depositAmount1: depositAmount1,
            depositor: address(this),
            tax0: 0,
            tax1: 0,
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
            deadline: block.timestamp
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

    function test_tokenWithTax_withdraw(uint256 depositAmount0, uint256 depositAmount1) public {
        depositAmount0 = bound(depositAmount0, 1e6, type(uint64).max);
        depositAmount1 = bound(depositAmount1, 1e6, type(uint64).max);
        (Currency currency0, Currency currency1) =
            (Currency.wrap(address(token0)), Currency.wrap(address(tokenWithTax)));
        if (currency0 > currency1) (currency0, currency1) = (currency1, currency0);
        (IBunniToken bunniToken, PoolKey memory key) =
            _deployPoolAndInitLiquidity(currency0, currency1, ERC4626(address(0)), ERC4626(address(0)));

        // make deposit
        (uint256 shares, uint256 amount0, uint256 amount1) = _makeDepositWithTax({
            key_: key,
            depositAmount0: depositAmount0,
            depositAmount1: depositAmount1,
            depositor: address(this),
            tax0: 0,
            tax1: TOKEN_TAX,
            vaultFee0: 0,
            vaultFee1: 0,
            snapLabel: ""
        });

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
        (uint256 withdrawAmount0, uint256 withdrawAmount1) = hub_.withdraw(withdrawParams);

        uint256 maxError = 100;

        if (Currency.unwrap(currency0) == address(tokenWithTax)) {
            uint256 amount0PostTax = amount0 * tokenWithTax.TAX_MULTIPLIER() / 100;
            assertApproxEqAbs(withdrawAmount0, amount0, maxError, "withdrawAmount0 incorrect (tax token)");
            assertApproxEqAbs(
                key.currency0.balanceOf(address(this)) - beforeBalance0,
                amount0PostTax,
                maxError,
                "token0 balance incorrect (tax token)"
            );
        } else {
            assertApproxEqAbs(withdrawAmount0, amount0, maxError, "withdrawAmount0 incorrect (not tax token)");
            assertApproxEqAbs(
                key.currency0.balanceOf(address(this)) - beforeBalance0,
                withdrawAmount0,
                maxError,
                "token0 balance incorrect (not tax token)"
            );
        }

        if (Currency.unwrap(currency1) == address(tokenWithTax)) {
            uint256 amount1PostTax = amount1 * tokenWithTax.TAX_MULTIPLIER() / 100;
            assertApproxEqAbs(withdrawAmount1, amount1, maxError, "withdrawAmount1 incorrect (tax token)");
            assertApproxEqAbs(
                key.currency1.balanceOf(address(this)) - beforeBalance1,
                amount1PostTax,
                maxError,
                "token1 balance incorrect (tax token)"
            );
        } else {
            assertApproxEqAbs(withdrawAmount1, amount1, maxError, "withdrawAmount1 incorrect (not tax token)");
            assertApproxEqAbs(
                key.currency1.balanceOf(address(this)) - beforeBalance1,
                withdrawAmount1,
                maxError,
                "token1 balance incorrect (not tax token)"
            );
        }

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
        uint256 inputAmount = PRECISION / 1000;
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
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            currency0,
            currency1,
            vault0_,
            vault1_,
            new GeometricDistribution(),
            bytes32(abi.encodePacked(int24(-3), int16(6), uint32(5e7), uint8(0))),
            bytes32(
                abi.encodePacked(
                    FEE_MIN,
                    FEE_MAX,
                    FEE_QUADRATIC_MULTIPLIER,
                    FEE_TWAP_SECONDS_AGO,
                    SURGE_FEE,
                    SURGE_HALFLIFE,
                    SURGE_AUTOSTART_TIME,
                    VAULT_SURGE_THRESHOLD_0,
                    VAULT_SURGE_THRESHOLD_1
                )
            )
        );

        uint256 inputAmount = 0.15e18;
        uint256 value = key.currency0.isNative() ? inputAmount : 0;

        _mint(key.currency0, address(this), inputAmount);

        (, int24 currentTick,,) = bunniHook.slot0s(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(-9)
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
        uint256 value = key.currency0.isNative() ? inputAmount : 0;

        _mint(key.currency0, address(this), inputAmount);

        (, int24 currentTick,,) = bunniHook.slot0s(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(-19)
        });

        _swap(key, params, value, snapLabel);

        (, currentTick,,) = bunniHook.slot0s(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick - key.tickSpacing * 2, "didn't cross two ticks");
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
        uint256 inputAmount = PRECISION / 1000;
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

        (, int24 currentTick,,) = bunniHook.slot0s(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(19)
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
        uint256 value = key.currency1.isNative() ? inputAmount : 0;

        _mint(key.currency1, address(this), inputAmount);

        (, int24 currentTick,,) = bunniHook.slot0s(key.toId());
        int24 beforeRoundedTick = roundTickSingle(currentTick, key.tickSpacing);

        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: false,
            amountSpecified: int256(inputAmount),
            sqrtPriceLimitX96: TickMath.getSqrtRatioAtTick(29)
        });

        _swap(key, params, value, snapLabel);

        (, currentTick,,) = bunniHook.slot0s(key.toId());
        int24 afterRoundedTick = roundTickSingle(currentTick, key.tickSpacing);
        assertEq(afterRoundedTick, beforeRoundedTick + key.tickSpacing * 2, "didn't cross two ticks");
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

        uint256 fee0 = poolManager.balanceOf(address(bunniHook), key.currency0.toId());
        uint256 fee1 = poolManager.balanceOf(address(bunniHook), key.currency1.toId());
        assertGt(fee0, 0, "protocol fee0 not accrued");
        assertGt(fee1, 0, "protocol fee1 not accrued");

        // collect fees
        Currency[] memory currencies = new Currency[](2);
        currencies[0] = key.currency0;
        currencies[1] = key.currency1;
        snapStart(string.concat("collect protocol fees", snapLabel));
        poolManager.lock(address(bunniHook), abi.encode(HookLockCallbackType.CLAIM_FEES, abi.encode(currencies)));
        snapEnd();

        // check balances
        assertEq(key.currency0.balanceOf(HOOK_FEES_RECIPIENT), fee0, "protocol fee0 not collected");
        assertEq(key.currency1.balanceOf(HOOK_FEES_RECIPIENT), fee1, "protocol fee1 not collected");
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
                refundRecipient: address(this),
                tax0: 0,
                tax1: 0,
                vaultFee0: 0,
                vaultFee1: 0
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
                tax0: 0,
                tax1: 0,
                vaultFee0: 0,
                vaultFee1: 0
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

    function test_hookHasInsufficientTokens() external {
        MockLDF ldf_ = new MockLDF();

        // set mu to be far to the left of rounded tick 0
        // so that the pool will have mostly token1
        ldf_.setMinTick(-100);

        // deploy pool and init liquidity
        Currency currency0 = CurrencyLibrary.NATIVE;
        Currency currency1 = Currency.wrap(address(token0));
        (, PoolKey memory key) =
            _deployPoolAndInitLiquidity(currency0, currency1, ERC4626(address(0)), ERC4626(address(0)), ldf_);

        // set mu to rounded tick 0
        // so that the pool has less token0 than the LDF suggests
        ldf_.setMinTick(0);

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

    function test_fuzz_swapZeroAmountDoesNothing(
        bool zeroForOne,
        bool useVault0,
        bool useVault1,
        uint32 alpha,
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier
    ) external {
        feeMin = uint24(bound(feeMin, 2e5, 1e6 - 1));
        feeMax = uint24(bound(feeMax, feeMin, 1e6 - 1));
        alpha = uint32(bound(alpha, 1e3, 12e8));

        GeometricDistribution ldf_ = new GeometricDistribution();
        bytes32 ldfParams = bytes32(abi.encodePacked(int24(-3), int16(6), alpha, uint8(0)));
        vm.assume(ldf_.isValidParams(TICK_SPACING, TWAP_SECONDS_AGO, ldfParams));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            ldf_,
            ldfParams,
            bytes32(
                abi.encodePacked(
                    feeMin,
                    feeMax,
                    feeQuadraticMultiplier,
                    FEE_TWAP_SECONDS_AGO,
                    SURGE_FEE,
                    SURGE_HALFLIFE,
                    SURGE_AUTOSTART_TIME,
                    VAULT_SURGE_THRESHOLD_0,
                    VAULT_SURGE_THRESHOLD_1
                )
            )
        );

        // execute swap with zero amount
        (Currency inputToken, Currency outputToken) =
            zeroForOne ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: int256(0),
            sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
        });
        uint256 inputAmount;
        uint256 outputAmount;
        (uint160 sqrtPriceX96, int24 tick,,) = bunniHook.slot0s(key.toId());
        {
            uint256 beforeInputTokenBalance = inputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = outputToken.balanceOfSelf();
            _swap(key, params, 0, "");
            inputAmount = beforeInputTokenBalance - inputToken.balanceOfSelf();
            outputAmount = outputToken.balanceOfSelf() - beforeOutputTokenBalance;
        }

        assertEq(inputAmount, 0, "input amount not 0");
        assertEq(outputAmount, 0, "output amount not 0");

        (uint160 afterSqrtPriceX96, int24 afterTick,,) = bunniHook.slot0s(key.toId());
        assertEq(afterSqrtPriceX96, sqrtPriceX96, "sqrtPriceX96 changed");
        assertEq(afterTick, tick, "tick changed");
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
        bytes32 ldfParams = bytes32(abi.encodePacked(int24(-3), int16(6), alpha, uint8(0)));
        vm.assume(ldf_.isValidParams(TICK_SPACING, TWAP_SECONDS_AGO, ldfParams));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            ldf_,
            ldfParams,
            bytes32(
                abi.encodePacked(
                    feeMin,
                    feeMax,
                    feeQuadraticMultiplier,
                    FEE_TWAP_SECONDS_AGO,
                    SURGE_FEE,
                    SURGE_HALFLIFE,
                    SURGE_AUTOSTART_TIME,
                    VAULT_SURGE_THRESHOLD_0,
                    VAULT_SURGE_THRESHOLD_1
                )
            )
        );

        // execute first swap
        (Currency firstSwapInputToken, Currency firstSwapOutputToken) =
            zeroForOneFirstSwap ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        _mint(firstSwapInputToken, address(this), swapAmount * 2);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOneFirstSwap,
            amountSpecified: int256(swapAmount),
            sqrtPriceLimitX96: zeroForOneFirstSwap ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
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
            amountSpecified: int256(firstSwapOutputAmount),
            sqrtPriceLimitX96: !zeroForOneFirstSwap ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
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
        swapAmount = bound(swapAmount, 1e6, 1e36);
        waitTime = bound(waitTime, 10, SURGE_AUTOSTART_TIME * 6);
        feeMin = uint24(bound(feeMin, 2e5, 1e6 - 1));
        feeMax = uint24(bound(feeMax, feeMin, 1e6 - 1));
        alpha = uint32(bound(alpha, 1e3, 12e8));

        GeometricDistribution ldf_ = new GeometricDistribution();
        bytes32 ldfParams = bytes32(abi.encodePacked(int24(-3), int16(6), alpha, uint8(0)));
        vm.assume(ldf_.isValidParams(TICK_SPACING, TWAP_SECONDS_AGO, ldfParams));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            ldf_,
            ldfParams,
            bytes32(
                abi.encodePacked(
                    feeMin,
                    feeMax,
                    feeQuadraticMultiplier,
                    FEE_TWAP_SECONDS_AGO,
                    SURGE_FEE,
                    SURGE_HALFLIFE,
                    SURGE_AUTOSTART_TIME,
                    VAULT_SURGE_THRESHOLD_0,
                    VAULT_SURGE_THRESHOLD_1
                )
            )
        );

        // execute first swap
        (Currency firstSwapInputToken, Currency firstSwapOutputToken) =
            zeroForOneFirstSwap ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOneFirstSwap,
            amountSpecified: -int256(swapAmount),
            sqrtPriceLimitX96: zeroForOneFirstSwap ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
        });
        (,,, uint256 firstSwapInputAmount, uint256 firstSwapOutputAmount,,) = quoter.quoteSwap(key, params);
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
            amountSpecified: int256(firstSwapOutputAmount),
            sqrtPriceLimitX96: !zeroForOneFirstSwap ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
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
        bytes32 ldfParams = bytes32(abi.encodePacked(int24(-3), int16(6), alpha, uint8(0)));
        vm.assume(ldf_.isValidParams(TICK_SPACING, TWAP_SECONDS_AGO, ldfParams));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            ldf_,
            ldfParams,
            bytes32(
                abi.encodePacked(
                    feeMin,
                    feeMax,
                    feeQuadraticMultiplier,
                    FEE_TWAP_SECONDS_AGO,
                    SURGE_FEE,
                    SURGE_HALFLIFE,
                    SURGE_AUTOSTART_TIME,
                    VAULT_SURGE_THRESHOLD_0,
                    VAULT_SURGE_THRESHOLD_1
                )
            )
        );

        // execute first swap
        (Currency firstSwapInputToken, Currency firstSwapOutputToken) =
            zeroForOneFirstSwap ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        _mint(firstSwapInputToken, address(this), swapAmount * 2);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOneFirstSwap,
            amountSpecified: int256(swapAmount),
            sqrtPriceLimitX96: zeroForOneFirstSwap ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
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
            amountSpecified: int256(firstSwapOutputAmount),
            sqrtPriceLimitX96: !zeroForOneFirstSwap ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
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
        params = IPoolManager.SwapParams({
            zeroForOne: zeroForOneFirstSwap,
            amountSpecified: int256(secondSwapOutputAmount),
            sqrtPriceLimitX96: zeroForOneFirstSwap ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
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
        params = IPoolManager.SwapParams({
            zeroForOne: !zeroForOneFirstSwap,
            amountSpecified: int256(thirdSwapOutputAmount),
            sqrtPriceLimitX96: !zeroForOneFirstSwap ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
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

    function test_tokenWithTax_fuzz_swapNoArb_exactIn(
        uint256 swapAmount,
        bool zeroForOneFirstSwap,
        bool useVault0,
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
        bytes32 ldfParams = bytes32(abi.encodePacked(int24(-3), int16(6), alpha, uint8(0)));
        vm.assume(ldf_.isValidParams(TICK_SPACING, TWAP_SECONDS_AGO, ldfParams));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(tokenWithTax)),
            useVault0 ? vault0 : ERC4626(address(0)),
            ERC4626(address(0)),
            ldf_,
            ldfParams,
            bytes32(
                abi.encodePacked(
                    feeMin,
                    feeMax,
                    feeQuadraticMultiplier,
                    FEE_TWAP_SECONDS_AGO,
                    SURGE_FEE,
                    SURGE_HALFLIFE,
                    SURGE_AUTOSTART_TIME,
                    VAULT_SURGE_THRESHOLD_0,
                    VAULT_SURGE_THRESHOLD_1
                )
            )
        );

        // execute first swap
        (Currency firstSwapInputToken, Currency firstSwapOutputToken) =
            zeroForOneFirstSwap ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        _mint(firstSwapInputToken, address(this), swapAmount * 2);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOneFirstSwap,
            amountSpecified: int256(
                Currency.unwrap(firstSwapInputToken) == address(tokenWithTax)
                    ? swapAmount * tokenWithTax.TAX_MULTIPLIER() / 100
                    : swapAmount
            ),
            sqrtPriceLimitX96: zeroForOneFirstSwap ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
        });
        uint256 firstSwapInputAmount;
        uint256 firstSwapOutputAmount;
        {
            uint256 beforeInputTokenBalance = firstSwapInputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = firstSwapOutputToken.balanceOfSelf();
            if (Currency.unwrap(firstSwapInputToken) == address(tokenWithTax)) {
                bytes memory data = abi.encode(key, params, type(uint256).max, 0, TOKEN_TAX);
                poolManager.lock(address(swapperWithTax), data);
            } else {
                _swap(key, params, 0, "");
            }
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
            amountSpecified: int256(
                int256(
                    Currency.unwrap(firstSwapOutputToken) == address(tokenWithTax)
                        ? firstSwapOutputAmount * tokenWithTax.TAX_MULTIPLIER() / 100
                        : firstSwapOutputAmount
                )
            ),
            sqrtPriceLimitX96: !zeroForOneFirstSwap ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
        });
        uint256 secondSwapInputAmount;
        uint256 secondSwapOutputAmount;
        {
            uint256 beforeInputTokenBalance = firstSwapOutputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = firstSwapInputToken.balanceOfSelf();
            if (Currency.unwrap(firstSwapOutputToken) == address(tokenWithTax)) {
                bytes memory data = abi.encode(key, params, type(uint256).max, 0, TOKEN_TAX);
                poolManager.lock(address(swapperWithTax), data);
            } else {
                _swap(key, params, 0, "");
            }
            secondSwapInputAmount = beforeInputTokenBalance - firstSwapOutputToken.balanceOfSelf();
            secondSwapOutputAmount = firstSwapInputToken.balanceOfSelf() - beforeOutputTokenBalance;
        }

        console2.log("secondSwapInputAmount", secondSwapInputAmount);
        console2.log("secondSwapOutputAmount", secondSwapOutputAmount);

        // verify no profits
        assertLeDecimal(secondSwapOutputAmount, firstSwapInputAmount, 18, "arb has profit");
    }

    function test_fuzz_quoter_quoteSwap(
        uint256 swapAmount,
        bool zeroForOne,
        bool useVault0,
        bool useVault1,
        uint32 alpha,
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier
    ) external {
        swapAmount = bound(swapAmount, 1e6, 1e36);
        feeMin = uint24(bound(feeMin, 2e5, 1e6 - 1));
        feeMax = uint24(bound(feeMax, feeMin, 1e6 - 1));
        alpha = uint32(bound(alpha, 1e3, 12e8));

        GeometricDistribution ldf_ = new GeometricDistribution();
        bytes32 ldfParams = bytes32(abi.encodePacked(int24(-3), int16(6), alpha, uint8(0)));
        vm.assume(ldf_.isValidParams(TICK_SPACING, TWAP_SECONDS_AGO, ldfParams));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            ldf_,
            ldfParams,
            bytes32(
                abi.encodePacked(
                    feeMin,
                    feeMax,
                    feeQuadraticMultiplier,
                    FEE_TWAP_SECONDS_AGO,
                    SURGE_FEE,
                    SURGE_HALFLIFE,
                    SURGE_AUTOSTART_TIME,
                    VAULT_SURGE_THRESHOLD_0,
                    VAULT_SURGE_THRESHOLD_1
                )
            )
        );

        (Currency inputToken, Currency outputToken) =
            zeroForOne ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        _mint(inputToken, address(this), swapAmount * 2);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: int256(swapAmount),
            sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1
        });

        // quote swap
        (bool success,,, uint256 inputAmount, uint256 outputAmount,,) = quoter.quoteSwap(key, params);
        assertTrue(success, "quoteSwap failed");

        // execute swap
        uint256 actualInputAmount;
        uint256 actualOutputAmount;
        {
            uint256 beforeInputTokenBalance = inputToken.balanceOfSelf();
            uint256 beforeOutputTokenBalance = outputToken.balanceOfSelf();
            bytes memory data = abi.encode(key, params, type(uint256).max, 0);
            poolManager.lock(address(swapper), data);
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
        bytes32 ldfParams = bytes32(abi.encodePacked(int24(-3), int16(6), alpha, uint8(0)));
        vm.assume(ldf_.isValidParams(TICK_SPACING, TWAP_SECONDS_AGO, ldfParams));
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            useVault0 ? vault0 : ERC4626(address(0)),
            useVault1 ? vault1 : ERC4626(address(0)),
            ldf_,
            ldfParams,
            bytes32(
                abi.encodePacked(
                    feeMin,
                    feeMax,
                    feeQuadraticMultiplier,
                    FEE_TWAP_SECONDS_AGO,
                    SURGE_FEE,
                    SURGE_HALFLIFE,
                    SURGE_AUTOSTART_TIME,
                    VAULT_SURGE_THRESHOLD_0,
                    VAULT_SURGE_THRESHOLD_1
                )
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
            tax0: 0,
            tax1: 0,
            vaultFee0: 0,
            vaultFee1: 0
        });
        (uint256 shares, uint256 amount0, uint256 amount1) = quoter.quoteDeposit(depositParams);

        // deposit tokens
        (uint256 actualShares, uint256 actualAmount0, uint256 actualAmount1) =
            _makeDeposit(key, depositAmount0, depositAmount1, address(this), "");

        // check if actual amounts match quoted amounts
        assertApproxEqRel(actualShares, shares, 1e12, "actual shares doesn't match quoted shares");
        assertEq(actualAmount0, amount0, "actual amount0 doesn't match quoted amount0");
        assertEq(actualAmount1, amount1, "actual amount1 doesn't match quoted amount1");
    }

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
            refundRecipient: depositor,
            tax0: 0,
            tax1: 0,
            vaultFee0: 0,
            vaultFee1: 0
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

    function _makeDepositWithTax(
        PoolKey memory key_,
        uint256 depositAmount0,
        uint256 depositAmount1,
        address depositor,
        uint256 tax0,
        uint256 tax1,
        uint256 vaultFee0,
        uint256 vaultFee1,
        string memory snapLabel
    ) internal returns (uint256 shares, uint256 amount0, uint256 amount1) {
        // mint tokens
        uint256 value;
        if (key_.currency0.isNative()) {
            value = depositAmount0.divWadUp(WAD - vaultFee0);
        } else if (key_.currency1.isNative()) {
            value = depositAmount1.divWadUp(WAD - vaultFee1);
        }
        _mint(key_.currency0, depositor, depositAmount0.divWadUp(WAD - tax0).divWadUp(WAD - vaultFee0));
        _mint(key_.currency1, depositor, depositAmount1.divWadUp(WAD - tax1).divWadUp(WAD - vaultFee1));

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
            tax0: tax0,
            tax1: tax1,
            vaultFee0: vaultFee0,
            vaultFee1: vaultFee1
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
            bytes32(abi.encodePacked(int24(-3), int16(6), ALPHA, ShiftMode.BOTH)),
            bytes32(
                abi.encodePacked(
                    FEE_MIN,
                    FEE_MAX,
                    FEE_QUADRATIC_MULTIPLIER,
                    FEE_TWAP_SECONDS_AGO,
                    SURGE_FEE,
                    SURGE_HALFLIFE,
                    SURGE_AUTOSTART_TIME,
                    VAULT_SURGE_THRESHOLD_0,
                    VAULT_SURGE_THRESHOLD_1
                )
            )
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
            bytes32(abi.encodePacked(int24(-3), int16(6), ALPHA, ShiftMode.BOTH)),
            bytes32(
                abi.encodePacked(
                    FEE_MIN,
                    FEE_MAX,
                    FEE_QUADRATIC_MULTIPLIER,
                    FEE_TWAP_SECONDS_AGO,
                    SURGE_FEE,
                    SURGE_HALFLIFE,
                    SURGE_AUTOSTART_TIME,
                    VAULT_SURGE_THRESHOLD_0,
                    VAULT_SURGE_THRESHOLD_1
                )
            )
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
                twapSecondsAgo: TWAP_SECONDS_AGO,
                liquidityDensityFunction: ldf_,
                statefulLdf: true,
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
        weth.approve(address(permit2), type(uint256).max);
        tokenWithTax.approve(address(permit2), type(uint256).max);
        permit2.approve(address(token0), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(token1), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(weth), address(hub), type(uint160).max, type(uint48).max);
        permit2.approve(address(tokenWithTax), address(hub), type(uint160).max, type(uint48).max);
        vm.stopPrank();
        uint256 tax0 = Currency.unwrap(currency0) == address(tokenWithTax) ? TOKEN_TAX : 0;
        uint256 tax1 = Currency.unwrap(currency1) == address(tokenWithTax) ? TOKEN_TAX : 0;
        uint256 vaultFee0 = address(vault0_) == address(vault0WithFee) || address(vault0_) == address(vault1WithFee)
            || address(vault0_) == address(vaultWethWithFee) ? VAULT_FEE : 0;
        uint256 vaultFee1 = address(vault1_) == address(vault0WithFee) || address(vault1_) == address(vault1WithFee)
            || address(vault1_) == address(vaultWethWithFee) ? VAULT_FEE : 0;
        _makeDepositWithTax(key, depositAmount0, depositAmount1, address(0x6969), tax0, tax1, vaultFee0, vaultFee1, "");
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
            CurrencyLibrary.NATIVE,
            Currency.wrap(address(token1)),
            vaultWethWithFee,
            ERC4626(address(0)),
            string.concat(label, ", token0 yes native yes vault with fee, token1 no native no vault")
        );
        vm.revertTo(snapshotId);

        fn(
            depositAmount0,
            depositAmount1,
            CurrencyLibrary.NATIVE,
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
        bytes memory data = abi.encode(key, params, type(uint256).max, 0);
        if (bytes(snapLabel).length > 0) {
            snapStart(snapLabel);
            poolManager.lock{value: value}(address(swapper_), data);
            snapEnd();
        } else {
            poolManager.lock{value: value}(address(swapper_), data);
        }
    }
}
