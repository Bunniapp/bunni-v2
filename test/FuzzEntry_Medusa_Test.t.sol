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
    // Reproduced from: medusa/test_results/1738097512801136000-97410eaf-3e15-4445-bdc4-21f5524b81d7.json

    function test_auto_test_swap_panics_0() public {
        vm.warp(block.timestamp + 360393);
        vm.roll(block.number + 60259);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(-4211147),
            uint64(1369563),
            uint64(6277969058929330912),
            int64(651895969596293),
            uint160(175446262561594300296678499311889627774),
            int24(-905311),
            int24(-423360),
            int24(6344663),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738088556756074000-a1492f40-a9c0-4f8b-b850-fc6a74db17ce.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_1() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1301748),
            uint64(16263),
            uint64(582645430566909357),
            int64(-73467697243886440),
            uint160(1461446703999947801168116551653009141806204347986),
            int24(0),
            int24(468733),
            int24(1783325),
            uint24(1048782),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738090651059396000-d529b354-c6a4-43fa-8bec-fdd0a3e39ac0.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_2() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-5922721),
            uint64(4),
            uint64(877441538674269),
            int64(5827758672736300523),
            uint160(0),
            int24(-1653630),
            int24(-7544508),
            int24(6076314),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738101397829327000-9cf0990d-1607-450b-b114-c5db5bbaf6c0.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_3() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(-868),
            uint64(6908568215580700575),
            uint64(2719958853289233785),
            int64(1),
            uint160(1348062482476305422960854442445358491257),
            int24(-2934470),
            int24(-1783179),
            int24(-48935),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738100634869178000-a2a25ae7-3a84-40e1-be3a-6ac5fdba2ff6.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_4()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(127),
            int24(1934939),
            int24(-5832117),
            int24(-532827),
            uint256(108362564806958668148080321378561151734657325361443481336443628248811356506361),
            uint256(862718293348820473429344482784626850970995960016184010195652143522685)
        );
    }

    // Reproduced from: medusa/test_results/1738097895128424000-d60d363f-7a8d-4f67-9fb3-d3ecd341f138.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_5() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1314078),
            uint64(4),
            uint64(10635607),
            int64(-214844417580),
            uint160(706580043516233566740200723219),
            int24(-6807361),
            int24(1751973),
            int24(-4698390),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738100634867981000-9bec7bba-21e5-4f36-a305-3cc9fc35cdd2.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_6()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(127),
            int24(1932532),
            int24(-4161218),
            int24(6108983),
            uint256(108362564806958668148080321378561151734657325361443481336443628248810155595199),
            uint256(220855883097298041197912187590077326121342188499106040667143226182772182)
        );
    }

    // Reproduced from: medusa/test_results/1738090651048022000-0e6678bf-6d5d-48b8-b2f5-f2ba1d12ab25.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_7() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1122908),
            uint64(4),
            uint64(120),
            int64(1046893903731417702),
            uint160(0),
            int24(1750323),
            int24(926588),
            int24(-8122613),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738097512840094000-3bc75ae9-a13b-4c58-92f9-b3f525d16ab7.json
    function test_auto_test_swap_panics_8() public {
        vm.warp(block.timestamp + 360393);
        vm.roll(block.number + 60259);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(330641),
            uint64(4194620),
            uint64(4616456620026304077),
            int64(1492912305021159299),
            uint160(608065551216730353684914890122863637489602342981),
            int24(1748983),
            int24(905940),
            int24(-5451731),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738090651035762000-2626b489-fd47-4c91-962b-fc24bd1a94da.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_9() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(2972080),
            uint64(3),
            uint64(1075),
            int64(1900389262248223828),
            uint160(324478436082628387245681869526741342),
            int24(-1735510),
            int24(1785365),
            int24(-4817144),
            uint24(1016435),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738100634870578000-d3c62e7d-b017-4ecf-b47f-a21bba5485cd.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_10()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(127),
            int24(1932667),
            int24(6041736),
            int24(-7035249),
            uint256(108362564806958668148080321378561151734657325361443481336443628248811355558796),
            uint256(12554209457084068122162217412257021717181608106672827917219)
        );
    }

    // Reproduced from: medusa/test_results/1738104806240513000-84578feb-9155-4f12-b1de-44bf389d4a1d.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_11(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(3),
            int24(948665),
            int24(5812044),
            int24(-432812),
            uint256(4112111866668518151349595566913276154315434411154476),
            int24(-744289),
            uint256(421249166674228746793538728489466146344433901579678189319740282720),
            uint32(3842850261),
            uint32(384580726),
            uint256(318716819266388652362911236976892208402)
        );
    }

    // Reproduced from: medusa/test_results/1738104806275633000-378e1f6c-0473-49b0-987b-f79c92ceca93.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_12(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(6),
            int24(-4740456),
            int24(-4268365),
            int24(-261065),
            uint256(28948187957981358496211304634979425383681329125650645477803823841890507950959),
            int24(5985785),
            uint256(28948022309329048855892746252171976963487633769850693096587690429379191140057),
            uint32(170229440),
            uint32(701253537),
            uint256(3213876088517980640283573384919789283411450412283545910050590)
        );
    }

    // Reproduced from: medusa/test_results/1738100634869519000-bce735ce-cf70-48ac-b697-d439a49a3229.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_13()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(127),
            int24(1932748),
            int24(6082452),
            int24(2505681),
            uint256(108362564806958668148080321378561151734657325361443481336443628248810155693785),
            uint256(9106625360881922460747902225088661710)
        );
    }

    // Reproduced from: medusa/test_results/1738097895131419000-5835740e-48fe-444b-959c-bba7dc0583c6.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_14() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(494576),
            uint64(4),
            uint64(1293),
            int64(-12),
            uint160(0),
            int24(-5237274),
            int24(1024111),
            int24(95935),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738090651058427000-7291c77c-7313-4b6b-aac2-d429e226ca4c.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_15() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1492734),
            uint64(4),
            uint64(400),
            int64(820163307761131567),
            uint160(0),
            int24(-1711109),
            int24(1019146),
            int24(3590560),
            uint24(342978),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738101397826580000-dc0fe7b1-5fe7-4138-8d32-400eef1b5d31.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_16() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(4684302),
            uint64(286988092989674143),
            uint64(212476166584701609),
            int64(1),
            uint160(21443272645727828010060985896782844485210),
            int24(-2961744),
            int24(2117931),
            int24(-2421138),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738088556765520000-ce30bc64-309d-497e-b07d-a8195b4ebdfd.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_17() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(213666),
            uint64(5),
            uint64(9051295128327029039),
            int64(-1065012016789366680),
            uint160(1461446703485210132347872064441638012047298966214),
            int24(1717560),
            int24(1042673),
            int24(1760460),
            uint24(2018904),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738097512840626000-511c7128-529a-4e57-9569-43ce745b7692.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_18() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-7702943),
            uint64(11),
            uint64(3751),
            int64(-5314941097904863945),
            uint160(175418951847),
            int24(-1693400),
            int24(-1561136),
            int24(87158),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738100634870861000-3ebb30eb-25ab-4e7e-b03d-9680894ac1e3.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_19()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(127),
            int24(1932655),
            int24(-4153226),
            int24(2072533),
            uint256(236952662531355408385708586112442095264388179986654261381119826713),
            uint256(7237005577332262213973186563042994240819532819742322750110920651906030625377)
        );
    }

    // Reproduced from: medusa/test_results/1738101397828741000-dca443ac-af91-4769-91ae-0fb52306b4b7.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_20() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(-8302806),
            uint64(10642455452531893784),
            uint64(17590180258376838680),
            int64(1),
            uint160(1826136448804265799360401133191132431463),
            int24(-2990765),
            int24(-3311316),
            int24(-106624),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738101397727147000-9d83f3df-b8fd-463c-9f4c-2f47ed29e5de.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_21() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(-1000057),
            uint64(10714333255631334017),
            uint64(509667573072737671),
            int64(1),
            uint160(56241079328855654690455815694016125052996685195),
            int24(-3002995),
            int24(5753194),
            int24(1038011),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738088556756679000-92e6c173-7a31-4e05-8c78-cf54e0b0cec5.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_22() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-5157838),
            uint64(9),
            uint64(8014965230494192019),
            int64(-2968295008068336753),
            uint160(405899316620203263488572700491),
            int24(1720880),
            int24(6242827),
            int24(1747088),
            uint24(7194712),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738104806277206000-6c931710-1874-486c-a069-34275443e449.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_23(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(39),
            uint256(6),
            int24(-4740538),
            int24(4133109),
            int24(-6637),
            uint256(56539106072908298546665520023784542879027115482346890582486969351554481796),
            int24(1957226),
            uint256(3618502788666131106986593281886858796532748411482506043274619055456853019900),
            uint32(2153358888),
            uint32(1200479203),
            uint256(348451978264116635435877386760575144087332)
        );
    }

    // Reproduced from: medusa/test_results/1738090651057904000-90c987e4-4a84-4fde-aee5-14bb3d29316d.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_24() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-5250915),
            uint64(2),
            uint64(18071),
            int64(185090993479019338),
            uint160(67009665774263416554021384014373873828104),
            int24(-5218146),
            int24(8240317),
            int24(-1623721),
            uint24(16516643),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738104806277920000-7294b58e-c79b-482c-89cc-96b3a5b29499.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_25(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(1000000000000000039),
            uint256(3),
            int24(-95425),
            int24(-2808628),
            int24(-1147269),
            uint256(141291087878678309713388139405575015450850090665087686992729024),
            int24(-3542179),
            uint256(3138550867696194877313938429227825527030117480453397636177),
            uint32(2966077855),
            uint32(587032994),
            uint256(374144418700908736208998703481575811607844181059814)
        );
    }

    // Reproduced from: medusa/test_results/1738100634869691000-a277d163-60b9-480e-9c3b-be06cc923d34.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_26()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(127),
            int24(7395615),
            int24(-4168063),
            int24(-799234),
            uint256(108362564806958668148080321378561151734317077019356751545959302073997068809372),
            uint256(411376139330301524538375115584088613921416520082298166843497125)
        );
    }

    // Reproduced from: medusa/test_results/1738090651061314000-f7a8734c-82f5-4a3a-9546-f1f7e8beec29.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_27() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(26558),
            uint64(24),
            uint64(263),
            int64(3371239850454034188),
            uint160(45671926155983790024087190365478183719732501325),
            int24(0),
            int24(3558482),
            int24(-1360864),
            uint24(3780926),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738100634868841000-27951800-ab33-40bf-8a27-f7bd8eb13355.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_28()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(127),
            int24(966331),
            int24(-4163373),
            int24(4251468),
            uint256(108362564806958668148080321378561151734657325361443481336443628248812555689871),
            uint256(9277820398819276050375175541383236056298681622)
        );
    }

    // Reproduced from: medusa/test_results/1738088556753752000-089351c9-23d8-4a7b-8804-0a900eec35b2.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_29() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-5816466),
            uint64(9),
            uint64(1095756607280496277),
            int64(-3525404640118),
            uint160(438857831766970309607998854181),
            int24(-65),
            int24(980670),
            int24(1724548),
            uint24(14459272),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738097512841277000-ebced592-7332-42e6-b458-6a91b1891500.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_30() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(2000463),
            uint64(19),
            uint64(1209266),
            int64(-733710742033773828),
            uint160(89370180701647201781072673945),
            int24(0),
            int24(-4678077),
            int24(257459),
            uint24(7065862),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738090650961859000-ec8dfe00-fcfa-4296-a3f3-c09b180a59f0.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_31() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7651049),
            uint64(4),
            uint64(92),
            int64(379257661937749),
            uint160(0),
            int24(-1747520),
            int24(-3366857),
            int24(-1656768),
            uint24(2739361),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738094266448637000-1c560555-ca2f-4dfb-a40a-a9149789f5e8.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_32() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-6081813),
            uint64(1),
            uint64(267),
            int64(4776689172088159),
            uint160(0),
            int24(1798846),
            int24(-4055141),
            int24(-2919807),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738094266450567000-f80d5637-7bd0-4e23-ab54-49873b10c23e.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_33() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-377864),
            uint64(122),
            uint64(1582551116747),
            int64(556989284078136164),
            uint160(225313880605394142014527100254297),
            int24(2036123),
            int24(6434557),
            int24(-1305917),
            uint24(1062645),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738097512838097000-5585faee-916e-4fcb-8e43-4ee1dcb0ee6d.json
    function test_auto_test_swap_panics_34() public {
        vm.warp(block.timestamp + 360393);
        vm.roll(block.number + 60259);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(2186605),
            uint64(9315081),
            uint64(6168634309376427844),
            int64(5689396513062978109),
            uint160(2529366847797778572830797689243355884),
            int24(-4531264),
            int24(202291),
            int24(-4145415),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738097512839494000-e191a100-8798-4591-9b8e-0cf51c0e1576.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_35() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(6013591),
            uint64(22),
            uint64(4838883),
            int64(-491466153866936076),
            uint160(0),
            int24(1898504),
            int24(286296),
            int24(-2714266),
            uint24(1125487),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738100634833926000-6f00bb9d-d0f2-4ddd-9579-ce93e6ca2717.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_36()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(127),
            int24(-7774182),
            int24(919184),
            int24(2473837),
            uint256(108362564806958668148080321378561151734657325361443481336443628248812554586939),
            uint256(7237005577332262226527390035460538243767375273022341559601129546311420041543)
        );
    }

    // Reproduced from: medusa/test_results/1738104806277684000-63705d26-85dd-4ea4-9fdf-31b3ea44b46d.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_37(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(6),
            int24(-4740417),
            int24(-7694665),
            int24(5051),
            uint256(348445741326983386893176808955508589225025),
            int24(-815646),
            uint256(14134776518227074636666380005943348242530818985673776376261569851098967011),
            uint32(1428919122),
            uint32(2058720951),
            uint256(11417763775995825964908190103329768090641436896)
        );
    }

    // Reproduced from: medusa/test_results/1738097895129536000-07b46427-226a-47a0-848c-3f8bd619b6c8.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_38() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1296155),
            uint64(26),
            uint64(9486),
            int64(-2),
            uint160(0),
            int24(-1696903),
            int24(-5739910),
            int24(133432),
            uint24(7677463),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738104806275116000-840e9eb9-ea60-44f2-a166-52152c226db4.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_39(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(3),
            int24(2700542),
            int24(-6018728),
            int24(4952098),
            uint256(113078212145817149011643066134693406155967180883232265920205649978060116499),
            int24(-4445990),
            uint256(1496577676626872835739276312238455915315694580793599),
            uint32(421117123),
            uint32(2699274104),
            uint256(28269553036454149273332760011887393151587735829879075218274590272862280960)
        );
    }

    // Reproduced from: medusa/test_results/1738097895131983000-cf0391a9-7c00-405b-918c-60397ade41eb.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_40() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1306835),
            uint64(2193),
            uint64(749645354538),
            int64(-190156673857507),
            uint160(365375409332752600981676468694886118127887387497),
            int24(5353845),
            int24(-6343827),
            int24(-1418116),
            uint24(1653302),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738101397828934000-0d6abbe4-c21b-4468-9afd-01e7baf9c5ff.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_41() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(-9929),
            uint64(6236825206194063011),
            uint64(234423475096803124),
            int64(1),
            uint160(1359997106012350685251111872616902098406),
            int24(-2985853),
            int24(326674),
            int24(3455939),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738101397825584000-e96193d9-6085-4442-ab76-3e889edca2bb.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_42() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(3079919),
            uint64(13433505794575106251),
            uint64(992008483267854765),
            int64(1),
            uint160(5679300481858831090279930645178011895151788),
            int24(-2974898),
            int24(5658453),
            int24(-5526354),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738094266449468000-87a9e1c8-5275-4b52-8d6d-819e94e0e339.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_43() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(6384527),
            uint64(1),
            uint64(278),
            int64(2911957218093828428),
            uint160(91343852333181432325230302645426084734122053963),
            int24(5158790),
            int24(117876),
            int24(-1650747),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738088556751926000-2bd9e5fb-9b96-41ac-84c0-a87e7a7dcb43.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_44() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7998563),
            uint64(5),
            uint64(3420748064682860945),
            int64(-124100457773278),
            uint160(955552010323721792707636474460),
            int24(0),
            int24(2650296),
            int24(-1726156),
            uint24(3065684),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738097512838470000-645a38e0-7cae-4e69-9300-6d0e6979c6f9.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_45() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(5098689),
            uint64(4025),
            uint64(6068005582485676714),
            int64(-831693944169097985),
            uint160(0),
            int24(-1404822),
            int24(-411),
            int24(-4676340),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738101397830028000-097d2fa7-3660-4f32-ab97-51ed8ee0b88c.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_46() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(32584),
            uint64(17715912809328499116),
            uint64(6809200245192118573),
            int64(1),
            uint160(903179443134269847780467849779325265517),
            int24(-2973838),
            int24(-2683003),
            int24(53458),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738088556618551000-941d4609-b3ef-47ed-b70d-dab379752f48.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_47() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(31889),
            uint64(5),
            uint64(573705696742389480),
            int64(-220314464503413807),
            uint160(291033491583407135010892616964),
            int24(0),
            int24(-2395528),
            int24(-1714962),
            uint24(1021846),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738097512839114000-7beb83c5-6f97-4bbd-8f3d-cda724418f3e.json
    function test_auto_test_swap_panics_48() public {
        vm.warp(block.timestamp + 360393);
        vm.roll(block.number + 60259);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(-5538),
            uint64(2),
            uint64(10856817146793952845),
            int64(162215370992440975),
            uint160(745864608369905200586647803731955291066),
            int24(-900343),
            int24(12503),
            int24(352493),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738100634869344000-04788326-21fb-47af-8226-0e41d4a35997.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_49()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(127),
            int24(1932659),
            int24(6042304),
            int24(7439842),
            uint256(108362564806958668148080321378561151734657325361443481336443628248810155646878),
            uint256(105312392102184952884899452030069998127009307319268528343543527682)
        );
    }

    // Reproduced from: medusa/test_results/1738097894989181000-6017bac2-2ccf-4f8f-a254-c3dafd6a2673.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_50() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-6433458),
            uint64(7),
            uint64(7853),
            int64(-1),
            uint160(0),
            int24(-40742),
            int24(-3440233),
            int24(-4877008),
            uint24(6177353),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738088556757987000-d49f8bf9-a438-4d3f-a2dd-1e44e8935e93.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_51() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(32001),
            uint64(6),
            uint64(282302596874671558),
            int64(-2481563372421571250),
            uint160(1063563429263432351839443176588),
            int24(1666272),
            int24(-3384046),
            int24(1723038),
            uint24(7119986),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738101397828540000-043f1d47-eda5-45cc-8a41-b9f6d140d1ec.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_52() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(-5634018),
            uint64(6826853006152285825),
            uint64(12314186899571273255),
            int64(1),
            uint160(607000596562051987872661347792489149097),
            int24(3908271),
            int24(-4767843),
            int24(3224203),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738104806278627000-3c7caa94-a5a9-4b86-b2be-916696f92260.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_53(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(94605),
            uint256(3),
            int24(6956608),
            int24(5771294),
            int24(1468060),
            uint256(578728295951066356585571843694984630598301499668613084935615985181),
            int24(4890694),
            uint256(55429650347661715417836844520549686240396609165627844622588394009834783),
            uint32(2768677841),
            uint32(235957485),
            uint256(438627544693787099425179993798933607)
        );
    }

    // Reproduced from: medusa/test_results/1738090651047206000-7c2688f6-62ac-49e3-bf82-67de0c5c25c7.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_54() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-3008041),
            uint64(2),
            uint64(89),
            int64(8405273724074293336),
            uint160(858260055804850600393548585496069444774907),
            int24(0),
            int24(84898),
            int24(-1656125),
            uint24(11105714),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738104806276081000-c591af20-d2c8-4416-bd9f-3909b4114b4f.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_55(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(6),
            int24(-4740539),
            int24(-4292114),
            int24(4015187),
            uint256(17661385984834788714173351033748426257142872646426723995529140),
            int24(-8150094),
            uint256(803469022129540807980464959517852283024221726318525215604805),
            uint32(610554995),
            uint32(4025401775),
            uint256(401734511064747568885575593734832981447877814951708957810315)
        );
    }

    // Reproduced from: medusa/test_results/1738101397827943000-b484af19-fd6d-4646-844d-4003d4171e85.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_56() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(-434771),
            uint64(9459561226969491659),
            uint64(4586268381340099297),
            int64(1),
            uint160(585920347880590479076664264765478421541),
            int24(3948047),
            int24(1006489),
            int24(1585035),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738090651051194000-3ecfed14-55d7-4b9b-8116-9bac44826d9e.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_57() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7052123),
            uint64(4),
            uint64(3366479958384268123),
            int64(-7413834560821493085),
            uint160(0),
            int24(-1697654),
            int24(-4867131),
            int24(1985602),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738088556761015000-cd981af5-f43e-4f1b-9018-0c15d32db5f0.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_58() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-7253646),
            uint64(4),
            uint64(10139175866988959148),
            int64(-1017243627561735850),
            uint160(440319301582743936730180786162),
            int24(-1708147),
            int24(-3295903),
            int24(1746672),
            uint24(9065240),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738094266446037000-0b03708a-25ba-4368-a28e-9df902572c88.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_59() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-2004890),
            uint64(1),
            uint64(57),
            int64(130229464019361144),
            uint160(10632760690210305970070443300775454140),
            int24(-1718772),
            int24(-1651537),
            int24(34149),
            uint24(3045276),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738104806278393000-fb9dae9b-33f1-4bc0-974d-b13263b7b938.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_60(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(3),
            int24(-4609138),
            int24(5779318),
            int24(7911396),
            uint256(3618503651384495101351006050020836599174227824024453956711410964797995193129),
            int24(-685355),
            uint256(14474011154664526034885231523515029864927331455309558567733198554230513855940),
            uint32(1755118593),
            uint32(2732221728),
            uint256(56539106072908298546665520143950523122287114338829150550713911203978273753)
        );
    }

    // Reproduced from: medusa/test_results/1738097895129214000-2677a939-db3a-4d17-9d04-cddaa6341077.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_61() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(3964688),
            uint64(7),
            uint64(29707),
            int64(-2),
            uint160(0),
            int24(-253),
            int24(195783),
            int24(5928597),
            uint24(1532075),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738097895136587000-a2c35d7c-71d3-4bbf-bde0-4989d9f6e1ed.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_62() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(730275),
            uint64(164),
            uint64(541911),
            int64(-1),
            uint160(0),
            int24(1687213),
            int24(-5908825),
            int24(-5013772),
            uint24(2060723),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738097512840977000-1c684657-c0a6-4a5c-9a48-4564237810b2.json
    function test_auto_test_swap_panics_63() public {
        vm.warp(block.timestamp + 1000);
        vm.roll(block.number + 488);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(-6908935),
            uint64(6701964205304099726),
            uint64(2235657350358458029),
            int64(9046493665011004093),
            uint160(56239362518850956476610246355849862114263138833),
            int24(-1440277),
            int24(5063936),
            int24(-5343008),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738100634867097000-a9ee371e-ad7b-4b38-8764-648e0b6b5b34.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_64()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(119),
            int24(1932661),
            int24(-4154617),
            int24(6259870),
            uint256(394220714249817931511840060709583724656645989672409363917556110295),
            uint256(100433627766186892221372495224055384622942611153909578963091)
        );
    }

    // Reproduced from: medusa/test_results/1738097895130136000-1b1d2d3c-8d63-4a83-a8bc-28d32983ed67.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_65() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(2116906),
            uint64(4948),
            uint64(8378112944697238),
            int64(-9),
            uint160(0),
            int24(-4838849),
            int24(-4940434),
            int24(399298),
            uint24(2571118),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738101397824937000-8434f688-e185-4412-b6f3-26e37a37a8d1.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_66() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(6845497),
            uint64(2465315000159474746),
            uint64(3098761116738176708),
            int64(1),
            uint160(2032889557820071604941083395774127087468),
            int24(-2995044),
            int24(-535253),
            int24(7639),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738097512842657000-a5999fb6-6f5f-4800-9a33-a4f08e3105e1.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_67() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1030745),
            uint64(4),
            uint64(17933),
            int64(-31396169985834011),
            uint160(657441526959148389570939554),
            int24(30),
            int24(2694752),
            int24(5480665),
            uint24(43),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738097895132836000-627883cb-de57-4782-9fbd-e0bc821afbce.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_68() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(3411837),
            uint64(4),
            uint64(3625),
            int64(-8372565167878719012),
            uint160(45994997462003567627957092596),
            int24(1741408),
            int24(-3427207),
            int24(-1139350),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738104806278161000-3b093a89-5ad5-4f3b-a0dc-9b29cb698cf5.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_69(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(1490042),
            uint256(3),
            int24(6191645),
            int24(3997129),
            int24(-1112686),
            uint256(226184105354242238178305462131470426315739337288594492232751592337396778190),
            int24(8320906),
            uint256(7238772424397040598302769860541870541632606950617988084116634542328098796831),
            uint32(851249903),
            uint32(3297535134),
            uint256(377817955568561917279098701605134151562)
        );
    }

    // Reproduced from: medusa/test_results/1738088556757327000-59ffa252-31f7-4186-bca9-b70136e24558.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_70() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-3789333),
            uint64(4),
            uint64(5197589473817565840),
            int64(-13257201815154),
            uint160(3708266985150446850508623450089),
            int24(0),
            int24(7777138),
            int24(1746377),
            uint24(5086174),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738097895130763000-3700d4fb-9165-46c6-9d58-52bf76fa20f5.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_71() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(3399095),
            uint64(189),
            uint64(512244657848),
            int64(-2416099522119149499),
            uint160(111264654553868864538631133687),
            int24(1763164),
            int24(3778873),
            int24(2091073),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738100634870258000-a4bb1c30-58f2-4d5f-ac41-bfbf8f8380a5.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_72()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(17592186046365),
            uint256(369),
            int24(966329),
            int24(6053020),
            int24(8362487),
            uint256(108362564806958668148080321378561151734657325361443481336443628248810155631470),
            uint256(677922873941997145909365634705230667001)
        );
    }

    // Reproduced from: medusa/test_results/1738088556758351000-d2a2d951-c83e-4302-90b4-fd969aae9a61.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_73() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-2592458),
            uint64(7),
            uint64(14878811080593324476),
            int64(-1936028554739),
            uint160(3037035770062285701929676525651),
            int24(0),
            int24(-718136),
            int24(1759875),
            uint24(3568),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738100634866591000-d53ee0de-a91c-40b8-8030-8aca1bd9eddd.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_74()
        public
    {
        vm.warp(block.timestamp + 426657);
        vm.roll(block.number + 6151);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(127),
            int24(5066101),
            int24(2688766),
            int24(-3029508),
            uint256(108362564806958668148080321378561151734657325361443481336443628248811355095199),
            uint256(3064991127403703837509874684296822567668698194817507101)
        );
    }

    // Reproduced from: medusa/test_results/1738101397827340000-4658caca-2d8d-4e47-b100-1a04b83bf90e.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_75() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(-1354171),
            uint64(5677670251952016068),
            uint64(3430620565216886238),
            int64(1),
            uint160(53664415295269156551901978084499105040024),
            int24(-3000294),
            int24(7230541),
            int24(-2110127),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738094266446633000-51486bd2-1f7a-43fa-9f43-2fdac7929324.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_76() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(3205720),
            uint64(1),
            uint64(47),
            int64(29137900585),
            uint160(14897394996762774),
            int24(0),
            int24(887520),
            int24(5522571),
            uint24(5009300),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738101397829131000-0deb666f-9332-47de-a313-41b48c13efdf.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_77() public {
        vm.warp(block.timestamp + 589042);
        vm.roll(block.number + 31172);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(58355),
            uint64(1896550606626630306),
            uint64(6654877527050414),
            int64(1),
            uint160(3282082191740752318564175265970899107894),
            int24(-2955808),
            int24(-5634262),
            int24(-720538),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738104806276652000-152b3be2-ac21-4b1a-a9d3-de5ca8b208df.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_78(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(3),
            int24(6890197),
            int24(7505255),
            int24(1977110),
            uint256(19684891159604701463222865702152509014714288207819093770803757863),
            int24(-7137607),
            uint256(89188569523995346129628447467355090772848147),
            uint32(1698362576),
            uint32(665024691),
            uint256(27606985387162257448482334747941323226736685989513330356562311125620058)
        );
    }

    // Reproduced from: medusa/test_results/1738090651056358000-ab8a3ba2-b821-4aa3-b5fa-c21e18255ea2.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_79() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(5651722),
            uint64(10),
            uint64(77),
            int64(621560523294825107),
            uint160(2721988174957933388213295008768786213580),
            int24(-1719607),
            int24(-743374),
            int24(-945438),
            uint24(6288319),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738104806277446000-e2824e41-e4bb-4b90-a6c0-9140170937fb.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_80(
    ) public {
        vm.warp(block.timestamp + 385216);
        vm.roll(block.number + 58804);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(8796093033244),
            uint256(3),
            int24(3810339),
            int24(4101571),
            int24(75978),
            uint256(28948022310276859498157208183208730799211102332225897010429878682614073477218),
            int24(151093),
            uint256(200965335246989201329680278897088971564488852542901500187388),
            uint32(1618934942),
            uint32(60988220),
            uint256(7237009136061677323430851566278587816546673419251882904588676683513167163419)
        );
    }

    // Reproduced from: medusa/test_results/1738090651050029000-f43c555a-fb94-4a51-9ec0-418948277ba7.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_81() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(412857),
            uint64(8),
            uint64(269),
            int64(135821291156744615),
            uint160(14059840797193375533760355656585475659320463576),
            int24(5150658),
            int24(-3636986),
            int24(-8058982),
            uint24(200336),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738088556759286000-422aaa01-f699-4865-ba30-da1a3ba8d5e1.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_82() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(2954321),
            uint64(138),
            uint64(211451277977476709),
            int64(-892666626095772),
            uint160(1461446703826442535000126592877016635429823952787),
            int24(0),
            int24(-4631820),
            int24(-1673003),
            uint24(143574),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738090651046777000-d49f7f46-304d-4da5-a5ab-79aa8de5fc1b.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_83() public {
        vm.warp(block.timestamp + 401880);
        vm.roll(block.number + 27364);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-2547081),
            uint64(2),
            uint64(221),
            int64(132410987315708459),
            uint160(0),
            int24(-1677793),
            int24(1773168),
            int24(-1489498),
            uint24(0),
            true
        );
    }

    // Reproduced from: medusa/test_results/1738088556758677000-ba4b7c4b-ec15-4e2d-8324-efe0e622721c.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_84() public {
        vm.warp(block.timestamp + 472569);
        vm.roll(block.number + 47031);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(3017913),
            uint64(5),
            uint64(2272288960625524882),
            int64(-124552200550678636),
            uint160(8940310612293912760637722478242),
            int24(547),
            int24(2809058),
            int24(1730741),
            uint24(1035487),
            false
        );
    }
}
