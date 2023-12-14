// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import {PoolId, PoolKey, BalanceDelta} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

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
    bool poolCredit0Set;
    bool poolCredit1Set;
    uint256 reserve0;
    uint256 reserve1;
}

struct RawPoolState {
    address immutableParamsPointer;
    bool poolCredit0Set;
    bool poolCredit1Set;
    uint256 reserve0;
    uint256 reserve1;
}

struct LiquidityDelta {
    int24 tickLower;
    int256 delta;
}

struct ModifyLiquidityInputData {
    PoolKey poolKey;
    int24 tickLower;
    int24 tickUpper;
    int256 liquidityDelta;
    BalanceDelta reserveDeltaInUnderlying;
    uint128 currentLiquidity;
    address user;
    ERC4626 vault0;
    ERC4626 vault1;
}

struct ModifyLiquidityReturnData {
    uint256 amount0;
    uint256 amount1;
    int256 reserveChange0;
    int256 reserveChange1;
}

struct HookCallbackInputData {
    PoolKey poolKey;
    ERC4626 vault0;
    ERC4626 vault1;
    bool poolCredit0Set;
    bool poolCredit1Set;
    LiquidityDelta[] liquidityDeltas;
}

struct HookCallbackReturnData {
    int256 reserveChange0;
    int256 reserveChange1;
}

struct InitializePoolCallbackInputData {
    PoolKey poolKey;
    uint160 sqrtPriceX96;
    uint24 twapSecondsAgo;
    bytes32 hookParams;
}
