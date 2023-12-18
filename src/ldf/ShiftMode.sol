// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

enum ShiftMode {
    BOTH,
    LEFT,
    RIGHT
}

function enforceShiftMode(int24 tick, int24 lastTick, ShiftMode shiftMode) pure returns (int24) {
    if ((shiftMode == ShiftMode.LEFT && tick > lastTick) || (shiftMode == ShiftMode.RIGHT && tick < lastTick)) {
        return lastTick;
    }
    return tick;
}
