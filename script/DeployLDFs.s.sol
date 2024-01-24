// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {DiscreteLaplaceDistribution} from "../src/ldf/DiscreteLaplaceDistribution.sol";
import {GeometricDistribution} from "../src/ldf/GeometricDistribution.sol";
// import {DoubleGeometricDistribution} from "../src/ldf/DoubleGeometricDistribution.sol";

contract DeployLDFsScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (DiscreteLaplaceDistribution discreteLaplace, GeometricDistribution geometric) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        discreteLaplace = DiscreteLaplaceDistribution(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("DiscreteLaplaceDistribution"),
                    type(DiscreteLaplaceDistribution).creationCode
                )
            )
        );
        geometric = GeometricDistribution(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("GeometricDistribution"), type(GeometricDistribution).creationCode
                )
            )
        );

        vm.stopBroadcast();
    }
}
