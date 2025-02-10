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
    // Reproduced from: medusa/test_results/1738226711367017000-96b47bb1-31c5-4c86-98d9-2d8355e3d2bd.json

    function test_auto_swap_should_move_sqrt_price_in_correct_direction_0() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(2431591),
            uint64(12263199411267445028),
            uint64(4282422680320060927),
            int64(-1),
            uint160(2787592726533198877256377895422333727229689),
            int24(-1397569),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }

    // Reproduced from: medusa/test_results/1738185270996976000-2ba619f3-17bf-4bcb-af62-70363900e634.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_1(
    ) public {
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(843201530070942580824563101788882193200888325591232020225676043082),
            int24(-497192),
            int24(-4571524),
            int24(-6304703),
            uint256(6612889410686119727540169826680399009960506172526972618961073775),
            int24(1364641),
            uint256(1606938045007279709605101910210712480785508464111487167956281),
            uint32(270942132),
            uint32(3602346150),
            uint256(166)
        );
    }

    // Reproduced from: medusa/test_results/1738333050850141000-b037ca75-768d-47f0-a1a1-ac85979a8338.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_2(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(5964385),
            uint256(104),
            int24(-4269637),
            int24(-7503524),
            int24(4072546),
            uint256(10068750462081783143184004921460414384256787141723705399653523922127784229313)
        );
    }

    // Reproduced from: medusa/test_results/1738333050849174000-32407103-c7e7-409a-8eee-8a7986702ea6.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_3(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(208),
            int24(6503568),
            int24(-2440843),
            int24(-6523752),
            uint256(10068750462081783143184004921460414384256787141723705399653523922127784257009)
        );
    }

    // Reproduced from: medusa/test_results/1738484572883821000-e0430d54-7d40-40cc-9bdc-fde33d2f587e.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_4() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1781013),
            uint64(15402722148311460526),
            uint64(18289314711159276046),
            int64(-3524),
            uint160(109842504940361149171483324019854093586471099),
            int24(1626545),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1738193973777205000-6df590fb-6af5-4be1-94e9-dc78ec552851.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_5() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-7458456),
            uint64(4737387383487723008),
            uint64(7353743345480704775),
            int64(18),
            uint160(148885905339517172831832394930865399598),
            int24(2981071),
            uint24(1022341),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1738729523478876000-e13d475b-18b2-4e7b-ae14-8e0755d18615.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_6() public {
        vm.warp(block.timestamp + 362681);
        vm.roll(block.number + 30689);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7070523),
            uint64(7070249286731406392),
            uint64(10560075965297779473),
            int64(134),
            uint160(5581891922040806590854027770023068388193006),
            int24(5108253),
            uint24(0),
            true,
            bytes8(hex"cc8973a0f4acc243")
        );
    }

    // Reproduced from: medusa/test_results/1738729523483867000-6b8cf965-5b14-4875-87e9-3b21f29dff82.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_7() public {
        vm.warp(block.timestamp + 362681);
        vm.roll(block.number + 30689);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7070532),
            uint64(16551016845639060858),
            uint64(16661902365569994763),
            int64(8),
            uint160(1427247693231863161056099301375542617628713449),
            int24(436),
            uint24(3313242),
            true,
            bytes8(hex"cc8973a0f4acc243")
        );
    }

    // Reproduced from: medusa/test_results/1738205114943248000-e8bded1e-ffb3-4fa8-af98-24c17829782f.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_8(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(179628662498162),
            uint256(46770906889974303602647264572878578803946493031570),
            int24(3967430),
            int24(-59628),
            int24(-1457279),
            uint256(6901746346792133062868693881895506324947143680884708272202216927426762),
            int24(2812591),
            uint256(5427754182999196660479889945666277996756719184629076725638222829852882943742),
            uint32(0),
            uint32(0),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1738231407309064000-458cd45f-b4ab-4f7a-9482-7b1b5c80b49c.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_9()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314513), int24(-2373606), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738206361037685000-9e02ea6e-18a8-49c4-89ae-f76579827b0c.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_10() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-5600188),
            uint64(3376715404708103377),
            uint64(9291026660424377271),
            int64(-2),
            uint160(0),
            int24(4228937),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1738484572882953000-55ef0517-352b-4fa8-b60c-8b4060b169c2.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_11() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1781171),
            uint64(15916061884392701394),
            uint64(17265071681352571293),
            int64(-3),
            uint160(85070323386749763512378518988625498747),
            int24(-2435),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1738231407308223000-4c4e7a63-f4e2-49c3-a5b6-f1d97d6deb6c.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_12()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314752), int24(-2370885), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738193973770063000-6c5612c1-21b0-401e-8ebb-aecc26e707bd.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_13() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-7458665),
            uint64(7100066048358245178),
            uint64(8682334560346742752),
            int64(149),
            uint160(340776971899385564246653090939311600484),
            int24(817788),
            uint24(3000275),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1738480636583171000-f943d262-1121-4227-857f-3770d7943fad.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_14(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(136),
            int24(-3327674),
            int24(2784384),
            int24(-315799),
            uint256(6129982163466348470950025473534550887402976319535265891),
            int24(1),
            uint256(904626559937482321618214226039235598710514064305078576585956331605512874024),
            uint32(27249351),
            uint32(168861095),
            uint256(14134776518227074636666380005943347998937228882765335419648910521328652994)
        );
    }

    // Reproduced from: medusa/test_results/1738370617109179000-73a222cb-6169-4788-bd56-effd88d0cc2d.json
    function test_auto_test_swap_panics_15() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6974800),
            uint64(240435259638295164),
            uint64(6987216207278879171),
            int64(-1171),
            uint160(21007793267476042468595361122083978296),
            int24(-6388895),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738206361040709000-fb37fb50-c6c9-4f29-a9ed-4a4f6fda35c3.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_16() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(5101029),
            uint64(13211802461400671688),
            uint64(152667221105632691),
            int64(-2),
            uint160(0),
            int24(-7658029),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1738484572886587000-c1612356-29a6-4b97-9296-0a328bfed33c.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_17() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1781172),
            uint64(11388761602004608602),
            uint64(8841458041188780306),
            int64(-16804),
            uint160(8571929483169181817530672833351821071769660),
            int24(42781),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1738333050851104000-898573e7-6173-46df-b4a6-71f8ca333faf.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_18(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(1957190),
            uint256(208),
            int24(6503568),
            int24(-2439683),
            int24(3380948),
            uint256(10068750462081783143184004921460414384256787141723705399653523922126584254166)
        );
    }

    // Reproduced from: medusa/test_results/1738222333246926000-ec82496f-7a72-4c22-80e3-98b34ab8bdd2.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_19(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(325),
            uint256(7067388259113716667952869289392308391560561826327756108958918169173205491),
            int24(3504193),
            int24(6399712),
            int24(7346020),
            uint256(46267268963585865782744244337905625521042166722149870237521),
            int24(2331834),
            uint256(14135207877373749046903094678181094622249004552060190549387186448297007731),
            uint32(182660951),
            uint32(1683327117),
            uint256(79228162514264337593543950488)
        );
    }

    // Reproduced from: medusa/test_results/1738206361038013000-1c9ac421-6af5-4f8b-93e2-988f32723a61.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_20() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(49711),
            uint64(131635765744145101),
            uint64(14552832676011720818),
            int64(-2),
            uint160(0),
            int24(1243536),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1738729523480568000-fa727240-3d92-489a-937a-49a02b4e0e17.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_21() public {
        vm.warp(block.timestamp + 362681);
        vm.roll(block.number + 30689);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7070543),
            uint64(7819689397208490139),
            uint64(9882994546327140680),
            int64(246),
            uint160(35104489483471794093261186635318005972453377997),
            int24(-149804),
            uint24(13000480),
            true,
            bytes8(hex"cc8973a0f4acc243")
        );
    }

    // Reproduced from: medusa/test_results/1738206361037081000-bfbc7d47-b432-49bc-945c-d23d79ed17ad.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_22() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-3025608),
            uint64(1914197916023),
            uint64(186554795827004624),
            int64(-2),
            uint160(0),
            int24(-32606),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1739001643463689000-71d9a461-78a5-4169-9390-b7da605393f7.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_23() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7959664),
            uint64(950730380554882890),
            uint64(957272084476286897),
            int64(4),
            uint160(53605591729522575132524268530522),
            int24(4035723),
            uint24(7257175),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738199253079989000-96d43da8-38c1-47a7-8d37-9c369db59384.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_24() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(1004789),
            uint64(169046432152444984),
            uint64(3314550232711777963),
            int64(-1),
            uint160(170072452586773387297202160748630989887),
            int24(912869),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1738199532501423000-1a6e6450-f3f7-4c29-8e81-3f106a0bbba7.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_25() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-5387828),
            uint64(3821390690748950222),
            uint64(4911909711875293697),
            int64(-1),
            uint160(95435950028333683580484981050131254351),
            int24(78843),
            uint24(7068906),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738370617107154000-54d46351-86b9-4a30-8aba-f0f8952b3d6f.json
    function test_auto_test_swap_panics_26() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(-5758216),
            uint64(1520880363112962632),
            uint64(548415809824769642),
            int64(-1026),
            uint160(176897640537949152450709427117950691),
            int24(-241985),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738205114941870000-64ae6384-9ac0-4a8b-9821-e9e3c39b2825.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_27(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(47741053883848),
            uint256(3972),
            int24(-5524462),
            int24(-7983893),
            int24(-65435),
            uint256(746440268825049178749069378889684056),
            int24(-7744),
            uint256(1811018673599488945581574146517076939289154670999569471527089163125878550342),
            uint32(1729719254),
            uint32(226197518),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1738436859460734000-a0b36fa0-d846-4933-9b21-5307960a7676.json
    function test_auto_test_swap_panics_28() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6973737),
            uint64(18275753641740474829),
            uint64(4182745659853623522),
            int64(-627658),
            uint160(45671926466115684545604108336206895623623170041),
            int24(-4711207),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1739001643485055000-2754c395-1700-4ce7-9b66-4b961a59a773.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_29() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7959618),
            uint64(712699931344909089),
            uint64(8011791247621970376),
            int64(4),
            uint160(104745927003162356532699976440755012383),
            int24(1419674),
            uint24(5150908),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738226711365809000-ab355229-00d7-477c-94fb-11f8baa18f5e.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_30() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-3572602),
            uint64(4251657459075127000),
            uint64(3327526741676652153),
            int64(-1),
            uint160(11763630669517939980740434637236894),
            int24(-4135),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }

    // Reproduced from: medusa/test_results/1738205114942024000-72c0764c-5262-45c7-aeb6-744682aa970d.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_31(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(1079792991174),
            uint256(86),
            int24(4152762),
            int24(-2891672),
            int24(-1830899),
            uint256(383123885219259818172582418193790283209460646952982723),
            int24(2714545),
            uint256(862718293348820473429344482784628143735426590571331078115542645819349),
            uint32(3308068245),
            uint32(249128230),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1738199532413083000-eda7524a-67d3-4a88-9b79-be2388b8399b.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_32() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-4461627),
            uint64(8747169586498128909),
            uint64(7913678203497506570),
            int64(-63),
            uint160(5446158808219073485824370888896673085411),
            int24(2488339),
            uint24(0),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738205114942509000-7707180b-eee0-4bf3-827e-157bb446a443.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_33(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(49014778823857509),
            uint256(23842),
            int24(-1939145),
            int24(2368892),
            int24(-1781170),
            uint256(52656145834278593348959013513230358246812460623121986648010867813),
            int24(990392),
            uint256(110427941548649020598956095717618989642580623551073637754877911432818569),
            uint32(6475907),
            uint32(2901851575),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1738231407307480000-b824f99b-94fc-45cd-be3d-d691150f243c.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_34()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314513), int24(-2375114), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738222333246687000-410264ec-8ce2-43a0-8e54-b763b74047ce.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_35(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(250066465),
            uint256(331488855816674795095241824193152747634546683384495573123569546),
            int24(3504204),
            int24(6399225),
            int24(-460505),
            uint256(421249166674228768336548136470073810200676548153303523830486936108),
            int24(-6981045),
            uint256(170073143997801161790490158391126927046),
            uint32(442756612),
            uint32(114767363),
            uint256(308)
        );
    }

    // Reproduced from: medusa/test_results/1738222333248575000-db061a33-06d4-4b6f-a1e2-c27e41b676e3.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_36(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(842509811724116967914323150413456891599569450024478930066542136208),
            int24(3504185),
            int24(6393753),
            int24(1010689),
            uint256(2468256836364938334667932437627221666101970116657605803310274864),
            int24(-3719125),
            uint256(68012253685716273268260013272871047),
            uint32(118162693),
            uint32(51119),
            uint256(7237005577332262213973186563042994240829374041597583492308957479394974105823)
        );
    }

    // Reproduced from: medusa/test_results/1738729523484847000-99204a18-8d15-4029-af69-317db3481657.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_37() public {
        vm.warp(block.timestamp + 362681);
        vm.roll(block.number + 30689);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7070544),
            uint64(13729907083500828847),
            uint64(15553703778081677659),
            int64(16392),
            uint160(439380908577682213208308220037134088302220651),
            int24(-28618),
            uint24(0),
            true,
            bytes8(hex"cc8973a0f4acc243")
        );
    }

    // Reproduced from: medusa/test_results/1738333050846994000-fd73a20f-ccad-4dc6-8a89-5ac883484cc5.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_38(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(455),
            int24(6503569),
            int24(952710),
            int24(298629),
            uint256(10068750462081783143184004921460414384256787141723705399653523922125384257703)
        );
    }

    // Reproduced from: medusa/test_results/1738480636586288000-61932e3b-25c9-402a-9f55-24b7041a4f0b.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_39(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(110),
            int24(-3327679),
            int24(-7723798),
            int24(5088401),
            uint256(2857979880836471936454093155368917106576395656),
            int24(1),
            uint256(2787593149682600621535630464988014724340711),
            uint32(3435255359),
            uint32(554733903),
            uint256(28948023225967235539014499270850497441145676281541038427898600676092562380849)
        );
    }

    // Reproduced from: medusa/test_results/1738185270969674000-a66b3338-218c-4ebe-883d-cf094574b41d.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_40(
    ) public {
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(386586486493163206238970129747725198699633058414421731024838153695320928688),
            int24(-7214225),
            int24(-2629401),
            int24(-1960836),
            uint256(877411747560915043465333564950678998264267121358),
            int24(-1008526),
            uint256(228477846865278104601911533911855715173829270696372184483013474234830095),
            uint32(1354874022),
            uint32(27472375),
            uint256(100)
        );
    }

    // Reproduced from: medusa/test_results/1738199532499948000-ab7b2653-f427-4e73-b0b4-58067bc36c58.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_41() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-5288012),
            uint64(6163576639661295311),
            uint64(9187731711883050016),
            int64(-1),
            uint160(4808233671057346922495749544874234250435),
            int24(-2151631),
            uint24(3555438),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738729523490085000-c03f6703-c523-4c08-8f55-2910f2845100.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_42() public {
        vm.warp(block.timestamp + 362681);
        vm.roll(block.number + 30689);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7070606),
            uint64(13397939235903618597),
            uint64(11625511042051355938),
            int64(28),
            uint160(54923982498328173290778836251406329164683676),
            int24(-352764),
            uint24(0),
            true,
            bytes8(hex"cc8973a0f4acc243")
        );
    }

    // Reproduced from: medusa/test_results/1738206361036664000-affbe9fb-08a0-47cf-9c70-c7c6d435f908.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_43() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-6409343),
            uint64(22913928279350727),
            uint64(982812477560640991),
            int64(-2),
            uint160(0),
            int24(-4881),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1738199253080967000-4099185c-76d1-4706-9cf9-6b01087ad410.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_44() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(912708),
            uint64(579904616679516816),
            uint64(1757317441899207301),
            int64(-1),
            uint160(21772034620251467729501303289619211097505),
            int24(-27291),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1738231407310226000-74697208-2c3d-41ff-9991-b418ec24ea65.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_45()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314513), int24(-2374891), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738184483528642000-b1759628-7eaa-44ac-94cf-57fd11f7df61.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_46(
    ) public {
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(500000000000000875),
            uint256(6040413851455675097483908277308206206358866626193655539170786876312847847),
            int24(-3591060),
            int24(-6530392),
            int24(-3679),
            uint256(60295276174405388516197288677448377103675823270765421906045),
            int24(-43885),
            uint256(124878254374585358811125290060481033302056038869092335864431390965808734231),
            uint32(982950614),
            uint32(2730783055),
            uint256(87)
        );
    }

    // Reproduced from: medusa/test_results/1738226711364844000-c353fb2c-d6aa-4c20-a19e-c63662803918.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_47() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(2431591),
            uint64(2694193385200787081),
            uint64(9121984150969209232),
            int64(-1),
            uint160(693058620625707355947529870831372330380),
            int24(-838907),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }

    // Reproduced from: medusa/test_results/1738185270999955000-ffaf67db-3ea1-4b30-a94d-948b95ccf094.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_48(
    ) public {
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(1474710412953045678096657294264757387745288946117168346848885869376046),
            int24(-5072041),
            int24(-6532656),
            int24(44815),
            uint256(942113689494360843822973269616125970751869169205597970736),
            int24(-260966),
            uint256(124878254374585358811125289582626898952336884264894352643712089686449920921),
            uint32(780707682),
            uint32(656613005),
            uint256(229)
        );
    }

    // Reproduced from: medusa/test_results/1738370617055827000-7033301f-7240-47fd-b7c4-f94e0b64d09b.json
    function test_auto_test_swap_panics_49() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(5477815),
            uint64(571526380340545512),
            uint64(17361375740878221498),
            int64(-3074),
            uint160(680563574848726236940166154046742507275),
            int24(-1573725),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738199532497947000-6d29ae0b-b3ad-4ea4-a078-8c4000eee465.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_50() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-4461599),
            uint64(3064468463387456311),
            uint64(3903096050278708272),
            int64(-1),
            uint160(11150370105820519249441570005706819889974387),
            int24(6709882),
            uint24(7088175),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738206361036149000-bab2e812-129f-4a44-80fd-0dea7ed0f8d0.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_51() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(7527614),
            uint64(4984186013794863746),
            uint64(15103628058640773853),
            int64(48),
            uint160(0),
            int24(366921),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1738459414158576000-1fb94558-ccc1-4383-9de9-51c90c7b3ce2.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_52(
    ) public {
        vm.warp(block.timestamp + 345874);
        vm.roll(block.number + 28883);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(
            int24(1920), uint256(1353806082722972), uint256(20160), int24(-1504833), int24(5177845)
        );
    }

    // Reproduced from: medusa/test_results/1738436859461112000-4e2088c1-f067-46b4-a770-cda72878e32c.json
    function test_auto_test_swap_panics_53() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6974834),
            uint64(30085289328422997),
            uint64(48962328370700667),
            int64(-136814),
            uint160(26823175744103924559919401611188583349322),
            int24(-6140168),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738222333245625000-a115980e-7446-47a6-8cd6-ff687e5263e7.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_54(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(376123413609654877517543639961638325694886779431589964417169482127),
            int24(3503824),
            int24(-7114120),
            int24(-4147105),
            uint256(1284174686185139140566045011284637653770824),
            int24(-7354523),
            uint256(904625697166532776746648320380374279995821459854507115075874318653076642789),
            uint32(92686403),
            uint32(244336503),
            uint256(7237005577332262213973186563042994240829374041597583492308957479394974114010)
        );
    }

    // Reproduced from: medusa/test_results/1738222333247153000-89b130e2-4d62-471d-a5d5-4319a424f4eb.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_55(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(40684373734581),
            uint256(1809251394344819410168598356161025933386178703196142997445185606608614445589),
            int24(3503821),
            int24(6399491),
            int24(-1841881),
            uint256(3450873173418415528199170685630629834266226943834714911170385725492601),
            int24(7098866),
            uint256(68012253685588403788760211959724346),
            uint32(196056194),
            uint32(2210334691),
            uint256(202)
        );
    }

    // Reproduced from: medusa/test_results/1738206361038302000-5cb97f73-9ecf-460e-8c9a-7a6964bc0d72.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_56() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(3048551),
            uint64(7015650299249229808),
            uint64(160074488424056005),
            int64(1),
            uint160(0),
            int24(306772),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1738226711332717000-cc1ac6b1-7980-44f7-ac26-76e0465df571.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_57() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(2431614),
            uint64(3893371740956712389),
            uint64(3337995630720530805),
            int64(-1),
            uint160(143204548276411912735232272359556869),
            int24(3601219),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }

    // Reproduced from: medusa/test_results/1738238197415810000-82463e99-6762-49ec-9ef9-f77b8f6fe1a6.json
    function test_auto_test_swap_panics_58() public {
        vm.warp(block.timestamp + 169036);
        vm.roll(block.number + 48792);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_swap_panics(
            int24(65013),
            uint64(2467141791054031296),
            uint64(10057466192125231),
            int64(1876),
            uint160(76429621831671064769780767652672760683548302899),
            int24(795865),
            true,
            bytes8(hex"6c6dd0939f6d8a96")
        );
    }

    // Reproduced from: medusa/test_results/1738193973773469000-8dba8bd4-8310-4736-a89a-2ad2cd2517e9.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_59() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-7458481),
            uint64(4957747471793563722),
            uint64(8482626906434222823),
            int64(1453),
            uint160(5352934093222354891135623490205713427),
            int24(230916),
            uint24(0),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1738231407308665000-75e49237-12d5-4040-b70d-66bea54783dd.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_60()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314513), int24(-2372209), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1739001643551391000-dc3ff5ba-5c54-44bd-a636-e13353f4f8b2.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_61() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7959618),
            uint64(770703867207737436),
            uint64(956055557116810209),
            int64(48),
            uint160(730750818570684546894188775188998941973540522038),
            int24(40348),
            uint24(0),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738199532500076000-fa7b27d6-aa55-4dd0-94d6-03321b3e39d2.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_62() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-5387813),
            uint64(10853259895919413993),
            uint64(14035729324597649843),
            int64(-4140),
            uint160(3970409967135449875918842377849518829770216),
            int24(-1627718),
            uint24(9),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738484572887531000-4fa80a1a-86be-4c12-8db0-1b10a03ab06c.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_63() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1780996),
            uint64(14177862282617832443),
            uint64(13787855368483357453),
            int64(-129),
            uint160(178406156818309867175713082602166183380715092),
            int24(-1588501),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1739001643552166000-58151916-ea61-4f9b-9fc2-5c2cbc068b66.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_64() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7959479),
            uint64(4366183921929496129),
            uint64(790859515511416859),
            int64(578),
            uint160(381067833159974638625941227399264241496),
            int24(-711769),
            uint24(0),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738370617108589000-66d01e6d-2424-43d7-9ea6-52fd0ff0273b.json
    function test_auto_test_swap_panics_65() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6400406),
            uint64(14913940989038604922),
            uint64(2006634399763502820),
            int64(-1541),
            uint160(14059884185745296094908321981712011387187634890),
            int24(-386214),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738333050850462000-673de78e-4003-425f-91a2-3c4947af1112.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_66(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(208),
            int24(6503568),
            int24(-7531818),
            int24(-6523904),
            uint256(10068750462081783143184004921460414384256787141723705399653523922128984230750)
        );
    }

    // Reproduced from: medusa/test_results/1738333050848865000-09bd32b6-b16b-4b9e-a0a3-7095483fdcb1.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_67(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(208),
            int24(-7347635),
            int24(6024519),
            int24(715903),
            uint256(10068750462081783143184004921460414384256787141723705399653523922126584290172)
        );
    }

    // Reproduced from: medusa/test_results/1738436859457607000-4450cd03-f7bb-4c43-b57a-00cc5f84d7ca.json
    function test_auto_test_swap_panics_68() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6974689),
            uint64(143357880135327594),
            uint64(1945233725987866579),
            int64(-102192),
            uint160(280835918520050901357342834787742139889163393952),
            int24(4716),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738480636584162000-8b0cdb01-430c-49f1-9e04-eec8719f90f4.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_69(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(206),
            int24(-3327679),
            int24(2782737),
            int24(5070201),
            uint256(1684996666696914987258210701232997383360746667220768762984834312312),
            int24(1),
            uint256(25711008708143844408714949579475548182813895262398429445184224),
            uint32(756609967),
            uint32(2757487343),
            uint256(486149578947429884722418453275388083)
        );
    }

    // Reproduced from: medusa/test_results/1738333050840935000-6af0c9c3-8d6d-46bd-b057-729711894c5a.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_70(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(208),
            int24(6504261),
            int24(6023438),
            int24(-6523641),
            uint256(10068750462081783143184004921460414384256787141723705399653523922127784260848)
        );
    }

    // Reproduced from: medusa/test_results/1738226711362935000-ab032d2e-56de-4711-95d8-ffe2c9e397e0.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_71() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(2431673),
            uint64(2652406231513832577),
            uint64(2539235205240754316),
            int64(-1),
            uint160(2704632084051395560230074753767087299),
            int24(-193536),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }

    // Reproduced from: medusa/test_results/1738206361040062000-9267aba4-c8f0-47e7-940f-660db530bf99.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_72() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(3047814),
            uint64(1617692081537967147),
            uint64(16956339471351625916),
            int64(1),
            uint160(0),
            int24(54577),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1738199253081572000-ce61da69-e564-463f-860d-98464bd97edf.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_73() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-3554547),
            uint64(456604165279455863),
            uint64(337593716667400607),
            int64(-1),
            uint160(1427247691388325613137985462694593029565492856),
            int24(-234807),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1738199253080449000-3bf10b64-6da3-4bbc-80f9-6827f807d5e4.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_74() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-36075),
            uint64(6088986648363674749),
            uint64(3073546973241288718),
            int64(-1),
            uint160(2787593149260642925021634891366788552741563),
            int24(0),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1739001643555254000-362e972e-8b4c-48e3-9b3f-0bdba4e6b86c.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_75() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7959626),
            uint64(1174616890272779994),
            uint64(3618120396147680120),
            int64(11),
            uint160(13733554321621221378479047041028806705208780),
            int24(-917018),
            uint24(0),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738484572877321000-528b4f6c-7897-4bb8-b7d2-91f0c79affd9.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_76() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1781176),
            uint64(14747463631682336232),
            uint64(14772906422181480554),
            int64(-2055),
            uint160(5089790625658178823230651570143881210),
            int24(3284854),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1738205114915613000-d3b71748-1c9e-4498-8af0-1c1676949e38.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_77(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(6261),
            int24(-228096),
            int24(-6515427),
            int24(-6802455),
            uint256(13486555351804604721504039380098067517069451295410710731534176855531),
            int24(5303101),
            uint256(14134776518227074636667547496086588549863112202760492896624968247980102830),
            uint32(11000037),
            uint32(0),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1738185271002714000-d2f2ef73-9213-44d7-9b67-4652181f0f63.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_78(
    ) public {
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(129),
            uint256(5760587550597834680065067555721485652099911837125998651385022396507),
            int24(-994266),
            int24(-4579208),
            int24(-1385549),
            uint256(842498333348917510033649438361212910483907753485935073386171772703),
            int24(6935206),
            uint256(3996104139986731481956009281935393065694033942477431747601476561066028687095),
            uint32(100179136),
            uint32(2055094091),
            uint256(28948022309329048855892746252171976963317496166390333969235829917579896422551)
        );
    }

    // Reproduced from: medusa/test_results/1738370617106779000-55f8ba43-4a1d-49df-a8ec-c22fe1d525a4.json
    function test_auto_test_swap_panics_79() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6974602),
            uint64(703500961368513542),
            uint64(6335342726366954802),
            int64(-1240),
            uint160(348517194592512547685425336990680232757268),
            int24(-6439971),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738226711365547000-5d671ab3-14ed-4daf-82cc-179b8dbaaabd.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_80() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(2431618),
            uint64(2176227306163068731),
            uint64(1704659644893506045),
            int64(-1),
            uint160(178405919055016581985884180650494831893556160),
            int24(-805786),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }

    // Reproduced from: medusa/test_results/1738436859462707000-491e2a38-063c-45c7-a691-4040d56ecb09.json
    function test_auto_test_swap_panics_81() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6974689),
            uint64(8204324027540120391),
            uint64(1099505794095935831),
            int64(-189263),
            uint160(82931290849517153014226610821900371153),
            int24(3549237),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1739001643550102000-fbecd375-2669-48aa-83bb-c3ecc9db15ab.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_82() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7959649),
            uint64(1017321499940057046),
            uint64(546846966443063761),
            int64(3),
            uint160(47278099258221069063572512861317807664),
            int24(19245),
            uint24(9142515),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738480636584593000-e279fa9c-f669-4524-bdca-6dc53ba4bfe2.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_83(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(108),
            int24(-3327675),
            int24(2786304),
            int24(4065201),
            uint256(21267992848128256184149468497351825625),
            int24(1),
            uint256(11150350426991695962008447454554968265887209),
            uint32(96094113),
            uint32(1218579193),
            uint256(1645504557321206042154969183022927756300628168022661436546489783)
        );
    }

    // Reproduced from: medusa/test_results/1738193973772691000-3657d0df-cfa5-4a83-bc82-4817d45983f8.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_84() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(2777563),
            uint64(11742864885654579380),
            uint64(10794741675125347431),
            int64(1),
            uint160(33079426914656364436341964507243126471),
            int24(1817),
            uint24(11531854),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1739001643554233000-6fb11bc3-5199-411d-abbd-73d63812c56b.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_85() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7959613),
            uint64(880837872942458888),
            uint64(3758264650287471926),
            int64(3),
            uint160(680572775137344541404327493443926949784),
            int24(-5925964),
            uint24(7543011),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738193973768686000-a885465f-658f-4335-8c00-dabcd67e8066.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_86() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-8375426),
            uint64(14261529857864261933),
            uint64(9021940632146829080),
            int64(1),
            uint160(377982782573437675751479016184773434066),
            int24(3299098),
            uint24(13610539),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1738206360971059000-61707b2c-6d89-4fbb-81f0-f80ff2965ad3.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_87() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(6334504),
            uint64(358375029385904910),
            uint64(3454928981948349073),
            int64(-2),
            uint160(0),
            int24(807257),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1738729523482399000-0795cfc2-f841-46e8-b971-ddc0fab43167.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_88() public {
        vm.warp(block.timestamp + 362681);
        vm.roll(block.number + 30689);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7070422),
            uint64(18269862801129289541),
            uint64(13129143264203280711),
            int64(59),
            uint160(44367286454833042865451425695347569754357),
            int24(-3159054),
            uint24(32349),
            true,
            bytes8(hex"cc8973a0f4acc243")
        );
    }

    // Reproduced from: medusa/test_results/1738370617107516000-a7e37a6b-2a98-49c6-8573-7a7767b284b7.json
    function test_auto_test_swap_panics_89() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(-2619770),
            uint64(473295417242984310),
            uint64(60887997813671688),
            int64(-1289),
            uint160(8776125175844439592114832076265028073778123753),
            int24(693),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738484572884295000-a9fa89eb-c8f4-446d-96a3-c34e6c4488f2.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_90() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1781176),
            uint64(15529601013617152495),
            uint64(13692253645539070847),
            int64(-1072),
            uint160(2854495382347378187356791155532575539413147995),
            int24(2087261),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1738222333246031000-53e7f429-4969-4b98-8aa3-d8e5469178c6.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_91(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(89674809839643210801705054966121456271951783669922156515294),
            int24(3503822),
            int24(6400068),
            int24(800261),
            uint256(26046156907981977475446345176402655971180506731457783231956212528493918175),
            int24(-930086),
            uint256(55213977356342739584302215547258835622797252036683259943001165287590973),
            uint32(45980536),
            uint32(2068745116),
            uint256(345)
        );
    }

    // Reproduced from: medusa/test_results/1738484572887053000-3d6d7d3f-e40e-4eb6-a389-7cc1f5022f66.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_92() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1780996),
            uint64(12278113659453884075),
            uint64(12978008546532685403),
            int64(-162),
            uint160(147298699947923618208572328981553214845),
            int24(273791),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1738231407309936000-6305fbeb-ed9f-45f0-ade2-a31ce1d404ba.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_93()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314513), int24(-2373719), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738185270998236000-4a6238a7-3002-4825-a729-bf5f77686642.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_94(
    ) public {
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(399),
            uint256(3092691891945305649911761037981801589904761674835113783070587871097097914764),
            int24(-2069811),
            int24(-6712251),
            int24(-2423483),
            uint256(421250773612274802720493060422879719800421030518610861307287595953),
            int24(69191),
            uint256(243902840575362028927979082149377017839004131574525757588100665473383991),
            uint32(2947546539),
            uint32(730040518),
            uint256(2332)
        );
    }

    // Reproduced from: medusa/test_results/1738185271003812000-fe727212-af78-4f6d-a80a-dfa89f0367af.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_95(
    ) public {
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(96646621623290801559742532675858366870227917468904741195056784785303698198),
            int24(4410095),
            int24(-938103),
            int24(-5177013),
            uint256(3509646989903689197001704864958195776729838045125),
            int24(5858571),
            uint256(243902840575362028927979082149377080165349157305068885689974884938065897),
            uint32(723023716),
            uint32(1020884223),
            uint256(115792089237316195423570985008687907853269984665482107714429055332726041739658)
        );
    }

    // Reproduced from: medusa/test_results/1738333050847581000-5b94f1b6-f8a0-455e-9af4-3c56d46e82f6.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_96(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(208),
            int24(6503569),
            int24(4339993),
            int24(7555400),
            uint256(10068750462081783143184004921460414384256787141723705399653523922127784292500)
        );
    }

    // Reproduced from: medusa/test_results/1738484572885211000-460f718c-d60b-49a4-8d17-c3ff36eea429.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_97() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1781171),
            uint64(15890503196657623246),
            uint64(17986428881055687895),
            int64(-2),
            uint160(730750818632665678816010326635857511188628647470),
            int24(959908),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1738222333177617000-ab084b3d-a31b-43a7-902f-44605287b3a4.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_98(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(8283),
            uint256(91827005275794649698049272060123961530766493762869920721353433),
            int24(3504071),
            int24(6402140),
            int24(-1841880),
            uint256(46768127569320909061018058212845667229105595223950),
            int24(7098562),
            uint256(424751026114823300816889681649843633608),
            uint32(691087545),
            uint32(2130872353),
            uint256(340)
        );
    }

    // Reproduced from: medusa/test_results/1739001643553208000-c0f0ad87-de23-45c9-a372-e43cd33b6229.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_99() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-1955472),
            uint64(831282432370970333),
            uint64(2084585734335289908),
            int64(4),
            uint160(44601511161355994251511929160687404767592138),
            int24(-277758),
            uint24(3243796),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738274136035620000-119377fc-a250-43d9-a410-d4bfb995e557.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_100(
    ) public {
        vm.warp(block.timestamp + 461100);
        vm.roll(block.number + 24171);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(
            int24(-251036), uint256(0), uint256(10781), int24(7193524), int24(3787185)
        );
    }

    // Reproduced from: medusa/test_results/1738222333244978000-d5e00577-5ebc-418a-95d4-1838cf33ad63.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_101(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(795584348983838417106584060462266711815352861343959990327),
            int24(3503749),
            int24(-2051943),
            int24(5491495),
            uint256(1725436586698363872936244994722281737590164064160772766495195944105070),
            int24(-2379762),
            uint256(407910355256664195055111393677826368),
            uint32(277528224),
            uint32(952250232),
            uint256(288)
        );
    }

    // Reproduced from: medusa/test_results/1738986775721221000-4b9f849a-a34a-48c3-956d-c0c9412e202e.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_102() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(3204116),
            uint64(863822344796235289),
            uint64(3536509336745379163),
            int64(142),
            uint160(5708990769778511902026661055790650038447862734),
            int24(905313),
            uint24(0),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738370617104037000-aef31d84-f9dc-4a7a-82cb-8fb9db42f94e.json
    function test_auto_test_swap_panics_103() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(8228657),
            uint64(982969028630363899),
            uint64(1495712669600217269),
            int64(-1095),
            uint160(1637795000299358928741221556114266186),
            int24(1668325),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738231407302718000-04a8430d-c97e-4584-9f02-6004b4a1f959.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_104()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314513), int24(-2372619), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738205114941361000-1fb776c0-d6ef-4bac-b64f-7034132a69fc.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_105(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(250006),
            int24(230584),
            int24(6106063),
            int24(719328),
            uint256(10606660842515392108405912950964943835),
            int24(145573),
            uint256(7237005577437574505641743749740912268403214111146936540957155521547700862067),
            uint32(3974888133),
            uint32(30051685),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1738333050850782000-eece87ec-d0bf-4da3-9709-c387890c65d5.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_106(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(208),
            int24(6503571),
            int24(-752044),
            int24(88),
            uint256(10068750462081783143184004921460414384256787141723705399653523922126584210070)
        );
    }

    // Reproduced from: medusa/test_results/1738222333247381000-a37548a7-dfb0-4a2b-9ef2-d1eb010aa902.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_107(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(197527758238396689391510127527631543838387919587767339923),
            int24(3504083),
            int24(6409766),
            int24(-2542947),
            uint256(6427752177122140606271238128054143238313965178303465319762093),
            int24(-1745110),
            uint256(170450968342388672520835754298280858227),
            uint32(39759290),
            uint32(101614464),
            uint256(313)
        );
    }

    // Reproduced from: medusa/test_results/1738222333248195000-9ecc850b-d96c-420c-be5f-3a731047300c.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_108(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(13164036459937977344802668833771589406525019605478248804432312847),
            int24(3503713),
            int24(-7391402),
            int24(-204080),
            uint256(57896044618658192467152329928197076986386562124687691527981706843554861205882),
            int24(6211938),
            uint256(28269553036454149273332760011886696248146797755409149915918686165006747614),
            uint32(276281192),
            uint32(194984617),
            uint256(237684487542793012780631855619)
        );
    }

    // Reproduced from: medusa/test_results/1738218910031393000-fa650ca6-d04f-4a88-b9fd-a1f3021a62c6.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_109() public {
        vm.warp(block.timestamp + 308783);
        vm.roll(block.number + 176);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(-182882),
            uint64(8068919976552194524),
            uint64(4390551197778590527),
            int64(2),
            uint160(0),
            int24(4266633),
            true,
            bytes8(hex"a305ef2cb4d71ecd")
        );
    }

    // Reproduced from: medusa/test_results/1738185270997202000-5bd72e2a-ae39-4ee1-9bd9-2af81f2719ba.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_110(
    ) public {
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(250033546305),
            uint256(193293243246581603119485064873862599438364706930305283064497108212654416044),
            int24(7709312),
            int24(1906495),
            int24(-13548),
            uint256(1040398588822159403401573038443286963747427592918778451540740958008951572672),
            int24(-625471),
            uint256(57896044726963092129898553599759842852826411091400173526162120577805505075303),
            uint32(111988799),
            uint32(92350356),
            uint256(69)
        );
    }

    // Reproduced from: medusa/test_results/1738199253083447000-f8f3e969-44e4-400c-bb08-d895a28da93c.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_111() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(918305),
            uint64(2406240087175550790),
            uint64(126693359024472627),
            int64(-1),
            uint160(10655187581431170966619280416882514616),
            int24(-978071),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1738193973769311000-f9bf631d-e58e-40c7-9b29-08ed31707c73.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_112() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-7458457),
            uint64(18444965145448240615),
            uint64(6760323913568626815),
            int64(302),
            uint160(642527658427846802604824077528559),
            int24(-3212463),
            uint24(216),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1738480636582627000-8681c751-3a9f-4a73-a4b6-21b54795606d.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_113(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(179),
            int24(-3327401),
            int24(2792335),
            int24(-1330614),
            uint256(13803492693581127574869511724554023217494887067568510074187260426766206),
            int24(-5089919),
            uint256(52656145932358307964375872293708000661670083490861314769036127494),
            uint32(3889169254),
            uint32(1494189810),
            uint256(12855504354095306230532990783366041890086413191340058309501546)
        );
    }

    // Reproduced from: medusa/test_results/1738205114940024000-f8e3c42f-6df6-4648-b38f-3feeb1e70d01.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_114(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(117368484),
            uint256(421249166674228746791649810866531398888730846131591219172463007520),
            int24(856620),
            int24(-216735),
            int24(-3692773),
            uint256(1809251394333065553493296640760748560202383516503837778260434462579917607370),
            int24(263306),
            uint256(441711766194596082395824740561206788840932757825139359742477851337766108),
            uint32(195115541),
            uint32(108627916),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1738370617106194000-98aa5df2-0bcb-4621-9438-70e5bb25681e.json
    function test_auto_test_swap_panics_115() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(-6393241),
            uint64(16053871553529705556),
            uint64(3409098866701479042),
            int64(-1114),
            uint160(356811923421303332226901497760412679920263190),
            int24(-49029),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738484572884749000-ee199e30-1ff3-4ac9-ab76-9a847b680ffa.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_116() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1780922),
            uint64(16407099784783361137),
            uint64(17999311088884839425),
            int64(-1799),
            uint160(144136847712695766998682423848414865418329461),
            int24(-1483),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1738484572885670000-fca4c24e-8b4f-4c16-bf53-e232c5dde366.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_117() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1781172),
            uint64(15945191836927043344),
            uint64(16223534988711388410),
            int64(-17),
            uint160(713623832515244855990671783535823930910337679),
            int24(-3012218),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1738199532503662000-4e1e9154-739e-4ce0-8144-a7d962c5bb64.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_118() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(5121167),
            uint64(15642185305525419314),
            uint64(6535622745523028519),
            int64(-1),
            uint160(449914900490589117086804151350286417225764881850),
            int24(-1737478),
            uint24(1261158),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738205114940640000-61c63052-71a8-4801-a231-e89180b6ccb5.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_119(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(82),
            int24(-4932013),
            int24(-6195385),
            int24(-3137563),
            uint256(13479973333575319897337240778923972451545800732649720200635295828155),
            int24(-8075),
            uint256(17821777334669037315907541530884447748286641877),
            uint32(1405109068),
            uint32(727794300),
            uint256(904625697166532776746648320380374280103671755278926099052884022517915714025)
        );
    }

    // Reproduced from: medusa/test_results/1738436859460352000-fc482412-7cd1-461f-a6ca-4275bc69789e.json
    function test_auto_test_swap_panics_120() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(-3160102),
            uint64(1385001136563681393),
            uint64(24277475709753456),
            int64(-138584),
            uint160(10966060396622375033058923129633928810),
            int24(899247),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738226711364349000-17d47630-c636-4429-9903-cd907d4c064b.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_121() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(2431558),
            uint64(5104521715819449956),
            uint64(6004166517901879061),
            int64(-1),
            uint160(91343851556512059173842762216097871079341649041),
            int24(-5517116),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }

    // Reproduced from: medusa/test_results/1738199532500199000-d6b77ede-1d3f-4eb9-8f4f-f1f8368d4334.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_122() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-5576077),
            uint64(4055249712540852507),
            uint64(4803841987603533108),
            int64(-1),
            uint160(294727933220246712525965532130882),
            int24(-137),
            uint24(1007048),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738199532499165000-4896fa15-a4a5-4cf5-8113-9dc12e0d4cfa.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_123() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-5641522),
            uint64(5037193495182194576),
            uint64(2756750419007961295),
            int64(169),
            uint160(5548363131494499459967178135964098852994784),
            int24(2383591),
            uint24(0),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738333050849487000-80f46c30-91d2-45a4-ae24-3c9b0f867fe9.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_124(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(208),
            int24(6503569),
            int24(-752914),
            int24(3381100),
            uint256(10068750462081783143184004921460414384256787141723705399653523922128984242056)
        );
    }

    // Reproduced from: medusa/test_results/1738333050849815000-193f36f4-b729-459c-ad55-08eee2f31923.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_125(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(108),
            int24(6503570),
            int24(-7521389),
            int24(-1375259),
            uint256(10068750462081783143184004921460414384256787141723705399653523922128984253891)
        );
    }

    // Reproduced from: medusa/test_results/1738484572802420000-1f216ee0-5364-46b7-ba82-9feebead3b9d.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_126() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1781167),
            uint64(17171797377279899833),
            uint64(17395990527737738275),
            int64(-168),
            uint160(340292758346194306838157864387305272263),
            int24(1321471),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1738480636585432000-771e5187-43fb-4f7c-bd68-f41f42a5ae52.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_127(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(111),
            int24(-3327667),
            int24(2785080),
            int24(4981601),
            uint256(28948022309329048855892746252217693490974486506981334038449513433539502101517),
            int24(1),
            uint256(24519928655638281349140501357044007541801097410705088365),
            uint32(3076365605),
            uint32(495517508),
            uint256(14134776524809092865951204174563224854163196438620958813909986013465802868)
        );
    }

    // Reproduced from: medusa/test_results/1738480636585864000-725360e9-806b-4690-a116-293028586881.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_128(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(130),
            int24(-3327671),
            int24(2820900),
            int24(4979401),
            uint256(5708990781424880710324207540546721258500698527),
            int24(-6510849),
            uint256(6582821698306953669466638516761910861871505666581696227516641381),
            uint32(584965923),
            uint32(2113396118),
            uint256(226156425134131527535119573678437791495279171867081704951540971298597105030)
        );
    }

    // Reproduced from: medusa/test_results/1738226711365286000-a8e1cf8b-e30e-4ff6-a364-e122cf0f0127.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_129() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(2431528),
            uint64(4603350658803391811),
            uint64(4278827857917047596),
            int64(-1),
            uint160(2621188998615547820712169943890626579),
            int24(2073681),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }

    // Reproduced from: medusa/test_results/1738231407294585000-fa06199d-2592-4492-9136-72a88055f762.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_130()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314617), int24(4697402), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738206361038691000-96e860af-8d98-4bbb-8081-b6914614d56d.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_131() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(1968205),
            uint64(4787592613905165284),
            uint64(1086979539488120018),
            int64(-2),
            uint160(0),
            int24(977137),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1738199253083105000-44f686c0-834e-4f81-9bd2-52d191a96cc8.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_132() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(7993386),
            uint64(824676252419525968),
            uint64(876515829797679063),
            int64(-1),
            uint160(1361211272781867595456485968842973412173),
            int24(-246102),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1738480636581483000-0fa85e14-5d9e-44d9-b9fa-091728a783e4.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_133(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(136),
            int24(-3327672),
            int24(2781130),
            int24(5173001),
            uint256(87282468631636619696323257211535541225205),
            int24(1),
            uint256(401734511064747570279287152200817283387285275916893363782757),
            uint32(192229606),
            uint32(1489009009),
            uint256(7238772424397040598302769860543678827428402451897319728567749464950315033057)
        );
    }

    // Reproduced from: medusa/test_results/1738222333243999000-3de5ba77-d3f2-4b0b-8d82-d967096b6e53.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_134(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(21380138409898590272793098487019620291536166301989312),
            int24(-1791561),
            int24(-1928574),
            int24(270651),
            uint256(448613512541479180721186302779571835273268595354326679464467915328349575),
            int24(-949922),
            uint256(3533700869543435446826543668239836602626498651083846613428155484206921158),
            uint32(126514392),
            uint32(1012019328),
            uint256(57896044618658097711785492504343953926634992332780667938471659835159792845167)
        );
    }

    // Reproduced from: medusa/test_results/1738480636530776000-83f9f2f4-efad-4c53-8fed-4d578e869507.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_135(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(132),
            int24(-3327676),
            int24(-7730100),
            int24(-1446799),
            uint256(9147773835953805594621875528771523991301),
            int24(1),
            uint256(12855504354071922204379251371991022087643956317219377155800383),
            uint32(1900477605),
            uint32(2106257288),
            uint256(5574987343769768868561666727842636347976061)
        );
    }

    // Reproduced from: medusa/test_results/1738333050848400000-d3d9092b-2684-40bb-bc6b-31d1f9d87f64.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_136(
    ) public {
        vm.warp(block.timestamp + 488446);
        vm.roll(block.number + 14558);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(208),
            int24(6503569),
            int24(-7526760),
            int24(7239582),
            uint256(10068750462081783143184004921460414384256787141723705399653523922125384257223)
        );
    }

    // Reproduced from: medusa/test_results/1738206361038900000-a04b25ce-87d9-469d-acc4-8df599d44b5d.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_137() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-511809),
            uint64(115),
            uint64(20879317868291967),
            int64(-1),
            uint160(22997965581567187166272265974795047243),
            int24(-5279337),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1738193973770858000-af87df5a-43d5-412f-9316-6762f806c235.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_138() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-7458464),
            uint64(6953565125260366678),
            uint64(5453291097621432926),
            int64(33),
            uint160(17140864208424468541457287458011437254766705),
            int24(409385),
            uint24(15026097),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1738185270999492000-e5a6f9ea-7bb1-4eab-983a-5de01faa157a.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_139(
    ) public {
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(17592186036192),
            uint256(58089337861904679314904977569217816525919003661185966035959247738760507276924),
            int24(284510),
            int24(-6028504),
            int24(4912886),
            uint256(15073819043601347129049288705396782226726458289571185531896),
            int24(-390883),
            uint256(487805681150724057855958164298754371374261880135857767454339211789283041),
            uint32(15711365),
            uint32(318235829),
            uint256(115792089237316195423570985008687907853269984665561335876943319670319585689685)
        );
    }

    // Reproduced from: medusa/test_results/1738205114942345000-462854df-bb5d-4f26-9e8c-d5090ec407e4.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_140(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(48322585745190),
            uint256(8),
            int24(-1374436),
            int24(7021696),
            int24(-1126999),
            uint256(862718293348820473429344482784628924146623198856763465974010040432606),
            int24(-5567),
            uint256(803469022130962815075330401240814008490170314303660629513787),
            uint32(17995219),
            uint32(4217170523),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1739001643555890000-fbdd9b23-b6e2-44e1-b82b-cbd2c1e0a5f9.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_141() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-1179926),
            uint64(753661027136456818),
            uint64(851420330512309646),
            int64(251),
            uint160(356811923093422909486932574403963892059622438),
            int24(2007560),
            uint24(160),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738729523482891000-634a90c8-7055-46e6-8ff9-79527cc3e4d9.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_142() public {
        vm.warp(block.timestamp + 362681);
        vm.roll(block.number + 30689);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7070509),
            uint64(7901195287635709979),
            uint64(9484455309357365890),
            int64(14),
            uint160(10888620902400656010175063916385478709678),
            int24(-938253),
            uint24(7019163),
            true,
            bytes8(hex"cc8973a0f4acc243")
        );
    }

    // Reproduced from: medusa/test_results/1738436859459961000-ff797c5f-fdaa-4db4-9922-610ceef970fb.json
    function test_auto_test_swap_panics_143() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6974761),
            uint64(19149068369518327),
            uint64(2941689621556876935),
            int64(-112021),
            uint160(44601490469319993300600682046072344717504232),
            int24(6548206),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738199253079599000-747a00fe-3ef7-42ce-8afa-643083f965ed.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_144() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-1379239),
            uint64(548526245871072431),
            uint64(1487470191802561621),
            int64(-1),
            uint160(89202980776249557757449702091189331339244104),
            int24(-2584096),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1738231407310538000-586d1360-66fb-41e2-9080-c83786698bc4.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_145()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314513), int24(-2373235), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738185270997513000-97901f55-a0e0-4ef1-a02b-2e585478fefb.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_146(
    ) public {
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(0),
            uint256(193293243246581603119485064873862599202175469507613447755909353725332335540),
            int24(-6648334),
            int24(2451344),
            int24(-190170),
            uint256(11972621841438572753731700935234818955146465924097581),
            int24(1715568),
            uint256(401741280728482025030176832717632225812247708145662624141266),
            uint32(2174287186),
            uint32(1490851633),
            uint256(147)
        );
    }

    // Reproduced from: medusa/test_results/1738199532498323000-1e7b86d0-a79d-41c4-8ae4-27525cf9efa7.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_147() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1418983),
            uint64(4144426360782169292),
            uint64(3087545817711473077),
            int64(-1),
            uint160(1393900951775729630397078746657988138611255),
            int24(-7697),
            uint24(1009175),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738436859458805000-58ae26b5-e5eb-4778-9308-984989b61f87.json
    function test_auto_test_swap_panics_148() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6974614),
            uint64(1083067227760809038),
            uint64(1484561336193595366),
            int64(-157543),
            uint160(5575187245444345132907331804000298195280522),
            int24(1906273),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738436859463110000-d3b38ce0-588d-4dce-9b14-29ad99a1c40f.json
    function test_auto_test_swap_panics_149() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6974757),
            uint64(8320292907605510233),
            uint64(506625146713784457),
            int64(-109438),
            uint160(15592042679784245162815519021891998),
            int24(0),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738480636586721000-d2c7041a-0fa9-4d08-9933-7c563cc95641.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_150(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(103),
            int24(-3327721),
            int24(2784871),
            int24(2544200),
            uint256(1464356132716936190092245297683793327998746611938),
            int24(6814213),
            uint256(52656145834278593348959014183076167141617196716296520499720309449),
            uint32(1086641130),
            uint32(1063026663),
            uint256(28269553036454149273332760011529897772526980803207992667422456359939522321)
        );
    }

    // Reproduced from: medusa/test_results/1738226711366069000-600464a9-b692-4d36-9766-1b3634c299e9.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_151() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(2431670),
            uint64(2385653068460042095),
            uint64(2289414449501336800),
            int64(-1),
            uint160(679746619375423247936244968476012206920),
            int24(0),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }

    // Reproduced from: medusa/test_results/1738193973717256000-0ebfd75b-e221-4d7a-a335-cf22ebb82881.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_152() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-7458454),
            uint64(7449358382494790439),
            uint64(5372723384962282313),
            int64(1),
            uint160(95014621027704505724369780261088005),
            int24(-53890),
            uint24(3147679),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1738206361038502000-29c591bd-da05-462a-bcb9-c19dcb5c9f58.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_153() public {
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-4485640),
            uint64(241561416712124505),
            uint64(1375722617834031416),
            int64(-2),
            uint160(0),
            int24(40598),
            false,
            bytes8(hex"b68af69e9073037d")
        );
    }

    // Reproduced from: medusa/test_results/1738226711367283000-3458e227-2194-451c-bbc3-2ca3d25049fe.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_154() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(2431732),
            uint64(2452471059985894958),
            uint64(2353635641440628674),
            int64(-1),
            uint160(154443992403100965233695808223494538652816740),
            int24(1489882),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }

    // Reproduced from: medusa/test_results/1738193973772177000-a6e12f88-f007-4269-8de1-0c2aca0d5fed.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_155() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-7458463),
            uint64(6811731682290519081),
            uint64(12624829140411636059),
            int64(17),
            uint160(137126949504046254373913391864872230272254698),
            int24(-8200324),
            uint24(7020872),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1738199253044660000-9ab6347c-bca4-4b8a-87cd-e6a76de55089.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_156() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-3716037),
            uint64(1298749926315918039),
            uint64(15664127701989748006),
            int64(-1),
            uint160(1461501637078373640920466349717976443537781210251),
            int24(2302824),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1738480636585011000-651a6b41-60a1-4993-baa8-c57ea95ad488.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_157(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(127),
            int24(-3327677),
            int24(-7730575),
            int24(1913401),
            uint256(89203316672027401309864026352312799897921711),
            int24(1),
            uint256(421249191782635688339108848597633095446112539879420553983034205070),
            uint32(170476907),
            uint32(1082545053),
            uint256(911030517776354419941387761689417965587828210853312098014929443497528380)
        );
    }

    // Reproduced from: medusa/test_results/1738436859459204000-5dfb165c-8baf-49b1-9400-e7162d567617.json
    function test_auto_test_swap_panics_158() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6989705),
            uint64(7855816377919451184),
            uint64(10675175210491790259),
            int64(-115462),
            uint160(68127827047110259866654052105831978),
            int24(-56476),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738199253081962000-560ca5fb-eaa9-426a-b9c2-fb33ce9bd84c.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_159() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-2274009),
            uint64(2780118386973018),
            uint64(530625636152883011),
            int64(-1),
            uint160(2724425095017519084983171207718241531302),
            int24(-2747808),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1738370617108216000-118536c7-b021-4d3d-976e-750d46f9ab43.json
    function test_auto_test_swap_panics_160() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(7974571),
            uint64(1751908549156518684),
            uint64(73887886874550015),
            int64(-4578),
            uint160(36565271318958437673439578508019967670),
            int24(-1435513),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738231407309354000-cf36f57f-2ec5-48fa-b431-3d3dbcbe580b.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_161()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314617), int24(-2373437), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738193973775548000-f77ebd19-8f4e-484d-9c26-88b162c02c8f.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_162() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-7458471),
            uint64(4040007539570943144),
            uint64(4987736262908603923),
            int64(3764),
            uint160(57436847059440385306849751065509518769),
            int24(-1618902),
            uint24(0),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1738436859459586000-6971bbf4-6edd-4c01-a7d1-a2e8dff3cf3b.json
    function test_auto_test_swap_panics_163() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(-2731735),
            uint64(89129798922924776),
            uint64(16521856027267570555),
            int64(-153394),
            uint160(165724447701496562248965321789589731),
            int24(866700),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738729523481413000-bc7d2bd7-38ec-47e6-82fc-14a962c52bb0.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_164() public {
        vm.warp(block.timestamp + 362681);
        vm.roll(block.number + 30689);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7070543),
            uint64(3688704921638151506),
            uint64(5510644379658127849),
            int64(301),
            uint160(43101031806474674546374202071553881935),
            int24(6846572),
            uint24(0),
            true,
            bytes8(hex"cc8973a0f4acc243")
        );
    }

    // Reproduced from: medusa/test_results/1738199532499606000-7d1e205c-69e0-4d14-bc63-cc29505b2a02.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_165() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-4400644),
            uint64(2025223917216579616),
            uint64(9991636189217970096),
            int64(215),
            uint160(1199589541264792977099244597039035056562),
            int24(-174173),
            uint24(0),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738436859463507000-946ec373-75fb-484b-9aa4-3284d56017d5.json
    function test_auto_test_swap_panics_166() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6974761),
            uint64(362236115904881434),
            uint64(5211300814408602648),
            int64(-162315),
            uint160(288520742275489513174300425984089050693),
            int24(-6502770),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738370617105554000-52b3ffa2-cfbf-427d-9f29-ec158756b743.json
    function test_auto_test_swap_panics_167() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6449192),
            uint64(85099501272859337),
            uint64(18458164788332530),
            int64(-1660),
            uint160(1071134009173772806331713460984015389124102),
            int24(46),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738182207631426000-e3e75eee-69fd-473b-9743-39edeee76640.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_168() public {
        vm.warp(block.timestamp + 330191);
        vm.roll(block.number + 16879);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(
            int24(-6845296),
            uint64(577610496812831237),
            uint64(11168238706049314837),
            int64(4),
            uint160(43063969689251991588418110594366056514186),
            int24(-6936140),
            false,
            bytes8(hex"e271f63b1e78c67d")
        );
    }

    // Reproduced from: medusa/test_results/1738199532500819000-b88e020d-2590-4c85-9db4-3b05cd70a7de.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_169() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-5641610),
            uint64(4478048040848612772),
            uint64(2665727861726392879),
            int64(122),
            uint160(91340420645524437383132925463978969816515825313),
            int24(2014479),
            uint24(0),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738480636583732000-e3c75197-fa30-4176-bc56-102ac37bee65.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_170(
    ) public {
        vm.warp(block.timestamp + 201241);
        vm.roll(block.number + 60251);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(261),
            int24(-3327668),
            int24(2782365),
            int24(4106801),
            uint256(1809251394359393626410435937435250367872404539012186476897725553429555010673),
            int24(1),
            uint256(113078212145816597093331040053255775783782808923771432310487643427605606904),
            uint32(2507470036),
            uint32(792984320),
            uint256(14134776518227074636666380005943348126627057387730666119669172389077848052)
        );
    }

    // Reproduced from: medusa/test_results/1738205114941026000-8ad31aa1-d2fc-4563-ae6d-6bde0748291d.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_171(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(1000000000000000000307462790750273702),
            uint256(3563),
            int24(4064767),
            int24(-7834166),
            int24(-2489798),
            uint256(21778071497419443181297147226612580211459),
            int24(-3307106),
            uint256(12855602433786537978034556186307221757483234018530311257750335),
            uint32(3744340623),
            uint32(1647252780),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1738205114941710000-7028621e-c5c6-45cc-9511-5bdcc16d729b.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_172(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(72690017952858907),
            uint256(12336),
            int24(-2203221),
            int24(5901860),
            int24(-3584853),
            uint256(6477968990919054548278534685770916466487964956948829512950096),
            int24(4972796),
            uint256(421352010709061322169306796350859516537890013056831959171072173501),
            uint32(598951151),
            uint32(879816331),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1738440434147288000-892be36a-e6c2-42a8-b198-60807ed4396b.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_173()
        public
    {
        vm.warp(block.timestamp + 360394);
        vm.roll(block.number + 31886);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(1000047996502213716),
            uint256(2199),
            int24(-7070639),
            int24(-4253730),
            int24(1541671),
            uint256(6739986666787659948666754468648171248472793041395552200856343300366),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1738199253082604000-beccff97-60a9-44b5-86c1-097cf38da6a9.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_174() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-5988500),
            uint64(8706699231690114325),
            uint64(217350354325338437),
            int64(-1),
            uint160(713623846204297053797460566418851943386011825),
            int24(6064500),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1738193973771356000-615da74d-6431-4125-86ee-3e6b27af06aa.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_175() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(2777521),
            uint64(5746534435807136005),
            uint64(6348364545640068611),
            int64(1),
            uint160(212782318224628834009724073314376719312),
            int24(2629792),
            uint24(1372722),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1738726169001272000-cd1ef49b-a470-4feb-aca5-9a2ad3b1801c.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_176() public {
        vm.warp(block.timestamp + 362681);
        vm.roll(block.number + 30689);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7070543),
            uint64(5199251001848823380),
            uint64(6737012563022724361),
            int64(764),
            uint160(11417981539068471395647700552578229373833132833),
            int24(104994),
            uint24(0),
            true,
            bytes8(hex"cc8973a0f4acc243")
        );
    }

    // Reproduced from: medusa/test_results/1738370617105002000-fc1aa755-3d39-46d0-b1ee-b87bb87466ce.json
    function test_auto_test_swap_panics_177() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(3486904),
            uint64(16413986327122966259),
            uint64(266072434276489636),
            int64(-1129),
            uint160(44601489643560507930630452650044582600786903),
            int24(6211568),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738199532500330000-b5819594-6b3c-416d-baba-8ef67861ccb0.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_178() public {
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1218565),
            uint64(14480428105923307407),
            uint64(7521995275486855480),
            int64(-11),
            uint160(31407120635206944709033399513706669640),
            int24(-4229111),
            uint24(0),
            true,
            bytes8(hex"ddbf2a17f8927e19")
        );
    }

    // Reproduced from: medusa/test_results/1738370617109647000-f3a05663-7108-4128-9eca-f790db9a47a6.json
    function test_auto_test_swap_panics_179() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(4804487),
            uint64(2373232984628264828),
            uint64(5836635994965814228),
            int64(-1940),
            uint160(10973996823234474156954095261826802306099),
            int24(7290810),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1738484572886127000-256f9edd-bc8e-434b-9d68-0f011db8acb5.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_180() public {
        vm.warp(block.timestamp + 95);
        vm.roll(block.number + 68);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-1785239),
            uint64(12655808399448436260),
            uint64(13346927379413966559),
            int64(-49),
            uint160(713623845151714500511202559586648591263573244),
            int24(-1401908),
            uint24(0),
            true,
            bytes8(hex"39dc6dadab5c4a43")
        );
    }

    // Reproduced from: medusa/test_results/1738231407309647000-16a20af5-337a-4922-ba2e-3a4bfcd1b161.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_181()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314513), int24(-2372644), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738436859390462000-21ab8533-ddc2-4184-8257-a406af2cd9af.json
    function test_auto_test_swap_panics_182() public {
        vm.warp(block.timestamp + 495534);
        vm.roll(block.number + 23850);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(
            int24(6941993),
            uint64(159376153894106137),
            uint64(106854140449870305),
            int64(-137067),
            uint160(1757501856812547795513892178802776927238017669),
            int24(-180465),
            true,
            bytes8(hex"921562872e9e6dd9")
        );
    }

    // Reproduced from: medusa/test_results/1739001643553717000-54e2f744-2e31-4df9-bcec-f6bee1c11efc.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_183() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7959628),
            uint64(1064822724719740877),
            uint64(846025773766830285),
            int64(4),
            uint160(63791096497274169389453954937703835996),
            int24(1254280),
            uint24(9208488),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738226711363505000-b34b54dd-1a4e-4eb1-a3c3-5f90ba0bad08.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_184() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(2431596),
            uint64(7120317311111855528),
            uint64(1917963453517468190),
            int64(-1),
            uint160(10636411836197717438024863749124004900),
            int24(545417),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }

    // Reproduced from: medusa/test_results/1738222333244540000-f3c2cf77-5123-49f7-a5ac-bd091abdee9c.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_185(
    ) public {
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(43786528242013286509235937747262937257818264019835099311),
            int24(3503825),
            int24(6408289),
            int24(2587652),
            uint256(2674589563176951631162088606790760058815455713),
            int24(2332138),
            uint256(7067388285441610235472486677453968453091720866760115945994872051261867990),
            uint32(5518002),
            uint32(1489994755),
            uint256(339)
        );
    }

    // Reproduced from: medusa/test_results/1738193973771604000-c74fd018-fe38-405a-8e36-7294d1a3ea1c.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_186() public {
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(-7458450),
            uint64(4833532291212561639),
            uint64(4675786385696636900),
            int64(7),
            uint160(45671926155961147915402337127978935694787416549),
            int24(-373291),
            uint24(3031360),
            false,
            bytes8(hex"216d6a53c80a63a5")
        );
    }

    // Reproduced from: medusa/test_results/1738199253081342000-de1fbb50-3aec-4564-b939-b45a85342bb3.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_187() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-4067483),
            uint64(14951458478040210540),
            uint64(194198871604374799),
            int64(-1),
            uint160(35183937184910868826145458535769534),
            int24(9946),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1738205114942186000-e0b77ff4-9e9f-4d27-948e-abfc426c2309.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_188(
    ) public {
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(1000000000000000021038382474148962879),
            uint256(849),
            int24(-1690333),
            int24(5910726),
            int24(563447),
            uint256(1725436586697640946859419716387921813418887723892451084730861904997345),
            int24(-4597091),
            uint256(3369993335842234263210622462807735453904225328096764207181627013816),
            uint32(892418721),
            uint32(1119668750),
            uint256(0)
        );
    }

    // Reproduced from: medusa/test_results/1738199253080712000-4da8f69a-3050-4b9b-8bb1-d043c7c62d90.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_189() public {
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(-2901568),
            uint64(1806386928506230119),
            uint64(1618233420749224710),
            int64(-1),
            uint160(10889035739254145990623968385104428632376),
            int24(5825179),
            true,
            bytes8(hex"d7d862e7caf4f507")
        );
    }

    // Reproduced from: medusa/test_results/1738231407297928000-89229557-8098-4dd4-b6ee-62a4ccb024be.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_190()
        public
    {
        vm.warp(block.timestamp + 525367);
        vm.roll(block.number + 7044);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(1809), int24(-314513), int24(-2374858), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1739001643552678000-444efd23-bb2a-47cd-8d66-1f9d9cd8df75.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_191() public {
        vm.warp(block.timestamp + 112);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7959548),
            uint64(803210906080935662),
            uint64(760961975354763053),
            int64(236),
            uint160(696898289649904827728578664043832468246122),
            int24(1003590),
            uint24(0),
            true,
            bytes8(hex"29d96e61abf66805")
        );
    }

    // Reproduced from: medusa/test_results/1738729523483377000-1530f752-09f2-4091-aae6-07137ef726a1.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_192() public {
        vm.warp(block.timestamp + 362681);
        vm.roll(block.number + 30689);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7070512),
            uint64(15760940256013031031),
            uint64(10300990106635363403),
            int64(16),
            uint160(340279257609833388832059609169190704894),
            int24(-1857853),
            uint24(7089631),
            true,
            bytes8(hex"cc8973a0f4acc243")
        );
    }

    // Reproduced from: medusa/test_results/1738729523481915000-d6868eb2-1f6c-4eea-a286-699df3923fd2.json
    function test_auto_test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut_193() public {
        vm.warp(block.timestamp + 362681);
        vm.roll(block.number + 30689);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_compare_swap_with_reverse_swap_with_exactIn_vs_exactOut(
            int24(-7070512),
            uint64(11734377570718781336),
            uint64(8630158758327124853),
            int64(13),
            uint160(165055001387329923146693605646127454),
            int24(-2681338),
            uint24(8084069),
            true,
            bytes8(hex"cc8973a0f4acc243")
        );
    }

    // Reproduced from: medusa/test_results/1738226711366330000-366adad3-5b16-40bf-80e9-a160b607fb9c.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_194() public {
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(
            int24(2431670),
            uint64(8173794313509089712),
            uint64(3651628738360893395),
            int64(-1),
            uint160(36417595898515878726680336391358457933),
            int24(-1126553),
            true,
            bytes8(hex"f5595c69408dce48")
        );
    }
}
