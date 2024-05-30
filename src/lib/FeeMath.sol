// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./Math.sol";
import "../base/Constants.sol";

using FixedPointMathLib for int256;
using FixedPointMathLib for uint256;

function computeSurgeFee(uint32 lastSurgeTimestamp, uint24 surgeFee, uint16 surgeFeeHalfLife)
    view
    returns (uint24 fee)
{
    // compute surge fee
    // surge fee gets applied after the LDF shifts (if it's dynamic)
    unchecked {
        uint256 timeSinceLastSurge = block.timestamp - lastSurgeTimestamp;
        fee = uint24(
            uint256(surgeFee).mulWadUp(
                uint256((-int256(timeSinceLastSurge.mulDiv(LN2_WAD, surgeFeeHalfLife))).expWad())
            )
        );
    }
}

function computeDynamicSwapFee(
    uint160 postSwapSqrtPriceX96,
    int24 arithmeticMeanTick,
    uint32 lastSurgeTimestamp,
    uint24 feeMin,
    uint24 feeMax,
    uint24 feeQuadraticMultiplier,
    uint24 surgeFee,
    uint16 surgeFeeHalfLife
) view returns (uint24 fee) {
    // compute surge fee
    // surge fee gets applied after the LDF shifts (if it's dynamic)
    fee = computeSurgeFee(lastSurgeTimestamp, surgeFee, surgeFeeHalfLife);

    // special case for fixed fee pools
    if (feeQuadraticMultiplier == 0 || feeMin == feeMax) return uint24(FixedPointMathLib.max(feeMin, fee));

    uint256 ratio = uint256(postSwapSqrtPriceX96).mulDiv(SWAP_FEE_BASE, TickMath.getSqrtPriceAtTick(arithmeticMeanTick));
    if (ratio > MAX_SWAP_FEE_RATIO) ratio = MAX_SWAP_FEE_RATIO;
    ratio = ratio.mulDiv(ratio, SWAP_FEE_BASE); // square the sqrtPrice ratio to get the price ratio
    uint256 delta = dist(ratio, SWAP_FEE_BASE);
    // unchecked is safe since we're using uint256 to store the result and the return value is bounded in the range [feeMin, feeMax]
    unchecked {
        uint256 quadraticTerm = uint256(feeQuadraticMultiplier).mulDivUp(delta * delta, SWAP_FEE_BASE_SQUARED);
        return uint24(FixedPointMathLib.max(fee, FixedPointMathLib.min(feeMin + quadraticTerm, feeMax)));
    }
}
