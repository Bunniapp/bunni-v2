// SPDX-License-Identifier: AGPL-3.0

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

    function quoteDeposit(IBunniHub.DepositParams calldata params)
        external
        view
        returns (uint256 shares, uint256 amount0, uint256 amount1);

    function quoteWithdraw(IBunniHub.WithdrawParams calldata params)
        external
        view
        returns (uint256 amount0, uint256 amount1);
}
