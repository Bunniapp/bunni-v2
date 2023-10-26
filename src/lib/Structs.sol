// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import {PoolId} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";

import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

struct BunniTokenState {
    PoolId poolId;
    ILiquidityDensityFunction liquidityDensityFunction;
    bytes12 ldfParams;
    uint24 feeMin;
    uint24 feeMax;
    uint24 feeQuadraticMultiplier;
    uint24 feeTwapSecondsAgo;
    uint128 reserve0;
    uint128 reserve1;
}

struct LiquidityDelta {
    int24 tickLower;
    int256 delta;
}
