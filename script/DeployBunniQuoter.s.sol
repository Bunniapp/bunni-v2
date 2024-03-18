// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {BunniQuoter} from "../src/periphery/BunniQuoter.sol";

contract DeployBunniQuoterScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (BunniQuoter quoter) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        quoter = BunniQuoter(
            create3.deploy(
                getCreate3ContractSalt("BunniQuoter"),
                bytes.concat(type(BunniQuoter).creationCode, abi.encode(getCreate3Contract("BunniHub")))
            )
        );

        vm.stopBroadcast();
    }
}
