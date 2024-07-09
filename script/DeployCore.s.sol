// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {LibString} from "solady/utils/LibString.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {BunniHub} from "../src/BunniHub.sol";
import {BunniZone} from "../src/BunniZone.sol";
import {BunniHook} from "../src/BunniHook.sol";
import {BunniToken} from "../src/BunniToken.sol";

contract DeployCoreScript is CREATE3Script {
    using LibString for uint256;
    using SafeCastLib for uint256;

    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (BunniHub hub, BunniZone zone, BunniHook hook, bytes32 hookSalt) {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        address deployer = vm.addr(deployerPrivateKey);

        address poolManager = vm.envAddress("POOL_MANAGER");
        address weth = vm.envAddress(string.concat("WETH_", block.chainid.toString()));
        address permit2 = vm.envAddress("PERMIT2");
        address owner = vm.envAddress(string.concat("OWNER_", block.chainid.toString()));
        uint32 hookFeeModifier = vm.envUint("HOOK_FEE_MODIFIER").toUint32();
        uint32 referralRewardModifier = vm.envUint("REFERRAL_REWARD_MODIFIER").toUint32();
        address floodPlain = vm.envAddress("FLOOD_PLAIN");

        vm.startBroadcast(deployerPrivateKey);

        hub = BunniHub(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("BunniHub"),
                    bytes.concat(
                        type(BunniHub).creationCode, abi.encode(poolManager, weth, permit2, new BunniToken(), owner)
                    )
                )
            )
        );

        // set the default referrer's address to owner
        hub.setReferrerAddress(0, owner);

        zone = BunniZone(
            payable(
                create3.deploy(
                    getCreate3ContractSalt("BunniZone"), bytes.concat(type(BunniZone).creationCode, abi.encode(owner))
                )
            )
        );

        unchecked {
            bytes32 hookBaseSalt = getCreate3ContractSalt("BunniHook");
            uint256 hookFlags = Hooks.AFTER_INITIALIZE_FLAG + Hooks.BEFORE_ADD_LIQUIDITY_FLAG + Hooks.BEFORE_SWAP_FLAG
                + Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG;
            for (uint256 offset; offset < 100000; offset++) {
                hookSalt = bytes32(uint256(hookBaseSalt) + offset);
                address hookDeployed = create3.getDeployed(deployer, hookSalt);
                if (uint160(bytes20(hookDeployed)) & Hooks.ALL_HOOK_MASK == hookFlags && hookDeployed.code.length == 0)
                {
                    break;
                }
            }
        }
        hook = BunniHook(
            payable(
                create3.deploy(
                    hookSalt,
                    bytes.concat(
                        type(BunniHook).creationCode,
                        abi.encode(
                            poolManager, hub, floodPlain, weth, zone, owner, hookFeeModifier, referralRewardModifier
                        )
                    )
                )
            )
        );

        vm.stopBroadcast();
    }
}
