// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {BunniSwapMath} from "../src/lib/BunniSwapMath.sol";
import {RebalanceLogic} from "../src/lib/RebalanceLogic.sol";

contract DeployLibrariesScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run()
        external
        returns (address swapMathLib, address rebalanceLib, bytes32 swapMathSalt, bytes32 rebalanceSalt)
    {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        swapMathSalt = getCreate3SaltFromEnv("BunniSwapMath");
        rebalanceSalt = getCreate3SaltFromEnv("RebalanceLogic");

        vm.startBroadcast(deployerPrivateKey);

        swapMathLib = create3.deploy(swapMathSalt, type(BunniSwapMath).creationCode);
        rebalanceLib = create3.deploy(rebalanceSalt, type(RebalanceLogic).creationCode);

        require(swapMathLib == getCreate3ContractFromEnvSalt("BunniSwapMath"), "swapMathLib invalid");
        require(rebalanceLib == getCreate3ContractFromEnvSalt("RebalanceLogic"), "rebalanceLib invalid");

        vm.stopBroadcast();
    }
}
