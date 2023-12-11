// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

function min(uint256 a, uint256 b) pure returns (uint256) {
    return a > b ? b : a;
}

function max(uint256 a, uint256 b) pure returns (uint256) {
    return a > b ? a : b;
}

function abs(int256 a) pure returns (uint256) {
    return a > 0 ? uint256(a) : uint256(-a);
}

function absDiff(uint256 a, uint256 b) pure returns (bool positive, uint256 diff) {
    return a > b ? (true, a - b) : (false, b - a);
}

function absDiffSimple(uint256 a, uint256 b) pure returns (uint256 diff) {
    return a > b ? a - b : b - a;
}

function roundTick(int24 currentTick, int24 tickSpacing) pure returns (int24 roundedTick, int24 nextRoundedTick) {
    int24 compressed = currentTick / tickSpacing;
    if (currentTick < 0 && currentTick % tickSpacing != 0) compressed--; // round towards negative infinity
    roundedTick = compressed * tickSpacing;
    nextRoundedTick = roundedTick + tickSpacing;
}

function roundTickSingle(int24 currentTick, int24 tickSpacing) pure returns (int24 roundedTick) {
    int24 compressed = currentTick / tickSpacing;
    if (currentTick < 0 && currentTick % tickSpacing != 0) compressed--; // round towards negative infinity
    roundedTick = compressed * tickSpacing;
}

function boundTick(int24 tick, int24 tickSpacing) pure returns (int24 boundedTick) {
    (int24 minTick, int24 maxTick) = (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
    if (tick < minTick) {
        return minTick;
    } else if (tick > maxTick) {
        return maxTick;
    }
    return tick;
}

function weightedSum(uint256 value0, uint256 weight0, uint256 value1, uint256 weight1) pure returns (uint256) {
    return (value0 * weight0 + value1 * weight1) / (weight0 + weight1);
}
