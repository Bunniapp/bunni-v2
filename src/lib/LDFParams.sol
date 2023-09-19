// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

function decodeLDFParams(bytes12 ldfParams) pure returns (bool useTwap, uint24 twapSecondsAgo, bytes11 params) {
    useTwap = uint8(ldfParams[0]) == 1; // first byte flags if the LDF uses TWAP
    if (useTwap) {
        // | twapSecondsAgo - 3 bytes | params - 8 bytes |
        twapSecondsAgo = uint24(bytes3(ldfParams << 8));
        params = bytes11(ldfParams << 32); // | params - 8 bytes | 0 - 3 bytes |
    } else {
        // 11 bytes for params
        params = bytes11(ldfParams << 8); // | params - 11 bytes |
    }
}
