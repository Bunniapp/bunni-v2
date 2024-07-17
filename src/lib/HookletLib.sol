// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {CustomRevert} from "@uniswap/v4-core/src/libraries/CustomRevert.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "../base/Constants.sol";
import {IHooklet} from "../interfaces/IHooklet.sol";
import {IBunniHub} from "../interfaces/IBunniHub.sol";

/// @dev Adapted from Uniswap v4's Hooks.sol
library HookletLib {
    using CustomRevert for bytes4;
    using HookletLib for IHooklet;
    using FixedPointMathLib for *;

    uint160 internal constant ALL_FLAGS_MASK = 0x3FF;
    uint160 internal constant BEFORE_INITIALIZE_FLAG = 1 << 9;
    uint160 internal constant AFTER_INITIALIZE_FLAG = 1 << 8;
    uint160 internal constant BEFORE_DEPOSIT_FLAG = 1 << 7;
    uint160 internal constant AFTER_DEPOSIT_FLAG = 1 << 6;
    uint160 internal constant BEFORE_WITHDRAW_FLAG = 1 << 5;
    uint160 internal constant AFTER_WITHDRAW_FLAG = 1 << 4;
    uint160 internal constant BEFORE_SWAP_FLAG = 1 << 3;
    uint160 internal constant BEFORE_SWAP_OVERRIDE_FEE_FLAG = 1 << 2;
    uint160 internal constant BEFORE_SWAP_OVERRIDE_PRICE_FLAG = 1 << 1;
    uint160 internal constant AFTER_SWAP_FLAG = 1;

    error HookletLib__FailedHookletCall();
    error HookletLib__InvalidHookletResponse();

    function callHooklet(IHooklet self, bytes4 selector, bytes memory data) internal returns (bytes memory result) {
        bytes4 decodedSelector;
        assembly ("memory-safe") {
            if iszero(call(gas(), self, 0, add(data, 0x20), mload(data), 0, 0)) {
                if iszero(returndatasize()) {
                    // if the call failed without a revert reason, revert with `HookletLib__FailedHookletCall()`
                    mstore(0, 0x855e32e7)
                    revert(0x1c, 0x04)
                }
                // bubble up revert
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
            // allocate result byte array from the free memory pointer
            result := mload(0x40)
            // store new free memory pointer at the end of the array padded to 32 bytes
            mstore(0x40, add(result, and(add(returndatasize(), 0x3f), not(0x1f))))
            // store length in memory
            mstore(result, returndatasize())
            // copy return data to result
            returndatacopy(add(result, 0x20), 0, returndatasize())
            // get the selector from the return data
            decodedSelector := mload(add(result, 0x20))
        }
        if (decodedSelector != selector) HookletLib__InvalidHookletResponse.selector.revertWith();
    }

    function staticcallHooklet(IHooklet self, bytes4 selector, bytes memory data)
        internal
        view
        returns (bytes memory result)
    {
        bytes4 decodedSelector;
        assembly ("memory-safe") {
            if iszero(staticcall(gas(), self, add(data, 0x20), mload(data), 0, 0)) {
                if iszero(returndatasize()) {
                    // if the call failed without a revert reason, revert with `HookletLib__FailedHookletCall()`
                    mstore(0, 0x855e32e7)
                    revert(0x1c, 0x04)
                }
                // bubble up revert
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
            // allocate result byte array from the free memory pointer
            result := mload(0x40)
            // store new free memory pointer at the end of the array padded to 32 bytes
            mstore(0x40, add(result, and(add(returndatasize(), 0x3f), not(0x1f))))
            // store length in memory
            mstore(result, returndatasize())
            // copy return data to result
            returndatacopy(add(result, 0x20), 0, returndatasize())
            // get the selector from the return data
            decodedSelector := mload(add(result, 0x20))
        }
        if (decodedSelector != selector) HookletLib__InvalidHookletResponse.selector.revertWith();
    }

    modifier noSelfCall(IHooklet self, address sender) {
        if (sender != address(self)) {
            _;
        }
    }

    function hookletBeforeInitialize(IHooklet self, address sender, IBunniHub.DeployBunniTokenParams calldata params)
        internal
        noSelfCall(self, sender)
    {
        if (self.hasPermission(BEFORE_INITIALIZE_FLAG)) {
            self.callHooklet(
                IHooklet.beforeInitialize.selector, abi.encodeCall(IHooklet.beforeInitialize, (sender, params))
            );
        }
    }

    function hookletAfterInitialize(
        IHooklet self,
        address sender,
        IBunniHub.DeployBunniTokenParams calldata params,
        IHooklet.InitializeReturnData memory returnData
    ) internal noSelfCall(self, sender) {
        if (self.hasPermission(AFTER_INITIALIZE_FLAG)) {
            self.callHooklet(
                IHooklet.afterInitialize.selector,
                abi.encodeCall(IHooklet.afterInitialize, (sender, params, returnData))
            );
        }
    }

    function hookletBeforeDeposit(IHooklet self, address sender, IBunniHub.DepositParams calldata params)
        internal
        noSelfCall(self, sender)
    {
        if (self.hasPermission(BEFORE_DEPOSIT_FLAG)) {
            self.callHooklet(IHooklet.beforeDeposit.selector, abi.encodeCall(IHooklet.beforeDeposit, (sender, params)));
        }
    }

    function hookletAfterDeposit(
        IHooklet self,
        address sender,
        IBunniHub.DepositParams calldata params,
        IHooklet.DepositReturnData memory returnData
    ) internal noSelfCall(self, sender) {
        if (self.hasPermission(AFTER_DEPOSIT_FLAG)) {
            self.callHooklet(
                IHooklet.afterDeposit.selector, abi.encodeCall(IHooklet.afterDeposit, (sender, params, returnData))
            );
        }
    }

    function hookletBeforeWithdraw(IHooklet self, address sender, IBunniHub.WithdrawParams calldata params)
        internal
        noSelfCall(self, sender)
    {
        if (self.hasPermission(BEFORE_WITHDRAW_FLAG)) {
            self.callHooklet(
                IHooklet.beforeWithdraw.selector, abi.encodeCall(IHooklet.beforeWithdraw, (sender, params))
            );
        }
    }

    function hookletAfterWithdraw(
        IHooklet self,
        address sender,
        IBunniHub.WithdrawParams calldata params,
        IHooklet.WithdrawReturnData memory returnData
    ) internal noSelfCall(self, sender) {
        if (self.hasPermission(AFTER_WITHDRAW_FLAG)) {
            self.callHooklet(
                IHooklet.afterWithdraw.selector, abi.encodeCall(IHooklet.afterWithdraw, (sender, params, returnData))
            );
        }
    }

    function hookletBeforeSwap(
        IHooklet self,
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params
    )
        internal
        noSelfCall(self, sender)
        returns (bool feeOverridden, uint24 fee, bool priceOverridden, uint160 sqrtPriceX96)
    {
        if (self.hasPermission(BEFORE_SWAP_FLAG)) {
            bytes memory result = self.callHooklet(
                IHooklet.beforeSwap.selector, abi.encodeCall(IHooklet.beforeSwap, (sender, key, params))
            );
            (bool canOverrideFee, bool canOverridePrice) =
                (self.hasPermission(BEFORE_SWAP_OVERRIDE_FEE_FLAG), self.hasPermission(BEFORE_SWAP_OVERRIDE_PRICE_FLAG));
            if (canOverrideFee || canOverridePrice) {
                // parse override data
                // equivalent to the following Solidity code:
                // (,feeOverridden, fee, priceOverridden, sqrtPriceX96) = abi.decode(result, (bytes4, bool, uint24, bool, uint160));
                /// @solidity memory-safe-assembly
                assembly {
                    feeOverridden := mload(add(result, 0x40))
                    fee := mload(add(result, 0x60))
                    priceOverridden := mload(add(result, 0x80))
                    sqrtPriceX96 := mload(add(result, 0xA0))
                }

                // ensure that the hooklet is allowed to override the fee and/or price
                // if the hooklet doesn't have a permission but the override is set, the override is ignored
                feeOverridden = canOverrideFee && feeOverridden;
                priceOverridden = canOverridePrice && priceOverridden;

                // clamp the override values to the valid range
                fee = feeOverridden ? uint24(fee.clamp(0, SWAP_FEE_BASE)) : 0;
                sqrtPriceX96 =
                    priceOverridden ? uint160(sqrtPriceX96.clamp(TickMath.MIN_SQRT_PRICE, TickMath.MAX_SQRT_PRICE)) : 0;
            }
        }
    }

    function hookletBeforeSwapView(
        IHooklet self,
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params
    )
        internal
        view
        noSelfCall(self, sender)
        returns (bool feeOverridden, uint24 fee, bool priceOverridden, uint160 sqrtPriceX96)
    {
        if (
            self.hasPermission(BEFORE_SWAP_FLAG)
                && (
                    self.hasPermission(BEFORE_SWAP_OVERRIDE_FEE_FLAG) || self.hasPermission(BEFORE_SWAP_OVERRIDE_PRICE_FLAG)
                )
        ) {
            bytes memory result = self.staticcallHooklet(
                IHooklet.beforeSwapView.selector, abi.encodeCall(IHooklet.beforeSwapView, (sender, key, params))
            );
            (bool canOverrideFee, bool canOverridePrice) =
                (self.hasPermission(BEFORE_SWAP_OVERRIDE_FEE_FLAG), self.hasPermission(BEFORE_SWAP_OVERRIDE_PRICE_FLAG));

            // parse override data
            // equivalent to the following Solidity code:
            // (,feeOverridden, fee, priceOverridden, sqrtPriceX96) = abi.decode(result, (bytes4, bool, uint24, bool, uint160));
            /// @solidity memory-safe-assembly
            assembly {
                feeOverridden := mload(add(result, 0x40))
                fee := mload(add(result, 0x60))
                priceOverridden := mload(add(result, 0x80))
                sqrtPriceX96 := mload(add(result, 0xA0))
            }

            // ensure that the hooklet is allowed to override the fee and/or price
            // if the hooklet doesn't have a permission but the override is set, the override is ignored
            feeOverridden = canOverrideFee && feeOverridden;
            priceOverridden = canOverridePrice && priceOverridden;

            // clamp the override values to the valid range
            fee = feeOverridden ? uint24(fee.clamp(0, SWAP_FEE_BASE)) : 0;
            sqrtPriceX96 =
                priceOverridden ? uint160(sqrtPriceX96.clamp(TickMath.MIN_SQRT_PRICE, TickMath.MAX_SQRT_PRICE)) : 0;
        }
    }

    /// @dev The hasPermission check is done outside of this function in order to avoid unnecessarily constructing returnData
    /// when calling it.
    function hookletAfterSwap(
        IHooklet self,
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        IHooklet.SwapReturnData memory returnData
    ) internal noSelfCall(self, sender) {
        self.callHooklet(
            IHooklet.afterSwap.selector, abi.encodeCall(IHooklet.afterSwap, (sender, key, params, returnData))
        );
    }

    function hasPermission(IHooklet self, uint160 flag) internal pure returns (bool) {
        return uint160(address(self)) & flag != 0;
    }
}
