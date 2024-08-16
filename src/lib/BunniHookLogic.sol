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
import "../base/Constants.sol";
import "../types/PoolState.sol";
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
        bytes calldata hookData,
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
            !feeOverridden && !hookParams.amAmmEnabled && hookParams.feeMin != hookParams.feeMax
                && hookParams.feeQuadraticMultiplier != 0
        )
            ? _getTwap(
                s, id, slot0.tick, hookParams.feeTwapSecondsAgo, updatedIntermediate, updatedIndex, updatedCardinality
            )
            : int24(0);

        // compute total token balances
        (uint256 reserveBalance0, uint256 reserveBalance1) = (
            getReservesInUnderlying(bunniState.reserve0, bunniState.vault0),
            getReservesInUnderlying(bunniState.reserve1, bunniState.vault1)
        );
        (uint256 balance0, uint256 balance1) =
            (bunniState.rawBalance0 + reserveBalance0, bunniState.rawBalance1 + reserveBalance1);

        // query the LDF to get total liquidity and token densities
        bytes32 ldfState = bunniState.statefulLdf ? s.ldfStates[id] : bytes32(0);
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
            balance1: balance1
        });
        if (bunniState.statefulLdf) s.ldfStates[id] = newLdfState;

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
            }),
            balance0: balance0,
            balance1: balance1
        });

        // ensure swap never moves price in the opposite direction
        if (
            (params.zeroForOne && updatedSqrtPriceX96 > slot0.sqrtPriceX96)
                || (!params.zeroForOne && updatedSqrtPriceX96 < slot0.sqrtPriceX96)
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
        bool amAmmEnableSurgeFee;
        if (hookParams.amAmmEnabled) {
            bytes7 payload;
            IAmAmm.Bid memory topBid = IAmAmm(address(this)).getTopBidWrite(id);
            (amAmmManager, payload) = (topBid.manager, topBid.payload);
            uint24 swapFee0For1;
            uint24 swapFee1For0;
            (swapFee0For1, swapFee1For0, amAmmEnableSurgeFee) = decodeAmAmmPayload(payload);
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
        bool exactIn = params.amountSpecified < 0;
        useAmAmmFee = hookParams.amAmmEnabled && amAmmManager != address(0);
        swapFee = useAmAmmFee
            ? (
                amAmmEnableSurgeFee
                    ? uint24(
                        FixedPointMathLib.max(
                            amAmmSwapFee, computeSurgeFee(lastSurgeTimestamp, hookParams.surgeFee, hookParams.surgeFeeHalfLife)
                        )
                    )
                    : amAmmSwapFee
            )
            : (
                feeOverridden
                    ? feeOverride
                    : computeDynamicSwapFee(
                        updatedSqrtPriceX96,
                        feeMeanTick,
                        lastSurgeTimestamp,
                        hookParams.feeMin,
                        hookParams.feeMax,
                        hookParams.feeQuadraticMultiplier,
                        hookParams.surgeFee,
                        hookParams.surgeFeeHalfLife
                    )
            );
        uint256 hookFeesAmount;
        uint256 hookHandleSwapInputAmount;
        uint256 hookHandleSwapOutoutAmount;
        if (exactIn) {
            // decrease output amount
            swapFeeAmount = outputAmount.mulDivUp(swapFee, SWAP_FEE_BASE);
            (amAmmFeeCurrency, amAmmFeeAmount) = (outputToken, swapFeeAmount);

            // take hook fees from swap fee
            hookFeesAmount = swapFeeAmount.mulDivUp(env.hookFeeModifier, MODIFIER_BASE);
            swapFeeAmount -= hookFeesAmount;

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
            // increase input amount
            // need to modify fee rate to maintain the same average price as exactIn case
            // in / (out * (1 - fee)) = in * (1 + fee') / out => fee' = fee / (1 - fee)
            swapFeeAmount = inputAmount.mulDivUp(swapFee, SWAP_FEE_BASE - swapFee);
            (amAmmFeeCurrency, amAmmFeeAmount) = (inputToken, swapFeeAmount);

            // take hook fees from swap fee
            hookFeesAmount = swapFeeAmount.mulDivUp(env.hookFeeModifier, MODIFIER_BASE);
            swapFeeAmount -= hookFeesAmount;

            // modify input amount with fees
            inputAmount += swapFeeAmount + hookFeesAmount;

            // return beforeSwapDelta
            // give out min(amountSpecified, outputAmount) such that if amountSpecified is greater we only give outputAmount and let the tx revert
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
            params.zeroForOne,
            inputAmount,
            outputAmount,
            updatedSqrtPriceX96,
            updatedTick,
            swapFee,
            totalLiquidity
        );

        // we should rebalance if:
        // - rebalanceThreshold != 0, i.e. rebalancing is enabled
        // - shouldSurge == true, since tokens can only go out of balance due to shifting or vault returns
        // - the deadline of the last rebalance order has passed
        if (hookParams.rebalanceThreshold != 0 && shouldSurge && block.timestamp > s.rebalanceOrderDeadline[id]) {
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
        if (address(bunniState.vault0) != address(0) && address(bunniState.vault1) != address(0)) {
            // only surge if both vaults are set because otherwise total liquidity won't automatically increase
            // so there's no risk of being sandwiched

            // compute share prices
            VaultSharePrices memory sharePrices = VaultSharePrices({
                initialized: true,
                sharePrice0: bunniState.reserve0 == 0 ? 0 : reserveBalance0.mulDivUp(WAD, bunniState.reserve0).toUint120(),
                sharePrice1: bunniState.reserve1 == 0 ? 0 : reserveBalance1.mulDivUp(WAD, bunniState.reserve1).toUint120()
            });

            // compare with share prices at last swap to see if we need to apply the surge fee
            VaultSharePrices memory prevSharePrices = s.vaultSharePricesAtLastSwap[id];
            if (
                prevSharePrices.initialized
                    && (
                        dist(sharePrices.sharePrice0, prevSharePrices.sharePrice0)
                            >= prevSharePrices.sharePrice0 / hookParams.vaultSurgeThreshold0
                            || dist(sharePrices.sharePrice1, prevSharePrices.sharePrice1)
                                >= prevSharePrices.sharePrice1 / hookParams.vaultSurgeThreshold1
                    )
            ) {
                // surge fee is applied if the share price has increased by more than 1 / vaultSurgeThreshold
                shouldSurge = true;
            }

            // update share prices at last swap
            if (
                !prevSharePrices.initialized || sharePrices.sharePrice0 != prevSharePrices.sharePrice0
                    || sharePrices.sharePrice1 != prevSharePrices.sharePrice1
            ) {
                s.vaultSharePricesAtLastSwap[id] = sharePrices;
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
        (uint256 totalLiquidity, uint256 totalDensity0X96, uint256 totalDensity1X96,,,) = queryLDF({
            key: input.key,
            sqrtPriceX96: input.updatedSqrtPriceX96,
            tick: input.updatedTick,
            arithmeticMeanTick: input.arithmeticMeanTick,
            ldf: bunniState.liquidityDensityFunction,
            ldfParams: bunniState.ldfParams,
            ldfState: input.newLdfState,
            balance0: balance0,
            balance1: balance1
        });

        // compute active balance, which is the balance implied by the total liquidity & the LDF
        (uint256 currentActiveBalance0, uint256 currentActiveBalance1) =
            (totalDensity0X96.fullMulDiv(totalLiquidity, Q96), totalDensity1X96.fullMulDiv(totalLiquidity, Q96));

        // compute excess liquidity if there's any
        (int24 minUsableTick, int24 maxUsableTick) = (
            TickMath.minUsableTick(input.key.tickSpacing),
            TickMath.maxUsableTick(input.key.tickSpacing) - input.key.tickSpacing
        );
        uint256 excessLiquidity0 = balance0 > currentActiveBalance0
            ? (balance0 - currentActiveBalance0).divWad(
                bunniState.liquidityDensityFunction.cumulativeAmount0(
                    input.key,
                    minUsableTick,
                    WAD,
                    input.arithmeticMeanTick,
                    input.updatedTick,
                    bunniState.ldfParams,
                    input.newLdfState
                )
            )
            : 0;
        uint256 excessLiquidity1 = balance1 > currentActiveBalance1
            ? (balance1 - currentActiveBalance1).divWad(
                bunniState.liquidityDensityFunction.cumulativeAmount1(
                    input.key,
                    maxUsableTick,
                    WAD,
                    input.arithmeticMeanTick,
                    input.updatedTick,
                    bunniState.ldfParams,
                    input.newLdfState
                )
            )
            : 0;

        // should rebalance if excessLiquidity / totalLiquidity >= 1 / rebalanceThreshold
        bool shouldRebalance0 =
            excessLiquidity0 != 0 && excessLiquidity0 >= totalLiquidity / input.hookParams.rebalanceThreshold;
        bool shouldRebalance1 =
            excessLiquidity1 != 0 && excessLiquidity1 >= totalLiquidity / input.hookParams.rebalanceThreshold;
        if (!shouldRebalance0 && !shouldRebalance1) return (false, inputToken, outputToken, inputAmount, outputAmount);

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
        // reusing totalDensity0X96 and totalDensity1X96 to store the token densities of the excess liquidity
        // after rebalancing
        (, totalDensity0X96, totalDensity1X96,,,) = queryLDF({
            key: input.key,
            sqrtPriceX96: rebalanceSpotPriceSqrtRatioX96,
            tick: rebalanceSpotPriceTick,
            arithmeticMeanTick: input.arithmeticMeanTick,
            ldf: bunniState.liquidityDensityFunction,
            ldfParams: bunniState.ldfParams,
            ldfState: input.newLdfState,
            balance0: 0,
            balance1: 0
        });

        // decide which token will be rebalanced (i.e., sold into the other token)
        bool willRebalanceToken0 = shouldRebalance0 && (!shouldRebalance1 || excessLiquidity0 > excessLiquidity1);

        // compute target amounts (i.e. the token amounts of the excess liquidity)
        uint256 excessLiquidity = willRebalanceToken0 ? excessLiquidity0 : excessLiquidity1;
        uint256 targetAmount0 = excessLiquidity.fullMulDiv(totalDensity0X96, Q96);
        uint256 targetAmount1 = excessLiquidity.fullMulDiv(totalDensity1X96, Q96);

        // determine input & output
        (inputToken, outputToken) = willRebalanceToken0
            ? (input.key.currency0, input.key.currency1)
            : (input.key.currency1, input.key.currency0);
        uint256 inputTokenExcessBalance =
            willRebalanceToken0 ? balance0 - currentActiveBalance0 : balance1 - currentActiveBalance1;
        uint256 inputTokenTarget = willRebalanceToken0 ? targetAmount0 : targetAmount1;
        uint256 outputTokenTarget = willRebalanceToken0 ? targetAmount1 : targetAmount0;
        if (inputTokenExcessBalance < inputTokenTarget) {
            // should never happen
            return (false, inputToken, outputToken, inputAmount, outputAmount);
        }
        inputAmount = inputTokenExcessBalance - inputTokenTarget;
        outputAmount = outputTokenTarget.mulDivUp(1e5 - input.hookParams.rebalanceMaxSlippage, 1e5);

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
        ERC20 inputERC20Token = inputToken.isNative() ? env.weth : ERC20(Currency.unwrap(inputToken));
        ERC20 outputERC20Token = outputToken.isNative() ? env.weth : ERC20(Currency.unwrap(outputToken));
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
            nonce: block.number,
            preHooks: preHooks,
            postHooks: postHooks
        });

        // record order for verification later
        s.rebalanceOrderHash[id] = _newOrderHash(order, env);
        s.rebalanceOrderDeadline[id] = order.deadline;
        s.rebalanceOrderHookArgsHash[id] = keccak256(abi.encode(hookArgs));

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
    function _newOrderHash(IFloodPlain.Order memory order, Env calldata env) internal view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                IEIP712(env.permit2).DOMAIN_SEPARATOR(),
                OrderHashMemory.hashAsWitness(order, address(env.floodPlain))
            )
        );
    }

    /// @dev Decodes hookParams into params used by this hook
    /// @param hookParams The hook params raw bytes
    /// @return p The decoded params struct
    function _decodeParams(bytes memory hookParams) internal pure returns (DecodedHookParams memory p) {
        // | feeMin - 3 bytes | feeMax - 3 bytes | feeQuadraticMultiplier - 3 bytes | feeTwapSecondsAgo - 3 bytes | surgeFee - 3 bytes | surgeFeeHalfLife - 2 bytes | surgeFeeAutostartThreshold - 2 bytes | vaultSurgeThreshold0 - 2 bytes | vaultSurgeThreshold1 - 2 bytes | rebalanceThreshold - 2 bytes | rebalanceMaxSlippage - 2 bytes | rebalanceTwapSecondsAgo - 2 bytes | rebalanceOrderTTL - 2 bytes | amAmmEnabled - 1 byte |
        bytes32 firstWord;
        // | oracleMinInterval - 4 bytes |
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
        p.surgeFee = uint24(bytes3(firstWord << 96));
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
    }
}
