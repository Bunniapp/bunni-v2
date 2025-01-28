// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

/// @dev Decodes the payload specified by the am-AMM manager.
/// Format:
/// | swapFee0For1 - 3 bytes | swapFee1For0 - 3 bytes |
/// @return swapFee0For1 The swap fee for token0 -> token1 swaps
/// @return swapFee1For0 The swap fee for token1 -> token0 swaps
function decodeAmAmmPayload(bytes6 payload) pure returns (uint24 swapFee0For1, uint24 swapFee1For0) {
    swapFee0For1 = uint24(bytes3(payload));
    swapFee1For0 = uint24(bytes3(payload << 24));
}
