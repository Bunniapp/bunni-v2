// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import "@uniswap/v4-core/src/types/PoolId.sol";
import "@uniswap/v4-core/src/types/Currency.sol";
import "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {SqrtPriceMath} from "@uniswap/v4-core/src/libraries/SqrtPriceMath.sol";

import "flood-contracts/src/interfaces/IZone.sol";
import "flood-contracts/src/interfaces/IFloodPlain.sol";
import "flood-contracts/src/interfaces/IOnChainOrders.sol";

import {IEIP712} from "permit2/src/interfaces/IEIP712.sol";

import {WETH} from "solady/tokens/WETH.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./Math.sol";
import "./FeeMath.sol";
import "./VaultMath.sol";
import "./AmAmmPayload.sol";
import "../base/Errors.sol";
import "../types/LDFType.sol";
import "../base/Constants.sol";
import "../types/PoolState.sol";
import "../types/IdleBalance.sol";
import "../base/SharedStructs.sol";
import {Oracle} from "./Oracle.sol";
import "../interfaces/IBunniHook.sol";
import {queryLDF} from "./QueryLDF.sol";
import {BunniHook} from "../BunniHook.sol";
import {HookletLib} from "./HookletLib.sol";
import {BunniSwapMath} from "./BunniSwapMath.sol";
import {IHooklet} from "../interfaces/IHooklet.sol";
import {IBunniHub} from "../interfaces/IBunniHub.sol";
import {OrderHashMemory} from "./OrderHashMemory.sol";
import {LiquidityAmounts} from "./LiquidityAmounts.sol";

