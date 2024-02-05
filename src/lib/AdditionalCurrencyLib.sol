// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

library AdditionalCurrencyLibrary {
    using SafeCastLib for uint256;
    using SafeTransferLib for address;
    using CurrencyLibrary for Currency;

    error NativeTransferToNotThis();
    error MsgValueInsufficient();

    function safeTransferFromPermit2(
        Currency currency,
        address from,
        address to,
        uint256 amount,
        IPermit2 permit2,
        uint256 msgValue
    ) internal {
        if (currency.isNative()) {
            if (amount > msgValue) revert MsgValueInsufficient();
            if (to != address(this)) to.safeTransferETH(amount);
        } else {
            permit2.transferFrom(from, to, amount.toUint160(), Currency.unwrap(currency));
        }
    }
}
