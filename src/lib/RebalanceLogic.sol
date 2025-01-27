// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import "@uniswap/v4-core/src/types/Currency.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

import "flood-contracts/src/interfaces/IZone.sol";
import "flood-contracts/src/interfaces/IFloodPlain.sol";
import "flood-contracts/src/interfaces/IOnChainOrders.sol";

import {IEIP712} from "permit2/src/interfaces/IEIP712.sol";

import {ERC20} from "solady/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./VaultMath.sol";
import "../types/PoolState.sol";
import "../types/IdleBalance.sol";
import "../base/SharedStructs.sol";
import {Oracle} from "./Oracle.sol";
import {queryLDF} from "./QueryLDF.sol";
import {FullMathX96} from "./FullMathX96.sol";
import {BunniHookLogic} from "./BunniHookLogic.sol";
import {OrderHashMemory} from "./OrderHashMemory.sol";

library RebalanceLogic {
    using FullMathX96 for *;
    using SafeTransferLib for *;
    using FixedPointMathLib for *;
    using IdleBalanceLibrary for *;
    using Oracle for Oracle.Observation[MAX_CARDINALITY];

    /// @dev Creates a rebalance order on FloodPlain.
    function rebalance(
        HookStorage storage s,
        BunniHookLogic.Env calldata env,
        BunniHookLogic.RebalanceInput calldata input
    ) external {
        // compute rebalance params
        (bool success, Currency inputToken, Currency outputToken, uint256 inputAmount, uint256 outputAmount) =
            _computeRebalanceParams(s, env, input);
        if (!success) return;

        // create rebalance order
        _createRebalanceOrder(
            s,
            env,
            input.id,
            input.key,
            input.hookParams.rebalanceOrderTTL,
            inputToken,
            outputToken,
            inputAmount,
            outputAmount
        );
    }

    function _computeRebalanceParams(
        HookStorage storage s,
        BunniHookLogic.Env calldata env,
        BunniHookLogic.RebalanceInput calldata input
    )
        private
        view
        returns (bool success, Currency inputToken, Currency outputToken, uint256 inputAmount, uint256 outputAmount)
    {
        // compute the ratio (excessLiquidity / totalLiquidity)
        // excessLiquidity is the minimum amount of liquidity that can be supported by the excess tokens

        // load fresh state
        PoolState memory bunniState = env.hub.poolState(input.id);

        // get fresh token balances
        (uint256 balance0, uint256 balance1) = (
            bunniState.rawBalance0 + getReservesInUnderlying(bunniState.reserve0, bunniState.vault0),
            bunniState.rawBalance1 + getReservesInUnderlying(bunniState.reserve1, bunniState.vault1)
        );

        // compute total liquidity and densities
        (uint256 totalLiquidity,,,,,,,) = queryLDF({
            key: input.key,
            sqrtPriceX96: input.updatedSqrtPriceX96,
            tick: input.updatedTick,
            arithmeticMeanTick: input.arithmeticMeanTick,
            ldf: bunniState.liquidityDensityFunction,
            ldfParams: bunniState.ldfParams,
            ldfState: input.newLdfState,
            balance0: balance0,
            balance1: balance1,
            idleBalance: bunniState.idleBalance
        });

        // compute excess liquidity if there's any
        (uint256 idleBalance, bool willRebalanceToken0) = bunniState.idleBalance.fromIdleBalance();
        uint256 excessLiquidity = willRebalanceToken0
            ? idleBalance.divWad(
                bunniState.liquidityDensityFunction.cumulativeAmount0(
                    input.key,
                    TickMath.minUsableTick(input.key.tickSpacing),
                    WAD,
                    input.arithmeticMeanTick,
                    input.updatedTick,
                    bunniState.ldfParams,
                    input.newLdfState
                )
            )
            : idleBalance.divWad(
                bunniState.liquidityDensityFunction.cumulativeAmount1(
                    input.key,
                    TickMath.maxUsableTick(input.key.tickSpacing) - input.key.tickSpacing,
                    WAD,
                    input.arithmeticMeanTick,
                    input.updatedTick,
                    bunniState.ldfParams,
                    input.newLdfState
                )
            );

        // should rebalance if excessLiquidity / totalLiquidity >= 1 / rebalanceThreshold
        bool shouldRebalance =
            excessLiquidity != 0 && excessLiquidity >= totalLiquidity / input.hookParams.rebalanceThreshold;
        if (!shouldRebalance) return (false, inputToken, outputToken, inputAmount, outputAmount);

        // compute target token densities of the excess liquidity after rebalancing
        // this is done by querying the LDF using a TWAP as the spot price to prevent manipulation
        int24 rebalanceSpotPriceTick = _getTwap(
            s,
            input.id,
            input.updatedTick,
            input.hookParams.rebalanceTwapSecondsAgo,
            input.updatedIntermediate,
            input.updatedIndex,
            input.updatedCardinality
        );
        uint160 rebalanceSpotPriceSqrtRatioX96 = TickMath.getSqrtPriceAtTick(rebalanceSpotPriceTick);
        // totalDensity0X96 and totalDensity1X96 are the token densities of the excess liquidity
        // after rebalancing
        (, uint256 totalDensity0X96, uint256 totalDensity1X96,,,,,) = queryLDF({
            key: input.key,
            sqrtPriceX96: rebalanceSpotPriceSqrtRatioX96,
            tick: rebalanceSpotPriceTick,
            arithmeticMeanTick: input.arithmeticMeanTick,
            ldf: bunniState.liquidityDensityFunction,
            ldfParams: bunniState.ldfParams,
            ldfState: input.newLdfState,
            balance0: 0,
            balance1: 0,
            idleBalance: IdleBalanceLibrary.ZERO
        });

        // compute target amounts (i.e. the token amounts of the excess liquidity)
        uint256 targetAmount0 = excessLiquidity.fullMulX96(totalDensity0X96);
        uint256 targetAmount1 = excessLiquidity.fullMulX96(totalDensity1X96);

        // determine input & output
        (inputToken, outputToken) = willRebalanceToken0
            ? (input.key.currency0, input.key.currency1)
            : (input.key.currency1, input.key.currency0);
        uint256 inputTokenTarget = willRebalanceToken0 ? targetAmount0 : targetAmount1;
        uint256 outputTokenTarget = willRebalanceToken0 ? targetAmount1 : targetAmount0;
        if (idleBalance < inputTokenTarget) {
            // should never happen
            return (false, inputToken, outputToken, inputAmount, outputAmount);
        }
        inputAmount = idleBalance - inputTokenTarget;
        outputAmount = outputTokenTarget.mulDivUp(
            REBALANCE_MAX_SLIPPAGE_BASE - input.hookParams.rebalanceMaxSlippage, REBALANCE_MAX_SLIPPAGE_BASE
        );

        success = true;
    }

    function _createRebalanceOrder(
        HookStorage storage s,
        BunniHookLogic.Env calldata env,
        PoolId id,
        PoolKey calldata key,
        uint16 rebalanceOrderTTL,
        Currency inputToken,
        Currency outputToken,
        uint256 inputAmount,
        uint256 outputAmount
    ) private {
        // create Flood order
        ERC20 inputERC20Token = inputToken.isAddressZero() ? env.weth : ERC20(Currency.unwrap(inputToken));
        ERC20 outputERC20Token = outputToken.isAddressZero() ? env.weth : ERC20(Currency.unwrap(outputToken));
        IFloodPlain.Item[] memory offer = new IFloodPlain.Item[](1);
        offer[0] = IFloodPlain.Item({token: address(inputERC20Token), amount: inputAmount});
        IFloodPlain.Item memory consideration =
            IFloodPlain.Item({token: address(outputERC20Token), amount: outputAmount});

        IBunniHook.RebalanceOrderHookArgs memory hookArgs = IBunniHook.RebalanceOrderHookArgs({
            key: key,
            preHookArgs: IBunniHook.RebalanceOrderPreHookArgs({currency: inputToken, amount: inputAmount}),
            postHookArgs: IBunniHook.RebalanceOrderPostHookArgs({currency: outputToken})
        });

        // prehook should pull input tokens from BunniHub to BunniHook and update pool balances
        IFloodPlain.Hook[] memory preHooks = new IFloodPlain.Hook[](1);
        preHooks[0] = IFloodPlain.Hook({
            target: address(this),
            data: abi.encodeCall(IBunniHook.rebalanceOrderPreHook, (hookArgs))
        });

        // posthook should push output tokens from BunniHook to BunniHub and update pool balances
        IFloodPlain.Hook[] memory postHooks = new IFloodPlain.Hook[](1);
        postHooks[0] = IFloodPlain.Hook({
            target: address(this),
            data: abi.encodeCall(IBunniHook.rebalanceOrderPostHook, (hookArgs))
        });

        IFloodPlain.Order memory order = IFloodPlain.Order({
            offerer: address(this),
            zone: address(env.floodZone),
            recipient: address(this),
            offer: offer,
            consideration: consideration,
            deadline: block.timestamp + rebalanceOrderTTL,
            nonce: uint256(keccak256(abi.encode(block.number, id))), // combine block.number and pool id to avoid nonce collisions between pools
            preHooks: preHooks,
            postHooks: postHooks
        });

        // record order for verification later
        (s.rebalanceOrderHash[id], s.rebalanceOrderPermit2Hash[id]) = _hashFloodOrder(order, env);
        s.rebalanceOrderDeadline[id] = order.deadline;

        // approve input token to permit2
        if (inputERC20Token.allowance(address(this), env.permit2) < inputAmount) {
            address(inputERC20Token).safeApproveWithRetry(env.permit2, type(uint256).max);
        }

        // etch order so fillers can pick it up
        // use PoolId as signature to enable isValidSignature() to find the correct order hash
        IOnChainOrders(address(env.floodPlain)).etchOrder(
            IFloodPlain.SignedOrder({order: order, signature: abi.encode(id)})
        );
    }

    function _getTwap(
        HookStorage storage s,
        PoolId id,
        int24 currentTick,
        uint32 twapSecondsAgo,
        Oracle.Observation calldata updatedIntermediate,
        uint32 updatedIndex,
        uint32 updatedCardinality
    ) private view returns (int24 arithmeticMeanTick) {
        (int56 tickCumulative0, int56 tickCumulative1) = s.observations[id].observeDouble(
            updatedIntermediate,
            uint32(block.timestamp),
            twapSecondsAgo,
            0,
            currentTick,
            updatedIndex,
            updatedCardinality
        );
        int56 tickCumulativesDelta = tickCumulative1 - tickCumulative0;
        arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(twapSecondsAgo)));
    }

    /// @dev The hash that Permit2 uses when verifying the order's signature.
    /// See https://github.com/Uniswap/permit2/blob/cc56ad0f3439c502c246fc5cfcc3db92bb8b7219/src/SignatureTransfer.sol#L65
    /// Always calls permit2 for the domain separator to maintain cross-chain replay protection in the event of a fork
    /// Also returns the Flood order hash
    function _hashFloodOrder(IFloodPlain.Order memory order, BunniHookLogic.Env calldata env)
        private
        view
        returns (bytes32 orderHash, bytes32 permit2Hash)
    {
        (orderHash, permit2Hash) = OrderHashMemory.hashAsWitness(order, address(env.floodPlain));
        permit2Hash = keccak256(abi.encodePacked("\x19\x01", IEIP712(env.permit2).DOMAIN_SEPARATOR(), permit2Hash));
    }
}