/// @title BunniHookLogic
/// @notice Split from BunniHook to reduce contract size below the Spurious Dragon limit
library BunniHookLogic {
    using TickMath for *;
    using SafeCastLib for *;
    using SafeTransferLib for *;
    using FixedPointMathLib for *;
    using HookletLib for IHooklet;
    using IdleBalanceLibrary for *;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using Oracle for Oracle.Observation[MAX_CARDINALITY];

    /// -----------------------------------------------------------------------
    /// Structs
    /// -----------------------------------------------------------------------

    struct Env {
        uint32 hookFeeModifier;
        uint32 referralRewardModifier;
        IBunniHub hub;
        IPoolManager poolManager;
        IFloodPlain floodPlain;
        IZone floodZone;
        WETH weth;
        address permit2;
    }

    struct RebalanceInput {
        PoolId id;
        PoolKey key;
        int24 updatedTick;
        uint160 updatedSqrtPriceX96;
        int24 arithmeticMeanTick;
        bytes32 newLdfState;
        DecodedHookParams hookParams;
        Oracle.Observation updatedIntermediate;
        uint32 updatedIndex;
        uint32 updatedCardinality;
    }

    /// -----------------------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------------------

    function afterInitialize(
        HookStorage storage s,
        address caller,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        int24 tick,
        IBunniHub hub
    ) external {
        if (caller != address(hub)) revert BunniHook__Unauthorized(); // prevents non-BunniHub contracts from initializing a pool using this hook
        PoolId id = key.toId();

        // initialize slot0
        s.slot0s[id] = Slot0({
            sqrtPriceX96: sqrtPriceX96,
            tick: tick,
            lastSwapTimestamp: uint32(block.timestamp),
            lastSurgeTimestamp: 0
        });

        // read hook data from hub
        bytes memory hookData = hub.poolInitData();

        // initialize first observation to be dated in the past
        // so that we can immediately start querying the oracle
        (uint24 twapSecondsAgo, bytes memory hookParams) = abi.decode(hookData, (uint24, bytes));
        DecodedHookParams memory hookParamsDecoded = _decodeParams(hookParams);
        uint32 maxTwapSecondsAgo = uint32(
            FixedPointMathLib.max(
                FixedPointMathLib.max(twapSecondsAgo, hookParamsDecoded.feeTwapSecondsAgo),
                hookParamsDecoded.rebalanceTwapSecondsAgo
            )
        );
        (s.states[id].intermediateObservation, s.states[id].cardinality, s.states[id].cardinalityNext) =
            s.observations[id].initialize(uint32(block.timestamp - maxTwapSecondsAgo), tick);

        // increase cardinality target based on maxTwapSecondsAgo
        uint32 cardinalityNext =
            (maxTwapSecondsAgo + (hookParamsDecoded.oracleMinInterval >> 1)) / hookParamsDecoded.oracleMinInterval + 1; // round up + 1
        if (cardinalityNext > 1) {
            uint32 cardinalityNextNew = s.observations[id].grow(1, cardinalityNext);
            s.states[id].cardinalityNext = cardinalityNextNew;
        }
    }

    function beforeSwap(
        HookStorage storage s,
        Env calldata env,
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params
    )
        external
        returns (
            bool useAmAmmFee,
            address amAmmManager,
            Currency amAmmFeeCurrency,
            uint256 amAmmFeeAmount,
            BeforeSwapDelta beforeSwapDelta
        )
    {
        // skip 0 amount swaps
        if (params.amountSpecified == 0) {
            return (false, address(0), Currency.wrap(address(0)), 0, BeforeSwapDeltaLibrary.ZERO_DELTA);
        }

        // get pool state
        PoolId id = key.toId();
        Slot0 memory slot0 = s.slot0s[id];
        PoolState memory bunniState = env.hub.poolState(id);

        // hooklet call
        (bool feeOverridden, uint24 feeOverride, bool priceOverridden, uint160 sqrtPriceX96Override) =
            bunniState.hooklet.hookletBeforeSwap(sender, key, params);

        // override price if needed
        if (priceOverridden) {
            slot0.sqrtPriceX96 = sqrtPriceX96Override;
            slot0.tick = sqrtPriceX96Override.getTickAtSqrtPrice();
        }

        // ensure swap makes sense
        if (
            slot0.sqrtPriceX96 == 0
                || (
                    params.zeroForOne
                        && (
                            params.sqrtPriceLimitX96 >= slot0.sqrtPriceX96
                                || params.sqrtPriceLimitX96 <= TickMath.MIN_SQRT_PRICE
                        )
                )
                || (
                    !params.zeroForOne
                        && (
                            params.sqrtPriceLimitX96 <= slot0.sqrtPriceX96
                                || params.sqrtPriceLimitX96 >= TickMath.MAX_SQRT_PRICE
                        )
                ) || params.amountSpecified > type(int128).max || params.amountSpecified < type(int128).min
        ) {
            revert BunniHook__InvalidSwap();
        }

        // compute total token balances
        (uint256 reserveBalance0, uint256 reserveBalance1) = (
            getReservesInUnderlying(bunniState.reserve0, bunniState.vault0),
            getReservesInUnderlying(bunniState.reserve1, bunniState.vault1)
        );
        (uint256 balance0, uint256 balance1) =
            (bunniState.rawBalance0 + reserveBalance0, bunniState.rawBalance1 + reserveBalance1);

        // if it's an exact output swap, revert if the requested output is greater than the balance
        bool exactIn = params.amountSpecified < 0;
        if (!exactIn && uint256(params.amountSpecified) > (params.zeroForOne ? balance1 : balance0)) {
            revert BunniHook__RequestedOutputExceedsBalance();
        }

        // decode hook params
        DecodedHookParams memory hookParams = _decodeParams(bunniState.hookParams);

        // update TWAP oracle
        // do it before we fetch the arithmeticMeanTick
        // which doesn't change the result but gives us updated index and cardinality
        (Oracle.Observation memory updatedIntermediate, uint32 updatedIndex, uint32 updatedCardinality) =
            _updateOracle(s, id, slot0.tick, hookParams.oracleMinInterval);

        // get TWAP values
        int24 arithmeticMeanTick = bunniState.twapSecondsAgo != 0
            ? _getTwap(s, id, slot0.tick, bunniState.twapSecondsAgo, updatedIntermediate, updatedIndex, updatedCardinality)
            : int24(0);
        int24 feeMeanTick = (
            !feeOverridden && hookParams.feeMin != hookParams.feeMax && hookParams.feeQuadraticMultiplier != 0
        )
            ? _getTwap(
                s, id, slot0.tick, hookParams.feeTwapSecondsAgo, updatedIntermediate, updatedIndex, updatedCardinality
            )
            : int24(0);

        // query the LDF to get total liquidity and token densities
        bytes32 ldfState = bunniState.ldfType == LDFType.DYNAMIC_AND_STATEFUL ? s.ldfStates[id] : bytes32(0);
        (
            uint256 totalLiquidity,
            uint256 totalDensity0X96,
            uint256 totalDensity1X96,
            uint256 liquidityDensityOfRoundedTickX96,
            bytes32 newLdfState,
            bool shouldSurge
        ) = queryLDF({
            key: key,
            sqrtPriceX96: slot0.sqrtPriceX96,
            tick: slot0.tick,
            arithmeticMeanTick: arithmeticMeanTick,
            ldf: bunniState.liquidityDensityFunction,
            ldfParams: bunniState.ldfParams,
            ldfState: ldfState,
            balance0: balance0,
            balance1: balance1,
            idleBalance: bunniState.idleBalance
        });
        shouldSurge == shouldSurge && bunniState.ldfType != LDFType.STATIC; // only surge from LDF if LDF type is not static
        if (bunniState.ldfType == LDFType.DYNAMIC_AND_STATEFUL) s.ldfStates[id] = newLdfState;

        if (shouldSurge) {
            // the LDF has been updated, so we need to update the idle balance
            (uint256 currentActiveBalance0, uint256 currentActiveBalance1) =
                (totalDensity0X96.fullMulDiv(totalLiquidity, Q96), totalDensity1X96.fullMulDiv(totalLiquidity, Q96));
            (uint256 extraBalance0, uint256 extraBalance1) = (
                balance0 > currentActiveBalance0 ? balance0 - currentActiveBalance0 : 0,
                balance1 > currentActiveBalance1 ? balance1 - currentActiveBalance1 : 0
            );
            bool isToken0 = extraBalance0 >= extraBalance1;
            env.hub.hookSetIdleBalance(key, FixedPointMathLib.max(extraBalance0, extraBalance1).toIdleBalance(isToken0));
        }

        // check surge based on vault share prices
        shouldSurge =
            shouldSurge || _shouldSurgeFromVaults(s, id, bunniState, hookParams, reserveBalance0, reserveBalance1);

        // compute swap result
        (uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount, uint256 outputAmount) = BunniSwapMath
            .computeSwap({
            input: BunniSwapMath.BunniComputeSwapInput({
                key: key,
                totalLiquidity: totalLiquidity,
                liquidityDensityOfRoundedTickX96: liquidityDensityOfRoundedTickX96,
                totalDensity0X96: totalDensity0X96,
                totalDensity1X96: totalDensity1X96,
                sqrtPriceX96: slot0.sqrtPriceX96,
                currentTick: slot0.tick,
                liquidityDensityFunction: bunniState.liquidityDensityFunction,
                arithmeticMeanTick: arithmeticMeanTick,
                ldfParams: bunniState.ldfParams,
                ldfState: ldfState,
                swapParams: params
            })
        });

        // revert if it's an exact output swap and outputAmount < params.amountSpecified
        if (!exactIn && outputAmount < uint256(params.amountSpecified)) {
            revert BunniHook__InsufficientOutput();
        }

        // ensure swap never moves price in the opposite direction
        // ensure the inputAmount is non-zero when it's an exact output swap
        if (
            (params.zeroForOne && updatedSqrtPriceX96 > slot0.sqrtPriceX96)
                || (!params.zeroForOne && updatedSqrtPriceX96 < slot0.sqrtPriceX96)
                || (params.amountSpecified > 0 && inputAmount == 0)
        ) {
            revert BunniHook__InvalidSwap();
        }

        // update slot0
        uint32 lastSurgeTimestamp = slot0.lastSurgeTimestamp;
        if (shouldSurge) {
            // use unchecked so that if uint32 overflows we wrap around
            // overflows are ok since we only look at differences
            unchecked {
                uint32 timeSinceLastSwap = uint32(block.timestamp) - slot0.lastSwapTimestamp;
                // if more than `surgeFeeAutostartThreshold` seconds has passed since the last swap,
                // we pretend that the surge started at `slot0.lastSwapTimestamp + surgeFeeAutostartThreshold`
                // so that the pool never gets stuck with a high fee
                lastSurgeTimestamp = timeSinceLastSwap >= hookParams.surgeFeeAutostartThreshold
                    ? slot0.lastSwapTimestamp + hookParams.surgeFeeAutostartThreshold
                    : uint32(block.timestamp);
            }
        }
        s.slot0s[id] = Slot0({
            sqrtPriceX96: updatedSqrtPriceX96,
            tick: updatedTick,
            lastSwapTimestamp: uint32(block.timestamp),
            lastSurgeTimestamp: lastSurgeTimestamp
        });

        // update am-AMM state
        uint24 amAmmSwapFee;
        if (hookParams.amAmmEnabled) {
            bytes7 payload;
            IAmAmm.Bid memory topBid = IAmAmm(address(this)).getTopBidWrite(id);
            (amAmmManager, payload) = (topBid.manager, topBid.payload);
            uint24 swapFee0For1;
            uint24 swapFee1For0;
            (swapFee0For1, swapFee1For0) = decodeAmAmmPayload(payload);
            amAmmSwapFee = params.zeroForOne ? swapFee0For1 : swapFee1For0;
        }

        // charge swap fee
        // precedence:
        // 1) am-AMM fee
        // 2) hooklet override fee
        // 3) dynamic fee
        (Currency inputToken, Currency outputToken) =
            params.zeroForOne ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        uint24 swapFee;
        uint256 swapFeeAmount;
        useAmAmmFee = hookParams.amAmmEnabled && amAmmManager != address(0);
        // swap fee used as the basis for computing hookFees when useAmAmmFee == true
        // this is to avoid a malicious am-AMM manager bypassing hookFees
        // by setting the swap fee to max and offering a proxy swap contract
        // that sets the Bunni swap fee to 0 during such swaps and charging swap fees
        // independently
        uint24 hookFeesBaseSwapFee = feeOverridden
            ? feeOverride
            : computeDynamicSwapFee(
                updatedSqrtPriceX96,
                feeMeanTick,
                lastSurgeTimestamp,
                hookParams.feeMin,
                hookParams.feeMax,
                hookParams.feeQuadraticMultiplier,
                hookParams.surgeFeeHalfLife
            );
        swapFee = useAmAmmFee
            ? uint24(FixedPointMathLib.max(amAmmSwapFee, computeSurgeFee(lastSurgeTimestamp, hookParams.surgeFeeHalfLife)))
            : hookFeesBaseSwapFee;
        uint256 hookFeesAmount;
        uint256 hookHandleSwapInputAmount;
        uint256 hookHandleSwapOutoutAmount;
        if (exactIn) {
            // compute the swap fee and the hook fee (i.e. protocol fee)
            // swap fee is taken by decreasing the output amount
            swapFeeAmount = outputAmount.mulDivUp(swapFee, SWAP_FEE_BASE);
            if (useAmAmmFee) {
                // instead of computing hook fees as a portion of the swap fee
                // and deducting it, we compute hook fees separately using hookFeesBaseSwapFee
                // and charge it as an extra fee on the swap
                hookFeesAmount = outputAmount.mulDivUp(hookFeesBaseSwapFee, SWAP_FEE_BASE).mulDivUp(
                    env.hookFeeModifier, MODIFIER_BASE
                );
            } else {
                hookFeesAmount = swapFeeAmount.mulDivUp(env.hookFeeModifier, MODIFIER_BASE);
                swapFeeAmount -= hookFeesAmount;
            }

            // set the am-AMM fee to be the swap fee amount
            // don't need to check if am-AMM is enabled since if it isn't
            // BunniHook.beforeSwap() simply ignores the returned values
            // this saves gas by avoiding an if statement
            (amAmmFeeCurrency, amAmmFeeAmount) = (outputToken, swapFeeAmount);

            // modify output amount with fees
            outputAmount -= swapFeeAmount + hookFeesAmount;

            // return beforeSwapDelta
            // take in max(amountSpecified, inputAmount) such that if amountSpecified is greater we just happily accept it
            int256 actualInputAmount = FixedPointMathLib.max(-params.amountSpecified, inputAmount.toInt256());
            inputAmount = uint256(actualInputAmount);
            beforeSwapDelta = toBeforeSwapDelta({
                deltaSpecified: actualInputAmount.toInt128(),
                deltaUnspecified: -outputAmount.toInt256().toInt128()
            });

            // if am-AMM is used, the swap fee needs to be taken from BunniHub, else it stays in BunniHub with the LPs
            (hookHandleSwapInputAmount, hookHandleSwapOutoutAmount) = (
                inputAmount, useAmAmmFee ? outputAmount + swapFeeAmount + hookFeesAmount : outputAmount + hookFeesAmount
            );
        } else {
            // compute the swap fee and the hook fee (i.e. protocol fee)
            // swap fee is taken by increasing the input amount
            // need to modify fee rate to maintain the same average price as exactIn case
            // in / (out * (1 - fee)) = in * (1 + fee') / out => fee' = fee / (1 - fee)
            swapFeeAmount = inputAmount.mulDivUp(swapFee, SWAP_FEE_BASE - swapFee);
            if (useAmAmmFee) {
                // instead of computing hook fees as a portion of the swap fee
                // and deducting it, we compute hook fees separately using hookFeesBaseSwapFee
                // and charge it as an extra fee on the swap
                hookFeesAmount = inputAmount.mulDivUp(hookFeesBaseSwapFee, SWAP_FEE_BASE - hookFeesBaseSwapFee).mulDivUp(
                    env.hookFeeModifier, MODIFIER_BASE
                );
            } else {
                hookFeesAmount = swapFeeAmount.mulDivUp(env.hookFeeModifier, MODIFIER_BASE);
                swapFeeAmount -= hookFeesAmount;
            }

            // set the am-AMM fee to be the swap fee amount
            // don't need to check if am-AMM is enabled since if it isn't
            // BunniHook.beforeSwap() simply ignores the returned values
            // this saves gas by avoiding an if statement
            (amAmmFeeCurrency, amAmmFeeAmount) = (inputToken, swapFeeAmount);

            // modify input amount with fees
            inputAmount += swapFeeAmount + hookFeesAmount;

            // return beforeSwapDelta
            // give out min(amountSpecified, outputAmount) such that we only give out as much as requested
            int256 actualOutputAmount = FixedPointMathLib.min(params.amountSpecified, outputAmount.toInt256());
            outputAmount = uint256(actualOutputAmount);
            beforeSwapDelta = toBeforeSwapDelta({
                deltaSpecified: -actualOutputAmount.toInt128(),
                deltaUnspecified: inputAmount.toInt256().toInt128()
            });

            // if am-AMM is not used, the swap fee needs to be sent to BunniHub to the LPs, else it stays in BunniHook with the am-AMM manager
            (hookHandleSwapInputAmount, hookHandleSwapOutoutAmount) = (
                useAmAmmFee ? inputAmount - swapFeeAmount - hookFeesAmount : inputAmount - hookFeesAmount, outputAmount
            );
        }

        // take input by minting claim tokens to hook
        env.poolManager.mint(address(this), inputToken.toId(), inputAmount);

        // call hub to handle swap
        // - pull input claim tokens from hook
        // - push output tokens to pool manager and mint claim tokens to hook
        // - update raw token balances
        env.hub.hookHandleSwap(key, params.zeroForOne, hookHandleSwapInputAmount, hookHandleSwapOutoutAmount);

        // burn output claim tokens
        env.poolManager.burn(address(this), outputToken.toId(), outputAmount);

        // distribute part of hookFees to referrers
        if (hookFeesAmount != 0) {
            uint256 referrerRewardAmount = hookFeesAmount.mulDiv(env.referralRewardModifier, MODIFIER_BASE);
            if (referrerRewardAmount != 0) {
                if (!env.poolManager.isOperator(address(this), address(bunniState.bunniToken))) {
                    env.poolManager.setOperator(address(bunniState.bunniToken), true);
                }
                bool isToken0 = exactIn != params.zeroForOne;
                bunniState.bunniToken.distributeReferralRewards(isToken0, referrerRewardAmount);
            }
        }

        // emit swap event
        emit IBunniHook.Swap(
            id,
            sender,
            exactIn,
            params.zeroForOne,
            inputAmount,
            outputAmount,
            updatedSqrtPriceX96,
            updatedTick,
            swapFee,
            totalLiquidity
        );

        // we should attempt to rebalance if:
        // 1) rebalanceThreshold != 0, i.e. rebalancing is enabled
        // 2.a) either shouldSurge == true, since tokens can only go out of balance due to shifting or vault returns, or:
        // 2.b) the deadline of the last rebalance order has passed and the order wasn't executed, in which case we should reattempt to rebalance
        uint256 rebalanceOrderDeadline = shouldSurge ? 0 : s.rebalanceOrderDeadline[id]; // gas: only do SLOAD if shouldSurge == false
        if (
            hookParams.rebalanceThreshold != 0
                && (shouldSurge || (block.timestamp > rebalanceOrderDeadline && rebalanceOrderDeadline != 0))
        ) {
            if (shouldSurge) {
                // surging makes any existing rebalance order meaningless
                // since the desired token ratio will be different
                // clear the existing rebalance order
                delete s.rebalanceOrderHash[id];
                delete s.rebalanceOrderPermit2Hash[id];
                delete s.rebalanceOrderDeadline[id];
            }

            _rebalance(
                s,
                env,
                RebalanceInput({
                    id: id,
                    key: key,
                    updatedTick: updatedTick,
                    updatedSqrtPriceX96: updatedSqrtPriceX96,
                    arithmeticMeanTick: arithmeticMeanTick,
                    newLdfState: newLdfState,
                    hookParams: hookParams,
                    updatedIntermediate: updatedIntermediate,
                    updatedIndex: updatedIndex,
                    updatedCardinality: updatedCardinality
                })
            );
        }

        // hooklet call
        if (bunniState.hooklet.hasPermission(HookletLib.AFTER_SWAP_FLAG)) {
            bunniState.hooklet.hookletAfterSwap(
                sender,
                key,
                params,
                IHooklet.SwapReturnData({
                    updatedSqrtPriceX96: updatedSqrtPriceX96,
                    updatedTick: updatedTick,
                    inputAmount: inputAmount,
                    outputAmount: outputAmount,
                    swapFee: swapFee,
                    totalLiquidity: totalLiquidity
                })
            );
        }
    }

    function decodeHookParams(bytes calldata hookParams) external pure returns (DecodedHookParams memory p) {
        return _decodeParams(hookParams);
    }

    /// -----------------------------------------------------------------------
    /// Internal utility functions
    /// -----------------------------------------------------------------------

    /// @dev Checks if the pool should surge based on the vault share price changes since the last swap.
    /// Also updates vaultSharePricesAtLastSwap.
    function _shouldSurgeFromVaults(
        HookStorage storage s,
        PoolId id,
        PoolState memory bunniState,
        DecodedHookParams memory hookParams,
        uint256 reserveBalance0,
        uint256 reserveBalance1
    ) private returns (bool shouldSurge) {
        if (address(bunniState.vault0) != address(0) || address(bunniState.vault1) != address(0)) {
            // only surge if at least one vault is set because otherwise total liquidity won't automatically increase
            // so there's no risk of being sandwiched

            // load share prices at last swap
            VaultSharePrices memory prevSharePrices = s.vaultSharePricesAtLastSwap[id];

            // compute current share prices
            uint120 sharePrice0 =
                bunniState.reserve0 == 0 ? 0 : reserveBalance0.divWadUp(bunniState.reserve0).toUint120();
            uint120 sharePrice1 =
                bunniState.reserve1 == 0 ? 0 : reserveBalance1.divWadUp(bunniState.reserve1).toUint120();

            // compare with share prices at last swap to see if we need to apply the surge fee
            if (
                prevSharePrices.initialized
                    && (
                        dist(sharePrice0, prevSharePrices.sharePrice0)
                            > prevSharePrices.sharePrice0 / hookParams.vaultSurgeThreshold0
                            || dist(sharePrice1, prevSharePrices.sharePrice1)
                                > prevSharePrices.sharePrice1 / hookParams.vaultSurgeThreshold1
                    )
            ) {
                // surge fee is applied if the share price has increased by more than 1 / vaultSurgeThreshold
                shouldSurge = true;
            }

            // update share prices at last swap
            if (
                !prevSharePrices.initialized || sharePrice0 != prevSharePrices.sharePrice0
                    || sharePrice1 != prevSharePrices.sharePrice1
            ) {
                s.vaultSharePricesAtLastSwap[id] =
                    VaultSharePrices({initialized: true, sharePrice0: sharePrice0, sharePrice1: sharePrice1});
            }
        }
    }

    /// @dev Creates a rebalance order on FloodPlain.
    function _rebalance(HookStorage storage s, Env calldata env, RebalanceInput memory input) internal {
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

    function _computeRebalanceParams(HookStorage storage s, Env calldata env, RebalanceInput memory input)
        internal
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
        (uint256 totalLiquidity,,,,,) = queryLDF({
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
        (, uint256 totalDensity0X96, uint256 totalDensity1X96,,,) = queryLDF({
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
        uint256 targetAmount0 = excessLiquidity.fullMulDiv(totalDensity0X96, Q96);
        uint256 targetAmount1 = excessLiquidity.fullMulDiv(totalDensity1X96, Q96);

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
        Env calldata env,
        PoolId id,
        PoolKey memory key,
        uint16 rebalanceOrderTTL,
        Currency inputToken,
        Currency outputToken,
        uint256 inputAmount,
        uint256 outputAmount
    ) internal {
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
        Oracle.Observation memory updatedIntermediate,
        uint32 updatedIndex,
        uint32 updatedCardinality
    ) internal view returns (int24 arithmeticMeanTick) {
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

    function _updateOracle(HookStorage storage s, PoolId id, int24 tick, uint32 oracleMinInterval)
        internal
        returns (Oracle.Observation memory updatedIntermediate, uint32 updatedIndex, uint32 updatedCardinality)
    {
        IBunniHook.ObservationState memory state = s.states[id];
        (updatedIntermediate, updatedIndex, updatedCardinality) = s.observations[id].write(
            state.intermediateObservation,
            state.index,
            uint32(block.timestamp),
            tick,
            state.cardinality,
            state.cardinalityNext,
            oracleMinInterval
        );
        (s.states[id].intermediateObservation, s.states[id].index, s.states[id].cardinality) =
            (updatedIntermediate, updatedIndex, updatedCardinality);
    }

    /// @dev The hash that Permit2 uses when verifying the order's signature.
    /// See https://github.com/Uniswap/permit2/blob/cc56ad0f3439c502c246fc5cfcc3db92bb8b7219/src/SignatureTransfer.sol#L65
    /// Always calls permit2 for the domain separator to maintain cross-chain replay protection in the event of a fork
    /// Also returns the Flood order hash
    function _hashFloodOrder(IFloodPlain.Order memory order, Env calldata env)
        internal
        view
        returns (bytes32 orderHash, bytes32 permit2Hash)
    {
        (orderHash, permit2Hash) = OrderHashMemory.hashAsWitness(order, address(env.floodPlain));
        permit2Hash = keccak256(abi.encodePacked("\x19\x01", IEIP712(env.permit2).DOMAIN_SEPARATOR(), permit2Hash));
    }

    /// @dev Decodes hookParams into params used by this hook
    /// @param hookParams The hook params raw bytes
    /// @return p The decoded params struct
    function _decodeParams(bytes memory hookParams) internal pure returns (DecodedHookParams memory p) {
        // | feeMin - 3 bytes | feeMax - 3 bytes | feeQuadraticMultiplier - 3 bytes | feeTwapSecondsAgo - 3 bytes | maxAmAmmFee - 3 bytes | surgeFeeHalfLife - 2 bytes | surgeFeeAutostartThreshold - 2 bytes | vaultSurgeThreshold0 - 2 bytes | vaultSurgeThreshold1 - 2 bytes | rebalanceThreshold - 2 bytes | rebalanceMaxSlippage - 2 bytes | rebalanceTwapSecondsAgo - 2 bytes | rebalanceOrderTTL - 2 bytes | amAmmEnabled - 1 byte |
        bytes32 firstWord;
        // | oracleMinInterval - 4 bytes | minRentMultiplier - 6 bytes |
        bytes32 secondWord;
        /// @solidity memory-safe-assembly
        assembly {
            firstWord := mload(add(hookParams, 32))
            secondWord := mload(add(hookParams, 64))
        }
        p.feeMin = uint24(bytes3(firstWord));
        p.feeMax = uint24(bytes3(firstWord << 24));
        p.feeQuadraticMultiplier = uint24(bytes3(firstWord << 48));
        p.feeTwapSecondsAgo = uint24(bytes3(firstWord << 72));
        p.maxAmAmmFee = uint24(bytes3(firstWord << 96));
        p.surgeFeeHalfLife = uint16(bytes2(firstWord << 120));
        p.surgeFeeAutostartThreshold = uint16(bytes2(firstWord << 136));
        p.vaultSurgeThreshold0 = uint16(bytes2(firstWord << 152));
        p.vaultSurgeThreshold1 = uint16(bytes2(firstWord << 168));
        p.rebalanceThreshold = uint16(bytes2(firstWord << 184));
        p.rebalanceMaxSlippage = uint16(bytes2(firstWord << 200));
        p.rebalanceTwapSecondsAgo = uint16(bytes2(firstWord << 216));
        p.rebalanceOrderTTL = uint16(bytes2(firstWord << 232));
        p.amAmmEnabled = uint8(bytes1(firstWord << 248)) != 0;
        p.oracleMinInterval = uint32(bytes4(secondWord));
        p.minRentMultiplier = uint48(bytes6(secondWord << 32));
    }
}
