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
    // Reproduced from: medusa/test_results/1737965682418173000-9b582323-3b09-47a4-be44-4b418f23fe5c.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_0() public { 
        
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-4668573), uint256(1000149985110628684), uint256(6721), int24(0), int24(0));
    }
    
    // Reproduced from: medusa/test_results/1737963947158521000-5873cea2-adb0-4089-8cad-07a071c7eda5.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_1() public { 
        
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(uint256(0), uint256(1), int24(-472), int24(2520631), int24(57), uint256(0), uint256(6901746346790563787458139888474317249612666736975358123370019703871749));
    }
    
    // Reproduced from: medusa/test_results/1737966443773963000-cdbdf9f4-47f9-40cf-b095-2bd1aae3606d.json
    function test_auto_test_swap_panics_2() public { 
        
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(-3460754), uint64(13006117943332757591), uint64(140737488355347), int64(-446261450701824914), uint160(713623846187653221163136665438906718011835938), int24(-1777921), int24(0), int24(-27), false);
    }
    
    // Reproduced from: medusa/test_results/1737966443818287000-c342df12-6bb3-413c-9153-365188b4f125.json
    function test_auto_test_swap_panics_3() public { 
        
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(2194199), uint64(7740714382425267), uint64(1044588106491851), int64(-1820591136414208), uint160(2787301516528673707531168970311742624325264), int24(1741452), int24(0), int24(-50), false);
    }
    
    // Reproduced from: medusa/test_results/1737966443756813000-d79267db-f04e-4649-92fd-10cb7d0bc8a3.json
    function test_auto_test_swap_panics_4() public { 
        
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(1653210), uint64(2521916408858630558), uint64(6249196916174), int64(-5971055140559690), uint160(13773891740152387968727674755103261763621452), int24(-2245), int24(0), int24(-42), false);
    }
    
    // Reproduced from: medusa/test_results/1737966443818033000-b92706f9-ac28-4fc0-a080-cd8c93116e7a.json
    function test_auto_test_swap_panics_5() public { 
        
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(-4794015), uint64(439788374970634), uint64(4553043526473752713), int64(-26115689186139626), uint160(22300725153184062179905864544831491866618926), int24(0), int24(10716), int24(-5310582), false);
    }
    
    // Reproduced from: medusa/test_results/1737966443819948000-a5d377f9-c4a3-4317-bce4-bba6f7aff27f.json
    function test_auto_test_swap_panics_6() public { 
        
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(-1709197), uint64(2507015034928657736), uint64(22517998133217244), int64(-2295413974737106377), uint160(1091331342961834057216515616863121), int24(-1), int24(6281146), int24(-1735228), false);
    }
    
    // Reproduced from: medusa/test_results/1737963947158028000-ee1b6640-a777-47ae-9c66-dc9b1534a997.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_7() public { 
        
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(uint256(0), uint256(1), int24(-563), int24(-4226973), int24(169), uint256(0), uint256(3213876136431850229340391134096713441363022276263083426061053));
    }
    
    // Reproduced from: medusa/test_results/1737965682418848000-5375a8ef-996d-425a-ace7-fc88cd79c535.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_8() public { 
        
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-4668573), uint256(50998458382761), uint256(6721), int24(0), int24(0));
    }
    
    // Reproduced from: medusa/test_results/1737963947157302000-cd767d28-193d-485a-a56f-3cee86374616.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_9() public { 
        
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(uint256(4158), uint256(1), int24(4191693), int24(2526079), int24(2220676), uint256(115792089237316195423570985008687907852929251270293017182800511579414811675784), uint256(11632281328460273187974698166564944123886744341292));
    }
    
    // Reproduced from: medusa/test_results/1737965682417868000-a08f281d-5c57-4e09-824a-d6e6070c4675.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_10() public { 
        
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-4668597), uint256(1000000001355384825), uint256(6721), int24(0), int24(0));
    }
    
    // Reproduced from: medusa/test_results/1737966443816926000-bf7fe7b8-6825-4cf5-89bf-7e1e2c44bb56.json
    function test_auto_test_swap_panics_11() public { 
        
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(6899139), uint64(14986673343684029940), uint64(5111748650), int64(-2968254007093088479), uint160(4388061225106918400755208705643357687987287783), int24(-1778468), int24(0), int24(-4), false);
    }
    
    // Reproduced from: medusa/test_results/1737963947157860000-8c7e5edd-a3c6-47e9-9c3d-eee6bb6251a0.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_12() public { 
        
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(uint256(1000000000000000000001125900077629980), uint256(1), int24(-6612453), int24(823308), int24(6525537), uint256(0), uint256(822752278660603021080272106396494220042731751786293687088757626));
    }
    
    // Reproduced from: medusa/test_results/1737965682417341000-52f33059-9599-4e7c-bc09-43759c5e4898.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_13() public { 
        
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-4668573), uint256(48995458894816), uint256(6721), int24(0), int24(0));
    }
    
    // Reproduced from: medusa/test_results/1737966443817300000-1a4e99f0-4ab7-471e-8554-a16b4f6d7d43.json
    function test_auto_test_swap_panics_14() public { 
        
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(1844055), uint64(6570056521235710548), uint64(826574159737), int64(-5980842598044196), uint160(66935237996264804630345982057793206144517), int24(-2387), int24(0), int24(-119), false);
    }
    
    // Reproduced from: medusa/test_results/1737965682417579000-0f23d74b-0240-4982-a69f-0b5d8bfe67d3.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_15() public { 
        
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-4668597), uint256(588564), uint256(6721), int24(0), int24(0));
    }
    
    // Reproduced from: medusa/test_results/1737965682417022000-82728524-3584-471b-a0cf-57c780e0464e.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_16() public { 
        
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-4668597), uint256(5992775), uint256(6721), int24(0), int24(0));
    }
    
    // Reproduced from: medusa/test_results/1737963947135665000-c96bfb1e-e89c-404b-b7a4-2f30ded4a777.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_17() public { 
        
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(uint256(0), uint256(1), int24(5165306), int24(-4265618), int24(7334747), uint256(0), uint256(3291009114642599155586207863666390860941607272444261076440784787));
    }
    
    // Reproduced from: medusa/test_results/1737966443818920000-e3a18108-379e-4351-8a90-ec334cc987d4.json
    function test_auto_test_swap_panics_18() public { 
        
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(2706721), uint64(348032021816569666), uint64(12), int64(-6661871091855981451), uint160(14828008533905389618760653531954929855), int24(-216), int24(4501777), int24(1780111), false);
    }
    
    // Reproduced from: medusa/test_results/1737965682402711000-f2b6efdb-b483-4149-a0f2-263266c323bb.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_19() public { 
        
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-4668573), uint256(48997367265558), uint256(6721), int24(0), int24(0));
    }
    
    // Reproduced from: medusa/test_results/1737963947158663000-19dbdd61-b566-4536-a303-09bc7907e257.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_20() public { 
        
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(uint256(0), uint256(1), int24(-204), int24(7645600), int24(-447), uint256(0), uint256(52656145834278593348959013842662919951413176144607224530584198188));
    }
    
    // Reproduced from: medusa/test_results/1737966443820105000-3ea56b25-3a4b-41e9-9a57-721a02b43323.json
    function test_auto_test_swap_panics_21() public { 
        
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(3717880), uint64(16497469272822823708), uint64(8133825), int64(-1480810142108320990), uint160(1406371870577893612706153237476039029488), int24(-1615), int24(0), int24(-3), false);
    }
    
    // Reproduced from: medusa/test_results/1737966443817607000-c3cab706-affa-4ceb-a125-806f773ecf0a.json
    function test_auto_test_swap_panics_22() public { 
        
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(int24(511260), uint64(1303475894458199), uint64(2179499087934466373), int64(-70393242501818333), uint160(2787593149184960791694400110288486765841348), int24(1747538), int24(0), int24(-1327), false);
    }
    
    // Reproduced from: medusa/test_results/1737963947158347000-47a2fcdb-c6ee-49a4-ad5d-917cfd54eb91.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_23() public { 
        
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(uint256(0), uint256(1), int24(8384129), int24(2533246), int24(5370181), uint256(0), uint256(6079869658409592917502478203173786623726612332626457));
    }
    
    // Reproduced from: medusa/test_results/1737963947119696000-32af5f12-b744-4f76-aed7-261e578f0d71.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_24() public { 
        
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(uint256(0), uint256(1), int24(3780457), int24(5762433), int24(543997), uint256(0), uint256(6277101735386651597934030944594666050133370237651473770384));
    }
    
    // Reproduced from: medusa/test_results/1737965682411069000-bc2974bf-6a5c-402e-89d8-094c46a9dd29.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_25() public { 
        
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(int24(-4668597), uint256(0), uint256(6721), int24(0), int24(0));
    }
    
    // Reproduced from: medusa/test_results/1737963947158178000-6f9c4bc2-593d-46d8-8906-23e9e87c919b.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_26() public { 
        
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(uint256(1000000000000000000000000001299438228), uint256(5), int24(-398), int24(7624102), int24(449), uint256(0), uint256(3533694129556769051485453463331790338659273659857322213851777939060185359));
    }
    
    // Reproduced from: medusa/test_results/1737963947157665000-ffed00f9-0d60-4365-a326-4199aab11cab.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_27() public { 
        
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(uint256(0), uint256(1), int24(-4311), int24(5943454), int24(-6399071), uint256(0), uint256(3039924832842607455107421243660546040690562126818981));
    }
    
}

    