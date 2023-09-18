// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

function decodeLDFParams(bytes12 ldfParams) pure returns (uint24 twapSecondsAgo, bytes11 params) {
    bool useTwap = uint8(ldfParams[0]) == 1; // first byte flags if the LDF uses TWAP
    if (useTwap) {
        // 3 bytes for twapSecondsAgo, 8 bytes for params
        twapSecondsAgo = uint24(bytes3(ldfParams << 8));
        params = bytes11(ldfParams << 40);
    } else {
        // 11 bytes for params
        params = bytes11(ldfParams << 8);
    }
}
