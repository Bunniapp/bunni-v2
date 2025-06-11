// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {BunniHookLogic} from "../src/lib/BunniHookLogic.sol";

contract DeployHookLogicScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (address hookLogic, bytes32 hookLogicSalt) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        hookLogicSalt = getCreate3SaltFromEnv("BunniHookLogic");

        vm.startBroadcast(deployerPrivateKey);

        hookLogic = create3.deploy(hookLogicSalt, type(BunniHookLogic).creationCode);

        require(hookLogic == getCreate3ContractFromEnvSalt("BunniHookLogic"), "hookLogic invalid");

        vm.stopBroadcast();
    }
}
