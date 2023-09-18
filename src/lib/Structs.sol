// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import {PoolKey} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";

import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

struct BunniTokenState {
    PoolKey poolKey;
    ILiquidityDensityFunction liquidityDensityFunction;
    bytes12 ldfParams;
    uint128 reserve0;
    uint128 reserve1;
}

struct LiquidityDelta {
    int24 tickLower;
    int256 delta;
}
