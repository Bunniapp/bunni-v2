// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {UniformDistribution} from "../src/ldf/UniformDistribution.sol";
import {GeometricDistribution} from "../src/ldf/GeometricDistribution.sol";
import {DoubleGeometricDistribution} from "../src/ldf/DoubleGeometricDistribution.sol";
import {CarpetedGeometricDistribution} from "../src/ldf/CarpetedGeometricDistribution.sol";
import {BuyTheDipGeometricDistribution} from "../src/ldf/BuyTheDipGeometricDistribution.sol";
import {CarpetedDoubleGeometricDistribution} from "../src/ldf/CarpetedDoubleGeometricDistribution.sol";

contract DeployLDFsScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run()
        external
        returns (
            GeometricDistribution geometric,
            DoubleGeometricDistribution doubleGeometric,
            CarpetedGeometricDistribution carpetedGeometric,
            CarpetedDoubleGeometricDistribution carpetedDoubleGeometric,
            UniformDistribution uniform,
            BuyTheDipGeometricDistribution buyTheDipGeometric
        )
    {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        geometric = GeometricDistribution(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("GeometricDistribution"), type(GeometricDistribution).creationCode
                )
            )
        );

        doubleGeometric = DoubleGeometricDistribution(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("DoubleGeometricDistribution"),
                    type(DoubleGeometricDistribution).creationCode
                )
            )
        );

        carpetedGeometric = CarpetedGeometricDistribution(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("CarpetedGeometricDistribution"),
                    type(CarpetedGeometricDistribution).creationCode
                )
            )
        );

        carpetedDoubleGeometric = CarpetedDoubleGeometricDistribution(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("CarpetedDoubleGeometricDistribution"),
                    type(CarpetedDoubleGeometricDistribution).creationCode
                )
            )
        );

        uniform = UniformDistribution(
            payable(
                create3.deploy(getCreate3ContractSalt("UniformDistribution"), type(UniformDistribution).creationCode)
            )
        );

        buyTheDipGeometric = BuyTheDipGeometricDistribution(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("BuyTheDipGeometricDistribution"),
                    type(BuyTheDipGeometricDistribution).creationCode
                )
            )
        );

        vm.stopBroadcast();
    }
}
