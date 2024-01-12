// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";

import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";

library AdditionalCurrencyLibrary {
    using SafeCastLib for uint256;
    using CurrencyLibrary for Currency;

    error NativeTransferToNotThis();
    error MsgValueInsufficient();

    function safeTransferFrom(Currency currency, address from, address to, uint256 amount) internal {
        if (currency.isNative()) {
            if (to != address(this)) revert NativeTransferToNotThis();
            if (amount > msg.value) revert MsgValueInsufficient();
        } else {
            SafeTransferLib.safeTransferFrom(Currency.unwrap(currency), from, to, amount);
        }
    }

    function safeTransferFromPermit2(Currency currency, address from, address to, uint256 amount, IPermit2 permit2)
        internal
    {
        if (currency.isNative()) {
            if (to != address(this)) revert NativeTransferToNotThis();
            if (amount > msg.value) revert MsgValueInsufficient();
        } else {
            permit2.transferFrom(from, to, amount.toUint160(), Currency.unwrap(currency));
        }
    }

    function safeApprove(Currency currency, address spender, uint256 amount) internal {
        if (!currency.isNative()) {
            SafeTransferLib.safeApprove(Currency.unwrap(currency), spender, amount);
        }
    }
}
