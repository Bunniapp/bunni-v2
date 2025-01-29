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

        address hub = getCreate3ContractFromEnvSalt("BunniHub");
        address hook = getCreate3ContractFromEnvSalt("BunniHook");
        address quoter = getCreate3ContractFromEnvSalt("BunniQuoter");

        vm.startBroadcast(deployerPrivateKey);

        geometric = GeometricDistribution(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("GeometricDistribution"),
                    bytes.concat(type(GeometricDistribution).creationCode, abi.encode(hub, hook, quoter))
                )
            )
        );

        doubleGeometric = DoubleGeometricDistribution(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("DoubleGeometricDistribution"),
                    bytes.concat(type(DoubleGeometricDistribution).creationCode, abi.encode(hub, hook, quoter))
                )
            )
        );

        carpetedGeometric = CarpetedGeometricDistribution(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("CarpetedGeometricDistribution"),
                    bytes.concat(type(CarpetedGeometricDistribution).creationCode, abi.encode(hub, hook, quoter))
                )
            )
        );

        carpetedDoubleGeometric = CarpetedDoubleGeometricDistribution(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("CarpetedDoubleGeometricDistribution"),
                    bytes.concat(type(CarpetedDoubleGeometricDistribution).creationCode, abi.encode(hub, hook, quoter))
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
                    bytes.concat(type(BuyTheDipGeometricDistribution).creationCode, abi.encode(hub, hook, quoter))
                )
            )
        );

        vm.stopBroadcast();
    }
}
