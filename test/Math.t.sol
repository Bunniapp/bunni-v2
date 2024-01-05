// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "forge-std/Test.sol";

import "../src/lib/Math.sol";

contract MathTest is Test {
    uint256 internal constant Q96 = 0x1000000000000000000000000;

    function testExpQ96() public {
        assertEq(ExpMath.expQ96(-5272010636899917441709581228289), 1);
        assertEq(ExpMath.expQ96(-5272010636899917441709581228290), 0);

        assertEq(ExpMath.expQ96(-3e18), 49787068367863942);
        assertEq(ExpMath.expQ96(-2e18), 135335283236612691);
        assertEq(ExpMath.expQ96(-1e18), 367879441171442321);

        assertEq(ExpMath.expQ96(-0.5e18), 606530659712633423);
        assertEq(ExpMath.expQ96(-0.3e18), 740818220681717866);

        assertEq(ExpMath.expQ96(0), 1000000000000000000);

        assertEq(ExpMath.expQ96(0.3e18), 1349858807576003103);
        assertEq(ExpMath.expQ96(0.5e18), 1648721270700128146);

        assertEq(ExpMath.expQ96(1e18), 2718281828459045235);
        assertEq(ExpMath.expQ96(2e18), 7389056098930650227);
        assertEq(ExpMath.expQ96(3e18), 20085536923187667741);
        // True value: 20085536923187667740.92

        assertEq(ExpMath.expQ96(10e18), 220264657948067165169_80);
        // True value: 22026465794806716516957.90
        // Relative error 9.987984547746668e-22

        assertEq(ExpMath.expQ96(50e18), 5184705528587072464_148529318587763226117);
        // True value: 5184705528587072464_087453322933485384827.47
        // Relative error: 1.1780031733243328e-20

        assertEq(ExpMath.expQ96(100e18), 268811714181613544841_34666106240937146178367581647816351662017);
        // True value: 268811714181613544841_26255515800135873611118773741922415191608
        // Relative error: 3.128803544297531e-22

        assertEq(
            ExpMath.expQ96(135305999368893231588),
            578960446186580976_50144101621524338577433870140581303254786265309376407432913
        );
        // True value: 578960446186580976_49816762928942336782129491980154662247847962410455084893091
        // Relative error: 5.653904247484822e-21
    }

    function testLnQ96() public {
        assertEq(ExpMath.lnQ96(int256(Q96)), 0);

        // Actual: 999999999999999999.8674576…
        assertEq(ExpMath.lnQ96(_toX96(2718281828459045235)), _toX96(999999999999999999));

        // Actual: 2461607324344817917.963296…
        assertEq(ExpMath.lnQ96(_toX96(11723640096265400935)), _toX96(2461607324344817918));
    }

    function _toX96(int256 x) internal pure returns (int256) {
        return x * int256(Q96) / 1e18;
    }

    function testLnQ96Small() public {
        // Actual: -41446531673892822312.3238461…
        assertEq(ExpMath.lnQ96(_toX96(1)), _toX96(-41446531673892822313));

        // Actual: -37708862055609454006.40601608…
        assertEq(ExpMath.lnQ96(_toX96(42)), _toX96(-37708862055609454007));

        // Actual: -32236191301916639576.251880365581…
        assertEq(ExpMath.lnQ96(_toX96(1e4)), _toX96(-32236191301916639577));

        // Actual: -20723265836946411156.161923092…
        assertEq(ExpMath.lnQ96(_toX96(1e9)), _toX96(-20723265836946411157));
    }

    function testLnQ96Big() public {
        // Actual: 135305999368893231589.070344787…
        assertEq(ExpMath.lnQ96(_toX96(2 ** 255 - 1)), _toX96(135305999368893231589));

        // Actual: 76388489021297880288.605614463571…
        assertEq(ExpMath.lnQ96(_toX96(2 ** 170)), _toX96(76388489021297880288));

        // Actual: 47276307437780177293.081865…
        assertEq(ExpMath.lnQ96(_toX96(2 ** 128)), _toX96(47276307437780177293));
    }

    function testLnQ96NegativeReverts() public {
        vm.expectRevert(ExpMath.LnQ96Undefined.selector);
        ExpMath.lnQ96(-1);
        ExpMath.lnQ96(-2 ** 255);
    }

    function testLnQ96OverflowReverts() public {
        vm.expectRevert(ExpMath.LnQ96Undefined.selector);
        ExpMath.lnQ96(0);
    }
}
