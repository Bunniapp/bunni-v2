// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

function min(uint256 a, uint256 b) pure returns (uint256) {
    return a > b ? b : a;
}

function max(uint256 a, uint256 b) pure returns (uint256) {
    return a > b ? a : b;
}

function abs(int24 a) pure returns (uint256) {
    return a > 0 ? uint256(int256(a)) : uint256(-int256(a));
}

function roundTick(int24 currentTick, int24 tickSpacing) pure returns (int24 roundedTick, int24 nextRoundedTick) {
    int24 compressed = currentTick / tickSpacing;
    if (currentTick < 0 && currentTick % tickSpacing != 0) compressed--; // round towards negative infinity
    roundedTick = compressed * tickSpacing;
    nextRoundedTick = roundedTick + tickSpacing;
}
