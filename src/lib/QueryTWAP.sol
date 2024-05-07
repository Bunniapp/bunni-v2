// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";

import {IBunniHook} from "../interfaces/IBunniHook.sol";

function queryTwap(PoolKey memory poolKey, uint24 twapSecondsAgo) view returns (int24 arithmeticMeanTick) {
    IBunniHook hook = IBunniHook(address(poolKey.hooks));
    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = twapSecondsAgo;
    secondsAgos[1] = 0;
    int56[] memory tickCumulatives = hook.observe(poolKey, secondsAgos);
    int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
    return int24(tickCumulativesDelta / int56(uint56(twapSecondsAgo)));
}
