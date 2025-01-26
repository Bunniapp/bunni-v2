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
    // Reproduced from: medusa/test_results/1737929113909919000-c40cfc18-d750-4ab6-ab94-b4c62eda1803.json

    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_0() public {
        vm.warp(block.timestamp + 128412);
        vm.roll(block.number + 51208);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(0),
            uint64(145755659),
            uint64(538199716345774668),
            int64(-5183092345642854404),
            uint160(85056314318470914758954069592399629272),
            int24(6640401),
            int24(0),
            int24(-1799758)
        );
    }

    // Reproduced from: medusa/test_results/1737929113913490000-a7fed9ab-7540-4ccd-b5e6-e07a0306487f.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_1() public {
        vm.warp(block.timestamp + 128412);
        vm.roll(block.number + 51208);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(0),
            uint64(6512365438643688),
            uint64(4069290471253161924),
            int64(-250476847829801477),
            uint160(710163743211927015848304420800787679451462454),
            int24(6409846),
            int24(0),
            int24(-5492544)
        );
    }

    // Reproduced from: medusa/test_results/1737929113912025000-d6940260-75ea-426f-bb59-fb6f757b78fc.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_2() public {
        vm.warp(block.timestamp + 128412);
        vm.roll(block.number + 51208);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(125954),
            uint64(1441321505287322),
            uint64(2310727169915678626),
            int64(-4231391106854839724),
            uint160(21568223422732958735409864914889077464615),
            int24(4701807),
            int24(-3605371),
            int24(-331617)
        );
    }

    // Reproduced from: medusa/test_results/1737929113910907000-e471a5ad-45da-4c05-bac5-f60f5803cd07.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_3() public {
        vm.warp(block.timestamp + 128412);
        vm.roll(block.number + 51208);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-2100003),
            uint64(27166826),
            uint64(571060712201260300),
            int64(-62663671927934200),
            uint160(1427194115788375096016312661214820322289581407),
            int24(1547774),
            int24(-4187041),
            int24(-5464271)
        );
    }

    // Reproduced from: medusa/test_results/1737929113910547000-d05ce851-3cd1-4d8b-b7e9-03e07ab99851.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_4() public {
        vm.warp(block.timestamp + 128412);
        vm.roll(block.number + 51208);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(0),
            uint64(2885880956507173158),
            uint64(5067073206978204801),
            int64(-1977671305972371312),
            uint160(42717923540202160063961267744615499421409),
            int24(4713897),
            int24(1125039),
            int24(-5491709)
        );
    }

    // Reproduced from: medusa/test_results/1737929113911750000-7ad33ed4-9381-4843-9b0e-1dbb700784f2.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_5() public {
        vm.warp(block.timestamp + 128412);
        vm.roll(block.number + 51208);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(0),
            uint64(122760150033710),
            uint64(1992244221440846951),
            int64(-51346893561484033),
            uint160(726913614897034508082728756708377286632053995),
            int24(6402679),
            int24(0),
            int24(-5469915)
        );
    }

    // Reproduced from: medusa/test_results/1737929113911554000-83c0543d-1e67-4994-8a98-e8c208aee103.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_6() public {
        vm.warp(block.timestamp + 128412);
        vm.roll(block.number + 51208);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-771632),
            uint64(70368749564209),
            uint64(2120192501835007800),
            int64(-2189505402451517),
            uint160(664491927640541106163018584877414082),
            int24(-1925528),
            int24(0),
            int24(-5477136)
        );
    }

    // Reproduced from: medusa/test_results/1737929113911389000-cb4a2496-29e2-4541-8873-252b75138a8c.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_7() public {
        vm.warp(block.timestamp + 128412);
        vm.roll(block.number + 51208);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(0),
            uint64(9817495197498),
            uint64(348953541280614048),
            int64(-1104162874590879),
            uint160(900543424168539962403563343261829133530948046073),
            int24(1360131),
            int24(1152953),
            int24(-5222259)
        );
    }

    // Reproduced from: medusa/test_results/1737929113911187000-b3590648-54fe-416e-aafd-7ba69927b296.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_8() public {
        vm.warp(block.timestamp + 128412);
        vm.roll(block.number + 51208);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(26),
            uint64(50942272003702),
            uint64(13796488003802713852),
            int64(-8188115189093743),
            uint160(87112285912481955893110548791447535976447),
            int24(4734731),
            int24(0),
            int24(-5467076)
        );
    }

    // Reproduced from: medusa/test_results/1737929113781080000-58a9c4cf-e5fa-4031-993a-b140165fb636.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_9() public {
        vm.warp(block.timestamp + 128412);
        vm.roll(block.number + 51208);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(0),
            uint64(381936678420),
            uint64(5440258248402633384),
            int64(-893492025230090077),
            uint160(168426605690165285741581720059410128),
            int24(-39009),
            int24(-2433093),
            int24(-42489)
        );
    }
}
