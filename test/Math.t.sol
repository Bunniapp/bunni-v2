// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "forge-std/Test.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "../src/lib/ExpMath.sol";

contract MathTest is Test {
    using ExpMath for int256;
    using FixedPointMathLib for int256;

    uint256 internal constant WAD = 1e18;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
    uint256 internal constant EXPQ96_MAX_REL_ERR = 1;
    uint256 internal constant LNQ96_MAX_REL_ERR = 1e5;

    function testExpQ96() public pure {
        assertApproxEqRel(ExpMath.expQ96(-5272010636899917441709581228289), 1, EXPQ96_MAX_REL_ERR);
        assertApproxEqRel(ExpMath.expQ96(-5272010636899917441709581228290), 0, EXPQ96_MAX_REL_ERR);

        assertApproxEqRel(ExpMath.expQ96(_toX96(-3e18)), 3944537943757913803250139538, EXPQ96_MAX_REL_ERR);
        assertApproxEqRel(ExpMath.expQ96(_toX96(-2e18)), 10722365814184344471345157570, EXPQ96_MAX_REL_ERR);
        assertApproxEqRel(ExpMath.expQ96(_toX96(-1e18)), 29146412150787779157341161347, EXPQ96_MAX_REL_ERR);

        assertApproxEqRel(ExpMath.expQ96(_toX96(-0.5e18)), 48054309677596482279189095253, EXPQ96_MAX_REL_ERR);
        assertApproxEqRel(ExpMath.expQ96(_toX96(-0.3e18)), 58693666381699285067152078220, EXPQ96_MAX_REL_ERR);

        assertApproxEqRel(ExpMath.expQ96(0), int256(Q96), EXPQ96_MAX_REL_ERR);

        assertApproxEqRel(ExpMath.expQ96(_toX96(0.3e18)), 106946832977942646757811282248, EXPQ96_MAX_REL_ERR);
        assertApproxEqRel(ExpMath.expQ96(_toX96(0.5e18)), 130625156775754158392272157367, EXPQ96_MAX_REL_ERR);

        assertApproxEqRel(ExpMath.expQ96(_toX96(1e18)), 215364474464724850177511348353, EXPQ96_MAX_REL_ERR);
        assertApproxEqRel(ExpMath.expQ96(_toX96(2e18)), 585421337433093623126455912475, EXPQ96_MAX_REL_ERR);
        assertApproxEqRel(ExpMath.expQ96(_toX96(3e18)), 1591340183536569437194234385268, EXPQ96_MAX_REL_ERR);
        // True value: 20085536923187667740.92

        assertApproxEqRel(ExpMath.expQ96(_toX96(10e18)), 1745116411605831136386745932035149, EXPQ96_MAX_REL_ERR);
        // True value: 22026465794806716516957.90
        // Relative error 1.0258385671358602879603145297813347238186103892972810170519... × 10^-21

        assertApproxEqRel(
            ExpMath.expQ96(_toX96(50e18)), 410774692207501362566875902318172955306535359146490, EXPQ96_MAX_REL_ERR
        );
        // True value: 5184705528587072464_087453322933485384827.47
        // Relative error: 1.1780031733243329380865021189067967523855580421617711636520... × 10^-20

        assertApproxEqRel(
            ExpMath.expQ96(_toX96(100e18)),
            2129745817691885348307036796455038216102748246983526077577564622785246408,
            EXPQ96_MAX_REL_ERR
        );
        // True value: 268811714181613544841_26255515800135873611118773741922415191608
        // Relative error: 3.128803544297531e-22
    }

    function testLnQ96() public pure {
        assertApproxEqAbs(ExpMath.lnQ96(int256(Q96)), 0, Q96 / (WAD / LNQ96_MAX_REL_ERR));

        // Actual: 999999999999999999.8674576…
        assertApproxEqRel(ExpMath.lnQ96(_toX96(2718281828459045235)), 79228162514264337583042863203, LNQ96_MAX_REL_ERR);

        // Actual: 2461607324344817917.963296…
        assertApproxEqRel(
            ExpMath.lnQ96(_toX96(11723640096265400935)), 195028625139494637934502645072, LNQ96_MAX_REL_ERR
        );
    }

    function testLnQ96Small() public pure {
        // Actual: -41446531673892822312.3238461…
        assertApproxEqRel(ExpMath.lnQ96(_toX96(1)), -3283732547111784853622338894909, LNQ96_MAX_REL_ERR);

        // Actual: -37708862055609454006.40601608…
        assertApproxEqRel(ExpMath.lnQ96(_toX96(42)), -2987603851169801797185404822657, LNQ96_MAX_REL_ERR);

        // Actual: -32236191301916639576.251880365581…
        assertApproxEqRel(ExpMath.lnQ96(_toX96(1e4)), -2554014203309165997261819140485, LNQ96_MAX_REL_ERR);

        // Actual: -20723265836946411156.161923092…
        assertApproxEqRel(ExpMath.lnQ96(_toX96(1e9)), -1641866273555892426811169447454, LNQ96_MAX_REL_ERR);
    }

    function testLnQ96Big() public pure {
        // Actual: 135305999368893231589.070344787…
        assertApproxEqRel(ExpMath.lnQ96(2 ** 255 - 1), 8731767617365488262831493909354, LNQ96_MAX_REL_ERR);

        // Actual: 76388489021297880288.605614463571…
        assertApproxEqRel(ExpMath.lnQ96(2 ** 170), 4063841532610353027984468863473, LNQ96_MAX_REL_ERR);

        // Actual: 47276307437780177293.081865…
        assertApproxEqRel(ExpMath.lnQ96(2 ** 128), 1757336878966639147236527076096, LNQ96_MAX_REL_ERR);
    }

    function test_getSqrtPriceAtTickWad(int24 tick) public pure {
        tick = int24(bound(tick, TickMath.MIN_TICK, TickMath.MAX_TICK));

        uint256 maxError = 1;

        int256 tickWad = int256(tick) * int256(WAD);
        uint160 sqrtRatioX96 = tickWad.getSqrtPriceAtTickWad();
        uint160 expectedSqrtRatioX96 = TickMath.getSqrtPriceAtTick(tick);
        if (int256(uint256(sqrtRatioX96)).dist(int256(uint256(expectedSqrtRatioX96))) > 1) {
            // we're OK with errors that are 1 wei, regardless of how big the relative error is
            assertApproxEqRel(sqrtRatioX96, expectedSqrtRatioX96, maxError, "sqrt ratio rel error too large");
        }
    }

    function _toX96(int256 x) internal pure returns (int256) {
        return x * int256(Q96) / 1e18;
    }
}
