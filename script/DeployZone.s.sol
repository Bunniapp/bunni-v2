// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {LibString} from "solady/utils/LibString.sol";

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {BunniZone} from "../src/BunniZone.sol";

contract DeployZoneScript is CREATE3Script {
    using LibString for uint256;

    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (BunniZone zone, bytes32 zoneSalt) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        address owner = vm.envAddress("OWNER");
        address[] memory initialZoneWhitelist =
            vm.envAddress(string.concat("FULFILLER_LIST_", block.chainid.toString()), ",");

        zoneSalt = getCreate3SaltFromEnv("BunniZone");

        vm.startBroadcast(deployerPrivateKey);

        zone = BunniZone(
            payable(
                create3.deploy(
                    zoneSalt, bytes.concat(type(BunniZone).creationCode, abi.encode(owner, initialZoneWhitelist))
                )
            )
        );

        vm.stopBroadcast();
    }
}
