// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {BunniLens} from "../test/utils/BunniLens.sol";

contract DeployBunniLensScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (BunniLens lens) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        lens = BunniLens(
            create3.deploy(
                getCreate3ContractSalt("BunniLens"),
                bytes.concat(type(BunniLens).creationCode, abi.encode(getCreate3Contract("BunniHub")))
            )
        );

        vm.stopBroadcast();
    }
}
