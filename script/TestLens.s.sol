// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.13;

import {CREATE3Script} from "./base/CREATE3Script.sol";

import {BunniLens} from "../test/utils/BunniLens.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";

import {IBunniHub} from "../src/interfaces/IBunniHub.sol";

contract TestLensScript is CREATE3Script {
    constructor() CREATE3Script(vm.envString("VERSION")) {}

    function run() external returns (uint256 excessLiquidity0, uint256 excessLiquidity1, uint256 totalLiquidity) {
        BunniLens lens = new BunniLens(IBunniHub(getCreate3Contract("BunniHub")));
        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(0x1a2d66D21C5D2D1E80D2Ebbe73BDC1F5d8a6c52C),
            currency1: Currency.wrap(0x67a53a2b9984AF64A2e27b1582bC72406a2317c3),
            fee: 0,
            tickSpacing: 60,
            hooks: IHooks(0x5EAab8B8147C46d0884E283C8EeeADd7C9819888)
        });
        return lens.getExcessLiquidity(key);
    }
}
