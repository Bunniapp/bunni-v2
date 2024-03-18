// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

uint256 constant WAD = 1e18;
uint256 constant Q96 = 0x1000000000000000000000000;
uint256 constant MAX_NONCE = 0x0FFFFF;
uint256 constant MIN_INITIAL_SHARES = 1e3;
uint256 constant MAX_SWAP_FEE_RATIO = 2.88e20; // max ratio that avoids overflow in swap fee calculation, roughly sqrt(SWAP_FEE_BASE) * sqrt(sqrt((type(uint256).max - SWAP_FEE_BASE) / type(uint24).max) - 1)
uint256 constant SWAP_FEE_BASE = 1e6;
uint256 constant SWAP_FEE_BASE_SQUARED = 1e12;
uint256 constant RAW_TOKEN_RATIO_BASE = 1e6;
uint256 constant LN2_WAD = 693147180559945309;
uint256 constant MAX_TAX_ERROR = 1e6;
