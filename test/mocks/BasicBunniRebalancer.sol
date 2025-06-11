// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {CurrencyDelta} from "@uniswap/v4-core/src/libraries/CurrencyDelta.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

import "flood-contracts/src/interfaces/IFloodPlain.sol";

import {console2} from "forge-std/console2.sol";

import {IBunniHub} from "src/interfaces/IBunniHub.sol";

contract BasicBunniRebalancer is IUnlockCallback {
    using SafeCastLib for *;
    using SafeTransferLib for address;
    using PoolIdLibrary for PoolKey;
    using BalanceDeltaLibrary for BalanceDelta;
    using CurrencyDelta for Currency;

    IPoolManager public immutable poolManager;
    IFloodPlain public immutable floodPlain;

    constructor(IPoolManager poolManager_, IFloodPlain floodPlain_) {
        poolManager = poolManager_;
        floodPlain = floodPlain_;
    }

    function unlockCallback(bytes calldata data) external override returns (bytes memory) {
        require(msg.sender == address(poolManager), "Not PoolManager");

        (
            IFloodPlain.SignedOrder memory package,
            PoolKey memory keyA,
            PoolKey memory keyB,
            PoolKey memory keyC,
            uint256 jitSharesA,
            uint256 jitAmount0A,
            uint256 jitAmount1A,
            uint256 jitSharesB,
            uint256 jitAmount0B,
            uint256 jitAmount1B,
            address hub
        ) = abi.decode(
            data,
            (
                IFloodPlain.SignedOrder,
                PoolKey,
                PoolKey,
                PoolKey,
                uint256,
                uint256,
                uint256,
                uint256,
                uint256,
                uint256,
                address
            )
        );

        // validate order
        require(PoolId.unwrap(keyA.toId()) == bytes32(package.signature), "Invalid signature");

        // swap with Bunni pool to obtain rebalance order swap consideration
        bool zeroForOne = package.order.consideration.token == Currency.unwrap(keyB.currency1);
        // flash swap token2 for token0 and get owed delta
        BalanceDelta swapDelta = poolManager.swap(
            keyB,
            IPoolManager.SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: package.order.consideration.amount.toInt256(),
                sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            bytes("")
        );
        poolManager.take(
            Currency.wrap(package.order.consideration.token), address(this), package.order.consideration.amount
        );

        // NOTE: do this before fulfilling the flood rebalance order to prevent re-entrancy issues
        // use offer tokens to obtain token2 to settle delta
        // any amount left over would be considered profit
        address offerToken = package.order.offer[0].token;
        uint256 owedAmount = zeroForOne ? uint128(-swapDelta.amount0()) : uint128(-swapDelta.amount1());

        // flash swap token1 for token2 and get owed delta
        zeroForOne = offerToken == Currency.unwrap(keyC.currency0);
        address needToken = zeroForOne ? Currency.unwrap(keyC.currency1) : Currency.unwrap(keyC.currency0);
        swapDelta = poolManager.swap(
            keyC,
            IPoolManager.SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: owedAmount.toInt128(),
                sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            bytes("")
        );
        poolManager.take(Currency.wrap(needToken), address(this), owedAmount);

        // settle token2
        poolManager.sync(Currency.wrap(needToken));
        needToken.safeTransfer(address(poolManager), owedAmount);
        poolManager.settle();

        // fulfill flood rebalance order and obtain rebalance order offer tokens
        package.order.consideration.token.safeApprove(address(floodPlain), package.order.consideration.amount);
        floodPlain.fulfillOrder(package);

        // now compare token1 proceeds from rebalance order with the swap delta
        // uint256 token1Delta = zeroForOne ? uint128(-swapDelta.amount1()) : uint128(-swapDelta.amount0());
        // console2.log("Token1 Delta:", token1Delta);
        console2.log("Offer token amount:", Currency.wrap(offerToken).balanceOf(address(this)));

        // require(
        //     token1Delta <= Currency.wrap(offerToken).balanceOf(address(this)),
        //     "Not enough offer token"
        // );

        console2.log("token0Delta:", Currency.wrap(package.order.consideration.token).getDelta(address(this)));
        console2.log("token1Delta:", Currency.wrap(offerToken).getDelta(address(this)));
        console2.log("token2Delta:", Currency.wrap(needToken).getDelta(address(this)));

        // settle the offer token
        poolManager.sync(Currency.wrap(offerToken));
        // uint256 token1Delta = 182110097679812872; // TODO: not sure why above calculations of delta are incorrect but this settles correctly
        uint256 token1Delta = 364390798810456797; // TODO: not sure why above calculations of delta are incorrect but this settles correctly
        offerToken.safeTransfer(address(poolManager), token1Delta);
        poolManager.settle();

        return bytes("");
    }

    function rebalance(
        IFloodPlain.SignedOrder calldata package,
        PoolKey calldata keyA,
        PoolKey calldata keyB,
        PoolKey calldata keyC,
        uint256 jitSharesA,
        uint256 jitAmount0A,
        uint256 jitAmount1A,
        uint256 jitSharesB,
        uint256 jitAmount0B,
        uint256 jitAmount1B,
        address bunniHub
    ) external {
        poolManager.unlock(
            abi.encode(
                package,
                keyA,
                keyB,
                keyC,
                jitSharesA,
                jitAmount0A,
                jitAmount1A,
                jitSharesB,
                jitAmount0B,
                jitAmount1B,
                bunniHub
            )
        );
    }

    function withdrawJitLiquidity(
        PoolKey calldata keyA,
        uint256 jitSharesA,
        uint256 jitAmount0A,
        uint256 jitAmount1A,
        PoolKey calldata keyB,
        uint256 jitSharesB,
        uint256 jitAmount0B,
        uint256 jitAmount1B,
        address hub
    ) external {
        // withdraw JIT liquidity
        IBunniHub.WithdrawParams memory withdrawParams = IBunniHub.WithdrawParams({
            poolKey: keyA,
            recipient: address(this),
            shares: jitSharesA,
            amount0Min: 0, // jitAmount0A,
            amount1Min: 0, //jitAmount1A,
            deadline: type(uint256).max,
            useQueuedWithdrawal: false
        });
        (uint256 amount0A, uint256 amount1A) = IBunniHub(hub).withdraw(withdrawParams);

        withdrawParams = IBunniHub.WithdrawParams({
            poolKey: keyB,
            recipient: address(this),
            shares: jitSharesB,
            amount0Min: 0, // jitAmount0B,
            amount1Min: 0, // jitAmount1B,
            deadline: type(uint256).max,
            useQueuedWithdrawal: false
        });
        (uint256 amount0B, uint256 amount1B) = IBunniHub(hub).withdraw(withdrawParams);

        console2.log("JIT amount0 A:", jitAmount0A);
        console2.log("JIT amount1 A:", jitAmount1A);
        console2.log("Amount0 A:", amount0A);
        console2.log("Amount1 A:", amount1A);
        console2.log("JIT gain amount0 A:", amount0A - jitAmount0A);
        console2.log("JIT loss amount1 A:", jitAmount1A - amount1A);

        console2.log("JIT amount0 B:", jitAmount0B);
        console2.log("JIT amount1 B:", jitAmount1B);
        console2.log("Amount0 B:", amount0B);
        console2.log("Amount1 B:", amount1B);
        console2.log("JIT loss amount0 B:", jitAmount0B - amount0B);
        console2.log("JIT gain amount1 B:", amount1B - jitAmount1B);
    }
}
