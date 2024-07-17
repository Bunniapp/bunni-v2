// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.0;

import "../../src/interfaces/IHooklet.sol";

contract HookletMock is IHooklet {
    bool public feeOverridden;
    uint24 public fee;
    bool public priceOverridden;
    uint160 public sqrtPriceX96;

    function beforeInitialize(address, /* sender */ IBunniHub.DeployBunniTokenParams calldata /* params */ )
        external
        pure
        returns (bytes4 selector)
    {
        return IHooklet.beforeInitialize.selector;
    }

    function afterInitialize(
        address, /* sender */
        IBunniHub.DeployBunniTokenParams calldata, /* params */
        InitializeReturnData calldata /* returnData */
    ) external pure returns (bytes4 selector) {
        return IHooklet.afterInitialize.selector;
    }

    function beforeDeposit(address, /* sender */ IBunniHub.DepositParams calldata /* params */ )
        external
        pure
        returns (bytes4 selector)
    {
        return IHooklet.beforeDeposit.selector;
    }

    function afterDeposit(
        address, /* sender */
        IBunniHub.DepositParams calldata, /* params */
        DepositReturnData calldata /* returnData */
    ) external pure returns (bytes4 selector) {
        return IHooklet.afterDeposit.selector;
    }

    function beforeWithdraw(address, /* sender */ IBunniHub.WithdrawParams calldata /* params */ )
        external
        pure
        returns (bytes4 selector)
    {
        return IHooklet.beforeWithdraw.selector;
    }

    function afterWithdraw(
        address, /* sender */
        IBunniHub.WithdrawParams calldata, /* params */
        WithdrawReturnData calldata /* returnData */
    ) external pure returns (bytes4 selector) {
        return IHooklet.afterWithdraw.selector;
    }

    function beforeSwap(
        address, /* sender */
        PoolKey calldata, /* key */
        IPoolManager.SwapParams calldata /* params */
    )
        external
        view
        returns (bytes4 selector, bool feeOverriden_, uint24 fee_, bool priceOverridden_, uint160 sqrtPriceX96_)
    {
        return (IHooklet.beforeSwap.selector, feeOverridden, fee, priceOverridden, sqrtPriceX96);
    }

    function beforeSwapView(
        address, /* sender */
        PoolKey calldata, /* key */
        IPoolManager.SwapParams calldata /* params */
    )
        external
        view
        returns (bytes4 selector, bool feeOverriden_, uint24 fee_, bool priceOverridden_, uint160 sqrtPriceX96_)
    {
        return (IHooklet.beforeSwap.selector, feeOverridden, fee, priceOverridden, sqrtPriceX96);
    }

    function afterSwap(
        address, /* sender */
        PoolKey calldata, /* key */
        IPoolManager.SwapParams calldata, /* params */
        SwapReturnData calldata /* returnData */
    ) external pure returns (bytes4 selector) {
        return IHooklet.afterSwap.selector;
    }

    function setBeforeSwapOverride(bool feeOverridden_, uint24 fee_, bool priceOverridden_, uint160 sqrtPriceX96_)
        external
    {
        feeOverridden = feeOverridden_;
        fee = fee_;
        priceOverridden = priceOverridden_;
        sqrtPriceX96 = sqrtPriceX96_;
    }
}
