// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {BunniQuoter} from "../src/periphery/BunniQuoter.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {IBunniHub} from "../src/interfaces/IBunniHub.sol";
import {CarpetedDoubleGeometricDistribution} from "../src/ldf/CarpetedDoubleGeometricDistribution.sol";

contract TestSwapScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external {
        BunniQuoter quoter = new BunniQuoter(IBunniHub(0x9fcB8DbbB93F908f0ff2f9B425594A0511dd71c4));
        vm.etch(0xA2Afc28157E54FfF80cd45Be1677d7A51837FDc3, type(CarpetedDoubleGeometricDistribution).runtimeCode);

        address sender = 0xC25560E513de24d927Fd1779fDCE848e3d1a9907;
        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(0x1ef5F52BdBe11Af2377C58ecC914A8c72Ea807cF),
            currency1: Currency.wrap(0x51C9b39CE3c0c0ea450674e6D8A5Ec088d44aE17),
            fee: 1,
            tickSpacing: 10,
            hooks: IHooks(0x56aafc3fF6B436Eb171615acb9fb723f025D1888)
        });
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -3391950120000000000,
            sqrtPriceLimitX96: 4295128740
        });
        quoter.quoteSwap(sender, key, params);
    }
}
