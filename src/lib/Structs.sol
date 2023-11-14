// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import {PoolId} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";

import {IBunniToken} from "../interfaces/IBunniToken.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

struct PoolState {
    ILiquidityDensityFunction liquidityDensityFunction;
    IBunniToken bunniToken;
    uint24 twapSecondsAgo;
    bytes32 ldfParams;
    bytes32 hookParams;
    uint256 reserve0;
    uint256 reserve1;
}

struct RawPoolState {
    address immutableParamsPointer;
    uint256 reserve0;
    uint256 reserve1;
}

struct LiquidityDelta {
    int24 tickLower;
    int256 delta;
}
