// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {BunniHubLogic} from "../src/lib/BunniHubLogic.sol";

contract DeployHubLogicScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (address hubLogic, bytes32 hubLogicSalt) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        hubLogicSalt = getCreate3SaltFromEnv("BunniHubLogic");

        vm.startBroadcast(deployerPrivateKey);

        hubLogic = create3.deploy(hubLogicSalt, type(BunniHubLogic).creationCode);

        require(hubLogic == getCreate3ContractFromEnvSalt("BunniHubLogic"), "hubLogic invalid");

        vm.stopBroadcast();
    }
}
