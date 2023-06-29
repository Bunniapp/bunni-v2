// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.4;

import "forge-std/Test.sol";

contract BunniHookTest is Test {
    function setUp() public {}

    function testExample() public {
        vm.startPrank(address(0xB0B));
        console2.log("Hello world!");
        assertTrue(true);
    }
}
