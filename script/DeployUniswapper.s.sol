// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {Uniswapper} from "../test/mocks/Uniswapper.sol";

contract DeployUniswapperScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (Uniswapper uniswapper) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        address poolManager = vm.envAddress("POOL_MANAGER");

        vm.startBroadcast(deployerPrivateKey);

        uniswapper = Uniswapper(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("Uniswapper"),
                    bytes.concat(type(Uniswapper).creationCode, abi.encode(poolManager))
                )
            )
        );

        vm.stopBroadcast();
    }
}
