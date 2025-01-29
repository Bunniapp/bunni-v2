// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {FixedPoint96} from "@uniswap/v4-core/src/libraries/FixedPoint96.sol";

import "../src/lib/Math.sol";
import {ShiftMode} from "../src/ldf/ShiftMode.sol";
import {ILiquidityDensityFunction} from "../src/interfaces/ILiquidityDensityFunction.sol";

abstract contract FuzzHelper {
    int24 internal constant MAX_TICK_SPACING = type(int16).max;
    uint256 internal constant INVCUM0_MAX_ERROR = 10;
    int24 internal constant MIN_TICK_SPACING = 1000; // >1 to make brute forcing viable
    ILiquidityDensityFunction internal ldf;
    bytes32 internal ldfParams;
    uint24 internal constant MAX_SWAP_FEE = 1_000_000;
    uint160 internal constant MIN_SQRT_PRICE = TickMath.MIN_SQRT_PRICE + 1;
    uint160 internal constant MAX_SQRT_PRICE = TickMath.MAX_SQRT_PRICE - 1;
    bytes32 internal constant LDF_STATE = bytes32(0);
    uint256 internal constant MIN_ALPHA = 1e3;
    uint256 internal constant MAX_ALPHA = 12e8;

    function findAbsDiff(uint256 x, uint256 y) public pure returns (uint256) {
        if (x > y) return (x - y);
        else return (y - x);
    }
}
