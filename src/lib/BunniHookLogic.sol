// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import "@uniswap/v4-core/src/types/Currency.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
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
import "./VaultMath.sol";
import "./AmAmmPayload.sol";
import "../base/Errors.sol";
import "../base/Constants.sol";
import "../base/SharedStructs.sol";
import {Oracle} from "./Oracle.sol";
import "../interfaces/IBunniHook.sol";
import {IBunniHub} from "../interfaces/IBunniHub.sol";
import {BunniSwapMath} from "./BunniSwapMath.sol";
import {OrderHashMemory} from "./OrderHashMemory.sol";
import {LiquidityAmounts} from "./LiquidityAmounts.sol";

/// @title BunniHookLogic
/// @notice Split from BunniHook to reduce contract size below the Spurious Dragon limit
library BunniHookLogic {
    using SafeCastLib for *;
    using SafeTransferLib for *;
    using FixedPointMathLib for *;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using Oracle for Oracle.Observation[MAX_CARDINALITY];

    /// -----------------------------------------------------------------------
    /// Structs
    /// -----------------------------------------------------------------------

    struct Env {
        uint96 hookFeesModifier;
        IBunniHub hub;
        IPoolManager poolManager;
        IFloodPlain floodPlain;
        IZone floodZone;
        WETH weth;
        address permit2;
        uint32 oracleMinInterval;
    }

    struct RebalanceInput {
        PoolId id;
        PoolKey key;
        int24 updatedTick;
        uint160 updatedSqrtPriceX96;
        int24 arithmeticMeanTick;
        bool useTwap;
        bytes32 newLdfState;
        DecodedHookParams p;
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
        IBunniHub hub,
        uint32 oracleMinInterval
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
        uint32 maxTwapSecondsAgo;
        {
            (uint24 twapSecondsAgo, bytes32 hookParams) = abi.decode(hookData, (uint24, bytes32));
            uint24 feeTwapSecondsAgo = uint24(bytes3(hookParams << 72));
            uint16 rebalanceTwapSecondsAgo = uint16(bytes2(hookParams << 216));
            maxTwapSecondsAgo = uint32(
                FixedPointMathLib.max(FixedPointMathLib.max(twapSecondsAgo, feeTwapSecondsAgo), rebalanceTwapSecondsAgo)
            );
            (s.states[id].intermediateObservation, s.states[id].cardinality, s.states[id].cardinalityNext) =
                s.observations[id].initialize(uint32(block.timestamp - maxTwapSecondsAgo), tick);
        }

        // increase cardinality target based on maxTwapSecondsAgo
        uint32 cardinalityNext = (maxTwapSecondsAgo + (oracleMinInterval >> 1)) / oracleMinInterval + 1; // round up + 1
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
    ) external returns (bool useAmAmmFee, address amAmmManager, Currency amAmmFeeCurrency, uint256 amAmmFeeAmount) {
        // ensure swap makes sense
        PoolId id = key.toId();
        Slot0 memory slot0 = s.slot0s[id];
        uint160 sqrtPriceX96 = slot0.sqrtPriceX96;
        if (
            sqrtPriceX96 == 0
                || (
                    params.zeroForOne
                        && (params.sqrtPriceLimitX96 >= sqrtPriceX96 || params.sqrtPriceLimitX96 <= TickMath.MIN_SQRT_RATIO)
                )
                || (
                    !params.zeroForOne
                        && (params.sqrtPriceLimitX96 <= sqrtPriceX96 || params.sqrtPriceLimitX96 >= TickMath.MAX_SQRT_RATIO)
                )
        ) {
            revert BunniHook__InvalidSwap();
        }

        // get pool state
        PoolState memory bunniState = env.hub.poolState(id);

        // decode hook params
        DecodedHookParams memory p = _decodeParams(bunniState.hookParams);

        // update TWAP oracle
        // do it before we fetch the arithmeticMeanTick
        // which doesn't change the result but gives us updated index and cardinality
        (Oracle.Observation memory updatedIntermediate, uint32 updatedIndex, uint32 updatedCardinality) =
            _updateOracle(s, id, slot0.tick, env.oracleMinInterval);

        // get TWAP values
        int24 arithmeticMeanTick;
        int24 feeMeanTick;
        if (bunniState.twapSecondsAgo != 0) {
            // need to use TWAP
            // compute TWAP value
            arithmeticMeanTick = _getTwap(
                s, id, slot0.tick, bunniState.twapSecondsAgo, updatedIntermediate, updatedIndex, updatedCardinality
            );
        }
        if (!p.amAmmEnabled && p.feeMin != p.feeMax && p.feeQuadraticMultiplier != 0) {
            // fee calculation needs TWAP
            feeMeanTick =
                _getTwap(s, id, slot0.tick, p.feeTwapSecondsAgo, updatedIntermediate, updatedIndex, updatedCardinality);
        }

        // query the LDF to get densities
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(slot0.tick, key.tickSpacing);
        (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
            (TickMath.getSqrtRatioAtTick(roundedTick), TickMath.getSqrtRatioAtTick(nextRoundedTick));
        bytes32 ldfState = bunniState.statefulLdf ? s.ldfStates[id] : bytes32(0);
        (
            uint256 liquidityDensityOfRoundedTickX96,
            uint256 density0RightOfRoundedTickX96,
            uint256 density1LeftOfRoundedTickX96,
            bytes32 newLdfState,
            bool shouldSurge
        ) = bunniState.liquidityDensityFunction.query(
            key,
            roundedTick,
            arithmeticMeanTick,
            slot0.tick,
            bunniState.twapSecondsAgo != 0,
            bunniState.ldfParams,
            ldfState
        );
        if (bunniState.statefulLdf) s.ldfStates[id] = newLdfState;

        // check surge based on vault share prices
        (uint256 reserveBalance0, uint256 reserveBalance1) = (
            getReservesInUnderlying(bunniState.reserve0, bunniState.vault0),
            getReservesInUnderlying(bunniState.reserve1, bunniState.vault1)
        );
        shouldSurge = shouldSurge || _shouldSurgeFromVaults(s, id, bunniState, p, reserveBalance0, reserveBalance1);

        // compute total token balances
        (uint256 balance0, uint256 balance1) =
            (bunniState.rawBalance0 + reserveBalance0, bunniState.rawBalance1 + reserveBalance1);

        // compute total liquidity
        uint256 totalLiquidity;
        {
            (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts
                .getAmountsForLiquidity(
                sqrtPriceX96,
                roundedTickSqrtRatio,
                nextRoundedTickSqrtRatio,
                uint128(liquidityDensityOfRoundedTickX96),
                false
            );
            uint256 totalDensity0X96 = density0RightOfRoundedTickX96 + density0OfRoundedTickX96;
            uint256 totalDensity1X96 = density1LeftOfRoundedTickX96 + density1OfRoundedTickX96;
            uint256 totalLiquidityEstimate0 = totalDensity0X96 == 0 ? 0 : balance0.fullMulDiv(Q96, totalDensity0X96);
            uint256 totalLiquidityEstimate1 = totalDensity1X96 == 0 ? 0 : balance1.fullMulDiv(Q96, totalDensity1X96);

            // Strategy: If one of the two liquidity estimates is 0, use the other one;
            // if both are non-zero, use the minimum of the two.
            // We must take the minimum because if the total liquidity we use is higher than
            // the min of the two estimates, then it's possible to extract a profit by
            // buying and immediately selling assuming the swap fee is non-zero. This happens
            // because the swap fee is added to the pool's balance, which can increase the total
            // liquidity estimate.
            if (totalLiquidityEstimate0 == 0) {
                totalLiquidity = totalLiquidityEstimate1;
            } else if (totalLiquidityEstimate1 == 0) {
                totalLiquidity = totalLiquidityEstimate0;
            } else {
                totalLiquidity = FixedPointMathLib.min(totalLiquidityEstimate0, totalLiquidityEstimate1);
            }
        }

        // compute swap result
        (uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount, uint256 outputAmount) = BunniSwapMath
            .computeSwap({
            key: key,
            totalLiquidity: totalLiquidity,
            liquidityDensityOfRoundedTickX96: liquidityDensityOfRoundedTickX96,
            density0RightOfRoundedTickX96: density0RightOfRoundedTickX96,
            density1LeftOfRoundedTickX96: density1LeftOfRoundedTickX96,
            sqrtPriceX96: sqrtPriceX96,
            currentTick: slot0.tick,
            roundedTickSqrtRatio: roundedTickSqrtRatio,
            nextRoundedTickSqrtRatio: nextRoundedTickSqrtRatio,
            balance0: balance0,
            balance1: balance1,
            liquidityDensityFunction: bunniState.liquidityDensityFunction,
            arithmeticMeanTick: arithmeticMeanTick,
            useTwap: bunniState.twapSecondsAgo != 0,
            ldfParams: bunniState.ldfParams,
            ldfState: ldfState,
            params: params
        });

        // ensure swap never moves price in the opposite direction
        if (
            (params.zeroForOne && updatedSqrtPriceX96 > sqrtPriceX96)
                || (!params.zeroForOne && updatedSqrtPriceX96 < sqrtPriceX96)
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
                lastSurgeTimestamp = timeSinceLastSwap >= p.surgeFeeAutostartThreshold
                    ? slot0.lastSwapTimestamp + p.surgeFeeAutostartThreshold
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
        if (p.amAmmEnabled) {
            bytes7 payload;
            IAmAmm.Bid memory topBid = IAmAmm(address(this)).getTopBid(id);
            (amAmmManager, payload) = (topBid.manager, topBid.payload);
            uint24 swapFee0For1;
            uint24 swapFee1For0;
            (swapFee0For1, swapFee1For0, amAmmEnableSurgeFee) = decodeAmAmmPayload(payload);
            amAmmSwapFee = params.zeroForOne ? swapFee0For1 : swapFee1For0;
        }

        // charge swap fee
        (Currency inputToken, Currency outputToken) =
            params.zeroForOne ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        uint24 swapFee;
        uint256 swapFeeAmount;
        bool exactIn = params.amountSpecified >= 0;
        useAmAmmFee = p.amAmmEnabled && amAmmManager != address(0);
        if (useAmAmmFee) {
            // give swap fee to am-AMM manager
            // apply surge fee if manager enabled it
            swapFee = amAmmEnableSurgeFee
                ? uint24(
                    FixedPointMathLib.max(amAmmSwapFee, computeSurgeFee(lastSurgeTimestamp, p.surgeFee, p.surgeFeeHalfLife))
                )
                : amAmmSwapFee;
        } else {
            // use default dynamic fee model
            swapFee = _getFee(
                updatedSqrtPriceX96,
                feeMeanTick,
                lastSurgeTimestamp,
                p.feeMin,
                p.feeMax,
                p.feeQuadraticMultiplier,
                p.surgeFee,
                p.surgeFeeHalfLife
            );
        }
        uint256 hookFeesAmount;
        uint256 hookHandleSwapInputAmount;
        uint256 hookHandleSwapOutoutAmount;
        if (exactIn) {
            // decrease output amount
            swapFeeAmount = outputAmount.mulDivUp(swapFee, SWAP_FEE_BASE);
            if (useAmAmmFee) (amAmmFeeCurrency, amAmmFeeAmount) = (outputToken, swapFeeAmount);

            // take hook fees from swap fee
            hookFeesAmount = swapFeeAmount.mulDivUp(env.hookFeesModifier, WAD);
            swapFeeAmount -= hookFeesAmount;

            // modify output amount with fees
            outputAmount -= swapFeeAmount + hookFeesAmount;

            // if am-AMM is used, the swap fee needs to be taken from BunniHub, else it stays in BunniHub with the LPs
            (hookHandleSwapInputAmount, hookHandleSwapOutoutAmount) = (
                inputAmount, useAmAmmFee ? outputAmount + swapFeeAmount + hookFeesAmount : outputAmount + hookFeesAmount
            );
        } else {
            // increase input amount
            // need to modify fee rate to maintain the same average price as exactIn case
            // in / (out * (1 - fee)) = in * (1 + fee') / out => fee' = fee / (1 - fee)
            swapFeeAmount = inputAmount.mulDivUp(swapFee, SWAP_FEE_BASE - swapFee);
            if (useAmAmmFee) (amAmmFeeCurrency, amAmmFeeAmount) = (inputToken, swapFeeAmount);

            // take hook fees from swap fee
            hookFeesAmount = swapFeeAmount.mulDivUp(env.hookFeesModifier, WAD);
            swapFeeAmount -= hookFeesAmount;

            // modify input amount with fees
            inputAmount += swapFeeAmount + hookFeesAmount;

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
        if (p.rebalanceThreshold != 0 && shouldSurge && block.timestamp > s.rebalanceOrderDeadline[id]) {
            _rebalance(
                s,
                env,
                RebalanceInput({
                    id: id,
                    key: key,
                    updatedTick: updatedTick,
                    updatedSqrtPriceX96: updatedSqrtPriceX96,
                    arithmeticMeanTick: arithmeticMeanTick,
                    useTwap: bunniState.twapSecondsAgo != 0,
                    newLdfState: newLdfState,
                    p: p,
                    updatedIntermediate: updatedIntermediate,
                    updatedIndex: updatedIndex,
                    updatedCardinality: updatedCardinality
                })
            );
        }
    }

    function decodeHookParams(bytes32 hookParams) external pure returns (DecodedHookParams memory p) {
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
        DecodedHookParams memory p,
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
                            >= prevSharePrices.sharePrice0 / p.vaultSurgeThreshold0
                            || dist(sharePrices.sharePrice1, prevSharePrices.sharePrice1)
                                >= prevSharePrices.sharePrice1 / p.vaultSurgeThreshold1
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
            s, env, input.id, input.key, input.p.rebalanceOrderTTL, inputToken, outputToken, inputAmount, outputAmount
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

        // compute total liquidity
        uint256 totalLiquidity;
        uint256 currentActiveBalance0;
        uint256 currentActiveBalance1;
        uint256 excessLiquidity0;
        uint256 excessLiquidity1;
        uint256 totalDensity0X96;
        uint256 totalDensity1X96;
        {
            (int24 roundedTick, int24 nextRoundedTick) = roundTick(input.updatedTick, input.key.tickSpacing);
            (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
                (TickMath.getSqrtRatioAtTick(roundedTick), TickMath.getSqrtRatioAtTick(nextRoundedTick));
            (
                uint256 liquidityDensityOfRoundedTickX96,
                uint256 density0RightOfRoundedTickX96,
                uint256 density1LeftOfRoundedTickX96,
                ,
            ) = bunniState.liquidityDensityFunction.query(
                input.key,
                roundedTick,
                input.arithmeticMeanTick,
                input.updatedTick,
                input.useTwap,
                bunniState.ldfParams,
                input.newLdfState
            );
            {
                (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts
                    .getAmountsForLiquidity(
                    input.updatedSqrtPriceX96,
                    roundedTickSqrtRatio,
                    nextRoundedTickSqrtRatio,
                    uint128(liquidityDensityOfRoundedTickX96),
                    false
                );
                totalDensity0X96 = density0RightOfRoundedTickX96 + density0OfRoundedTickX96;
                totalDensity1X96 = density1LeftOfRoundedTickX96 + density1OfRoundedTickX96;
                uint256 totalLiquidityEstimate0 = totalDensity0X96 == 0 ? 0 : balance0.fullMulDiv(Q96, totalDensity0X96);
                uint256 totalLiquidityEstimate1 = totalDensity1X96 == 0 ? 0 : balance1.fullMulDiv(Q96, totalDensity1X96);
                if (totalLiquidityEstimate0 == 0) {
                    totalLiquidity = totalLiquidityEstimate1;
                } else if (totalLiquidityEstimate1 == 0) {
                    totalLiquidity = totalLiquidityEstimate0;
                } else {
                    totalLiquidity = FixedPointMathLib.min(totalLiquidityEstimate0, totalLiquidityEstimate1);
                }
            }

            // compute active balance, which is the balance implied by the total liquidity & the LDF
            (currentActiveBalance0, currentActiveBalance1) =
                ((totalDensity0X96 * totalLiquidity) >> 96, (totalDensity1X96 * totalLiquidity) >> 96);

            // compute excess liquidity if there's any
            (int24 minUsableTick, int24 maxUsableTick) = (
                TickMath.minUsableTick(input.key.tickSpacing),
                TickMath.maxUsableTick(input.key.tickSpacing) - input.key.tickSpacing
            );
            excessLiquidity0 = balance0 > currentActiveBalance0
                ? (balance0 - currentActiveBalance0).divWad(
                    bunniState.liquidityDensityFunction.cumulativeAmount0(
                        input.key,
                        minUsableTick,
                        WAD,
                        input.arithmeticMeanTick,
                        input.updatedTick,
                        input.useTwap,
                        bunniState.ldfParams,
                        input.newLdfState
                    )
                )
                : 0;
            excessLiquidity1 = balance1 > currentActiveBalance1
                ? (balance1 - currentActiveBalance1).divWad(
                    bunniState.liquidityDensityFunction.cumulativeAmount1(
                        input.key,
                        maxUsableTick,
                        WAD,
                        input.arithmeticMeanTick,
                        input.updatedTick,
                        input.useTwap,
                        bunniState.ldfParams,
                        input.newLdfState
                    )
                )
                : 0;
        }

        // should rebalance if excessLiquidity / totalLiquidity >= 1 / rebalanceThreshold
        bool shouldRebalance0 = excessLiquidity0 != 0 && excessLiquidity0 >= totalLiquidity / input.p.rebalanceThreshold;
        bool shouldRebalance1 = excessLiquidity1 != 0 && excessLiquidity1 >= totalLiquidity / input.p.rebalanceThreshold;
        if (!shouldRebalance0 && !shouldRebalance1) return (false, inputToken, outputToken, inputAmount, outputAmount);

        // compute density of token0 and token1 after excess liquidity has been rebalanced
        // this is done by querying the LDF using a TWAP as the spot price to prevent manipulation
        {
            int24 rebalanceSpotPriceTick = _getTwap(
                s,
                input.id,
                input.updatedTick,
                input.p.rebalanceTwapSecondsAgo,
                input.updatedIntermediate,
                input.updatedIndex,
                input.updatedCardinality
            );
            uint160 rebalanceSpotPriceSqrtRatioX96 = TickMath.getSqrtRatioAtTick(rebalanceSpotPriceTick);
            (int24 roundedTick, int24 nextRoundedTick) = roundTick(rebalanceSpotPriceTick, input.key.tickSpacing);
            (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
                (TickMath.getSqrtRatioAtTick(roundedTick), TickMath.getSqrtRatioAtTick(nextRoundedTick));
            (
                uint256 liquidityDensityOfRoundedTickX96,
                uint256 density0RightOfRoundedTickX96,
                uint256 density1LeftOfRoundedTickX96,
                ,
            ) = bunniState.liquidityDensityFunction.query(
                input.key,
                roundedTick,
                input.arithmeticMeanTick,
                rebalanceSpotPriceTick,
                input.useTwap,
                bunniState.ldfParams,
                input.newLdfState
            );
            (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts
                .getAmountsForLiquidity(
                rebalanceSpotPriceSqrtRatioX96,
                roundedTickSqrtRatio,
                nextRoundedTickSqrtRatio,
                uint128(liquidityDensityOfRoundedTickX96),
                false
            );
            totalDensity0X96 = density0RightOfRoundedTickX96 + density0OfRoundedTickX96;
            totalDensity1X96 = density1LeftOfRoundedTickX96 + density1OfRoundedTickX96;
        }

        // decide which token will be rebalanced (i.e. sold into the other token)
        bool willRebalanceToken0;
        if (shouldRebalance0 && shouldRebalance1) {
            // edge case where both tokens have excess liquidity
            // likely one token has actual excess liquidity, the other token has negligible excess liquidity from rounding errors
            // rebalance the token for which excessLiquidity is larger
            willRebalanceToken0 = excessLiquidity0 > excessLiquidity1;
        } else if (shouldRebalance0) {
            // rebalance token0
            willRebalanceToken0 = true;
        } else if (shouldRebalance1) {
            // rebalance token1
            willRebalanceToken0 = false;
        }

        // compute target amounts (i.e. the token amounts of the excess liquidity)
        uint256 excessLiquidity = willRebalanceToken0 ? excessLiquidity0 : excessLiquidity1;
        uint256 targetAmount0 = excessLiquidity.fullMulDiv(totalDensity0X96, Q96);
        uint256 targetAmount1 = excessLiquidity.fullMulDiv(totalDensity1X96, Q96);

        // determin input & output
        if (willRebalanceToken0) {
            (inputToken, outputToken) = (input.key.currency0, input.key.currency1);
            if (balance0 - currentActiveBalance0 < targetAmount0) {
                return (false, inputToken, outputToken, inputAmount, outputAmount);
            } // should never happen
            inputAmount = balance0 - currentActiveBalance0 - targetAmount0;
            outputAmount = targetAmount1.mulDivUp(1e5 - input.p.rebalanceMaxSlippage, 1e5);
        } else {
            (inputToken, outputToken) = (input.key.currency1, input.key.currency0);
            if (balance1 - currentActiveBalance1 < targetAmount1) {
                return (false, inputToken, outputToken, inputAmount, outputAmount);
            } // should never happen
            inputAmount = balance1 - currentActiveBalance1 - targetAmount1;
            outputAmount = targetAmount0.mulDivUp(1e5 - input.p.rebalanceMaxSlippage, 1e5);
        }

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

    function _getFee(
        uint160 postSwapSqrtPriceX96,
        int24 arithmeticMeanTick,
        uint32 lastSurgeTimestamp,
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier,
        uint24 surgeFee,
        uint16 surgeFeeHalfLife
    ) internal view returns (uint24 fee) {
        // compute surge fee
        // surge fee gets applied after the LDF shifts (if it's dynamic)
        fee = computeSurgeFee(lastSurgeTimestamp, surgeFee, surgeFeeHalfLife);

        // special case for fixed fee pools
        if (feeQuadraticMultiplier == 0 || feeMin == feeMax) return uint24(FixedPointMathLib.max(feeMin, fee));

        uint256 ratio =
            uint256(postSwapSqrtPriceX96).mulDiv(SWAP_FEE_BASE, TickMath.getSqrtRatioAtTick(arithmeticMeanTick));
        if (ratio > MAX_SWAP_FEE_RATIO) ratio = MAX_SWAP_FEE_RATIO;
        ratio = ratio.mulDiv(ratio, SWAP_FEE_BASE); // square the sqrtPrice ratio to get the price ratio
        uint256 delta = dist(ratio, SWAP_FEE_BASE);
        // unchecked is safe since we're using uint256 to store the result and the return value is bounded in the range [feeMin, feeMax]
        unchecked {
            uint256 quadraticTerm = uint256(feeQuadraticMultiplier).mulDivUp(delta * delta, SWAP_FEE_BASE_SQUARED);
            return uint24(FixedPointMathLib.max(fee, FixedPointMathLib.min(feeMin + quadraticTerm, feeMax)));
        }
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
    /// @param hookParams The hook params raw bytes32
    /// @return p The decoded params struct
    function _decodeParams(bytes32 hookParams) internal pure returns (DecodedHookParams memory p) {
        // | feeMin - 3 bytes | feeMax - 3 bytes | feeQuadraticMultiplier - 3 bytes | feeTwapSecondsAgo - 3 bytes | surgeFee - 3 bytes | surgeFeeHalfLife - 2 bytes | surgeFeeAutostartThreshold - 2 bytes | vaultSurgeThreshold0 - 2 bytes | vaultSurgeThreshold1 - 2 bytes | rebalanceThreshold - 2 bytes | rebalanceMaxSlippage - 2 bytes | rebalanceTwapSecondsAgo - 2 bytes | rebalanceOrderTTL - 2 bytes | amAmmEnabled - 1 byte |
        p.feeMin = uint24(bytes3(hookParams));
        p.feeMax = uint24(bytes3(hookParams << 24));
        p.feeQuadraticMultiplier = uint24(bytes3(hookParams << 48));
        p.feeTwapSecondsAgo = uint24(bytes3(hookParams << 72));
        p.surgeFee = uint24(bytes3(hookParams << 96));
        p.surgeFeeHalfLife = uint16(bytes2(hookParams << 120));
        p.surgeFeeAutostartThreshold = uint16(bytes2(hookParams << 136));
        p.vaultSurgeThreshold0 = uint16(bytes2(hookParams << 152));
        p.vaultSurgeThreshold1 = uint16(bytes2(hookParams << 168));
        p.rebalanceThreshold = uint16(bytes2(hookParams << 184));
        p.rebalanceMaxSlippage = uint16(bytes2(hookParams << 200));
        p.rebalanceTwapSecondsAgo = uint16(bytes2(hookParams << 216));
        p.rebalanceOrderTTL = uint16(bytes2(hookParams << 232));
        p.amAmmEnabled = uint8(bytes1(hookParams << 248)) != 0;
    }
}
