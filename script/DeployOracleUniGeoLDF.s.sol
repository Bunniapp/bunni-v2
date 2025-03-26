// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";
import {OracleUniGeoDistribution} from "../src/ldf/managed/OracleUniGeoDistribution.sol";

contract DeployOracleUniGeoLDFScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (OracleUniGeoDistribution oracleUniGeo, bytes32 oracleUniGeoSalt) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        address hub = getCreate3ContractFromEnvSalt("BunniHub");
        address hook = getCreate3ContractFromEnvSalt("BunniHook");
        address quoter = getCreate3ContractFromEnvSalt("BunniQuoter");

        address bond = vm.envAddress("BOND_TOKEN");
        address stablecoin = vm.envAddress("STABLECOIN");
        address oracle = vm.envAddress("ORACLE");
        address owner = vm.envAddress("OWNER");

        oracleUniGeoSalt = getCreate3SaltFromEnv("OracleUniGeoDistribution");

        vm.startBroadcast(deployerPrivateKey);

        oracleUniGeo = OracleUniGeoDistribution(
            create3.deploy(
                oracleUniGeoSalt,
                bytes.concat(
                    type(OracleUniGeoDistribution).creationCode,
                    abi.encode(hub, hook, quoter, owner, oracle, bond, stablecoin)
                )
            )
        );

        vm.stopBroadcast();
    }
}
