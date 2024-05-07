// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {IAmAmm} from "biddog/interfaces/IAmAmm.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import {IBunniHub} from "../interfaces/IBunniHub.sol";
import {IBunniHook} from "../interfaces/IBunniHook.sol";
import {IBunniQuoter} from "../interfaces/IBunniQuoter.sol";

import "../lib/Math.sol";
import "../lib/VaultMath.sol";
import "../base/Constants.sol";
import "../types/PoolState.sol";
import "../lib/AmAmmPayload.sol";
import "../lib/BunniSwapMath.sol";
import "../base/SharedStructs.sol";
import {BunniHookLogic} from "../lib/BunniHookLogic.sol";
import {LiquidityAmounts} from "../lib/LiquidityAmounts.sol";

contract BunniQuoter is IBunniQuoter {
    using SafeCastLib for int256;
    using SafeCastLib for uint256;
    using PoolIdLibrary for PoolKey;
    using FixedPointMathLib for int256;
    using FixedPointMathLib for uint256;

    IBunniHub internal immutable hub;

    constructor(IBunniHub hub_) {
        hub = hub_;
    }

    /// -----------------------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------------------

    function quoteSwap(PoolKey memory key, IPoolManager.SwapParams memory params)
        external
        view
        override
        returns (
            bool success,
            uint160 updatedSqrtPriceX96,
            int24 updatedTick,
            uint256 inputAmount,
            uint256 outputAmount,
            uint24 swapFee,
            uint256 totalLiquidity
        )
    {
        // ensure swap makes sense
        PoolId id = key.toId();
        IBunniHook hook = IBunniHook(address(key.hooks));
        (uint160 sqrtPriceX96, int24 currentTick, uint32 lastSwapTimestamp, uint32 lastSurgeTimestamp) = hook.slot0s(id);
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
            return (false, 0, 0, 0, 0, 0, 0);
        }

        // get pool state
        PoolState memory bunniState = hub.poolState(id);

        // decode hook params
        DecodedHookParams memory hookParams = BunniHookLogic.decodeHookParams(bunniState.hookParams);

        // get TWAP values
        int24 arithmeticMeanTick = bunniState.twapSecondsAgo != 0 ? _getTwap(key, bunniState.twapSecondsAgo) : int24(0);
        int24 feeMeanTick = (
            !hookParams.amAmmEnabled && hookParams.feeMin != hookParams.feeMax && hookParams.feeQuadraticMultiplier != 0
        ) ? _getTwap(key, hookParams.feeTwapSecondsAgo) : int24(0);

        // compute total token balances
        (uint256 reserveBalance0, uint256 reserveBalance1) = (
            getReservesInUnderlying(bunniState.reserve0, bunniState.vault0),
            getReservesInUnderlying(bunniState.reserve1, bunniState.vault1)
        );
        (uint256 balance0, uint256 balance1) =
            (bunniState.rawBalance0 + reserveBalance0, bunniState.rawBalance1 + reserveBalance1);

        // query the LDF to get total liquidity and token densities
        bytes32 ldfState = bunniState.statefulLdf ? hook.ldfStates(id) : bytes32(0);
        (
            uint256 totalLiquidity_,
            uint256 totalDensity0X96,
            uint256 totalDensity1X96,
            uint256 liquidityDensityOfRoundedTickX96,
            ,
            bool shouldSurge
        ) = queryLDF({
            key: key,
            sqrtPriceX96: sqrtPriceX96,
            tick: currentTick,
            arithmeticMeanTick: arithmeticMeanTick,
            useTwap: bunniState.twapSecondsAgo != 0,
            ldf: bunniState.liquidityDensityFunction,
            ldfParams: bunniState.ldfParams,
            ldfState: ldfState,
            balance0: balance0,
            balance1: balance1
        });
        totalLiquidity = totalLiquidity_;

        // check surge based on vault share prices
        shouldSurge =
            shouldSurge || _shouldSurgeFromVaults(id, hook, bunniState, hookParams, reserveBalance0, reserveBalance1);

        // compute swap result
        (updatedSqrtPriceX96, updatedTick, inputAmount, outputAmount) = BunniSwapMath.computeSwap({
            input: BunniSwapMath.BunniComputeSwapInput({
                key: key,
                totalLiquidity: totalLiquidity,
                liquidityDensityOfRoundedTickX96: liquidityDensityOfRoundedTickX96,
                totalDensity0X96: totalDensity0X96,
                totalDensity1X96: totalDensity1X96,
                sqrtPriceX96: sqrtPriceX96,
                currentTick: currentTick,
                liquidityDensityFunction: bunniState.liquidityDensityFunction,
                arithmeticMeanTick: arithmeticMeanTick,
                useTwap: bunniState.twapSecondsAgo != 0,
                ldfParams: bunniState.ldfParams,
                ldfState: ldfState,
                swapParams: params
            }),
            balance0: balance0,
            balance1: balance1
        });

        // ensure swap never moves price in the opposite direction
        if (
            (params.zeroForOne && updatedSqrtPriceX96 > sqrtPriceX96)
                || (!params.zeroForOne && updatedSqrtPriceX96 < sqrtPriceX96)
        ) {
            return (false, 0, 0, 0, 0, 0, 0);
        }

        if (shouldSurge) {
            // use unchecked so that if uint32 overflows we wrap around
            // overflows are ok since we only look at differences
            unchecked {
                uint32 timeSinceLastSwap = uint32(block.timestamp) - lastSwapTimestamp;
                // if more than `surgeFeeAutostartThreshold` seconds has passed since the last swap,
                // we pretend that the surge started at `lastSwapTimestamp + surgeFeeAutostartThreshold`
                // so that the pool never gets stuck with a high fee
                lastSurgeTimestamp = timeSinceLastSwap >= hookParams.surgeFeeAutostartThreshold
                    ? lastSwapTimestamp + hookParams.surgeFeeAutostartThreshold
                    : uint32(block.timestamp);
            }
        }

        // get am-AMM state
        uint24 amAmmSwapFee;
        bool amAmmEnableSurgeFee;
        address amAmmManager;
        if (hookParams.amAmmEnabled) {
            bytes7 payload;
            IAmAmm.Bid memory topBid = IAmAmm(address(this)).getTopBid(id);
            (amAmmManager, payload) = (topBid.manager, topBid.payload);
            uint24 swapFee0For1;
            uint24 swapFee1For0;
            (swapFee0For1, swapFee1For0, amAmmEnableSurgeFee) = decodeAmAmmPayload(payload);
            amAmmSwapFee = params.zeroForOne ? swapFee0For1 : swapFee1For0;
        }

        // charge swap fee
        uint256 swapFeeAmount;
        bool exactIn = params.amountSpecified > 0;
        bool useAmAmmFee = hookParams.amAmmEnabled && amAmmManager != address(0);
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
            : _getFee(
                updatedSqrtPriceX96,
                feeMeanTick,
                lastSurgeTimestamp,
                hookParams.feeMin,
                hookParams.feeMax,
                hookParams.feeQuadraticMultiplier,
                hookParams.surgeFee,
                hookParams.surgeFeeHalfLife
            );
        if (exactIn) {
            swapFeeAmount = outputAmount.mulDivUp(swapFee, SWAP_FEE_BASE);
            outputAmount -= swapFeeAmount;
        } else {
            // increase input amount
            // need to modify fee rate to maintain the same average price as exactIn case
            // in / (out * (1 - fee)) = in * (1 + fee') / out => fee' = fee / (1 - fee)
            swapFeeAmount = inputAmount.mulDivUp(swapFee, SWAP_FEE_BASE - swapFee);
            inputAmount += swapFeeAmount;
        }

        // if we reached this point, the swap was successful
        success = true;
    }

    function quoteDeposit(IBunniHub.DepositParams calldata params)
        external
        view
        override
        returns (uint256 shares, uint256 amount0, uint256 amount1)
    {
        PoolId poolId = params.poolKey.toId();
        PoolState memory state = hub.poolState(poolId);

        (uint160 sqrtPriceX96, int24 currentTick,,) = IBunniHook(address(params.poolKey.hooks)).slot0s(poolId);

        DepositLogicReturnData memory depositReturnData = _depositLogic(
            DepositLogicInputData({
                state: state,
                params: params,
                poolKey: params.poolKey,
                poolId: poolId,
                currentTick: currentTick,
                sqrtPriceX96: sqrtPriceX96
            })
        );
        amount0 = depositReturnData.amount0;
        amount1 = depositReturnData.amount1;

        (uint256 rawAmount0, uint256 reserveAmount0) = address(state.vault0) != address(0)
            ? (amount0 - depositReturnData.reserveAmount0, depositReturnData.reserveAmount0.mulWad(WAD - params.vaultFee0))
            : (amount0, 0);
        (uint256 rawAmount1, uint256 reserveAmount1) = address(state.vault1) != address(0)
            ? (amount1 - depositReturnData.reserveAmount1, depositReturnData.reserveAmount1.mulWad(WAD - params.vaultFee1))
            : (amount1, 0);

        // compute shares
        uint256 existingShareSupply = state.bunniToken.totalSupply();
        if (existingShareSupply == 0) {
            // no existing shares, just give WAD - MIN_INITIAL_SHARES
            shares = WAD - MIN_INITIAL_SHARES;
        } else {
            // given that the position may become single-sided, we need to handle the case where one of the existingAmount values is zero
            shares = FixedPointMathLib.min(
                depositReturnData.balance0 == 0
                    ? type(uint256).max
                    : existingShareSupply.mulDiv(rawAmount0 + reserveAmount0, depositReturnData.balance0),
                depositReturnData.balance1 == 0
                    ? type(uint256).max
                    : existingShareSupply.mulDiv(rawAmount1 + reserveAmount1, depositReturnData.balance1)
            );
        }
    }

    function quoteWithdraw(IBunniHub.WithdrawParams calldata params)
        external
        view
        override
        returns (uint256 amount0, uint256 amount1)
    {
        PoolId poolId = params.poolKey.toId();
        PoolState memory state = hub.poolState(poolId);

        uint256 currentTotalSupply = state.bunniToken.totalSupply();

        // compute token amount to withdraw and the component amounts
        uint256 reserveAmount0 =
            getReservesInUnderlying(state.reserve0.mulDiv(params.shares, currentTotalSupply), state.vault0);
        uint256 reserveAmount1 =
            getReservesInUnderlying(state.reserve1.mulDiv(params.shares, currentTotalSupply), state.vault1);
        uint256 rawAmount0 = state.rawBalance0.mulDiv(params.shares, currentTotalSupply);
        uint256 rawAmount1 = state.rawBalance1.mulDiv(params.shares, currentTotalSupply);
        amount0 = reserveAmount0 + rawAmount0;
        amount1 = reserveAmount1 + rawAmount1;
    }

    /// -----------------------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------------------

    struct DepositLogicInputData {
        PoolState state;
        IBunniHub.DepositParams params;
        PoolKey poolKey;
        PoolId poolId;
        int24 currentTick;
        uint160 sqrtPriceX96;
    }

    struct DepositLogicReturnData {
        uint256 reserveAmount0;
        uint256 reserveAmount1;
        uint256 amount0;
        uint256 amount1;
        uint256 balance0;
        uint256 balance1;
    }

    /// @dev Separated to avoid stack too deep error
    function _depositLogic(DepositLogicInputData memory inputData)
        private
        view
        returns (DepositLogicReturnData memory returnData)
    {
        // query existing assets
        // assets = urrent tick tokens + reserve tokens + pool credits
        (uint256 reserveBalance0, uint256 reserveBalance1) = (
            getReservesInUnderlying(inputData.state.reserve0, inputData.state.vault0),
            getReservesInUnderlying(inputData.state.reserve1, inputData.state.vault1)
        );
        (returnData.balance0, returnData.balance1) =
            (inputData.state.rawBalance0 + reserveBalance0, inputData.state.rawBalance1 + reserveBalance1);

        // update TWAP oracle and optionally observe
        bool requiresLDF = returnData.balance0 == 0 && returnData.balance1 == 0;

        if (requiresLDF) {
            // use LDF to initialize token proportions

            // compute density
            bool useTwap = inputData.state.twapSecondsAgo != 0;
            int24 arithmeticMeanTick =
                useTwap ? _getTwap(inputData.params.poolKey, inputData.state.twapSecondsAgo) : int24(0);
            IBunniHook hook = IBunniHook(address(inputData.params.poolKey.hooks));
            bytes32 ldfState = inputData.state.statefulLdf ? hook.ldfStates(inputData.poolId) : bytes32(0);
            (uint256 totalLiquidity, uint256 totalDensity0X96, uint256 totalDensity1X96,,,) = queryLDF({
                key: inputData.params.poolKey,
                sqrtPriceX96: inputData.sqrtPriceX96,
                tick: inputData.currentTick,
                arithmeticMeanTick: arithmeticMeanTick,
                useTwap: useTwap,
                ldf: inputData.state.liquidityDensityFunction,
                ldfParams: inputData.state.ldfParams,
                ldfState: ldfState,
                balance0: inputData.params.amount0Desired, // use amount0Desired since we're initializing liquidity
                balance1: inputData.params.amount1Desired // use amount1Desired since we're initializing liquidity
            });

            // compute token amounts to add
            (returnData.amount0, returnData.amount1) =
                (totalLiquidity.mulDivUp(totalDensity0X96, Q96), totalLiquidity.mulDivUp(totalDensity1X96, Q96));

            // sanity check against desired amounts
            // the amounts can exceed the desired amounts due to math errors
            if (
                (returnData.amount0 > inputData.params.amount0Desired)
                    || (returnData.amount1 > inputData.params.amount1Desired)
            ) {
                // scale down amounts and take minimum
                if (returnData.amount0 == 0) {
                    returnData.amount1 = inputData.params.amount1Desired;
                } else if (returnData.amount1 == 0) {
                    returnData.amount0 = inputData.params.amount0Desired;
                } else {
                    // both are non-zero
                    (returnData.amount0, returnData.amount1) = (
                        FixedPointMathLib.min(
                            inputData.params.amount0Desired,
                            returnData.amount0.mulDiv(inputData.params.amount1Desired, returnData.amount1)
                        ),
                        FixedPointMathLib.min(
                            inputData.params.amount1Desired,
                            returnData.amount1.mulDiv(inputData.params.amount0Desired, returnData.amount0)
                        )
                    );
                }
            }

            // update token amounts to deposit into vaults
            (returnData.reserveAmount0, returnData.reserveAmount1) = (
                returnData.amount0
                    - returnData.amount0.mulDiv(inputData.state.targetRawTokenRatio0, RAW_TOKEN_RATIO_BASE),
                returnData.amount1
                    - returnData.amount1.mulDiv(inputData.state.targetRawTokenRatio1, RAW_TOKEN_RATIO_BASE)
            );
        } else {
            // already initialized liquidity shape
            // simply add tokens at the current ratio
            // need to update: reserveAmount0, reserveAmount1, amount0, amount1

            // compute amount0 and amount1 such that the ratio is the same as the current ratio
            uint256 amount0Desired = inputData.params.amount0Desired;
            uint256 amount1Desired = inputData.params.amount1Desired;
            uint256 balance0 = returnData.balance0;
            uint256 balance1 = returnData.balance1;

            returnData.amount0 = balance1 == 0
                ? amount0Desired
                : FixedPointMathLib.min(amount0Desired, amount1Desired.mulDiv(balance0, balance1));
            returnData.amount1 = balance0 == 0
                ? amount1Desired
                : FixedPointMathLib.min(amount1Desired, amount0Desired.mulDiv(balance1, balance0));

            returnData.reserveAmount0 = balance0 == 0 ? 0 : returnData.amount0.mulDiv(reserveBalance0, balance0);
            returnData.reserveAmount1 = balance1 == 0 ? 0 : returnData.amount1.mulDiv(reserveBalance1, balance1);
        }
    }

    /// @dev Decodes hookParams into params used by this hook
    /// @param hookParams The hook params raw bytes32
    /// @return feeMin The minimum swap fee, 6 decimals
    /// @return feeMax The maximum swap fee (may be exceeded if surge fee is active), 6 decimals
    /// @return feeQuadraticMultiplier The quadratic multiplier for the dynamic swap fee formula, 6 decimals
    /// @return feeTwapSecondsAgo The time window for the TWAP used by the dynamic swap fee formula
    /// @return surgeFee The max surge swap fee, 6 decimals
    /// @return surgeFeeHalfLife The half-life of the surge fee in seconds. The surge fee decays exponentially, and the half-life is the time it takes for the surge fee to decay to half its value.
    /// @return surgeFeeAutostartThreshold Time after a swap when the surge fee exponential decay autostarts, in seconds. The autostart avoids the pool being stuck on a high fee.
    /// @return vaultSurgeThreshold0 The threshold for the vault0 share price change to trigger the surge fee. Only used if both vaults are set.
    ///         1 / vaultSurgeThreshold is the minimum percentage change in the vault share price to trigger the surge fee.
    /// @return vaultSurgeThreshold1 The threshold for the vault1 share price change to trigger the surge fee. Only used if both vaults are set.
    ///         1 / vaultSurgeThreshold is the minimum percentage change in the vault share price to trigger the surge fee.
    /// @return rebalanceThreshold The threshold for triggering a rebalance from excess liquidity.
    ///         1 / rebalanceThreshold is the minimum ratio of excess liquidity to total liquidity to trigger a rebalance.
    ///         When set to 0, rebalancing is disabled.
    /// @return rebalanceMaxSlippage The maximum slippage (vs TWAP) allowed during rebalancing, 5 decimals.
    /// @return rebalanceTwapSecondsAgo The time window for the TWAP used during rebalancing
    /// @return rebalanceOrderTTL The time-to-live for a rebalance order, in seconds
    /// @return amAmmEnabled Whether the am-AMM is enabled for this pool
    function _decodeParams(bytes32 hookParams)
        internal
        pure
        returns (
            uint24 feeMin,
            uint24 feeMax,
            uint24 feeQuadraticMultiplier,
            uint24 feeTwapSecondsAgo,
            uint24 surgeFee,
            uint16 surgeFeeHalfLife,
            uint16 surgeFeeAutostartThreshold,
            uint16 vaultSurgeThreshold0,
            uint16 vaultSurgeThreshold1,
            uint16 rebalanceThreshold,
            uint16 rebalanceMaxSlippage,
            uint16 rebalanceTwapSecondsAgo,
            uint16 rebalanceOrderTTL,
            bool amAmmEnabled
        )
    {
        // | feeMin - 3 bytes | feeMax - 3 bytes | feeQuadraticMultiplier - 3 bytes | feeTwapSecondsAgo - 3 bytes | surgeFee - 3 bytes | surgeFeeHalfLife - 2 bytes | surgeFeeAutostartThreshold - 2 bytes | vaultSurgeThreshold0 - 2 bytes | vaultSurgeThreshold1 - 2 bytes | rebalanceThreshold - 2 bytes | rebalanceMaxSlippage - 2 bytes | rebalanceTwapSecondsAgo - 2 bytes | rebalanceOrderTTL - 2 bytes | amAmmEnabled - 1 byte |
        feeMin = uint24(bytes3(hookParams));
        feeMax = uint24(bytes3(hookParams << 24));
        feeQuadraticMultiplier = uint24(bytes3(hookParams << 48));
        feeTwapSecondsAgo = uint24(bytes3(hookParams << 72));
        surgeFee = uint24(bytes3(hookParams << 96));
        surgeFeeHalfLife = uint16(bytes2(hookParams << 120));
        surgeFeeAutostartThreshold = uint16(bytes2(hookParams << 136));
        vaultSurgeThreshold0 = uint16(bytes2(hookParams << 152));
        vaultSurgeThreshold1 = uint16(bytes2(hookParams << 168));
        rebalanceThreshold = uint16(bytes2(hookParams << 184));
        rebalanceMaxSlippage = uint16(bytes2(hookParams << 200));
        rebalanceTwapSecondsAgo = uint16(bytes2(hookParams << 216));
        rebalanceOrderTTL = uint16(bytes2(hookParams << 232));
        amAmmEnabled = uint8(bytes1(hookParams << 248)) != 0;
    }

    function _getTwap(PoolKey memory poolKey, uint24 twapSecondsAgo) internal view returns (int24 arithmeticMeanTick) {
        IBunniHook hook = IBunniHook(address(poolKey.hooks));
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = twapSecondsAgo;
        secondsAgos[1] = 0;
        int56[] memory tickCumulatives = hook.observe(poolKey, secondsAgos);
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        return int24(tickCumulativesDelta / int56(uint56(twapSecondsAgo)));
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

    /// @dev Checks if the pool should surge based on the vault share price changes since the last swap.
    function _shouldSurgeFromVaults(
        PoolId id,
        IBunniHook hook,
        PoolState memory bunniState,
        DecodedHookParams memory hookParams,
        uint256 reserveBalance0,
        uint256 reserveBalance1
    ) private view returns (bool shouldSurge) {
        // only surge if both vaults are set because otherwise total liquidity won't automatically increase
        // so there's no risk of being sandwiched
        if (address(bunniState.vault0) == address(0) && address(bunniState.vault1) == address(0)) return false;

        // compute share prices
        VaultSharePrices memory sharePrices = VaultSharePrices({
            initialized: true,
            sharePrice0: bunniState.reserve0 == 0 ? 0 : reserveBalance0.mulDivUp(WAD, bunniState.reserve0).toUint120(),
            sharePrice1: bunniState.reserve1 == 0 ? 0 : reserveBalance1.mulDivUp(WAD, bunniState.reserve1).toUint120()
        });

        // compare with share prices at last swap to see if we need to apply the surge fee
        // surge fee is applied if the share price has increased by more than 1 / vaultSurgeThreshold
        (bool prevSharePricesInitialized, uint120 prevSharePrice0, uint120 prevSharePrice1) =
            hook.vaultSharePricesAtLastSwap(id);
        return (
            prevSharePricesInitialized
                && (
                    dist(sharePrices.sharePrice0, prevSharePrice0) >= prevSharePrice0 / hookParams.vaultSurgeThreshold0
                        || dist(sharePrices.sharePrice1, prevSharePrice1) >= prevSharePrice1 / hookParams.vaultSurgeThreshold1
                )
        );
    }
}
