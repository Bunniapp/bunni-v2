// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// --------------------------------------------------------------------
/// @notice This file was automatically generated using fuzz-utils
/// --------------------------------------------------------------------

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../fuzz/FuzzEntry.sol";

contract FuzzEntry_Medusa_Test is Test {
    FuzzEntry target;

    function setUp() public {
        target = new FuzzEntry();
    }
    // Reproduced from: medusa/test_results/1730772642114703000-69cab260-1e95-4b3e-8233-1f0137609bc7.json

    function test_auto_compare_exact_in_swap_with_exact_out_swap_0() public {
        vm.warp(block.timestamp + 415998);
        vm.roll(block.number + 23783);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_exact_in_swap_with_exact_out_swap(
            int24(2743571),
            uint64(85036323857242128),
            uint64(1048576),
            int64(-5077420025644778166),
            uint160(0),
            int24(-2002111),
            int24(3917552),
            int24(1795312),
            false
        );
    }

    // Reproduced from: medusa/test_results/1733190576260561000-ff3cc95f-44d5-4306-a881-7d8dc33a60a4.json
    function test_auto_test_swap_panics_1() public {
        vm.warp(block.timestamp + 423312);
        vm.roll(block.number + 45);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_swap_panics(
            int24(309981),
            uint64(6578343627211024248),
            uint64(0),
            int64(-3603),
            uint160(86962243123123036749989189048793895901635),
            int24(134787),
            int24(172),
            int24(1029929),
            false
        );
    }

    // Reproduced from: medusa/test_results/1733190576259901000-5fe8471b-0926-46bb-b0a9-76d0864a9dda.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_2() public {
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(
            int24(0),
            uint64(2541541517846523460),
            uint64(8082000445000154006),
            int64(978675),
            uint160(2854495300611766788554622079889745203628986048),
            int24(1318907),
            int24(-1107600),
            int24(-5712430),
            false
        );
    }

    // Reproduced from: medusa/test_results/1733190576260202000-beeb1ccb-4696-4456-b1c4-5b8fc02aeae2.json
    function test_auto_test_swap_panics_3() public {
        vm.warp(block.timestamp + 423312);
        vm.roll(block.number + 45);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_swap_panics(
            int24(3852505),
            uint64(145820442900062192),
            uint64(1219557432245820828),
            int64(-100006171),
            uint160(73585158625906735033072916874495540),
            int24(5547145),
            int24(7468086),
            int24(-5970324),
            false
        );
    }

    // Reproduced from: medusa/test_results/1733190576261152000-8ce2f1c2-e685-48c4-81d5-aaa8e7e7def3.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_4() public {
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(
            int24(156034),
            uint64(3238927980791116120),
            uint64(7149582490983130623),
            int64(144115314351203863),
            uint160(85069487459292896489098117942938592832),
            int24(989495),
            int24(-1642263),
            int24(4602952),
            false
        );
    }
}
