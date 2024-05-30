// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

library ExpMath {
    using ExpMath for int256;
    using SafeCastLib for int256;
    using SafeCastLib for uint256;
    using FixedPointMathLib for int256;
    using FixedPointMathLib for uint256;

    uint256 internal constant WAD = 1e18;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
    int256 internal constant LN_Q96_DIV_WAD = 25095597659861927392; // ln(Q96 / WAD) * WAD
    int256 internal constant HALF_LN_TICK_BASE = 49997500166654; // 1/2 ln(1.0001) * WAD
    int256 internal constant HALF_LN_TICK_BASE_Q96 = 3961210068510634698400736; // 1/2 ln(1.0001) * Q96

    /// @dev The output is undefined, as the input is less-than-or-equal to zero.
    error LnQ96Undefined();

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error ExpOverflow();

    /// @dev Returns `exp(x)`, denominated in `Q96`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    function expQ96(int256 x) internal pure returns (int256 r) {
        unchecked {
            // When the result is less than 0.5 we return zero.
            // This happens when `x <= floor(ln(1 / 2**96) * 2**96)`.
            if (x <= -5272010636899917441709581228290) return r;

            /// @solidity memory-safe-assembly
            assembly {
                // When the result is greater than `(2**255 - 1) / 2**96` we can not represent it as
                // an int. This happens when `x >= floor(log((2**255 - 1) / 2**96) * 2**96) ≈ 110 * 2**96`.
                if iszero(slt(x, 8731767617365488262831493909354)) {
                    mstore(0x00, 0xa37bfec9) // `ExpOverflow()`.
                    revert(0x1c, 0x04)
                }
            }

            // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
            // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
            // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;
            x = x - k * 54916777467707473351141471128;

            // `k` is in the range `[-61, 195]`.

            // Evaluate using a (6, 7)-term rational approximation.
            // `p` is made monic, we'll multiply by a scale factor later.
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            /// @solidity memory-safe-assembly
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial won't have zeros in the domain as all its roots are complex.
                // No scaling is necessary because p is already `2**96` too large.
                r := sdiv(p, q)
            }

            // r should be in the range `(0.09, 0.25) * 2**96`.

            // We now need to multiply r by:
            // - The scale factor `s ≈ 6.031367120`.
            // - The `2**k` factor from the range reduction.
            int256 shift = 117 - k;
            r = shift >= 0
                ? int256((uint256(r) * 1002132753603162656746435578141647308) >> uint256(shift))
                : int256((uint256(r) * 1002132753603162656746435578141647308) << uint256(-shift));
        }
    }

    /// @dev Returns `ln(x)`, denominated in `Q96`.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/22/exp-ln
    function lnQ96(int256 x) internal pure returns (int256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute `k = log2(x) - 96`, `r = 159 - k = 255 - log2(x) = 255 ^ log2(x)`.
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            // We place the check here for more optimal stack operations.
            if iszero(sgt(x, 0)) {
                mstore(0x00, 0xe65fd7ca) // `LnQ96Undefined()`.
                revert(0x1c, 0x04)
            }
            // forgefmt: disable-next-item
            r := xor(r, byte(and(0x1f, shr(shr(r, x), 0x8421084210842108cc6318c6db6d54be)),
                0xf8f9f9faf9fdfafbf9fdfcfdfafbfcfef9fafdfafcfcfbfefafafcfbffffffff))

            // Reduce range of x to (1, 2) * 2**96
            // ln(2^k * x) = k * ln(2) + ln(x)
            x := shr(159, shl(r, x))

            // Evaluate using a (8, 8)-term rational approximation.
            // `p` is made monic, we will multiply by a scale factor later.
            // forgefmt: disable-next-item
            let p := sub( // This heavily nested expression is to avoid stack-too-deep for via-ir.
                sar(96, mul(add(43456485725739037958740375743393,
                sar(96, mul(add(24828157081833163892658089445524,
                sar(96, mul(add(3273285459638523848632254066296,
                    x), x))), x))), x)), 11111509109440967052023855526967)
            p := sub(sar(96, mul(p, x)), 45023709667254063763336534515857)
            p := sub(sar(96, mul(p, x)), 14706773417378608786704636184526)
            p := sub(mul(p, x), shl(96, 795164235651350426258249787498))
            // We leave `p` in `2**192` basis so we don't need to scale it back up for the division.

            // `q` is monic by convention.
            let q := add(5573035233440673466300451813936, x)
            q := add(71694874799317883764090561454958, sar(96, mul(x, q)))
            q := add(283447036172924575727196451306956, sar(96, mul(x, q)))
            q := add(401686690394027663651624208769553, sar(96, mul(x, q)))
            q := add(204048457590392012362485061816622, sar(96, mul(x, q)))
            q := add(31853899698501571402653359427138, sar(96, mul(x, q)))
            q := add(909429971244387300277376558375, sar(96, mul(x, q)))

            // `p / q` is in the range `(0, 0.125) * 2**96`.

            // Finalization, we need to:
            // - Multiply by the scale factor `s = 5.549…`.
            // - Add `k * ln(2)`.

            // The q polynomial is known not to have zeros in the domain.
            // No scaling required because p is already `2**96` too large.
            p := sdiv(p, q)
            // Multiply by the scaling factor: `s * 2**96`, base is now `2**192`.
            p := mul(439668470185123797622540459591, p)
            // Add `ln(2) * k * 2**192`.
            // forgefmt: disable-next-item
            p := add(mul(4350955369971217654477563090224794165364344896676135745069, sub(159, r)), p)
            // Base conversion: div `2**96`.
            r := sar(96, p)
        }
    }

    function getSqrtPriceAtTickWad(int256 tickWad) internal pure returns (uint160 sqrtRatioX96) {
        sqrtRatioX96 = uint256((HALF_LN_TICK_BASE_Q96 * tickWad / int256(WAD)).expQ96()).toUint160();
    }
}
