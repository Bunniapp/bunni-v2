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
    // Reproduced from: medusa/test_results/1729174553707355000-3346fdb2-80fe-4c95-b714-303b62e4044e.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution_0() public { 
        
        vm.warp(block.timestamp + 6603);
        vm.roll(block.number + 552);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-8044348), uint256(0), uint256(576281249999999798786), int24(0), int24(4173256));
    }
    
    // Reproduced from: medusa/test_results/1729179771891177000-b014effe-bf62-4f3c-9413-b043d4143b0e.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_1() public { 
        
        vm.warp(block.timestamp + 360607);
        vm.roll(block.number + 23050);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-512889), uint64(59348646603384322), uint64(14618958198585320642), int64(1863319832186077046), uint160(4591786860483705022), int24(1723901), int24(-379661), int24(-3311728));
    }
    
    // Reproduced from: medusa/test_results/1729179771912229000-202e80be-a958-4725-a2c4-735acfa73d22.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_2() public { 
        
        vm.warp(block.timestamp + 360607);
        vm.roll(block.number + 23050);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(27408), uint64(3597389610921124), uint64(66018540603152), int64(-7006564944584327748), uint160(5708990909556824304555579389407632225386552672), int24(-1801106), int24(-2440735), int24(1724323));
    }
    
    // Reproduced from: medusa/test_results/1729179771913253000-51c38d10-7e90-4f64-8f2e-5f868fd3aa7e.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_3() public { 
        
        vm.warp(block.timestamp + 360607);
        vm.roll(block.number + 23050);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(1877753), uint64(276871129724667603), uint64(14301755499357511679), int64(666441233867510912), uint160(735949603101580753442259344391), int24(1670667), int24(-109042), int24(-1714417));
    }
    
    // Reproduced from: medusa/test_results/1729179702967300000-a044bd24-4b3b-4658-8f9c-bac5362863aa.json
    function test_auto_test_swap_panics_4() public { 
        
        vm.warp(block.timestamp + 580254);
        vm.roll(block.number + 1);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(-1303725), uint64(1975076932628247407), uint64(202740708956996852), int64(1039658480601245339), uint160(1608382757326898716598402942106414059950060), int24(1926621), int24(-89), int24(8004490), true);
    }
    
    // Reproduced from: medusa/test_results/1729179771923708000-ead4dfcd-44b0-4907-9039-94a802170753.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_5() public { 
        
        vm.warp(block.timestamp + 360607);
        vm.roll(block.number + 23050);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(2310), uint64(1674588200079525), uint64(2453391012327), int64(436068634019951736), uint160(455231222727699331411256152720693), int24(7469), int24(2336278), int24(-1421439));
    }
    
    // Reproduced from: medusa/test_results/1729179702970123000-50d8cad1-abca-41f9-ad66-722f26239f09.json
    function test_auto_test_swap_panics_6() public { 
        
        vm.warp(block.timestamp + 460556);
        vm.roll(block.number + 103);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_swap_panics(int24(-8106771), uint64(226196655013564025), uint64(11310236227021449193), int64(1680202883949373669), uint160(43573243485060102168631159046466892751128), int24(187340), int24(-3248525), int24(-4478928), false);
    }
    
    // Reproduced from: medusa/test_results/1729179702970615000-6c06ffe6-69a8-460d-b879-2ead0da80038.json
    function test_auto_test_swap_panics_7() public { 
        
        vm.warp(block.timestamp + 580254);
        vm.roll(block.number + 1);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(7246116), uint64(1987511079210365523), uint64(451351300132758920), int64(530553868098619119), uint160(17184425532353371310074183100659028249040578), int24(1974793), int24(-785577), int24(8387964), true);
    }
    
    // Reproduced from: medusa/test_results/1729179771923198000-6e49efa8-7631-413f-8f35-8e2b6876bcb5.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_8() public { 
        
        vm.warp(block.timestamp + 360607);
        vm.roll(block.number + 23050);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(452771), uint64(557917482759850018), uint64(280850432322856), int64(2582874864561197724), uint160(0), int24(-3536473), int24(-957432), int24(2031986));
    }
    
    // Reproduced from: medusa/test_results/1729182205243295000-90543c90-7c4e-4299-a59a-c6507848c292.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric_9() public { 
        
        vm.warp(block.timestamp + 314084);
        vm.roll(block.number + 21);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric(uint256(143), uint256(54457951835691968901522315156395788569184496573700077353997656798091744496997), int24(4), int24(-471286), int24(5418173), uint256(115792089237316195423570985008687907853269984665640564039457584007913129639840), uint256(115792089237316195423570985008687907852929634238843417719092132090926129000521));
    }
    
    // Reproduced from: medusa/test_results/1729182205242319000-9781790d-c31d-4499-82b8-1bfe255169c6.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric_10() public { 
        
        vm.warp(block.timestamp + 314084);
        vm.roll(block.number + 21);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric(uint256(143), uint256(54457951835691968901522315156395788569184496573700077354493364797715801534196), int24(4), int24(-7068272), int24(-2801599), uint256(115792089237316195423570985008687907853269984665640564039457584007913129639840), uint256(115792089237316195423570985008687907852929634238843417719092132090926129000521));
    }
    
    // Reproduced from: medusa/test_results/1729185039286819000-1797f094-6e4f-43a3-bf98-731776ee70ba.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_11() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(18914), uint64(16793893866453458286), uint64(15257168568726755087), int64(104465231227638447), uint160(0), int24(3808), int24(2607), int24(5885393), true);
    }
    
    // Reproduced from: medusa/test_results/1729182205242858000-48a662fa-34e0-481c-95c4-6cf1f6bab52f.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric_12() public { 
        
        vm.warp(block.timestamp + 314084);
        vm.roll(block.number + 21);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric(uint256(1000000000000000143), uint256(54457951835691968901522315156395788569184496573700077354337443688549216737438), int24(4), int24(4500063), int24(-441637), uint256(115792089237316195423570985008687907853269984665640564039457584007913129639840), uint256(115792089237316195423570985008687907852929634238843417719092132090926129000521));
    }
    
    // Reproduced from: medusa/test_results/1729182205242577000-7f61c16b-67c2-46f5-b26a-450313872dd0.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric_13() public { 
        
        vm.warp(block.timestamp + 314084);
        vm.roll(block.number + 21);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric(uint256(143), uint256(54457951835691968901522315156395788569184496573700077354074521226726445297454), int24(4), int24(-5429097), int24(6598316), uint256(115792089237316195423570985008687907853269984665640564039457584007913129639840), uint256(115792089237316195423570985008687907852929634238843417719092132090926129000521));
    }
    
    // Reproduced from: medusa/test_results/1729179771923832000-8f79f3b5-8695-4e99-a008-76ee8eb851f6.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_14() public { 
        
        vm.warp(block.timestamp + 147361);
        vm.roll(block.number + 7424);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(-119478), uint64(8097015911325976438), uint64(2021425479330258804), int64(35848633053), uint160(0), int24(0), int24(1683232), int24(1935518), true);
    }
    
    // Reproduced from: medusa/test_results/1729174553706973000-bfb1c642-9c04-462a-956f-586ccc0156a1.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution_15() public { 
        
        vm.warp(block.timestamp + 6603);
        vm.roll(block.number + 552);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-6442092), uint256(0), uint256(999999999999999713070312499999897776), int24(0), int24(-2));
    }
    
    // Reproduced from: medusa/test_results/1729179375953260000-84dd3a07-446c-446a-a9ba-ba0eef45ec1f.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_16() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(1967644), uint64(84275017942417207), uint64(473247276727402576), int64(915557512272085188), uint160(0), int24(4078), int24(1805), int24(-7270250), true);
    }
    
    // Reproduced from: medusa/test_results/1729179702969977000-9a49deae-9d0a-4d23-b36b-24ed8bb343bd.json
    function test_auto_test_swap_panics_17() public { 
        
        vm.warp(block.timestamp + 146805);
        vm.roll(block.number + 82);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(int24(161896), uint64(1289865186247061471), uint64(614818041755925656), int64(961377888678933977), uint160(510276763258332411430445210683553193), int24(1471603), int24(-4528572), int24(937275), true);
    }
    
    // Reproduced from: medusa/test_results/1729179702969112000-befb9bcf-dc3f-4b16-a23d-ecdb61b0c835.json
    function test_auto_test_swap_panics_18() public { 
        
        vm.warp(block.timestamp + 146805);
        vm.roll(block.number + 82);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(int24(1174717), uint64(15103997225294155510), uint64(2263663868745669163), int64(477741348094053774), uint160(3515657055722008794108406663432962433650200271), int24(-1621049), int24(-8158688), int24(1721565), true);
    }
    
    // Reproduced from: medusa/test_results/1729179771910177000-eb214b25-080c-4383-ae1e-595243d39b52.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_19() public { 
        
        vm.warp(block.timestamp + 360607);
        vm.roll(block.number + 23050);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(132910), uint64(59373846268582336), uint64(8490276537293648), int64(495539027611907349), uint160(21789469870812616015259352), int24(2921902), int24(1797184), int24(-1504749));
    }
    
    // Reproduced from: medusa/test_results/1729179702948694000-ee16fd22-a234-4591-9424-3e2e47b938a0.json
    function test_auto_test_swap_panics_20() public { 
        
        vm.warp(block.timestamp + 580254);
        vm.roll(block.number + 1);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(1922989), uint64(12478482804580940356), uint64(844988783227415583), int64(2541411053746691), uint160(21813394513745822431880765088367513774611), int24(-5401631), int24(-3324661), int24(8145976), true);
    }
    
    // Reproduced from: medusa/test_results/1729179375940890000-0ecd55b5-1e4c-423e-9a1c-43a0034ed02d.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_21() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-4956763), uint64(3220491473978168974), uint64(857672123281148825), int64(3695396752905551871), uint160(53283968400705547980384708709887852), int24(393243), int24(-260336), int24(5029467), true);
    }
    
    // Reproduced from: medusa/test_results/1729179771908112000-72cff928-673c-43e7-a31b-7118f033aeae.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_22() public { 
        
        vm.warp(block.timestamp + 147361);
        vm.roll(block.number + 7424);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(-5996544), uint64(11255823726353892069), uint64(1051236997312466297), int64(144115908719428121), uint160(0), int24(0), int24(-699439), int24(-8379716), true);
    }
    
    // Reproduced from: medusa/test_results/1729174553706768000-b846810e-e54f-4399-8985-142ee16d3e6e.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution_23() public { 
        
        vm.warp(block.timestamp + 6603);
        vm.roll(block.number + 552);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-369631), uint256(0), uint256(1000000000000000288265624999985142108), int24(0), int24(7699216));
    }
    
    // Reproduced from: medusa/test_results/1729179702970791000-38a90874-a759-497b-ad00-7906a8d979b4.json
    function test_auto_test_swap_panics_24() public { 
        
        vm.warp(block.timestamp + 460556);
        vm.roll(block.number + 103);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_swap_panics(int24(-880293), uint64(1132486732627653968), uint64(229512900505129419), int64(152481729699394889), uint160(2787505199543203307989685748717202275404826), int24(-5325405), int24(996087), int24(2202108), false);
    }
    
    // Reproduced from: medusa/test_results/1729179771923587000-56506f02-ce60-4ff9-9a55-8c535a351d93.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_25() public { 
        
        vm.warp(block.timestamp + 360607);
        vm.roll(block.number + 23050);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(248620), uint64(144334050824013455), uint64(297048328722956319), int64(623778436), uint160(0), int24(1463803), int24(1889514), int24(-1697849));
    }
    
    // Reproduced from: medusa/test_results/1729179702970704000-94a3befa-1a1b-4301-a4e8-e791a2424cf0.json
    function test_auto_test_swap_panics_26() public { 
        
        vm.warp(block.timestamp + 146805);
        vm.roll(block.number + 82);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_swap_panics(int24(106664), uint64(7660880179153524957), uint64(665179148534724316), int64(0), uint160(3280103546448362047894100759048474223), int24(40976), int24(-3448789), int24(4494995), true);
    }
    
    // Reproduced from: medusa/test_results/1729179375942549000-ce4c9cd9-c902-48fb-abca-ff88dd35f3e0.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_27() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-3041881), uint64(7534629533306225828), uint64(713077860782818311), int64(66379041188481949), uint160(336440423271830941207339295159240330215), int24(4024359), int24(47), int24(1095503), true);
    }
    
    // Reproduced from: medusa/test_results/1729179771907269000-84083357-d193-4dfa-905b-a655668afd41.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_28() public { 
        
        vm.warp(block.timestamp + 360607);
        vm.roll(block.number + 23050);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(int24(-3902696), uint64(948051788134736568), uint64(367879443664307187), int64(496009226728136313), uint160(1461501636331569583627139569560863486490638386021), int24(-1725959), int24(-4202027), int24(2520967));
    }
    
    // Reproduced from: medusa/test_results/1729179375953143000-d8522a18-abbb-45d0-9071-a642f6080057.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_29() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(432), uint64(14425479077478504185), uint64(36493796887156046), int64(4299628192345451234), uint160(7054259284305777650371851232605), int24(-170074), int24(997720), int24(0), true);
    }
    
    // Reproduced from: medusa/test_results/1729182205241977000-cf9a08f9-b865-4041-8115-b08e28ab01b3.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric_30() public { 
        
        vm.warp(block.timestamp + 314084);
        vm.roll(block.number + 21);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric(uint256(143), uint256(54457951835691968901522315156395788569184496573700077354313062362579940014309), int24(4), int24(4507931), int24(3464831), uint256(115792089237316195423570985008687907853269984665640564039457584007913129639840), uint256(115792089237316195423570985008687907852929634238843417719092132090926129000521));
    }
    
    // Reproduced from: medusa/test_results/1729185039277133000-589db8a1-cb7c-4f21-8df3-5dc978a9dd79.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_31() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-259422), uint64(7263516477992249665), uint64(18049355699297255), int64(53361729543386), uint160(0), int24(1609836), int24(-5476777), int24(5724935), true);
    }
    
    // Reproduced from: medusa/test_results/1729179375953199000-2305350c-0a07-49a2-83d0-996ced327702.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_32() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-169166), uint64(8382620068704132257), uint64(116557830389725935), int64(5480898352426012284), uint160(1363789905032489906181919116076104200583), int24(-563736), int24(3913446), int24(3681), true);
    }
    
    // Reproduced from: medusa/test_results/1729174553707562000-965cfd75-774d-4bd7-8558-8185b94c84ae.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution_33() public { 
        
        vm.warp(block.timestamp + 6603);
        vm.roll(block.number + 552);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(8166983), uint256(0), uint256(18035156249998359432), int24(0), int24(3319435));
    }
    
    // Reproduced from: medusa/test_results/1729179375943570000-9d7349c0-ea18-4997-b4b5-fbe20f58dcde.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_34() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(772), uint64(3570594567179749613), uint64(2626298481296419958), int64(-3854327084998222925), uint160(4698388488011632524965305227008565671), int24(546363), int24(-96178), int24(3522013), true);
    }
    
    // Reproduced from: medusa/test_results/1729185039285714000-50bb6f6f-76ab-4349-81ab-98c7531dcce5.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_35() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-3132060), uint64(532416762821058606), uint64(1350324716596032888), int64(1935842647728375), uint160(1461446704964649014611953036067666599534229166146), int24(-4802761), int24(-1572380), int24(-2919343), true);
    }
    
    // Reproduced from: medusa/test_results/1729185039287479000-fa7a5b6e-19ee-44e9-9baf-ebb631ccdaac.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_36() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(61938), uint64(1282327171598213187), uint64(3798927726167608915), int64(1133), uint160(1163785449735290556), int24(-862481), int24(-1219795), int24(-1655509), true);
    }
    
    // Reproduced from: medusa/test_results/1729185039287172000-cf3c56bf-6a1f-4071-9597-012f67489ac5.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_37() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(1049182), uint64(3074874283535991093), uint64(15258049762978170862), int64(58877618303367669), uint160(0), int24(228969), int24(2034703), int24(2600313), true);
    }
    
    // Reproduced from: medusa/test_results/1729185039288184000-69c0e5ac-a4c7-4c44-a38d-ad2295804f54.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_38() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-192222), uint64(1212209034760956773), uint64(2009510151557865658), int64(462072362483692381), uint160(93796697630052242384058320562793893), int24(365575), int24(-8081524), int24(-4489234), true);
    }
    
    // Reproduced from: medusa/test_results/1729185039286421000-868093a3-8701-4623-ae21-b189d345b578.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_39() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(46019), uint64(4939224293626636396), uint64(320491770738460744), int64(21942324369211970), uint160(95406729989120319169901561), int24(1810777), int24(7890192), int24(-2902499), true);
    }
    
    // Reproduced from: medusa/test_results/1729174553705944000-df96018e-463a-4e03-89db-6e91944b068f.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution_40() public { 
        
        vm.warp(block.timestamp + 6603);
        vm.roll(block.number + 552);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(2036545), uint256(62500000000493732), uint256(72017578125001543495), int24(0), int24(7818264));
    }
    
    // Reproduced from: medusa/test_results/1729179375941350000-b4ff619a-5a48-4242-87a2-0795e2bdb384.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_41() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(24885), uint64(7662551540590030777), uint64(90385786015797084), int64(1589986063328937157), uint160(0), int24(1903112), int24(-362857), int24(-5443804), true);
    }
    
    // Reproduced from: medusa/test_results/1729174553706463000-3390d2fb-c20a-4a71-9545-72a422a68870.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution_42() public { 
        
        vm.warp(block.timestamp + 6603);
        vm.roll(block.number + 552);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(1244413), uint256(1000000000000000000000000003397219730), uint256(140624999994872292), int24(0), int24(6854213));
    }
    
    // Reproduced from: medusa/test_results/1729179702968406000-7ca413c4-7867-49d4-a0b5-d9f33ee21fd9.json
    function test_auto_test_swap_panics_43() public { 
        
        vm.warp(block.timestamp + 580254);
        vm.roll(block.number + 1);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(-1269109), uint64(1955565575779629613), uint64(2447896766226), int64(-1515302840108586589), uint160(85070551817441883768004814677468871805), int24(2051937), int24(-5814842), int24(5279774), true);
    }
    
    // Reproduced from: medusa/test_results/1729182205243086000-e9112580-6054-49e2-aa54-32dd5c02f014.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric_44() public { 
        
        vm.warp(block.timestamp + 314084);
        vm.roll(block.number + 21);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric(uint256(143), uint256(54457951835691968901522315156395788569184496573700077354245621319512860689549), int24(4), int24(-3750024), int24(331481), uint256(115792089237316195423570985008687907853269984665640564039457584007913129639840), uint256(115792089237316195423570985008687907852929634238843417719092132090926129000521));
    }
    
    // Reproduced from: medusa/test_results/1729182205223277000-7b290f79-0bf4-42f5-830c-251200d63af3.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric_45() public { 
        
        vm.warp(block.timestamp + 314084);
        vm.roll(block.number + 21);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric(uint256(1000000000000000143), uint256(54457951835691968901522315156395788569184496573700077354599428302905534606081), int24(4), int24(-5425958), int24(331562), uint256(115792089237316195423570985008687907853269984665640564039457584007913129639840), uint256(115792089237316195423570985008687907852929634238843417719092132090926129000521));
    }
    
    // Reproduced from: medusa/test_results/1729182205243500000-5b4c81d1-fe9a-4b71-98ec-4de1a932d547.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric_46() public { 
        
        vm.warp(block.timestamp + 314084);
        vm.roll(block.number + 21);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric(uint256(1000000000000000143), uint256(54457951835691968901522315156395788569184496573700077354322906316113036652894), int24(4), int24(-3778130), int24(-4314139), uint256(115792089237316195423570985008687907853269984665640564039457584007913129639840), uint256(115792089237316195423570985008687907852929634238843417719092132090926129000521));
    }
    
    // Reproduced from: medusa/test_results/1729174553706998000-1dc879bc-8371-4ecb-ae61-0f595687996b.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution_47() public { 
        
        vm.warp(block.timestamp + 6603);
        vm.roll(block.number + 552);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-1553186), uint256(0), uint256(36035156249997790666), int24(0), int24(0));
    }
    
    // Reproduced from: medusa/test_results/1729179375953080000-b64a3926-d510-479c-90be-ca7541153f35.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_48() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-6656292), uint64(3278396617234941398), uint64(29877408338353838), int64(266548471703402890), uint160(741064831538102499323031607426171408967695197), int24(-1446465), int24(3897730), int24(-4526112), true);
    }
    
    // Reproduced from: medusa/test_results/1729174553705559000-ad239336-6294-4599-bf33-051dd58d4a1d.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution_49() public { 
        
        vm.warp(block.timestamp + 6603);
        vm.roll(block.number + 552);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-1530461), uint256(0), uint256(1000000000000281249999999639871), int24(0), int24(-2496757));
    }
    
    // Reproduced from: medusa/test_results/1729185039287637000-254bd1d0-1234-45ad-bace-74a06d6ed5d1.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_50() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-7023212), uint64(127538232842414478), uint64(311860405583743360), int64(31), uint160(0), int24(-1875944), int24(-8086400), int24(-3421901), true);
    }
    
    // Reproduced from: medusa/test_results/1729182205243768000-12fcf8bc-156d-4f4c-a88a-5cc88a59d847.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric_51() public { 
        
        vm.warp(block.timestamp + 314084);
        vm.roll(block.number + 21);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric(uint256(143), uint256(54457951835691968901522315156395788569184496573700077353984311843841258457628), int24(4), int24(-5423234), int24(1511624), uint256(115792089237316195423570985008687907853269984665640564039457584007913129639840), uint256(115792089237316195423570985008687907852929634238843417719092132090926129000521));
    }
    
    // Reproduced from: medusa/test_results/1729182205241488000-ac4112aa-b706-48bf-a94b-943a7a2bb86d.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric_52() public { 
        
        vm.warp(block.timestamp + 314084);
        vm.roll(block.number + 21);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_carpeted_geometric(uint256(143), uint256(54457951835691968901522315156395788569184496573700077354683014463446967340639), int24(4), int24(-5430697), int24(2691281), uint256(115792089237316195423570985008687907853269984665640564039457584007913129639840), uint256(115792089237316195423570985008687907852929634238843417719092132090926129000521));
    }
    
    // Reproduced from: medusa/test_results/1729179702970282000-35472aa7-16f3-46e6-916a-af0706eac736.json
    function test_auto_test_swap_panics_53() public { 
        
        vm.warp(block.timestamp + 460556);
        vm.roll(block.number + 103);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_swap_panics(int24(-1729626), uint64(4290816343405685459), uint64(43526030735972081), int64(35726144558722722), uint160(365361762983588402409471212576752616312249122268), int24(501431), int24(1492102), int24(6102931), false);
    }
    
    // Reproduced from: medusa/test_results/1729179375943251000-8b346c8e-1ce6-452a-b36c-9e5148ef854f.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_54() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-89686), uint64(1739728832947697462), uint64(1145350984194598914), int64(-1123001878312634126), uint160(22300766169209321034810062578325249497523936), int24(81), int24(-525372), int24(402348), true);
    }
    
    // Reproduced from: medusa/test_results/1729179375928426000-0498a87e-042e-404d-a005-afecbfe63879.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_55() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(37784), uint64(17254556367194546290), uint64(7159346576425495842), int64(-936641188983851666), uint160(45671926156383820939937178889140455601587517293), int24(3065301), int24(-1504144), int24(0), true);
    }
    
    // Reproduced from: medusa/test_results/1729185039288024000-957844c6-c716-4ff2-808a-e69cc1cb4324.json
    function test_auto_test_free_or_loss_of_tokens_during_swap_56() public { 
        
        vm.warp(block.timestamp + 559527);
        vm.roll(block.number + 50486);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.test_free_or_loss_of_tokens_during_swap(int24(-4067341), uint64(8467307588109887674), uint64(7497197282433292146), int64(4193424), uint160(1461501636168637894825051457354677154569737706203), int24(-8227613), int24(-4111206), int24(-961050), true);
    }
    
    // Reproduced from: medusa/test_results/1729174553706952000-8ac3fe11-da05-43aa-ae86-9155ad6c4129.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution_57() public { 
        
        vm.warp(block.timestamp + 6603);
        vm.roll(block.number + 552);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-3627023), uint256(0), uint256(999999999999999999281249999997839239), int24(0), int24(853805));
    }
    
    // Reproduced from: medusa/test_results/1729174553703145000-e04ac006-edb9-4ee7-b53c-a7f3c010abbd.json
    function test_auto_inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution_58() public { 
        
        vm.warp(block.timestamp + 6603);
        vm.roll(block.number + 552);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_less_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(376018), uint256(0), uint256(1000000000359406249999999719253), int24(0), int24(-849317));
    }
    
}

    