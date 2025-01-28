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
    // Reproduced from: medusa/test_results/1738027168717553000-bd08a963-d893-404d-9b65-c0dd86a40d36.json

    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_0() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(4952139),
            uint64(7623520030585946345),
            uint64(8877079921050859296),
            int64(12036),
            uint160(1361115993065898821759473218169622620068),
            int24(3036915),
            int24(-7343509),
            int24(0),
            uint24(10)
        );
    }

    // Reproduced from: medusa/test_results/1738005585501513000-a964eee0-691e-42ba-8b05-e47a7a2d413c.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_1()
        public
    {
        vm.warp(block.timestamp + 360621);
        vm.roll(block.number + 15782);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(48),
            int24(244805),
            int24(-5149263),
            int24(0),
            uint256(36265561943263937248354834973183185125648306522041094101563787483664629872487),
            uint256(113188640087365252391031731528023981256358262265484132438450531808541526570)
        );
    }

    // Reproduced from: medusa/test_results/1738005585501968000-3162d94a-738d-4588-b01c-2f3f7dc6a7fa.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_2()
        public
    {
        vm.warp(block.timestamp + 360621);
        vm.roll(block.number + 15782);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(16),
            int24(-7916230),
            int24(-80),
            int24(0),
            uint256(36265561943263937248354834973183185125648306522041094101563787483662230236176),
            uint256(3547497622250349786741464513210218236282924309091102879628454039755394224)
        );
    }

    // Reproduced from: medusa/test_results/1738022041841633000-50439342-6030-4fe4-899f-899b18b8f2ce.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_3(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-6644311),
            uint256(0),
            uint256(199),
            int24(5212526),
            int24(-1832967),
            uint256(57731211141290440788045118758773593880237699653025599781280401492166221449631)
        );
    }

    // Reproduced from: medusa/test_results/1738035588947047000-19e769d6-9a4a-4c2e-8858-f971b3f038c7.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_4() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906459),
            uint64(12019132262036446346),
            uint64(15376860310198830828),
            int64(16),
            uint160(1427247692505263741956165215092527060123723221),
            int24(6438912),
            int24(6230723),
            int24(0),
            uint24(3014490)
        );
    }

    // Reproduced from: medusa/test_results/1738007192487699000-9c67ed38-40c3-4e7e-8ffd-329b47124065.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_5()
        public
    {
        vm.warp(block.timestamp + 116477);
        vm.roll(block.number + 47623);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(159),
            int24(-2296533),
            int24(0),
            int24(3377934),
            uint256(36029408600730301075335018509470931467700182848197722882940523082924752987978),
            uint256(22300745327594685346440039518561847957559359)
        );
    }

    // Reproduced from: medusa/test_results/1738020740542788000-fbc61fe4-aa27-41ca-a808-2618a381e593.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_6(
    ) public {
        vm.warp(block.timestamp + 238045);
        vm.roll(block.number + 139);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(88),
            int24(-1180007),
            int24(-2426966),
            int24(0),
            uint256(105972240291859636746807295116423337795408367748903810472314437267107055526445)
        );
    }

    // Reproduced from: medusa/test_results/1738035588875881000-f3822a48-d133-47ed-a7e5-eba0bd189d65.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_7() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906498),
            uint64(17388307858158291429),
            uint64(17673434876806879683),
            int64(21),
            uint160(40531656592408356769951805639498639114),
            int24(-3807597),
            int24(3778888),
            int24(0),
            uint24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738020740542448000-4ab6f47e-63ad-4711-b230-0fb1ca89846d.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_8(
    ) public {
        vm.warp(block.timestamp + 238045);
        vm.roll(block.number + 139);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(88),
            int24(-1180006),
            int24(-2433296),
            int24(0),
            uint256(105972240291859636746807295116423337795408367748903810472314437267109455538715)
        );
    }

    // Reproduced from: medusa/test_results/1737965682418173000-9b582323-3b09-47a4-be44-4b418f23fe5c.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_9()
        public
    {
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(
            int24(-4668573), uint256(1000149985110628684), uint256(6721), int24(0), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738027168803049000-eb06e673-f0c8-4abd-ae5c-2c2d1833301c.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_10() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1713693),
            uint64(7287741502980107532),
            uint64(18248565116014220687),
            int64(-1),
            uint160(41666196060129756128718088801839422),
            int24(1330339),
            int24(-1146817),
            int24(0),
            uint24(11057573)
        );
    }

    // Reproduced from: medusa/test_results/1738007192451677000-da44afb9-c09f-4270-860e-9695e39cf40c.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_11()
        public
    {
        vm.warp(block.timestamp + 116477);
        vm.roll(block.number + 47623);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(159),
            int24(-2296529),
            int24(0),
            int24(-519),
            uint256(36029408600730301075335018509470931467700182848197722882940523082925953004000),
            uint256(19746054687854472597203482532858199247243684919290995351497275633)
        );
    }

    // Reproduced from: medusa/test_results/1738012860064336000-977b7c84-2239-440a-9b77-af87277883b6.json
    function test_auto_inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution_12()
        public
    {
        vm.warp(block.timestamp + 279091);
        vm.roll(block.number + 23691);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount1_less_than_equal_to_cummulative_amount1_in_uniform_distribution(
            uint256(0), uint256(359), int24(-5558115), int24(4668935), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1737963947158521000-5873cea2-adb0-4089-8cad-07a071c7eda5.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_13()
        public
    {
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(1),
            int24(-472),
            int24(2520631),
            int24(57),
            uint256(0),
            uint256(6901746346790563787458139888474317249612666736975358123370019703871749)
        );
    }

    // Reproduced from: medusa/test_results/1738022041841832000-411dc831-e394-4605-8fc0-5e4c537d0b77.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_14(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-6644301),
            uint256(0),
            uint256(199),
            int24(1870990),
            int24(-7138184),
            uint256(57731211141290440788045118758773593880237699653025599781280401492166221440646)
        );
    }

    // Reproduced from: medusa/test_results/1738005585501165000-ede52ae5-0845-402b-8ce4-29e3cf8309bf.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_15()
        public
    {
        vm.warp(block.timestamp + 360621);
        vm.roll(block.number + 15782);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(41),
            int24(61046),
            int24(-5141856),
            int24(0),
            uint256(36265561943263937248354834973183185125648306522041094101563787483663430055279),
            uint256(50216909664064928634871210063622895445200509362565359057098)
        );
    }

    // Reproduced from: medusa/test_results/1737966443773963000-cdbdf9f4-47f9-40cf-b095-2bd1aae3606d.json
    function test_auto_test_swap_panics_16() public {
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(-3460754),
            uint64(13006117943332757591),
            uint64(140737488355347),
            int64(-446261450701824914),
            uint160(713623846187653221163136665438906718011835938),
            int24(-1777921),
            int24(0),
            int24(-27),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738005585492477000-a1ab54a8-bd92-4b8a-ab8a-07f40e9007ed.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_17()
        public
    {
        vm.warp(block.timestamp + 360621);
        vm.roll(block.number + 15782);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(48),
            int24(7579133),
            int24(5093808),
            int24(0),
            uint256(36265561943263937248354834973183185125648306522041094101563787483662230150615),
            uint256(23384115400434705440542954240057952996870960034232)
        );
    }

    // Reproduced from: medusa/test_results/1738007192487138000-88f21be2-8fdd-4d1d-99f7-a80327832abf.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_18()
        public
    {
        vm.warp(block.timestamp + 116477);
        vm.roll(block.number + 47623);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(159),
            int24(-2296536),
            int24(0),
            int24(-4612152),
            uint256(36029408600730301075335018509470931467700182848197722882940523082925952965229),
            uint256(52656145834278593360554972344018865490665135288400766799588867243)
        );
    }

    // Reproduced from: medusa/test_results/1737966443818287000-c342df12-6bb3-413c-9153-365188b4f125.json
    function test_auto_test_swap_panics_19() public {
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(2194199),
            uint64(7740714382425267),
            uint64(1044588106491851),
            int64(-1820591136414208),
            uint160(2787301516528673707531168970311742624325264),
            int24(1741452),
            int24(0),
            int24(-50),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738022041839929000-23e6d62f-08bb-4b26-80ba-f8f42b0e57c6.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_20(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-6644302),
            uint256(0),
            uint256(199),
            int24(204339),
            int24(2002616),
            uint256(57731211141290440788045118758773593880237699653025599781280401492165021469702)
        );
    }

    // Reproduced from: medusa/test_results/1738035588944930000-e209c328-d368-43b2-b726-4410b705db32.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_21() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906498),
            uint64(16493938049974741098),
            uint64(16879382712041933832),
            int64(15),
            uint160(174224592666839800912179683556524914727051),
            int24(1321958),
            int24(-3643350),
            int24(0),
            uint24(1009966)
        );
    }

    // Reproduced from: medusa/test_results/1738007192485494000-34d24f18-f008-47ea-9a55-84151a36dbf2.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_22()
        public
    {
        vm.warp(block.timestamp + 116477);
        vm.roll(block.number + 47623);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(159),
            int24(-2296536),
            int24(0),
            int24(222),
            uint256(36029408600730301075335018509470931467700182848197722882940523082925952965857),
            uint256(492333000356846247113214573846478420534)
        );
    }

    // Reproduced from: medusa/test_results/1738016030394783000-5d0e2a10-f494-4255-b2cb-30cac4d2975e.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_23(
    ) public {
        vm.warp(block.timestamp + 395199);
        vm.roll(block.number + 36411);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(31),
            int24(0),
            int24(5881152),
            int24(-170185),
            uint256(158941037392422835200690662044483369962315951),
            int24(-7192512),
            uint256(57896044618658097711785492504343953926634992332820282019728792003956563173243),
            uint32(611448338),
            uint32(1001488350),
            uint256(3547497622250350571379204820572037638298075122185121500786757016449062452)
        );
    }

    // Reproduced from: medusa/test_results/1737966443756813000-d79267db-f04e-4649-92fd-10cb7d0bc8a3.json
    function test_auto_test_swap_panics_24() public {
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(1653210),
            uint64(2521916408858630558),
            uint64(6249196916174),
            int64(-5971055140559690),
            uint160(13773891740152387968727674755103261763621452),
            int24(-2245),
            int24(0),
            int24(-42),
            false
        );
    }

    // Reproduced from: medusa/test_results/1737966443818033000-b92706f9-ac28-4fc0-a080-cd8c93116e7a.json
    function test_auto_test_swap_panics_25() public {
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(-4794015),
            uint64(439788374970634),
            uint64(4553043526473752713),
            int64(-26115689186139626),
            uint160(22300725153184062179905864544831491866618926),
            int24(0),
            int24(10716),
            int24(-5310582),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738035588945713000-7a8eaf06-7f5e-4c5c-8a62-bd148ac00173.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_26() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906459),
            uint64(12750113913513777941),
            uint64(17071952419347675086),
            int64(214),
            uint160(365375409247867825601631376031325925239668437113),
            int24(-3783913),
            int24(1291253),
            int24(0),
            uint24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738016030372886000-fc7b748c-7b13-49a3-be06-8d3850550004.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_27(
    ) public {
        vm.warp(block.timestamp + 395199);
        vm.roll(block.number + 36411);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(15),
            int24(0),
            int24(-7334459),
            int24(207885),
            uint256(28948022309329048855892746252172016584479563835966707142961166668291924846933),
            int24(2514192),
            uint256(57896044618658097711785492504343953927315489016993741600722539951247399853446),
            uint32(3256916058),
            uint32(1391267996),
            uint256(111211425506553710359043586628161759686334046615071594233511559568617)
        );
    }

    // Reproduced from: medusa/test_results/1738016030394475000-7e6f0f52-0859-4822-8de3-6a280380719d.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_28(
    ) public {
        vm.warp(block.timestamp + 395199);
        vm.roll(block.number + 36411);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(31),
            int24(0),
            int24(5880005),
            int24(-786850),
            uint256(39735259218036705346926556958218551835867968),
            int24(-7192512),
            uint256(57896044618658097711785492504343953926634992332820282019728792003956365021257),
            uint32(2081718625),
            uint32(647506632),
            uint256(22300755274053409374153584113219338565636799)
        );
    }

    // Reproduced from: medusa/test_results/1738020740541479000-4cbc0601-a806-4dfa-8056-f6f38f1a1aa5.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_29(
    ) public {
        vm.warp(block.timestamp + 238045);
        vm.roll(block.number + 139);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(88),
            int24(-4384068),
            int24(2687428),
            int24(0),
            uint256(105972240291859636746807295116423337795408367748903810472314437267105855498468)
        );
    }

    // Reproduced from: medusa/test_results/1738016030391543000-de591ce8-de41-4a29-99ea-97b35c7b66cc.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_30(
    ) public {
        vm.warp(block.timestamp + 395199);
        vm.roll(block.number + 36411);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(31),
            int24(0),
            int24(-2362787),
            int24(3976389),
            uint256(107839786668602559179319082837248710886466289073750988303882837193671),
            int24(-7192512),
            uint256(57896044618658097711785492504343953926294743990733552229244465829139877156706),
            uint32(531875677),
            uint32(3138973530),
            uint256(3421412764644202686625837517091690928601105137402782960594302)
        );
    }

    // Reproduced from: medusa/test_results/1737966443819948000-a5d377f9-c4a3-4317-bce4-bba6f7aff27f.json
    function test_auto_test_swap_panics_31() public {
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(-1709197),
            uint64(2507015034928657736),
            uint64(22517998133217244),
            int64(-2295413974737106377),
            uint160(1091331342961834057216515616863121),
            int24(-1),
            int24(6281146),
            int24(-1735228),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738027168808111000-8084ad72-9594-46ed-a328-5103d326eaf2.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_32() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1713559),
            uint64(15555458728262784425),
            uint64(14115923017609172634),
            int64(5),
            uint160(109842361874602604131347696134033129279613268),
            int24(-3779163),
            int24(6212397),
            int24(0),
            uint24(7009985)
        );
    }

    // Reproduced from: medusa/test_results/1738005585502941000-06d4df2e-9e11-499c-9836-e4619db1afb5.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_33()
        public
    {
        vm.warp(block.timestamp + 360621);
        vm.roll(block.number + 15782);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(47),
            int24(-6266013),
            int24(-6864526),
            int24(0),
            uint256(36265561943263937248354834973183185125648306522041094101563787483664630129915),
            uint256(822752278660603066749410756518669184021018317640263314066117694)
        );
    }

    // Reproduced from: medusa/test_results/1738020740540432000-c3062fc7-423a-42e2-af42-cac4bc5c4d1e.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_34(
    ) public {
        vm.warp(block.timestamp + 238045);
        vm.roll(block.number + 139);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(88),
            int24(-1180009),
            int24(-2435674),
            int24(0),
            uint256(105972240291859636746807295116423337795408367748903810472314437267105855511829)
        );
    }

    // Reproduced from: medusa/test_results/1738027168806129000-ce62cb28-660c-48c2-a68c-3b13b80fd414.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_35() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1713408),
            uint64(8564465460288737603),
            uint64(12644349554174351901),
            int64(10253),
            uint160(101663932722607991897332010994723398933),
            int24(-7186471),
            int24(1278098),
            int24(0),
            uint24(0)
        );
    }

    // Reproduced from: medusa/test_results/1737963947158028000-ee1b6640-a777-47ae-9c66-dc9b1534a997.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_36()
        public
    {
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(1),
            int24(-563),
            int24(-4226973),
            int24(169),
            uint256(0),
            uint256(3213876136431850229340391134096713441363022276263083426061053)
        );
    }

    // Reproduced from: medusa/test_results/1738027168811084000-b3a1e509-40dc-49b1-9833-572f769b1da6.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_37() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1713608),
            uint64(8174881927314071246),
            uint64(17831988690838282668),
            int64(-1),
            uint160(2296761309362457883430849852688078971),
            int24(-7200531),
            int24(-6059470),
            int24(0),
            uint24(1027360)
        );
    }

    // Reproduced from: medusa/test_results/1738027168809891000-0322dbd1-f2ea-4fcd-8947-c67e2048f40f.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_38() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1713658),
            uint64(11844704356884189450),
            uint64(17844389089453155112),
            int64(11),
            uint160(4388105114408029930012178858777696923463607590),
            int24(-7211271),
            int24(3748089),
            int24(0),
            uint24(1007320)
        );
    }

    // Reproduced from: medusa/test_results/1738007192485963000-cdfc826a-0f26-478f-9c41-06e613741678.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_39()
        public
    {
        vm.warp(block.timestamp + 116477);
        vm.roll(block.number + 47623);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(159),
            int24(-2296534),
            int24(0),
            int24(3075255),
            uint256(36029408600730301075335018509470931467700182848197722882940523082925952980861),
            uint256(13493137370033889545670747296949123015435231284132476708484044971777)
        );
    }

    // Reproduced from: medusa/test_results/1738022041836550000-fb44e161-17b3-409a-a864-20f10d5f9d2b.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_40(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-6644301),
            uint256(0),
            uint256(199),
            int24(5229652),
            int24(457176),
            uint256(57731211141290440788045118758773593880237699653025599781280401492167421444009)
        );
    }

    // Reproduced from: medusa/test_results/1738005585473273000-08d45f7b-1992-4a48-b24e-e53c548accda.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_41()
        public
    {
        vm.warp(block.timestamp + 360621);
        vm.roll(block.number + 15782);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(48),
            int24(244815),
            int24(4974369),
            int24(0),
            uint256(36265561943263937248354834973183185125648306522041094101563787483664629896039),
            uint256(10499090518654438905268277193379362559)
        );
    }

    // Reproduced from: medusa/test_results/1738022041840931000-9a0a9b2c-d935-4558-b6c0-7e958bd310b3.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_42(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-6644472),
            uint256(1039),
            uint256(199),
            int24(1853468),
            int24(8036287),
            uint256(57731211141290440788045118758773593880237699653025599781280401492166221449095)
        );
    }

    // Reproduced from: medusa/test_results/1738016030390487000-02ad485c-3113-4e4d-8b9b-4279675718c6.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_43(
    ) public {
        vm.warp(block.timestamp + 395199);
        vm.roll(block.number + 36411);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(31),
            int24(0),
            int24(-4016334),
            int24(16971),
            uint256(205688069665150755270087448090672561373535808443343117332003672),
            int24(2514192),
            uint256(57896044618658097711785492504343953926634992332820282019728792003955366185584),
            uint32(1619245778),
            uint32(877275025),
            uint256(107839786668602559178668082648823730599146831143753309627898602424720)
        );
    }

    // Reproduced from: medusa/test_results/1738022041842413000-cd24bec5-3bbc-40d4-b49e-1b0edaa265da.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_44(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-3322151),
            uint256(1000001005189861015),
            uint256(199),
            int24(1771783),
            int24(-2706948),
            uint256(57731211141290440788045118758773593880237699653025599781280401492165021483273)
        );
    }

    // Reproduced from: medusa/test_results/1738005585502576000-7ae14ec1-6444-4d22-8a83-2fda96952ca2.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_45()
        public
    {
        vm.warp(block.timestamp + 360621);
        vm.roll(block.number + 15782);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(48),
            int24(219815),
            int24(-5147919),
            int24(0),
            uint256(36265561943263937248354834973183185125648306522041094101563787483664629868992),
            uint256(110427941548649020598956093796432407243934141571210177474436529150154827)
        );
    }

    // Reproduced from: medusa/test_results/1738035588946235000-20b868fb-e74a-4b5c-9076-d5a07e17e521.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_46() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906498),
            uint64(14207350896485508347),
            uint64(16860186792464107664),
            int64(10),
            uint160(365375409247813386621858196326342293925822103416),
            int24(3028997),
            int24(-4855774),
            int24(0),
            uint24(3075102)
        );
    }

    // Reproduced from: medusa/test_results/1738007192489049000-840ddd09-1399-4eef-bbed-5e31070feace.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_47()
        public
    {
        vm.warp(block.timestamp + 116477);
        vm.roll(block.number + 47623);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(159),
            int24(-2296533),
            int24(0),
            int24(6845619),
            uint256(36029408600730301075335018509470931467700182848197722882940523082923552986315),
            uint256(13164036458569648337239753460458804041140294726397188495273214205)
        );
    }

    // Reproduced from: medusa/test_results/1737965682418848000-5375a8ef-996d-425a-ace7-fc88cd79c535.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_48(
    ) public {
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(
            int24(-4668573), uint256(50998458382761), uint256(6721), int24(0), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738016030394946000-b7fc1c95-c3d9-4332-ad5b-670feefcdf74.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_49(
    ) public {
        vm.warp(block.timestamp + 395199);
        vm.roll(block.number + 36411);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(31),
            int24(0),
            int24(2594845),
            int24(-3901367),
            uint256(421249267107859179566709139428841151143153698646250488300853533135),
            int24(2514192),
            uint256(28948022309329048855892746252171976962977247824323411219380069827163394291605),
            uint32(1223116324),
            uint32(1946198255),
            uint256(1427944549279022211072001847764748893660830147)
        );
    }

    // Reproduced from: medusa/test_results/1738020740542619000-633ed5e5-e673-484d-89ef-c90f69bb1191.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_50(
    ) public {
        vm.warp(block.timestamp + 238045);
        vm.roll(block.number + 139);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(88),
            int24(-1180006),
            int24(-2427993),
            int24(0),
            uint256(105972240291859636746807295116423337795408367748903810472314437267105855539912)
        );
    }

    // Reproduced from: medusa/test_results/1737963947157302000-cd767d28-193d-485a-a56f-3cee86374616.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_51()
        public
    {
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(4158),
            uint256(1),
            int24(4191693),
            int24(2526079),
            int24(2220676),
            uint256(115792089237316195423570985008687907852929251270293017182800511579414811675784),
            uint256(11632281328460273187974698166564944123886744341292)
        );
    }

    // Reproduced from: medusa/test_results/1738020740540855000-400a4a6a-669d-4581-b416-0b1b05f610b2.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_52(
    ) public {
        vm.warp(block.timestamp + 238045);
        vm.roll(block.number + 139);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(499999999858),
            uint256(88),
            int24(-1180000),
            int24(-2435885),
            int24(0),
            uint256(105972240291859636746807295116423337795408367748903810472314437267104655496529)
        );
    }

    // Reproduced from: medusa/test_results/1738022041842616000-328174fa-6ca2-4b11-b618-bb4980d0506c.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_53(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-6644501),
            uint256(0),
            uint256(199),
            int24(-1603755),
            int24(1193105),
            uint256(57731211141290440788045118758773593880237699653025599781280401492166221447473)
        );
    }

    // Reproduced from: medusa/test_results/1738016030393377000-55231b92-44b1-4f7b-b48e-cd97aa1c404e.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_54(
    ) public {
        vm.warp(block.timestamp + 395199);
        vm.roll(block.number + 36411);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(15),
            int24(0),
            int24(-7322514),
            int24(313021),
            uint256(1241803112333707237651628938363259740279488),
            int24(-7192512),
            uint256(57896044618658097711785492504343953926975240674907011810213118178769650804653),
            uint32(1251343159),
            uint32(681110967),
            uint256(3450873173396066531434301266234058947557155995985909523688001902006710)
        );
    }

    // Reproduced from: medusa/test_results/1737965682417868000-a08f281d-5c57-4e09-824a-d6e6070c4675.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_55(
    ) public {
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(
            int24(-4668597), uint256(1000000001355384825), uint256(6721), int24(0), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738035588941986000-87a03255-9052-4ec0-9a0a-f9bfba77bcb6.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_56() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906498),
            uint64(16998416392376715691),
            uint64(17108727232161691417),
            int64(10),
            uint160(17140800500798718127557944893643801217110642),
            int24(-3812583),
            int24(77306),
            int24(0),
            uint24(15053359)
        );
    }

    // Reproduced from: medusa/test_results/1737966443816926000-bf7fe7b8-6825-4cf5-89bf-7e1e2c44bb56.json
    function test_auto_test_swap_panics_57() public {
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(6899139),
            uint64(14986673343684029940),
            uint64(5111748650),
            int64(-2968254007093088479),
            uint160(4388061225106918400755208705643357687987287783),
            int24(-1778468),
            int24(0),
            int24(-4),
            false
        );
    }

    // Reproduced from: medusa/test_results/1737963947157860000-8c7e5edd-a3c6-47e9-9c3d-eee6bb6251a0.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_58()
        public
    {
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(1000000000000000000001125900077629980),
            uint256(1),
            int24(-6612453),
            int24(823308),
            int24(6525537),
            uint256(0),
            uint256(822752278660603021080272106396494220042731751786293687088757626)
        );
    }

    // Reproduced from: medusa/test_results/1737965682417341000-52f33059-9599-4e7c-bc09-43759c5e4898.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_59(
    ) public {
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(
            int24(-4668573), uint256(48995458894816), uint256(6721), int24(0), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738016030395111000-e532faeb-d4d1-4ad3-b5f3-f9b4d2167574.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_60(
    ) public {
        vm.warp(block.timestamp + 395199);
        vm.roll(block.number + 36411);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(31),
            int24(0),
            int24(931961),
            int24(-2997753),
            uint256(57896044618658097711785492504343953926477869165112990502356664352231319765977),
            int24(2514192),
            uint256(57896044618658097711785492504343953926634992332820282019728792003956567780494),
            uint32(135110587),
            uint32(870120833),
            uint256(25108406941546723066231055400821603957691997657381134891117)
        );
    }

    // Reproduced from: medusa/test_results/1737966443817300000-1a4e99f0-4ab7-471e-8554-a16b4f6d7d43.json
    function test_auto_test_swap_panics_61() public {
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(1844055),
            uint64(6570056521235710548),
            uint64(826574159737),
            int64(-5980842598044196),
            uint160(66935237996264804630345982057793206144517),
            int24(-2387),
            int24(0),
            int24(-119),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738035588944120000-ae3c2d4b-63c3-4ab8-bb54-1bfab8e58f41.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_62() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906459),
            uint64(8472171234365898320),
            uint64(16814841249256086453),
            int64(14),
            uint160(43554521386039811020198393703482982099246),
            int24(-7195448),
            int24(6240327),
            int24(0),
            uint24(3030477)
        );
    }

    // Reproduced from: medusa/test_results/1738005585500863000-74f8b32b-622a-45af-9302-8d7c809e71ce.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_63()
        public
    {
        vm.warp(block.timestamp + 360621);
        vm.roll(block.number + 15782);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(48),
            int24(244816),
            int24(-5151597),
            int24(0),
            uint256(36265561943263937248354834973183185125648306522041094101563787483663430188623),
            uint256(51422017416287597476923818781778323758264323165398097545275002)
        );
    }

    // Reproduced from: medusa/test_results/1738007192487018000-afca06a2-9f93-4bdb-8f61-1a655908b1c9.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_64()
        public
    {
        vm.warp(block.timestamp + 116477);
        vm.roll(block.number + 47623);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(159),
            int24(-2296531),
            int24(0),
            int24(-7148478),
            uint256(36029408600730301075335018509470931467700182848197722882940523082924752983168),
            uint256(766247771124285127054282655500901042355050314481529223)
        );
    }

    // Reproduced from: medusa/test_results/1738027168809661000-43128dd5-a6d2-4b13-b981-d1bed389e59c.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_65() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1713648),
            uint64(7978828013727054217),
            uint64(18128934228381396920),
            int64(166),
            uint160(1361129471899507175780661769260000458647),
            int24(-374656),
            int24(6228320),
            int24(0),
            uint24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738035588945974000-62e2b2f3-abb1-4ab2-86b4-6e07383e8763.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_66() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906498),
            uint64(15271079921550910922),
            uint64(17453642662760598330),
            int64(13),
            uint160(21775710402754387824675780937546379690528),
            int24(-3807752),
            int24(-4863775),
            int24(0),
            uint24(1118616)
        );
    }

    // Reproduced from: medusa/test_results/1737965682417579000-0f23d74b-0240-4982-a69f-0b5d8bfe67d3.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_67(
    ) public {
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(
            int24(-4668597), uint256(588564), uint256(6721), int24(0), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738020740515697000-dbcadb6c-1f3f-40ad-bc19-9160f0b1e9a9.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_68(
    ) public {
        vm.warp(block.timestamp + 238045);
        vm.roll(block.number + 139);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(88),
            int24(-8077221),
            int24(4356546),
            int24(0),
            uint256(105972240291859636746807295116423337795408367748903810472314437267108255520502)
        );
    }

    // Reproduced from: medusa/test_results/1738035588945196000-dd8d8ab8-c1f4-41ed-8571-392692cfadb8.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_69() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906459),
            uint64(16170595276578621071),
            uint64(16395893740527449579),
            int64(12),
            uint160(34281728408358213595423694486195812501212929),
            int24(-3805332),
            int24(1307427),
            int24(0),
            uint24(1178363)
        );
    }

    // Reproduced from: medusa/test_results/1737970907670865000-44e65603-f099-42f1-a5d5-b3b81005448b.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric_70(
    ) public {
        vm.warp(block.timestamp + 570644);
        vm.roll(block.number + 36951);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_double_geometric(
            uint256(2784),
            uint256(352),
            int24(-728192),
            int24(7864200),
            int24(-7218995),
            uint256(13479973333575319897363373426993027738629268015699612799998662084147),
            int24(5581441),
            uint256(13479973333575319897333507543847311011287971100198002002471762395347),
            uint32(56888717),
            uint32(3604426259),
            uint256(1809251394333065553493296640760748560207343510399395873077239369848743524341)
        );
    }

    // Reproduced from: medusa/test_results/1737965682417022000-82728524-3584-471b-a0cf-57c780e0464e.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_71(
    ) public {
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(
            int24(-4668597), uint256(5992775), uint256(6721), int24(0), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738027168804576000-484eb5a1-3cda-43a9-81ff-6c45b6e4f3b8.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_72() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1713630),
            uint64(9063258101569370806),
            uint64(15924665954505406307),
            int64(5),
            uint160(1393796574030239230875345623516006235742139),
            int24(-7190427),
            int24(6222257),
            int24(0),
            uint24(7054934)
        );
    }

    // Reproduced from: medusa/test_results/1738027168808665000-197bb316-e867-4434-a56a-10705902639a.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_73() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1713529),
            uint64(11741591583017822349),
            uint64(17212866390265201219),
            int64(228),
            uint160(1976743282787723298419211915303548214584),
            int24(8132271),
            int24(1295437),
            int24(0),
            uint24(1003047)
        );
    }

    // Reproduced from: medusa/test_results/1737963947135665000-c96bfb1e-e89c-404b-b7a4-2f30ded4a777.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_74()
        public
    {
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(1),
            int24(5165306),
            int24(-4265618),
            int24(7334747),
            uint256(0),
            uint256(3291009114642599155586207863666390860941607272444261076440784787)
        );
    }

    // Reproduced from: medusa/test_results/1738007192487968000-50c0243f-81aa-4258-95d1-ae4681cd5054.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_75()
        public
    {
        vm.warp(block.timestamp + 116477);
        vm.roll(block.number + 47623);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(159),
            int24(-2296530),
            int24(0),
            int24(-207),
            uint256(36029408600730301075335018509470931467700182848197722882940523082924753000400),
            uint256(25711008708143867244634481707048237680676117284214764861264726)
        );
    }

    // Reproduced from: medusa/test_results/1738005585500291000-dbba3bcb-0c23-4fda-8421-fa1acc087332.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_76()
        public
    {
        vm.warp(block.timestamp + 360621);
        vm.roll(block.number + 15782);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(24),
            int24(3844680),
            int24(-5086940),
            int24(0),
            uint256(36265561943263937248354834973183185125648306522041094101563787483663430959960),
            uint256(46768052394297553926765316968629048448510178004205)
        );
    }

    // Reproduced from: medusa/test_results/1738022041841260000-886d4c67-040c-42f7-98fd-a2c19d522803.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_77(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-6644299),
            uint256(0),
            uint256(199),
            int24(3540319),
            int24(-3367144),
            uint256(57731211141290440788045118758773593880237699653025599781280401492167421461660)
        );
    }

    // Reproduced from: medusa/test_results/1738035588945458000-a055feef-4d7d-4df0-9ccc-f62a7f8984b2.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_78() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906460),
            uint64(11107696355062119867),
            uint64(17219026369165377394),
            int64(11),
            uint160(178405961811870028867371761425734968527603037),
            int24(-7197071),
            int24(6216649),
            int24(0),
            uint24(15018379)
        );
    }

    // Reproduced from: medusa/test_results/1738007192487264000-61e1d639-dfe9-49c9-a910-62edceabcbc0.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_79()
        public
    {
        vm.warp(block.timestamp + 116477);
        vm.roll(block.number + 47623);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(159),
            int24(-2296537),
            int24(0),
            int24(5308200),
            uint256(36029408600730301075335018509470931467700182848197722882940523082922352967086),
            uint256(9873886591491940581714260196146965984)
        );
    }

    // Reproduced from: medusa/test_results/1738022041840396000-6e08f951-bf80-41fc-b2f0-20fc26be4446.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_80(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-6775310),
            uint256(0),
            uint256(199),
            int24(242098),
            int24(697852),
            uint256(57731211141290440788045118758773593880237699653025599781280401492166221411396)
        );
    }

    // Reproduced from: medusa/test_results/1737966443818920000-e3a18108-379e-4351-8a90-ec334cc987d4.json
    function test_auto_test_swap_panics_81() public {
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(2706721),
            uint64(348032021816569666),
            uint64(12),
            int64(-6661871091855981451),
            uint160(14828008533905389618760653531954929855),
            int24(-216),
            int24(4501777),
            int24(1780111),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738020740542962000-2a1d119f-f42d-432b-99f6-cb3d89d4b274.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_82(
    ) public {
        vm.warp(block.timestamp + 238045);
        vm.roll(block.number + 139);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(53094475071),
            uint256(88),
            int24(-1180009),
            int24(-2441578),
            int24(0),
            uint256(105972240291859636746807295116423337795408367748903810472314437267104655551214)
        );
    }

    // Reproduced from: medusa/test_results/1737965682402711000-f2b6efdb-b483-4149-a0f2-263266c323bb.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_83(
    ) public {
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(
            int24(-4668573), uint256(48997367265558), uint256(6721), int24(0), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738027168805421000-5313e514-bdaa-44e7-b7a3-835fcbd3658e.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_84() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1713608),
            uint64(12306331823460226203),
            uint64(13218575294295518865),
            int64(6),
            uint160(1461501636992786919103015327564675344228300413702),
            int24(-3791287),
            int24(6213162),
            int24(0),
            uint24(1025115)
        );
    }

    // Reproduced from: medusa/test_results/1738027168803842000-01b455f5-6ec4-43f2-a1f2-611af6ee611a.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_85() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1713649),
            uint64(10378791186547471686),
            uint64(17790634254187284647),
            int64(9),
            uint160(12868085629908820100527507228863543),
            int24(-7209952),
            int24(-1159303),
            int24(0),
            uint24(1021643)
        );
    }

    // Reproduced from: medusa/test_results/1737963947158663000-19dbdd61-b566-4536-a303-09bc7907e257.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_86()
        public
    {
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(1),
            int24(-204),
            int24(7645600),
            int24(-447),
            uint256(0),
            uint256(52656145834278593348959013842662919951413176144607224530584198188)
        );
    }

    // Reproduced from: medusa/test_results/1737966443820105000-3ea56b25-3a4b-41e9-9a57-721a02b43323.json
    function test_auto_test_swap_panics_87() public {
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(3717880),
            uint64(16497469272822823708),
            uint64(8133825),
            int64(-1480810142108320990),
            uint160(1406371870577893612706153237476039029488),
            int24(-1615),
            int24(0),
            int24(-3),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738007192486709000-722b64ce-fc3d-4b62-bdb3-e9f88d1d7ce1.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_88()
        public
    {
        vm.warp(block.timestamp + 116477);
        vm.roll(block.number + 47623);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(159),
            int24(-2296535),
            int24(-1705063),
            int24(8383506),
            uint256(36029408600730301075335018509470931467700182848197722882940523082924752968302),
            uint256(3533694129556768659166595001396637405120929859232967564892563877477162407)
        );
    }

    // Reproduced from: medusa/test_results/1737966443817607000-c3cab706-affa-4ceb-a125-806f773ecf0a.json
    function test_auto_test_swap_panics_89() public {
        vm.warp(block.timestamp + 206638);
        vm.roll(block.number + 6);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.test_swap_panics(
            int24(511260),
            uint64(1303475894458199),
            uint64(2179499087934466373),
            int64(-70393242501818333),
            uint160(2787593149184960791694400110288486765841348),
            int24(1747538),
            int24(0),
            int24(-1327),
            false
        );
    }

    // Reproduced from: medusa/test_results/1738035588943658000-3fb325d0-3ca8-400c-864a-dd91206c4be2.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_90() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906498),
            uint64(9437841986813461654),
            uint64(17598877466629167893),
            int64(500),
            uint160(22835962606483991308180527292999305707881442552),
            int24(4739552),
            int24(6228920),
            int24(0),
            uint24(9)
        );
    }

    // Reproduced from: medusa/test_results/1738022041842027000-33bcc95e-6bf0-499d-a8fa-c4b2a65cb9aa.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_91(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-6644305),
            uint256(0),
            uint256(199),
            int24(1864789),
            int24(-7188840),
            uint256(57731211141290440788045118758773593880237699653025599781280401492166221417998)
        );
    }

    // Reproduced from: medusa/test_results/1738016030394630000-9305c7c1-81d8-42e3-b71d-1a5167c7a1b4.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_92(
    ) public {
        vm.warp(block.timestamp + 395199);
        vm.roll(block.number + 36411);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(31),
            int24(0),
            int24(2597247),
            int24(-2161106),
            uint256(102844034832763917054969364812077606885749896954301422734941662),
            int24(2514192),
            uint256(57896044618658097711785492504343953927315489016993741600697444353585137726033),
            uint32(333449651),
            uint32(2739505421),
            uint256(55651219613705415086759033453402652065)
        );
    }

    // Reproduced from: medusa/test_results/1738027168807287000-5b56ac65-dc9d-4b48-ab84-b7bfc359d3bc.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_93() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(1713801),
            uint64(5036450985943543495),
            uint64(8586192598784566632),
            int64(6),
            uint160(27176281945200523149442590546851353852086),
            int24(-3794980),
            int24(2556085),
            int24(0),
            uint24(7053683)
        );
    }

    // Reproduced from: medusa/test_results/1738020740542143000-9c85eab3-eeb4-4d59-bb90-476e1d79bd6a.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_94(
    ) public {
        vm.warp(block.timestamp + 238045);
        vm.roll(block.number + 139);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(88),
            int24(-1180001),
            int24(-2420317),
            int24(0),
            uint256(105972240291859636746807295116423337795408367748903810472314437267105855476075)
        );
    }

    // Reproduced from: medusa/test_results/1738022041842217000-fbb21a55-89c3-4e6b-a83f-e043d1da4402.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_95(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-3322151),
            uint256(0),
            uint256(199),
            int24(3544161),
            int24(-2469698),
            uint256(57731211141290440788045118758773593880237699653025599781280401492163821448027)
        );
    }

    // Reproduced from: medusa/test_results/1738035588942690000-f47ec9f2-7e84-4e5d-8a6d-c7cdc21eee9c.json
    function test_auto_compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero_96() public {
        vm.warp(block.timestamp + 468447);
        vm.roll(block.number + 7315);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
            int24(7906498),
            uint64(9466706303971590764),
            uint64(18445518170111896053),
            int64(10),
            uint160(18405666490475252280334762983491634754),
            int24(-3795730),
            int24(6251473),
            int24(0),
            uint24(3028737)
        );
    }

    // Reproduced from: medusa/test_results/1738020740543131000-3a892492-f7c6-4af9-ba4b-b15c7bdf287d.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution_97(
    ) public {
        vm.warp(block.timestamp + 238045);
        vm.roll(block.number + 139);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_geometric_distribution(
            uint256(0),
            uint256(88),
            int24(-1180009),
            int24(-751149),
            int24(0),
            uint256(105972240291859636746807295116423337795408367748903810472314437267104655518961)
        );
    }

    // Reproduced from: medusa/test_results/1737963947158347000-47a2fcdb-c6ee-49a4-ad5d-917cfd54eb91.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_98()
        public
    {
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(1),
            int24(8384129),
            int24(2533246),
            int24(5370181),
            uint256(0),
            uint256(6079869658409592917502478203173786623726612332626457)
        );
    }

    // Reproduced from: medusa/test_results/1738005585502835000-d37814bc-6449-43b1-906c-69f741285ead.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric_99()
        public
    {
        vm.warp(block.timestamp + 360621);
        vm.roll(block.number + 15782);
        vm.prank(0x0000000000000000000000000000000000010000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_carpeted_geometric(
            uint256(0),
            uint256(48),
            int24(244824),
            int24(-5160480),
            int24(0),
            uint256(36265561943263937248354834973183185125648306522041094101563787483662230358687),
            uint256(14134776518227074636666403389969545421063872087450888910194578361247769078)
        );
    }

    // Reproduced from: medusa/test_results/1737963947119696000-32af5f12-b744-4f76-aed7-261e578f0d71.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_100()
        public
    {
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(1),
            int24(3780457),
            int24(5762433),
            int24(543997),
            uint256(0),
            uint256(6277101735386651597934030944594666050133370237651473770384)
        );
    }

    // Reproduced from: medusa/test_results/1737965682411069000-bc2974bf-6a5c-402e-89d8-094c46a9dd29.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution_101(
    ) public {
        vm.warp(block.timestamp + 96);
        vm.roll(block.number + 64);
        vm.prank(0x0000000000000000000000000000000000030000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_uniform_distribution(
            int24(-4668597), uint256(0), uint256(6721), int24(0), int24(0)
        );
    }

    // Reproduced from: medusa/test_results/1738016030394037000-dad4593c-b6b2-467a-90ee-5410298308b1.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric_102(
    ) public {
        vm.warp(block.timestamp + 395199);
        vm.roll(block.number + 36411);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_double_geometric(
            uint256(0),
            uint256(31),
            int24(0),
            int24(7539922),
            int24(-760130),
            uint256(6129982163485895325395236242077396387612873816918508051),
            int24(-7192512),
            uint256(57896044618658097711785492504343953926294743990733552229244097949702306731106),
            uint32(1011717159),
            uint32(907478425),
            uint256(1427073414434989929022144687656681809910538106)
        );
    }

    // Reproduced from: medusa/test_results/1737963947158178000-6f9c4bc2-593d-46d8-8906-23e9e87c919b.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_103()
        public
    {
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(1000000000000000000000000001299438228),
            uint256(5),
            int24(-398),
            int24(7624102),
            int24(449),
            uint256(0),
            uint256(3533694129556769051485453463331790338659273659857322213851777939060185359)
        );
    }

    // Reproduced from: medusa/test_results/1738022041814621000-b45342c9-8264-4c0f-b302-6287f46f083a.json
    function test_auto_inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution_104(
    ) public {
        vm.warp(block.timestamp + 360497);
        vm.roll(block.number + 6860);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount0_greater_than_equal_to_cummulative_amount0_in_geometric_distribution(
            int24(-6644302),
            uint256(1000001001475691485),
            uint256(199),
            int24(-8152996),
            int24(-3834536),
            uint256(57731211141290440788045118758773593880237699653025599781280401492165021473114)
        );
    }

    // Reproduced from: medusa/test_results/1737963947157665000-ffed00f9-0d60-4365-a326-4199aab11cab.json
    function test_auto_inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric_105()
        public
    {
        vm.warp(block.timestamp + 471731);
        vm.roll(block.number + 23310);
        vm.prank(0x0000000000000000000000000000000000020000);
        target.inverse_cummulative_amount1_greater_than_equal_to_cummulative_amount1_in_carpeted_geometric(
            uint256(0),
            uint256(1),
            int24(-4311),
            int24(5943454),
            int24(-6399071),
            uint256(0),
            uint256(3039924832842607455107421243660546040690562126818981)
        );
    }
}
