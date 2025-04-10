// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "../base/CREATE3Script.sol";
import {OracleUniGeoDistribution} from "../../src/ldf/managed/OracleUniGeoDistribution.sol";
import {ERC20Mock} from "../../test/mocks/ERC20Mock.sol";
import {MockOracle} from "../../test/mocks/MockOracle.sol";

contract DeployMockOracleUniGeoLDFScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run()
        external
        returns (
            OracleUniGeoDistribution oracleUniGeo,
            bytes32 oracleUniGeoSalt,
            address bondToken,
            address stablecoinToken,
            address oracleAddress
        )
    {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        address hub = getCreate3ContractFromEnvSalt("BunniHub");
        address hook = getCreate3ContractFromEnvSalt("BunniHook");
        address quoter = getCreate3ContractFromEnvSalt("BunniQuoter");
        address owner = vm.envAddress("OWNER");

        oracleUniGeoSalt = getCreate3SaltFromEnv("OracleUniGeoDistribution");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy mock ERC20 tokens
        ERC20Mock bond = new ERC20Mock();
        ERC20Mock stablecoin = new ERC20Mock();
        bondToken = address(bond);
        stablecoinToken = address(stablecoin);

        // Deploy mock oracle
        MockOracle oracle = new MockOracle();
        oracleAddress = address(oracle);

        // Set initial floor price (1e18 = 1.0 in WAD format)
        oracle.setFloorPrice(0.83e18);

        oracleUniGeo = OracleUniGeoDistribution(
            create3.deploy(
                oracleUniGeoSalt,
                bytes.concat(
                    type(OracleUniGeoDistribution).creationCode,
                    abi.encode(hub, hook, quoter, owner, oracle, bondToken, stablecoinToken)
                )
            )
        );

        vm.stopBroadcast();
    }
}
