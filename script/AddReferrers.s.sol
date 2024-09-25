// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {LibString} from "solady/utils/LibString.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {IBunniHub} from "../src/interfaces/IBunniHub.sol";

contract AddReferrersScript is CREATE3Script {
    using stdJson for string;
    using LibString for *;
    using SafeCastLib for *;

    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        IBunniHub hub = IBunniHub(payable(getCreate3Contract("BunniHub", "1.0.15-test")));
        string memory json = vm.readFile("./script/referrers.json");
        uint256 numReferrers;
        while (vm.keyExistsJson(json, string.concat("$[", numReferrers.toString(), "]"))) {
            numReferrers++;
        }
        uint24[] memory referrerIds = new uint24[](numReferrers);
        address[] memory referrerAddresses = new address[](numReferrers);
        for (uint256 i; i < numReferrers; i++) {
            uint24 referrerId = json.readUint(string.concat("$[", i.toString(), "].referrerId")).toUint24();
            require(referrerId != 0, "referrerId is 0");
            address referrerAddress = json.readAddress(string.concat("$[", i.toString(), "].referrerAddress"));
            referrerIds[i] = referrerId;
            referrerAddresses[i] = referrerAddress;
        }

        vm.startBroadcast(deployerPrivateKey);

        for (uint256 i; i < numReferrers; i++) {
            hub.setReferrerAddress(referrerIds[i], referrerAddresses[i]);
        }

        vm.stopBroadcast();
    }
}
