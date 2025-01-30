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
        target.swap_should_move_sqrt_price_in_correct_direction(int24(2431591), uint64(12263199411267445028), uint64(4282422680320060927), int64(-1), uint160(2787592726533198877256377895422333727229689), int24(-1397569), true, bytes8(hex"f5595c69408dce48"));
    }
    
    // Reproduced from: medusa/test_results/1738185270996976000-2ba619f3-17bf-4bcb-af62-70363900e634.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_1() public { 
        
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(uint256(0), uint256(843201530070942580824563101788882193200888325591232020225676043082), int24(-497192), int24(-4571524), int24(-6304703), uint256(6612889410686119727540169826680399009960506172526972618961073775), int24(1364641), uint256(1606938045007279709605101910210712480785508464111487167956281), uint32(270942132), uint32(3602346150), uint256(166));
    }
    
    // Reproduced from: medusa/test_results/1738193973777205000-6df590fb-6af5-4be1-94e9-dc78ec552851.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_2() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-7458456), uint64(4737387383487723008), uint64(7353743345480704775), int64(18), uint160(148885905339517172831832394930865399598), int24(2981071), uint24(1022341), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738205114943248000-e8bded1e-ffb3-4fa8-af98-24c17829782f.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_3() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(179628662498162), uint256(46770906889974303602647264572878578803946493031570), int24(3967430), int24(-59628), int24(-1457279), uint256(6901746346792133062868693881895506324947143680884708272202216927426762), int24(2812591), uint256(5427754182999196660479889945666277996756719184629076725638222829852882943742), uint32(0), uint32(0), uint256(0));
    }
    
    // Reproduced from: medusa/test_results/1738206361037685000-9e02ea6e-18a8-49c4-89ae-f76579827b0c.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_4() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-5600188), uint64(3376715404708103377), uint64(9291026660424377271), int64(-2), uint160(0), int24(4228937), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738193973770063000-6c5612c1-21b0-401e-8ebb-aecc26e707bd.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_5() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-7458665), uint64(7100066048358245178), uint64(8682334560346742752), int64(149), uint160(340776971899385564246653090939311600484), int24(817788), uint24(3000275), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738206361040709000-fb37fb50-c6c9-4f29-a9ed-4a4f6fda35c3.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_6() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(5101029), uint64(13211802461400671688), uint64(152667221105632691), int64(-2), uint160(0), int24(-7658029), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738222333246926000-ec82496f-7a72-4c22-80e3-98b34ab8bdd2.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_7() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(325), uint256(7067388259113716667952869289392308391560561826327756108958918169173205491), int24(3504193), int24(6399712), int24(7346020), uint256(46267268963585865782744244337905625521042166722149870237521), int24(2331834), uint256(14135207877373749046903094678181094622249004552060190549387186448297007731), uint32(182660951), uint32(1683327117), uint256(79228162514264337593543950488));
    }
    
    // Reproduced from: medusa/test_results/1738206361038013000-1c9ac421-6af5-4f8b-93e2-988f32723a61.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_8() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(49711), uint64(131635765744145101), uint64(14552832676011720818), int64(-2), uint160(0), int24(1243536), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738206361037081000-bfbc7d47-b432-49bc-945c-d23d79ed17ad.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_9() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-3025608), uint64(1914197916023), uint64(186554795827004624), int64(-2), uint160(0), int24(-32606), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738199253079989000-96d43da8-38c1-47a7-8d37-9c369db59384.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_10() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(1004789), uint64(169046432152444984), uint64(3314550232711777963), int64(-1), uint160(170072452586773387297202160748630989887), int24(912869), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738199532501423000-1a6e6450-f3f7-4c29-8e81-3f106a0bbba7.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_11() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-5387828), uint64(3821390690748950222), uint64(4911909711875293697), int64(-1), uint160(95435950028333683580484981050131254351), int24(78843), uint24(7068906), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738205114941870000-64ae6384-9ac0-4a8b-9821-e9e3c39b2825.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_12() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(47741053883848), uint256(3972), int24(-5524462), int24(-7983893), int24(-65435), uint256(746440268825049178749069378889684056), int24(-7744), uint256(1811018673599488945581574146517076939289154670999569471527089163125878550342), uint32(1729719254), uint32(226197518), uint256(0));
    }
    
    // Reproduced from: medusa/test_results/1738226711365809000-ab355229-00d7-477c-94fb-11f8baa18f5e.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_13() public { 
        
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-3572602), uint64(4251657459075127000), uint64(3327526741676652153), int64(-1), uint160(11763630669517939980740434637236894), int24(-4135), true, bytes8(hex"f5595c69408dce48"));
    }
    
    // Reproduced from: medusa/test_results/1738205114942024000-72c0764c-5262-45c7-aeb6-744682aa970d.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_14() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(1079792991174), uint256(86), int24(4152762), int24(-2891672), int24(-1830899), uint256(383123885219259818172582418193790283209460646952982723), int24(2714545), uint256(862718293348820473429344482784628143735426590571331078115542645819349), uint32(3308068245), uint32(249128230), uint256(0));
    }
    
    // Reproduced from: medusa/test_results/1738199532413083000-eda7524a-67d3-4a88-9b79-be2388b8399b.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_15() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-4461627), uint64(8747169586498128909), uint64(7913678203497506570), int64(-63), uint160(5446158808219073485824370888896673085411), int24(2488339), uint24(0), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738205114942509000-7707180b-eee0-4bf3-827e-157bb446a443.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_16() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(49014778823857509), uint256(23842), int24(-1939145), int24(2368892), int24(-1781170), uint256(52656145834278593348959013513230358246812460623121986648010867813), int24(990392), uint256(110427941548649020598956095717618989642580623551073637754877911432818569), uint32(6475907), uint32(2901851575), uint256(0));
    }
    
    // Reproduced from: medusa/test_results/1738222333246687000-410264ec-8ce2-43a0-8e54-b763b74047ce.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_17() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(250066465), uint256(331488855816674795095241824193152747634546683384495573123569546), int24(3504204), int24(6399225), int24(-460505), uint256(421249166674228768336548136470073810200676548153303523830486936108), int24(-6981045), uint256(170073143997801161790490158391126927046), uint32(442756612), uint32(114767363), uint256(308));
    }
    
    // Reproduced from: medusa/test_results/1738222333248575000-db061a33-06d4-4b6f-a1e2-c27e41b676e3.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_18() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(0), uint256(842509811724116967914323150413456891599569450024478930066542136208), int24(3504185), int24(6393753), int24(1010689), uint256(2468256836364938334667932437627221666101970116657605803310274864), int24(-3719125), uint256(68012253685716273268260013272871047), uint32(118162693), uint32(51119), uint256(7237005577332262213973186563042994240829374041597583492308957479394974105823));
    }
    
    // Reproduced from: medusa/test_results/1738185270969674000-a66b3338-218c-4ebe-883d-cf094574b41d.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_19() public { 
        
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(uint256(0), uint256(386586486493163206238970129747725198699633058414421731024838153695320928688), int24(-7214225), int24(-2629401), int24(-1960836), uint256(877411747560915043465333564950678998264267121358), int24(-1008526), uint256(228477846865278104601911533911855715173829270696372184483013474234830095), uint32(1354874022), uint32(27472375), uint256(100));
    }
    
    // Reproduced from: medusa/test_results/1738199532499948000-ab7b2653-f427-4e73-b0b4-58067bc36c58.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_20() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-5288012), uint64(6163576639661295311), uint64(9187731711883050016), int64(-1), uint160(4808233671057346922495749544874234250435), int24(-2151631), uint24(3555438), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738206361036664000-affbe9fb-08a0-47cf-9c70-c7c6d435f908.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_21() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-6409343), uint64(22913928279350727), uint64(982812477560640991), int64(-2), uint160(0), int24(-4881), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738199253080967000-4099185c-76d1-4706-9cf9-6b01087ad410.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_22() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(912708), uint64(579904616679516816), uint64(1757317441899207301), int64(-1), uint160(21772034620251467729501303289619211097505), int24(-27291), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738184483528642000-b1759628-7eaa-44ac-94cf-57fd11f7df61.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_23() public { 
        
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(uint256(500000000000000875), uint256(6040413851455675097483908277308206206358866626193655539170786876312847847), int24(-3591060), int24(-6530392), int24(-3679), uint256(60295276174405388516197288677448377103675823270765421906045), int24(-43885), uint256(124878254374585358811125290060481033302056038869092335864431390965808734231), uint32(982950614), uint32(2730783055), uint256(87));
    }
    
    // Reproduced from: medusa/test_results/1738226711364844000-c353fb2c-d6aa-4c20-a19e-c63662803918.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_24() public { 
        
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(2431591), uint64(2694193385200787081), uint64(9121984150969209232), int64(-1), uint160(693058620625707355947529870831372330380), int24(-838907), true, bytes8(hex"f5595c69408dce48"));
    }
    
    // Reproduced from: medusa/test_results/1738185270999955000-ffaf67db-3ea1-4b30-a94d-948b95ccf094.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_25() public { 
        
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(uint256(0), uint256(1474710412953045678096657294264757387745288946117168346848885869376046), int24(-5072041), int24(-6532656), int24(44815), uint256(942113689494360843822973269616125970751869169205597970736), int24(-260966), uint256(124878254374585358811125289582626898952336884264894352643712089686449920921), uint32(780707682), uint32(656613005), uint256(229));
    }
    
    // Reproduced from: medusa/test_results/1738199532497947000-6d29ae0b-b3ad-4ea4-a078-8c4000eee465.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_26() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-4461599), uint64(3064468463387456311), uint64(3903096050278708272), int64(-1), uint160(11150370105820519249441570005706819889974387), int24(6709882), uint24(7088175), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738206361036149000-bab2e812-129f-4a44-80fd-0dea7ed0f8d0.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_27() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(7527614), uint64(4984186013794863746), uint64(15103628058640773853), int64(48), uint160(0), int24(366921), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738222333245625000-a115980e-7446-47a6-8cd6-ff687e5263e7.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_28() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(0), uint256(376123413609654877517543639961638325694886779431589964417169482127), int24(3503824), int24(-7114120), int24(-4147105), uint256(1284174686185139140566045011284637653770824), int24(-7354523), uint256(904625697166532776746648320380374279995821459854507115075874318653076642789), uint32(92686403), uint32(244336503), uint256(7237005577332262213973186563042994240829374041597583492308957479394974114010));
    }
    
    // Reproduced from: medusa/test_results/1738222333247153000-89b130e2-4d62-471d-a5d5-4319a424f4eb.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_29() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(40684373734581), uint256(1809251394344819410168598356161025933386178703196142997445185606608614445589), int24(3503821), int24(6399491), int24(-1841881), uint256(3450873173418415528199170685630629834266226943834714911170385725492601), int24(7098866), uint256(68012253685588403788760211959724346), uint32(196056194), uint32(2210334691), uint256(202));
    }
    
    // Reproduced from: medusa/test_results/1738206361038302000-5cb97f73-9ecf-460e-8c9a-7a6964bc0d72.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_30() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(3048551), uint64(7015650299249229808), uint64(160074488424056005), int64(1), uint160(0), int24(306772), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738226711332717000-cc1ac6b1-7980-44f7-ac26-76e0465df571.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_31() public { 
        
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(2431614), uint64(3893371740956712389), uint64(3337995630720530805), int64(-1), uint160(143204548276411912735232272359556869), int24(3601219), true, bytes8(hex"f5595c69408dce48"));
    }
    
    // Reproduced from: medusa/test_results/1738193973773469000-8dba8bd4-8310-4736-a89a-2ad2cd2517e9.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_32() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-7458481), uint64(4957747471793563722), uint64(8482626906434222823), int64(1453), uint160(5352934093222354891135623490205713427), int24(230916), uint24(0), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738199532500076000-fa7b27d6-aa55-4dd0-94d6-03321b3e39d2.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_33() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-5387813), uint64(10853259895919413993), uint64(14035729324597649843), int64(-4140), uint160(3970409967135449875918842377849518829770216), int24(-1627718), uint24(9), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738226711362935000-ab032d2e-56de-4711-95d8-ffe2c9e397e0.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_34() public { 
        
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(2431673), uint64(2652406231513832577), uint64(2539235205240754316), int64(-1), uint160(2704632084051395560230074753767087299), int24(-193536), true, bytes8(hex"f5595c69408dce48"));
    }
    
    // Reproduced from: medusa/test_results/1738206361040062000-9267aba4-c8f0-47e7-940f-660db530bf99.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_35() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(3047814), uint64(1617692081537967147), uint64(16956339471351625916), int64(1), uint160(0), int24(54577), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738199253081572000-ce61da69-e564-463f-860d-98464bd97edf.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_36() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-3554547), uint64(456604165279455863), uint64(337593716667400607), int64(-1), uint160(1427247691388325613137985462694593029565492856), int24(-234807), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738199253080449000-3bf10b64-6da3-4bbc-80f9-6827f807d5e4.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_37() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-36075), uint64(6088986648363674749), uint64(3073546973241288718), int64(-1), uint160(2787593149260642925021634891366788552741563), int24(0), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738205114915613000-d3b71748-1c9e-4498-8af0-1c1676949e38.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_38() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(0), uint256(6261), int24(-228096), int24(-6515427), int24(-6802455), uint256(13486555351804604721504039380098067517069451295410710731534176855531), int24(5303101), uint256(14134776518227074636667547496086588549863112202760492896624968247980102830), uint32(11000037), uint32(0), uint256(0));
    }
    
    // Reproduced from: medusa/test_results/1738185271002714000-d2f2ef73-9213-44d7-9b67-4652181f0f63.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_39() public { 
        
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(uint256(129), uint256(5760587550597834680065067555721485652099911837125998651385022396507), int24(-994266), int24(-4579208), int24(-1385549), uint256(842498333348917510033649438361212910483907753485935073386171772703), int24(6935206), uint256(3996104139986731481956009281935393065694033942477431747601476561066028687095), uint32(100179136), uint32(2055094091), uint256(28948022309329048855892746252171976963317496166390333969235829917579896422551));
    }
    
    // Reproduced from: medusa/test_results/1738226711365547000-5d671ab3-14ed-4daf-82cc-179b8dbaaabd.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_40() public { 
        
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(2431618), uint64(2176227306163068731), uint64(1704659644893506045), int64(-1), uint160(178405919055016581985884180650494831893556160), int24(-805786), true, bytes8(hex"f5595c69408dce48"));
    }
    
    // Reproduced from: medusa/test_results/1738193973772691000-3657d0df-cfa5-4a83-bc82-4817d45983f8.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_41() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(2777563), uint64(11742864885654579380), uint64(10794741675125347431), int64(1), uint160(33079426914656364436341964507243126471), int24(1817), uint24(11531854), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738193973768686000-a885465f-658f-4335-8c00-dabcd67e8066.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_42() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-8375426), uint64(14261529857864261933), uint64(9021940632146829080), int64(1), uint160(377982782573437675751479016184773434066), int24(3299098), uint24(13610539), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738206360971059000-61707b2c-6d89-4fbb-81f0-f80ff2965ad3.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_43() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(6334504), uint64(358375029385904910), uint64(3454928981948349073), int64(-2), uint160(0), int24(807257), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738222333246031000-53e7f429-4969-4b98-8aa3-d8e5469178c6.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_44() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(0), uint256(89674809839643210801705054966121456271951783669922156515294), int24(3503822), int24(6400068), int24(800261), uint256(26046156907981977475446345176402655971180506731457783231956212528493918175), int24(-930086), uint256(55213977356342739584302215547258835622797252036683259943001165287590973), uint32(45980536), uint32(2068745116), uint256(345));
    }
    
    // Reproduced from: medusa/test_results/1738185270998236000-4a6238a7-3002-4825-a729-bf5f77686642.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_45() public { 
        
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(uint256(399), uint256(3092691891945305649911761037981801589904761674835113783070587871097097914764), int24(-2069811), int24(-6712251), int24(-2423483), uint256(421250773612274802720493060422879719800421030518610861307287595953), int24(69191), uint256(243902840575362028927979082149377017839004131574525757588100665473383991), uint32(2947546539), uint32(730040518), uint256(2332));
    }
    
    // Reproduced from: medusa/test_results/1738185271003812000-fe727212-af78-4f6d-a80a-dfa89f0367af.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_46() public { 
        
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(uint256(0), uint256(96646621623290801559742532675858366870227917468904741195056784785303698198), int24(4410095), int24(-938103), int24(-5177013), uint256(3509646989903689197001704864958195776729838045125), int24(5858571), uint256(243902840575362028927979082149377080165349157305068885689974884938065897), uint32(723023716), uint32(1020884223), uint256(115792089237316195423570985008687907853269984665482107714429055332726041739658));
    }
    
    // Reproduced from: medusa/test_results/1738222333177617000-ab084b3d-a31b-43a7-902f-44605287b3a4.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_47() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(8283), uint256(91827005275794649698049272060123961530766493762869920721353433), int24(3504071), int24(6402140), int24(-1841880), uint256(46768127569320909061018058212845667229105595223950), int24(7098562), uint256(424751026114823300816889681649843633608), uint32(691087545), uint32(2130872353), uint256(340));
    }
    
    // Reproduced from: medusa/test_results/1738222333244978000-d5e00577-5ebc-418a-95d4-1838cf33ad63.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_48() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(0), uint256(795584348983838417106584060462266711815352861343959990327), int24(3503749), int24(-2051943), int24(5491495), uint256(1725436586698363872936244994722281737590164064160772766495195944105070), int24(-2379762), uint256(407910355256664195055111393677826368), uint32(277528224), uint32(952250232), uint256(288));
    }
    
    // Reproduced from: medusa/test_results/1738205114941361000-1fb776c0-d6ef-4bac-b64f-7034132a69fc.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_49() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(0), uint256(250006), int24(230584), int24(6106063), int24(719328), uint256(10606660842515392108405912950964943835), int24(145573), uint256(7237005577437574505641743749740912268403214111146936540957155521547700862067), uint32(3974888133), uint32(30051685), uint256(0));
    }
    
    // Reproduced from: medusa/test_results/1738222333247381000-a37548a7-dfb0-4a2b-9ef2-d1eb010aa902.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_50() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(0), uint256(197527758238396689391510127527631543838387919587767339923), int24(3504083), int24(6409766), int24(-2542947), uint256(6427752177122140606271238128054143238313965178303465319762093), int24(-1745110), uint256(170450968342388672520835754298280858227), uint32(39759290), uint32(101614464), uint256(313));
    }
    
    // Reproduced from: medusa/test_results/1738222333248195000-9ecc850b-d96c-420c-be5f-3a731047300c.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_51() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(0), uint256(13164036459937977344802668833771589406525019605478248804432312847), int24(3503713), int24(-7391402), int24(-204080), uint256(57896044618658192467152329928197076986386562124687691527981706843554861205882), int24(6211938), uint256(28269553036454149273332760011886696248146797755409149915918686165006747614), uint32(276281192), uint32(194984617), uint256(237684487542793012780631855619));
    }
    
    // Reproduced from: medusa/test_results/1738218910031393000-fa650ca6-d04f-4a88-b9fd-a1f3021a62c6.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_52() public { 
        
        vm.warp(block.timestamp + 308783);
        vm.roll(block.number + 176);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-182882), uint64(8068919976552194524), uint64(4390551197778590527), int64(2), uint160(0), int24(4266633), true, bytes8(hex"a305ef2cb4d71ecd"));
    }
    
    // Reproduced from: medusa/test_results/1738185270997202000-5bd72e2a-ae39-4ee1-9bd9-2af81f2719ba.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_53() public { 
        
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(uint256(250033546305), uint256(193293243246581603119485064873862599438364706930305283064497108212654416044), int24(7709312), int24(1906495), int24(-13548), uint256(1040398588822159403401573038443286963747427592918778451540740958008951572672), int24(-625471), uint256(57896044726963092129898553599759842852826411091400173526162120577805505075303), uint32(111988799), uint32(92350356), uint256(69));
    }
    
    // Reproduced from: medusa/test_results/1738199253083447000-f8f3e969-44e4-400c-bb08-d895a28da93c.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_54() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(918305), uint64(2406240087175550790), uint64(126693359024472627), int64(-1), uint160(10655187581431170966619280416882514616), int24(-978071), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738193973769311000-f9bf631d-e58e-40c7-9b29-08ed31707c73.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_55() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-7458457), uint64(18444965145448240615), uint64(6760323913568626815), int64(302), uint160(642527658427846802604824077528559), int24(-3212463), uint24(216), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738205114940024000-f8e3c42f-6df6-4648-b38f-3feeb1e70d01.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_56() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(117368484), uint256(421249166674228746791649810866531398888730846131591219172463007520), int24(856620), int24(-216735), int24(-3692773), uint256(1809251394333065553493296640760748560202383516503837778260434462579917607370), int24(263306), uint256(441711766194596082395824740561206788840932757825139359742477851337766108), uint32(195115541), uint32(108627916), uint256(0));
    }
    
    // Reproduced from: medusa/test_results/1738199532503662000-4e1e9154-739e-4ce0-8144-a7d962c5bb64.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_57() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(5121167), uint64(15642185305525419314), uint64(6535622745523028519), int64(-1), uint160(449914900490589117086804151350286417225764881850), int24(-1737478), uint24(1261158), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738205114940640000-61c63052-71a8-4801-a231-e89180b6ccb5.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_58() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(0), uint256(82), int24(-4932013), int24(-6195385), int24(-3137563), uint256(13479973333575319897337240778923972451545800732649720200635295828155), int24(-8075), uint256(17821777334669037315907541530884447748286641877), uint32(1405109068), uint32(727794300), uint256(904625697166532776746648320380374280103671755278926099052884022517915714025));
    }
    
    // Reproduced from: medusa/test_results/1738226711364349000-17d47630-c636-4429-9903-cd907d4c064b.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_59() public { 
        
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(2431558), uint64(5104521715819449956), uint64(6004166517901879061), int64(-1), uint160(91343851556512059173842762216097871079341649041), int24(-5517116), true, bytes8(hex"f5595c69408dce48"));
    }
    
    // Reproduced from: medusa/test_results/1738199532500199000-d6b77ede-1d3f-4eb9-8f4f-f1f8368d4334.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_60() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-5576077), uint64(4055249712540852507), uint64(4803841987603533108), int64(-1), uint160(294727933220246712525965532130882), int24(-137), uint24(1007048), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738199532499165000-4896fa15-a4a5-4cf5-8113-9dc12e0d4cfa.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_61() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-5641522), uint64(5037193495182194576), uint64(2756750419007961295), int64(169), uint160(5548363131494499459967178135964098852994784), int24(2383591), uint24(0), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738226711365286000-a8e1cf8b-e30e-4ff6-a364-e122cf0f0127.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_62() public { 
        
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(2431528), uint64(4603350658803391811), uint64(4278827857917047596), int64(-1), uint160(2621188998615547820712169943890626579), int24(2073681), true, bytes8(hex"f5595c69408dce48"));
    }
    
    // Reproduced from: medusa/test_results/1738206361038691000-96e860af-8d98-4bbb-8081-b6914614d56d.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_63() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(1968205), uint64(4787592613905165284), uint64(1086979539488120018), int64(-2), uint160(0), int24(977137), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738199253083105000-44f686c0-834e-4f81-9bd2-52d191a96cc8.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_64() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(7993386), uint64(824676252419525968), uint64(876515829797679063), int64(-1), uint160(1361211272781867595456485968842973412173), int24(-246102), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738222333243999000-3de5ba77-d3f2-4b0b-8d82-d967096b6e53.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_65() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(0), uint256(21380138409898590272793098487019620291536166301989312), int24(-1791561), int24(-1928574), int24(270651), uint256(448613512541479180721186302779571835273268595354326679464467915328349575), int24(-949922), uint256(3533700869543435446826543668239836602626498651083846613428155484206921158), uint32(126514392), uint32(1012019328), uint256(57896044618658097711785492504343953926634992332780667938471659835159792845167));
    }
    
    // Reproduced from: medusa/test_results/1738206361038900000-a04b25ce-87d9-469d-acc4-8df599d44b5d.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_66() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-511809), uint64(115), uint64(20879317868291967), int64(-1), uint160(22997965581567187166272265974795047243), int24(-5279337), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738193973770858000-af87df5a-43d5-412f-9316-6762f806c235.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_67() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-7458464), uint64(6953565125260366678), uint64(5453291097621432926), int64(33), uint160(17140864208424468541457287458011437254766705), int24(409385), uint24(15026097), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738185270999492000-e5a6f9ea-7bb1-4eab-983a-5de01faa157a.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_68() public { 
        
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(uint256(17592186036192), uint256(58089337861904679314904977569217816525919003661185966035959247738760507276924), int24(284510), int24(-6028504), int24(4912886), uint256(15073819043601347129049288705396782226726458289571185531896), int24(-390883), uint256(487805681150724057855958164298754371374261880135857767454339211789283041), uint32(15711365), uint32(318235829), uint256(115792089237316195423570985008687907853269984665561335876943319670319585689685));
    }
    
    // Reproduced from: medusa/test_results/1738205114942345000-462854df-bb5d-4f26-9e8c-d5090ec407e4.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_69() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(48322585745190), uint256(8), int24(-1374436), int24(7021696), int24(-1126999), uint256(862718293348820473429344482784628924146623198856763465974010040432606), int24(-5567), uint256(803469022130962815075330401240814008490170314303660629513787), uint32(17995219), uint32(4217170523), uint256(0));
    }
    
    // Reproduced from: medusa/test_results/1738199253079599000-747a00fe-3ef7-42ce-8afa-643083f965ed.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_70() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-1379239), uint64(548526245871072431), uint64(1487470191802561621), int64(-1), uint160(89202980776249557757449702091189331339244104), int24(-2584096), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738185270997513000-97901f55-a0e0-4ef1-a02b-2e585478fefb.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_71() public { 
        
        vm.warp(block.timestamp + 15);
        vm.roll(block.number + 0);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(uint256(0), uint256(193293243246581603119485064873862599202175469507613447755909353725332335540), int24(-6648334), int24(2451344), int24(-190170), uint256(11972621841438572753731700935234818955146465924097581), int24(1715568), uint256(401741280728482025030176832717632225812247708145662624141266), uint32(2174287186), uint32(1490851633), uint256(147));
    }
    
    // Reproduced from: medusa/test_results/1738199532498323000-1e7b86d0-a79d-41c4-8ae4-27525cf9efa7.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_72() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-1418983), uint64(4144426360782169292), uint64(3087545817711473077), int64(-1), uint160(1393900951775729630397078746657988138611255), int24(-7697), uint24(1009175), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738226711366069000-600464a9-b692-4d36-9766-1b3634c299e9.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_73() public { 
        
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(2431670), uint64(2385653068460042095), uint64(2289414449501336800), int64(-1), uint160(679746619375423247936244968476012206920), int24(0), true, bytes8(hex"f5595c69408dce48"));
    }
    
    // Reproduced from: medusa/test_results/1738193973717256000-0ebfd75b-e221-4d7a-a335-cf22ebb82881.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_74() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-7458454), uint64(7449358382494790439), uint64(5372723384962282313), int64(1), uint160(95014621027704505724369780261088005), int24(-53890), uint24(3147679), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738206361038502000-29c591bd-da05-462a-bcb9-c19dcb5c9f58.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_75() public { 
        
        vm.warp(block.timestamp + 335997);
        vm.roll(block.number + 46509);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-4485640), uint64(241561416712124505), uint64(1375722617834031416), int64(-2), uint160(0), int24(40598), false, bytes8(hex"b68af69e9073037d"));
    }
    
    // Reproduced from: medusa/test_results/1738226711367283000-3458e227-2194-451c-bbc3-2ca3d25049fe.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_76() public { 
        
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(2431732), uint64(2452471059985894958), uint64(2353635641440628674), int64(-1), uint160(154443992403100965233695808223494538652816740), int24(1489882), true, bytes8(hex"f5595c69408dce48"));
    }
    
    // Reproduced from: medusa/test_results/1738193973772177000-a6e12f88-f007-4269-8de1-0c2aca0d5fed.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_77() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-7458463), uint64(6811731682290519081), uint64(12624829140411636059), int64(17), uint160(137126949504046254373913391864872230272254698), int24(-8200324), uint24(7020872), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738199253044660000-9ab6347c-bca4-4b8a-87cd-e6a76de55089.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_78() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-3716037), uint64(1298749926315918039), uint64(15664127701989748006), int64(-1), uint160(1461501637078373640920466349717976443537781210251), int24(2302824), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738199253081962000-560ca5fb-eaa9-426a-b9c2-fb33ce9bd84c.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_79() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-2274009), uint64(2780118386973018), uint64(530625636152883011), int64(-1), uint160(2724425095017519084983171207718241531302), int24(-2747808), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738193973775548000-f77ebd19-8f4e-484d-9c26-88b162c02c8f.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_80() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-7458471), uint64(4040007539570943144), uint64(4987736262908603923), int64(3764), uint160(57436847059440385306849751065509518769), int24(-1618902), uint24(0), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738199532499606000-7d1e205c-69e0-4d14-bc63-cc29505b2a02.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_81() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-4400644), uint64(2025223917216579616), uint64(9991636189217970096), int64(215), uint160(1199589541264792977099244597039035056562), int24(-174173), uint24(0), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738182207631426000-e3e75eee-69fd-473b-9743-39edeee76640.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_82() public { 
        
        vm.warp(block.timestamp + 330191);
        vm.roll(block.number + 16879);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-6845296), uint64(577610496812831237), uint64(11168238706049314837), int64(4), uint160(43063969689251991588418110594366056514186), int24(-6936140), false, bytes8(hex"e271f63b1e78c67d"));
    }
    
    // Reproduced from: medusa/test_results/1738199532500819000-b88e020d-2590-4c85-9db4-3b05cd70a7de.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_83() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-5641610), uint64(4478048040848612772), uint64(2665727861726392879), int64(122), uint160(91340420645524437383132925463978969816515825313), int24(2014479), uint24(0), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738205114941026000-8ad31aa1-d2fc-4563-ae6d-6bde0748291d.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_84() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(1000000000000000000307462790750273702), uint256(3563), int24(4064767), int24(-7834166), int24(-2489798), uint256(21778071497419443181297147226612580211459), int24(-3307106), uint256(12855602433786537978034556186307221757483234018530311257750335), uint32(3744340623), uint32(1647252780), uint256(0));
    }
    
    // Reproduced from: medusa/test_results/1738205114941710000-7028621e-c5c6-45cc-9511-5bdcc16d729b.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_85() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(72690017952858907), uint256(12336), int24(-2203221), int24(5901860), int24(-3584853), uint256(6477968990919054548278534685770916466487964956948829512950096), int24(4972796), uint256(421352010709061322169306796350859516537890013056831959171072173501), uint32(598951151), uint32(879816331), uint256(0));
    }
    
    // Reproduced from: medusa/test_results/1738199253082604000-beccff97-60a9-44b5-86c1-097cf38da6a9.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_86() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-5988500), uint64(8706699231690114325), uint64(217350354325338437), int64(-1), uint160(713623846204297053797460566418851943386011825), int24(6064500), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738193973771356000-615da74d-6431-4125-86ee-3e6b27af06aa.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_87() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(2777521), uint64(5746534435807136005), uint64(6348364545640068611), int64(1), uint160(212782318224628834009724073314376719312), int24(2629792), uint24(1372722), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738199532500330000-b5819594-6b3c-416d-baba-8ef67861ccb0.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_88() public { 
        
        vm.warp(block.timestamp + 477561);
        vm.roll(block.number + 23867);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-1218565), uint64(14480428105923307407), uint64(7521995275486855480), int64(-11), uint160(31407120635206944709033399513706669640), int24(-4229111), uint24(0), true, bytes8(hex"ddbf2a17f8927e19"));
    }
    
    // Reproduced from: medusa/test_results/1738226711363505000-b34b54dd-1a4e-4eb1-a3c3-5f90ba0bad08.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_89() public { 
        
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(2431596), uint64(7120317311111855528), uint64(1917963453517468190), int64(-1), uint160(10636411836197717438024863749124004900), int24(545417), true, bytes8(hex"f5595c69408dce48"));
    }
    
    // Reproduced from: medusa/test_results/1738222333244540000-f3c2cf77-5123-49f7-a5ac-bd091abdee9c.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_90() public { 
        
        vm.warp(block.timestamp + 30);
        vm.roll(block.number + 16);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(0), uint256(43786528242013286509235937747262937257818264019835099311), int24(3503825), int24(6408289), int24(2587652), uint256(2674589563176951631162088606790760058815455713), int24(2332138), uint256(7067388285441610235472486677453968453091720866760115945994872051261867990), uint32(5518002), uint32(1489994755), uint256(339));
    }
    
    // Reproduced from: medusa/test_results/1738193973771604000-c74fd018-fe38-405a-8e36-7294d1a3ea1c.json
    function test_auto_test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_91() public { 
        
        vm.warp(block.timestamp + 35392);
        vm.roll(block.number + 32);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-7458450), uint64(4833532291212561639), uint64(4675786385696636900), int64(7), uint160(45671926155961147915402337127978935694787416549), int24(-373291), uint24(3031360), false, bytes8(hex"216d6a53c80a63a5"));
    }
    
    // Reproduced from: medusa/test_results/1738199253081342000-de1fbb50-3aec-4564-b939-b45a85342bb3.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_92() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-4067483), uint64(14951458478040210540), uint64(194198871604374799), int64(-1), uint160(35183937184910868826145458535769534), int24(9946), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738205114942186000-e0b77ff4-9e9f-4d27-948e-abfc426c2309.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_93() public { 
        
        vm.warp(block.timestamp + 147384);
        vm.roll(block.number + 7502);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(uint256(1000000000000000021038382474148962879), uint256(849), int24(-1690333), int24(5910726), int24(563447), uint256(1725436586697640946859419716387921813418887723892451084730861904997345), int24(-4597091), uint256(3369993335842234263210622462807735453904225328096764207181627013816), uint32(892418721), uint32(1119668750), uint256(0));
    }
    
    // Reproduced from: medusa/test_results/1738199253080712000-4da8f69a-3050-4b9b-8bb1-d043c7c62d90.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_94() public { 
        
        vm.warp(block.timestamp + 206627);
        vm.roll(block.number + 41149);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(-2901568), uint64(1806386928506230119), uint64(1618233420749224710), int64(-1), uint160(10889035739254145990623968385104428632376), int24(5825179), true, bytes8(hex"d7d862e7caf4f507"));
    }
    
    // Reproduced from: medusa/test_results/1738226711366330000-366adad3-5b16-40bf-80e9-a160b607fb9c.json
    function test_auto_swap_should_move_sqrt_price_in_correct_direction_95() public { 
        
        vm.warp(block.timestamp + 347792);
        vm.roll(block.number + 25575);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.swap_should_move_sqrt_price_in_correct_direction(int24(2431670), uint64(8173794313509089712), uint64(3651628738360893395), int64(-1), uint160(36417595898515878726680336391358457933), int24(-1126553), true, bytes8(hex"f5595c69408dce48"));
    }
    
}

    