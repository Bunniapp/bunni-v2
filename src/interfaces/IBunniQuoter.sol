// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;
pragma abicoder v2;

import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {IBunniHub} from "./IBunniHub.sol";

interface IBunniQuoter {
    function quoteSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata params)
        external
        view
        returns (
            bool success,
            uint160 updatedSqrtPriceX96,
            int24 updatedTick,
            uint256 inputAmount,
            uint256 outputAmount,
            uint24 swapFee,
            uint256 totalLiquidity
        );

    function quoteDeposit(address sender, IBunniHub.DepositParams calldata params)
        external
        view
        returns (bool success, uint256 shares, uint256 amount0, uint256 amount1);

    function quoteWithdraw(address sender, IBunniHub.WithdrawParams calldata params)
        external
        view
        returns (bool success, uint256 amount0, uint256 amount1);

    function getTotalLiquidity(PoolKey calldata key) external view returns (uint256 totalLiquidity);

    function getExcessLiquidity(PoolKey calldata key)
        external
        view
        returns (
            uint256 totalLiquidity,
            uint256 idleBalance,
            bool willRebalanceToken0,
            bool shouldRebalance,
            uint256 thresholdBalance,
            uint256 inputAmount,
            uint256 outputAmount
        );
}
