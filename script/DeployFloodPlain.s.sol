// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "flood-contracts/src/interfaces/IFloodPlain.sol";

import {FloodDeployer} from "../test/utils/FloodDeployer.sol";

contract DeployFloodPlainScript is Script, FloodDeployer {
    constructor() {}

    function run() external returns (IFloodPlain floodPlain) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        address permit2 = vm.envAddress("PERMIT2");

        vm.startBroadcast(deployerPrivateKey);

        floodPlain = _deployFlood(permit2);

        vm.stopBroadcast();
    }
}
