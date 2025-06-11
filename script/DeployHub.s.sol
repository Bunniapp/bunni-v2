// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {LibString} from "solady/utils/LibString.sol";

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {BunniHub} from "../src/BunniHub.sol";
import {BunniToken} from "../src/BunniToken.sol";

contract DeployHubScript is CREATE3Script {
    using LibString for uint256;

    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (BunniHub hub, bytes32 hubSalt) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        address poolManager = vm.envAddress(string.concat("POOL_MANAGER_", block.chainid.toString()));
        address weth = vm.envAddress(string.concat("WETH_", block.chainid.toString()));
        address owner = vm.envAddress("OWNER");

        hubSalt = getCreate3SaltFromEnv("BunniHub");

        address[] memory hookWhitelist = new address[](1);
        hookWhitelist[0] = getCreate3ContractFromEnvSalt("BunniHook");

        vm.startBroadcast(deployerPrivateKey);

        hub = BunniHub(
            payable(
                create3.deploy(
                    hubSalt,
                    bytes.concat(
                        type(BunniHub).creationCode,
                        abi.encode(poolManager, weth, vm.envAddress("PERMIT2"), new BunniToken(), owner, hookWhitelist)
                    )
                )
            )
        );

        vm.stopBroadcast();
    }
}
