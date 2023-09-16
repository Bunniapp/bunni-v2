// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import {Currency} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";

import {BunniHook} from "../src/BunniHook.sol";
import {BunniHub} from "../src/BunniHub.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {IBunniHub, BunniTokenState, ShiftMode} from "../src/interfaces/IBunniHub.sol";
import {IBunniToken} from "../src/interfaces/IBunniToken.sol";

contract BunniHubTest is Test {
    uint256 internal constant PRECISION = 10 ** 18;
    uint8 internal constant DECIMALS = 18;
    int24 internal constant TICK_SPACING = 10;
    uint256 internal constant MIN_INITIAL_SHARES = 1e3;

    IPoolManager internal poolManager;
    ERC20Mock internal token0;
    ERC20Mock internal token1;
    IBunniHub internal hub;
    IBunniToken internal bunniToken;
    BunniHook internal constant bunniHook = BunniHook(
        address(
            uint160(
                Hooks.AFTER_INITIALIZE_FLAG + Hooks.BEFORE_MODIFY_POSITION_FLAG + Hooks.BEFORE_SWAP_FLAG
                    + Hooks.AFTER_SWAP_FLAG
            )
        )
    );

    function setUp() public {
        // initialize uniswap
        token0 = new ERC20Mock();
        token1 = new ERC20Mock();
        if (address(token0) >= address(token1)) {
            (token0, token1) = (token1, token0);
        }
        poolManager = new PoolManager(1e7);

        // initialize bunni hub
        hub = new BunniHub(poolManager);

        // initialize bunni hook
        deployCodeTo("BunniHook.sol", abi.encode(poolManager, hub), address(bunniHook));

        // initialize bunni
        bunniToken = hub.deployBunniToken(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            TICK_SPACING,
            -100,
            100,
            ShiftMode.BOTH,
            3600,
            1 days,
            bunniHook,
            TickMath.getSqrtRatioAtTick(0)
        );

        // approve tokens
        token0.approve(address(hub), type(uint256).max);
        token0.approve(address(poolManager), type(uint256).max);
        token1.approve(address(hub), type(uint256).max);
        token1.approve(address(poolManager), type(uint256).max);

        // make initial deposit to avoid accounting for MIN_INITIAL_SHARES
        uint256 depositAmount0 = PRECISION;
        uint256 depositAmount1 = PRECISION;
        _makeDeposit(depositAmount0, depositAmount1, address(0x6969));
    }

    function test_deposit() public {
        // make deposit
        uint256 depositAmount0 = PRECISION;
        uint256 depositAmount1 = PRECISION;
        (uint256 shares, uint128 newLiquidity, uint256 amount0, uint256 amount1) =
            _makeDeposit(depositAmount0, depositAmount1);

        // check return values
        assertEqDecimal(shares, newLiquidity, DECIMALS);
        assertEqDecimal(amount0, depositAmount0, DECIMALS);
        assertEqDecimal(amount1, depositAmount1, DECIMALS);

        // check token balances
        assertEqDecimal(token0.balanceOf(address(this)), 0, DECIMALS);
        assertEqDecimal(token1.balanceOf(address(this)), 0, DECIMALS);
        assertEqDecimal(bunniToken.balanceOf(address(this)), shares, DECIMALS);
    }

    function test_withdraw() public {
        // make deposit
        uint256 depositAmount0 = PRECISION;
        uint256 depositAmount1 = PRECISION;
        (uint256 shares,,,) = _makeDeposit(depositAmount0, depositAmount1);

        // withdraw
        IBunniHub.WithdrawParams memory withdrawParams = IBunniHub.WithdrawParams({
            bunniToken: bunniToken,
            recipient: address(this),
            shares: shares,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp
        });
        (, uint256 withdrawAmount0, uint256 withdrawAmount1) = hub.withdraw(withdrawParams);

        // check return values
        // withdraw amount less than original due to rounding
        assertEqDecimal(withdrawAmount0, depositAmount0 - 1, DECIMALS, "withdrawAmount0 incorrect");
        assertEqDecimal(withdrawAmount1, depositAmount1 - 1, DECIMALS, "withdrawAmount1 incorrect");

        // check token balances
        assertEqDecimal(token0.balanceOf(address(this)), depositAmount0 - 1, DECIMALS, "token0 balance incorrect");
        assertEqDecimal(token1.balanceOf(address(this)), depositAmount1 - 1, DECIMALS, "token1 balance incorrect");
        assertEqDecimal(bunniToken.balanceOf(address(this)), 0, DECIMALS, "didn't burn shares");
    }

    /*function test_compound() public {
        // make deposit
        uint256 depositAmount0 = PRECISION;
        uint256 depositAmount1 = PRECISION;
        _makeDeposit(depositAmount0, depositAmount1);

        // do a few trades to generate fees
        {
            // swap token0 to token1
            uint256 amountIn = PRECISION / 100;
            token0.mint(address(this), amountIn);
            ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter.ExactInputSingleParams({
                tokenIn: address(token0),
                tokenOut: address(token1),
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            router.exactInputSingle(swapParams);
        }

        {
            // swap token1 to token0
            uint256 amountIn = PRECISION / 50;
            token1.mint(address(this), amountIn);
            ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter.ExactInputSingleParams({
                tokenIn: address(token1),
                tokenOut: address(token0),
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
            router.exactInputSingle(swapParams);
        }

        // compound
        uint256 beforeBalance0 = token0.balanceOf(address(this));
        uint256 beforeBalance1 = token1.balanceOf(address(this));
        vm.recordLogs();
        (uint256 addedLiquidity, uint256 amount0, uint256 amount1) = hub.compound(key);

        // check added liquidity
        assertGtDecimal(addedLiquidity, 0, DECIMALS);
        assertGtDecimal(amount0, 0, DECIMALS);
        assertGtDecimal(amount1, 0, DECIMALS);

        // check protocol fee
        // fetch protocol fee directly from logs
        (uint256 protocolFee0, uint256 protocolFee1) = abi.decode(vm.getRecordedLogs()[7].data, (uint256, uint256));
        assertEqDecimal(
            token0.balanceOf(address(hub)), protocolFee0, DECIMALS, "hub balance0 not equal to protocol fee"
        );
        assertEqDecimal(
            token1.balanceOf(address(hub)), protocolFee1, DECIMALS, "hub balance1 not equal to protocol fee"
        );

        // check token balances
        assertEqDecimal(token0.balanceOf(address(this)), beforeBalance0, DECIMALS, "sender balance0 changed");
        assertEqDecimal(token1.balanceOf(address(this)), beforeBalance1, DECIMALS, "sender balance1 changed");
    }

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
        token0.mint(address(this), depositAmount0);
        token1.mint(address(this), depositAmount1);

        // deposit tokens
        // max slippage is 1%
        IBunniHub.DepositParams memory depositParams = IBunniHub.DepositParams({
            bunniToken: bunniToken,
            amount0Desired: depositAmount0,
            amount1Desired: depositAmount1,
            amount0Min: (depositAmount0 * 99) / 100,
            amount1Min: (depositAmount1 * 99) / 100,
            deadline: block.timestamp,
            recipient: recipient
        });
        return hub.deposit(depositParams);
    }
}
