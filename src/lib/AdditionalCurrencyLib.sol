// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.20;

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";

library AdditionalCurrencyLibrary {
    using SafeCastLib for uint256;

    function safeTransferFromPermit2(Currency currency, IPermit2 permit2, address from, address to, uint256 amount)
        internal
    {
        permit2.transferFrom(from, to, amount.toUint160(), Currency.unwrap(currency));
    }
}
