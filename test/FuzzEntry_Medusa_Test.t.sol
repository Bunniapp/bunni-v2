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
    // Reproduced from: medusa/test_results/1733200579285318000-b266a467-a0d7-4ac4-bd78-8de3abfe0217.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_0() public { 
        
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(189655), uint64(44357396820235), uint64(1228026181857), int64(477774600224), uint160(174229900146090081231864721421376084905660), int24(-1949563), int24(3529009), int24(4420616), false);
    }
    
    // Reproduced from: medusa/test_results/1733200579287109000-0fb12ef9-3db6-4203-9c40-982d9e4c7bd5.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_1() public { 
        
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(3107684), uint64(4854771064589732002), uint64(11929887409295337709), int64(8), uint160(340448055182675393334379058308858501350), int24(3281970), int24(193749), int24(1624752), false);
    }
    
    // Reproduced from: medusa/test_results/1730772642114703000-69cab260-1e95-4b3e-8233-1f0137609bc7.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_2() public { 
        
        vm.warp(block.timestamp + 415998);
        vm.roll(block.number + 23783);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(2743571), uint64(85036323857242128), uint64(1048576), int64(-5077420025644778166), uint160(0), int24(-2002111), int24(3917552), int24(1795312), false);
    }
    
    // Reproduced from: medusa/test_results/1733200579286466000-5e1b8468-cb90-4b34-b154-e87459ab1f15.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_3() public { 
        
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(0), uint64(2661325449551235), uint64(381293559403363141), int64(553), uint160(11164563489478895821490688842836544728), int24(8009088), int24(255476), int24(1590751), false);
    }
    
    // Reproduced from: medusa/test_results/1733200579286505000-626248fc-793d-4794-bfb0-3bcd08dd8dc8.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_4() public { 
        
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(-1999818), uint64(379327352562271), uint64(6282454105834794396), int64(-239397824515297575), uint160(1461501637171824243620351951624285891428165214194), int24(-5565705), int24(-1597929), int24(-3810636), false);
    }
    
    // Reproduced from: medusa/test_results/1733190576260561000-ff3cc95f-44d5-4306-a881-7d8dc33a60a4.json
    function test_auto_test_swap_panics_5() public { 
        
        vm.warp(block.timestamp + 423312);
        vm.roll(block.number + 45);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_swap_panics(int24(309981), uint64(6578343627211024248), uint64(0), int64(-3603), uint160(86962243123123036749989189048793895901635), int24(134787), int24(172), int24(1029929), false);
    }
    
    // Reproduced from: medusa/test_results/1733200930549089000-1b0f5e8d-e506-4448-ab3f-6334d31cab92.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_6() public { 
        
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(-847664), uint64(3786954031997951880), uint64(6720716097786075438), int64(1149790501542150810), uint160(21693068921290094937539687099982049814882), int24(4911525), int24(-5627968), int24(-17280), false);
    }
    
    // Reproduced from: medusa/test_results/1733190576259901000-5fe8471b-0926-46bb-b0a9-76d0864a9dda.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_7() public { 
        
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(0), uint64(2541541517846523460), uint64(8082000445000154006), int64(978675), uint160(2854495300611766788554622079889745203628986048), int24(1318907), int24(-1107600), int24(-5712430), false);
    }
    
    // Reproduced from: medusa/test_results/1733200579284541000-a37c0e1c-16c8-46ea-888c-c873ee2edabb.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_8() public { 
        
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(-1945175), uint64(6519920732056287199), uint64(244142697979753423), int64(2707606174148738), uint160(43188464492290305741742442508939453171), int24(1649506), int24(-482694), int24(-1841225), false);
    }
    
    // Reproduced from: medusa/test_results/1733190576260202000-beeb1ccb-4696-4456-b1c4-5b8fc02aeae2.json
    function test_auto_test_swap_panics_9() public { 
        
        vm.warp(block.timestamp + 423312);
        vm.roll(block.number + 45);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.test_swap_panics(int24(3852505), uint64(145820442900062192), uint64(1219557432245820828), int64(-100006171), uint160(73585158625906735033072916874495540), int24(5547145), int24(7468086), int24(-5970324), false);
    }
    
    // Reproduced from: medusa/test_results/1733200579284022000-16488673-54cd-4f76-8b72-b7c1f3e405fa.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_10() public { 
        
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(4904833), uint64(1012085190174828804), uint64(2198137948554255809), int64(47437), uint160(6703181261534118993904988153950285263962), int24(4425910), int24(744104), int24(1681921), false);
    }
    
    // Reproduced from: medusa/test_results/1733200579286194000-e67b610d-a746-477c-a268-cb2e4f79874e.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_11() public { 
        
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(-3987755), uint64(23562405956556200), uint64(15855702891112770), int64(140741806851885), uint160(697033604756490483801291460095723694311864), int24(4463077), int24(370806), int24(-2089870), false);
    }
    
    // Reproduced from: medusa/test_results/1733200930547816000-043dc9a9-95ed-45da-a0bf-81c61c9faba5.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_12() public { 
        
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(1029550), uint64(702063479489981802), uint64(441461581176753549), int64(1953105085449), uint160(170077466340340087101107532124336585829), int24(-7372265), int24(5128432), int24(-1766), false);
    }
    
    // Reproduced from: medusa/test_results/1733190576261152000-8ce2f1c2-e685-48c4-81d5-aaa8e7e7def3.json
    function test_auto_compare_exact_in_swap_with_exact_out_swap_13() public { 
        
        vm.warp(block.timestamp + 349825);
        vm.roll(block.number + 19352);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_exact_in_swap_with_exact_out_swap(int24(156034), uint64(3238927980791116120), uint64(7149582490983130623), int64(144115314351203863), uint160(85069487459292896489098117942938592832), int24(989495), int24(-1642263), int24(4602952), false);
    }
    
}

    