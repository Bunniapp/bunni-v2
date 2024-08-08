// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

uint256 constant WAD = 1e18;
uint256 constant Q96 = 0x1000000000000000000000000;
uint256 constant MAX_NONCE = 1e6;
uint256 constant MIN_INITIAL_SHARES = 1e3;
uint256 constant MAX_SWAP_FEE_RATIO = 2.88e20; // max ratio that avoids overflow in swap fee calculation, roughly sqrt(SWAP_FEE_BASE) * sqrt(sqrt((type(uint256).max - SWAP_FEE_BASE) / type(uint24).max) - 1)
uint256 constant SWAP_FEE_BASE = 1e6;
uint256 constant SWAP_FEE_BASE_SQUARED = 1e12;
uint256 constant RAW_TOKEN_RATIO_BASE = 1e6;
uint256 constant LN2_WAD = 693147180559945309;
uint256 constant MAX_VAULT_FEE_ERROR = 1e6;
uint256 constant MAX_CARDINALITY = 2 ** 24 - 1;
uint56 constant WITHDRAW_DELAY = 1 minutes;
uint56 constant WITHDRAW_GRACE_PERIOD = 15 minutes;
uint256 constant REFERRAL_REWARD_PER_TOKEN_PRECISION = 1e30;
uint256 constant MODIFIER_BASE = 1e6;

/// @dev The max referrer value.
uint24 constant MAX_REFERRER = 0x7fffff;
