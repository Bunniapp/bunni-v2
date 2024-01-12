// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {LibString} from "solady/src/utils/LibString.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {BunniHub} from "../src/BunniHub.sol";
import {BunniHook} from "../src/BunniHook.sol";

contract DeployScript is CREATE3Script {
    using LibString for uint256;
    using SafeCastLib for uint256;

    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (BunniHub hub, BunniHook hook) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        address poolManager = vm.envAddress("POOL_MAMAGER");
        address weth = vm.envAddress(string.concat("WETH_", block.chainid.toString()));
        address permit2 = vm.envAddress("PERMIT2");
        address owner = vm.envAddress(string.concat("OWNER_", block.chainid.toString()));
        address hookFeesRecipient = vm.envAddress(string.concat("HOOK_FEES_RECIPIENT_", block.chainid.toString()));
        uint96 hookFeesModifier = vm.envUint("HOOK_FEES_MODIFIER").toUint96();

        vm.startBroadcast(deployerPrivateKey);

        hub = BunniHub(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("BunniHub"),
                    bytes.concat(type(BunniHub).creationCode, abi.encode(poolManager, weth, permit2))
                )
            )
        );
        hook = BunniHook(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("BunniHook"),
                    bytes.concat(
                        type(BunniHook).creationCode,
                        abi.encode(poolManager, hub, owner, hookFeesRecipient, hookFeesModifier)
                    )
                )
            )
        );

        vm.stopBroadcast();
    }
}
