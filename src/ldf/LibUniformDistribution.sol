// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {SqrtPriceMath} from "@uniswap/v4-core/src/libraries/SqrtPriceMath.sol";

import "../lib/Math.sol";
import "../base/Constants.sol";

library LibUniformDistribution {
    using TickMath for int24;
    using TickMath for uint160;
    using SafeCastLib for uint256;

    /// @dev Queries the liquidity density and the cumulative amounts at the given rounded tick.
    /// @param roundedTick The rounded tick to query
    /// @param tickSpacing The spacing of the ticks
    /// @return liquidityDensityX96_ The liquidity density at the given rounded tick. Range is [0, 1]. Scaled by 2^96.
    /// @return cumulativeAmount0DensityX96 The cumulative amount of token0 in the rounded ticks [roundedTick + tickSpacing, tickUpper)
    /// @return cumulativeAmount1DensityX96 The cumulative amount of token1 in the rounded ticks [tickLower, roundedTick - tickSpacing]
    function query(int24 roundedTick, int24 tickSpacing, int24 tickLower, int24 tickUpper)
        internal
        pure
        returns (uint256 liquidityDensityX96_, uint256 cumulativeAmount0DensityX96, uint256 cumulativeAmount1DensityX96)
    {
        // compute liquidityDensityX96
        liquidityDensityX96_ = liquidityDensityX96(roundedTick, tickSpacing, tickLower, tickUpper);

        uint24 length = uint24((tickUpper - tickLower) / tickSpacing);
        uint128 liquidity = uint128(Q96 / length);

        uint160 sqrtRatioTickLower = tickLower.getSqrtRatioAtTick();
        uint160 sqrtRatioTickUpper = tickUpper.getSqrtRatioAtTick();

        // compute cumulativeAmount0DensityX96 for the rounded tick to the right of the rounded current tick
        if (roundedTick + tickSpacing >= tickUpper) {
            // cumulativeAmount0DensityX96 is just 0
            cumulativeAmount0DensityX96 = 0;
        } else if (roundedTick + tickSpacing <= tickLower) {
            cumulativeAmount0DensityX96 =
                SqrtPriceMath.getAmount0Delta(sqrtRatioTickLower, sqrtRatioTickUpper, liquidity, false);
        } else {
            cumulativeAmount0DensityX96 = SqrtPriceMath.getAmount0Delta(
                (roundedTick + tickSpacing).getSqrtRatioAtTick(), sqrtRatioTickUpper, liquidity, false
            );
        }

        // compute cumulativeAmount1DensityX96 for the rounded tick to the left of the rounded current tick
        if (roundedTick - tickSpacing < tickLower) {
            // cumulativeAmount1DensityX96 is just 0
            cumulativeAmount1DensityX96 = 0;
        } else if (roundedTick >= tickUpper) {
            cumulativeAmount1DensityX96 =
                SqrtPriceMath.getAmount1Delta(sqrtRatioTickLower, sqrtRatioTickUpper, liquidity, false);
        } else {
            cumulativeAmount1DensityX96 =
                SqrtPriceMath.getAmount1Delta(sqrtRatioTickLower, roundedTick.getSqrtRatioAtTick(), liquidity, false);
        }
    }

    /// @dev Computes the cumulative amount of token0 in the rounded ticks [roundedTick, tickUpper).
    function cumulativeAmount0(
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 tickLower,
        int24 tickUpper
    ) internal pure returns (uint256 amount0) {
        if (roundedTick >= tickUpper || tickLower >= tickUpper) {
            // cumulativeAmount0DensityX96 is just 0
            return 0;
        } else if (roundedTick < tickLower) {
            roundedTick = tickLower;
        }

        uint24 length = uint24((tickUpper - tickLower) / tickSpacing);
        uint128 liquidity = (totalLiquidity / length).toUint128();
        uint160 sqrtRatioTickUpper = tickUpper.getSqrtRatioAtTick();
        amount0 = SqrtPriceMath.getAmount0Delta(roundedTick.getSqrtRatioAtTick(), sqrtRatioTickUpper, liquidity, false);
    }

    /// @dev Computes the cumulative amount of token1 in the rounded ticks [tickLower, roundedTick].
    function cumulativeAmount1(
        int24 roundedTick,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 tickLower,
        int24 tickUpper
    ) internal pure returns (uint256 amount1) {
        if (roundedTick < tickLower || tickLower >= tickUpper) {
            // cumulativeAmount1DensityX96 is just 0
            return 0;
        } else if (roundedTick > tickUpper - tickSpacing) {
            roundedTick = tickUpper - tickSpacing;
        }

        uint24 length = uint24((tickUpper - tickLower) / tickSpacing);
        uint128 liquidity = (totalLiquidity / length).toUint128();
        uint160 sqrtRatioTickLower = tickLower.getSqrtRatioAtTick();
        amount1 = SqrtPriceMath.getAmount1Delta(
            sqrtRatioTickLower, (roundedTick + tickSpacing).getSqrtRatioAtTick(), liquidity, false
        );
    }

    /// @dev Given a cumulativeAmount0, computes the rounded tick whose cumulativeAmount0 is closest to the input. Range is [tickLower, tickUpper].
    ///      If roundUp is true, the returned tick will be the smallest rounded tick whose cumulativeAmount0 is less than or equal to the input.
    ///      If roundUp is false, the returned tick will be the largest rounded tick whose cumulativeAmount0 is greater than or equal to the input.
    ///      In the case that the input exceeds the cumulativeAmount0 of all rounded ticks, the function will return (false, 0).
    function inverseCumulativeAmount0(
        uint256 cumulativeAmount0_,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 tickLower,
        int24 tickUpper,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        uint24 length = uint24((tickUpper - tickLower) / tickSpacing);
        uint128 liquidity = (totalLiquidity / length).toUint128();

        uint160 sqrtRatioTickLower = tickLower.getSqrtRatioAtTick();
        uint160 sqrtRatioTickUpper = tickUpper.getSqrtRatioAtTick();
        uint160 sqrtPrice =
            SqrtPriceMath.getNextSqrtPriceFromAmount0RoundingUp(sqrtRatioTickUpper, liquidity, cumulativeAmount0_, true);
        if (sqrtPrice < sqrtRatioTickLower) {
            return (false, 0);
        }
        int24 tick = sqrtPrice.getTickAtSqrtRatio();
        if (roundUp) {
            tick += tickSpacing - 1;
        }
        success = true;
        roundedTick = roundTickSingle(tick, tickSpacing);

        if (roundedTick < tickLower || roundedTick > tickUpper) {
            return (false, 0);
        }
    }

    /// @dev Given a cumulativeAmount1, computes the rounded tick whose cumulativeAmount1 is closest to the input. Range is [tickLower - tickSpacing, tickUpper - tickSpacing].
    ///      If roundUp is true, the returned tick will be the smallest rounded tick whose cumulativeAmount1 is greater than or equal to the input.
    ///      If roundUp is false, the returned tick will be the largest rounded tick whose cumulativeAmount1 is less than or equal to the input.
    ///      In the case that the input exceeds the cumulativeAmount1 of all rounded ticks, the function will return (false, 0).
    function inverseCumulativeAmount1(
        uint256 cumulativeAmount1_,
        uint256 totalLiquidity,
        int24 tickSpacing,
        int24 tickLower,
        int24 tickUpper,
        bool roundUp
    ) internal pure returns (bool success, int24 roundedTick) {
        uint24 length = uint24((tickUpper - tickLower) / tickSpacing);
        uint128 liquidity = (totalLiquidity / length).toUint128();

        uint160 sqrtRatioTickLower = tickLower.getSqrtRatioAtTick();
        uint160 sqrtRatioTickUpper = tickUpper.getSqrtRatioAtTick();
        uint160 sqrtPrice = SqrtPriceMath.getNextSqrtPriceFromAmount1RoundingDown(
            sqrtRatioTickLower, liquidity, cumulativeAmount1_, true
        );
        if (sqrtPrice > sqrtRatioTickUpper) {
            return (false, 0);
        }
        int24 tick = sqrtPrice.getTickAtSqrtRatio() - tickSpacing;
        if (roundUp) {
            tick += tickSpacing - 1;
        }
        success = true;
        roundedTick = roundTickSingle(tick, tickSpacing);

        if (roundedTick < tickLower - tickSpacing || roundedTick >= tickUpper) {
            return (false, 0);
        }
    }

    function isValidParams(int24 tickSpacing, bytes32 ldfParams) internal pure returns (bool) {
        // | tickLower - 3 bytes | tickUpper - 3 bytes |
        int24 tickLower = int24(uint24(bytes3(ldfParams)));
        int24 tickUpper = int24(uint24(bytes3(ldfParams << 24)));
        return tickLower % tickSpacing == 0 && tickUpper % tickSpacing == 0 && tickLower < tickUpper;
    }

    function liquidityDensityX96(int24 roundedTick, int24 tickSpacing, int24 tickLower, int24 tickUpper)
        internal
        pure
        returns (uint256)
    {
        if (roundedTick < tickLower || roundedTick >= tickUpper) {
            // roundedTick is outside of the distribution
            return 0;
        }
        uint256 length = uint24((tickUpper - tickLower) / tickSpacing);
        return Q96 / length;
    }

    /// @dev Combines several operations used during a swap into one function to save gas.
    ///      Given a cumulative amount, it computes its inverse to find the closest rounded tick, then computes the cumulative amount at that tick,
    ///      and finally computes the liquidity of the tick that will handle the remainder of the swap.
    function computeSwap(
        uint256 inverseCumulativeAmountInput,
        uint256 totalLiquidity,
        bool zeroForOne,
        bool exactIn,
        int24 tickSpacing,
        int24 tickLower,
        int24 tickUpper
    ) internal pure returns (bool success, int24 roundedTick, uint256 cumulativeAmount, uint128 swapLiquidity) {
        if (exactIn == zeroForOne) {
            // compute roundedTick by inverting the cumulative amount
            // below is an illustration of 4 rounded ticks, the input amount, and the resulting roundedTick (rick)
            // notice that the inverse tick is between two rounded ticks, and we round up to the rounded tick to the right
            // e.g. go from 1.5 to 2
            //       input
            //      ├──────┤
            // ┌──┬──┬──┬──┐
            // │  │ █│██│██│
            // │  │ █│██│██│
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //       │
            //       ▼
            //      rick
            (success, roundedTick) = inverseCumulativeAmount0(
                inverseCumulativeAmountInput, totalLiquidity, tickSpacing, tickLower, tickUpper, true
            );
            if (!success) return (false, 0, 0, 0);

            // compute the cumulative amount up to roundedTick
            // below is an illustration of the cumulative amount at roundedTick
            // notice that (input - cum) is the remainder of the swap that will be handled by Uniswap math
            //         cum
            //       ├─────┤
            // ┌──┬──┬──┬──┐
            // │  │ █│██│██│
            // │  │ █│██│██│
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //       │
            //       ▼
            //      rick
            cumulativeAmount = cumulativeAmount0(roundedTick, totalLiquidity, tickSpacing, tickLower, tickUpper);

            // compute liquidity of the rounded tick that will handle the remainder of the swap
            // below is an illustration of the liquidity of the rounded tick that will handle the remainder of the swap
            // because we got rick by rounding up, the liquidity of (rick - tickSpacing) is used by the Uniswap math
            //    liq
            //    ├──┤
            // ┌──┬──┬──┬──┐
            // │  │ █│██│██│
            // │  │ █│██│██│
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //    │
            //    ▼
            //   rick - tickSpacing
            swapLiquidity = (
                (liquidityDensityX96(roundedTick - tickSpacing, tickSpacing, tickLower, tickUpper) * totalLiquidity)
                    >> 96
            ).toUint128();
        } else {
            // compute roundedTick by inverting the cumulative amount
            // below is an illustration of 4 rounded ticks, the input amount, and the resulting roundedTick (rick)
            // notice that the inverse tick is between two rounded ticks, and we round up to the rounded tick to the right
            // e.g. go from 1.5 to 2
            //  input
            // ├──────┤
            // ┌──┬──┬──┬──┐
            // │██│██│█ │  │
            // │██│██│█ │  │
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //       │
            //       ▼
            //      rick
            (success, roundedTick) = inverseCumulativeAmount1(
                inverseCumulativeAmountInput, totalLiquidity, tickSpacing, tickLower, tickUpper, true
            );
            if (!success) return (false, 0, 0, 0);

            // compute the cumulative amount up to roundedTick
            // below is an illustration of the cumulative amount at roundedTick
            // notice that (input - cum) is the remainder of the swap that will be handled by Uniswap math
            //   cum
            // ├─────┤
            // ┌──┬──┬──┬──┐
            // │██│██│█ │  │
            // │██│██│█ │  │
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //    │
            //    ▼
            //   rick - tickSpacing
            cumulativeAmount =
                cumulativeAmount1(roundedTick - tickSpacing, totalLiquidity, tickSpacing, tickLower, tickUpper);

            // compute liquidity of the rounded tick that will handle the remainder of the swap
            // below is an illustration of the liquidity of the rounded tick that will handle the remainder of the swap
            //       liq
            //       ├──┤
            // ┌──┬──┬──┬──┐
            // │██│██│█ │  │
            // │██│██│█ │  │
            // └──┴──┴──┴──┘
            // 0  1  2  3  4
            //       │
            //       ▼
            //      rick
            swapLiquidity = (
                (liquidityDensityX96(roundedTick, tickSpacing, tickLower, tickUpper) * totalLiquidity) >> 96
            ).toUint128();
        }
    }

    /// @return tickLower The lower tick of the distribution
    /// @return tickUpper The upper tick of the distribution
    function decodeParams(bytes32 ldfParams) internal pure returns (int24 tickLower, int24 tickUpper) {
        // | tickLower - 3 bytes | tickUpper - 3 bytes |
        tickLower = int24(uint24(bytes3(ldfParams)));
        tickUpper = int24(uint24(bytes3(ldfParams << 24)));
    }
}
