// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import {PoolId} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {ERC4626} from "solmate/mixins/ERC4626.sol";

import {IBunniToken} from "../interfaces/IBunniToken.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

struct PoolState {
    ILiquidityDensityFunction liquidityDensityFunction;
    IBunniToken bunniToken;
    uint24 twapSecondsAgo;
    bytes32 ldfParams;
    bytes32 hookParams;
    ERC4626 vault0;
    ERC4626 vault1;
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
