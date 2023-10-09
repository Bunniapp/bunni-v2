// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

function decodeLDFParams(bytes12 ldfParams)
    pure
    returns (bool useTwap, uint8 compoundThreshold, uint24 twapSecondsAgo, bytes11 params)
{
    useTwap = uint8(ldfParams[0] >> 7) == 1; // first bit flags if the LDF uses TWAP

    // Next 7 bits are the (inverse) compound threshold which is the
    // min relative difference between the computed current tick liquidity and actual liquidity
    // required for modifying the current tick liquidity before swap.
    // If set to 0, compound triggers before every swap.
    // Scaled by 0.1, so the threshold ranges from 1/1270 to 1/10.
    compoundThreshold = uint8(ldfParams[0] & 0x7F);

    if (useTwap) {
        // | twapSecondsAgo - 3 bytes | params - 8 bytes |
        twapSecondsAgo = uint24(bytes3(ldfParams << 8));
        params = bytes11(ldfParams << 32); // | params - 8 bytes | 0 - 3 bytes |
    } else {
        // 11 bytes for params
        params = bytes11(ldfParams << 8); // | params - 11 bytes |
    }
}
