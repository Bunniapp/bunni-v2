// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import "@uniswap/v4-core/src/types/Currency.sol";
import {Fees} from "@uniswap/v4-core/src/Fees.sol";
import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import "@uniswap/v4-core/src/libraries/SqrtPriceMath.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {SqrtPriceMath} from "@uniswap/v4-core/src/libraries/SqrtPriceMath.sol";

import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
import "./lib/VaultMath.sol";
import "./lib/Constants.sol";
import "./interfaces/IBunniHook.sol";
import {Oracle} from "./lib/Oracle.sol";
import {Ownable} from "./lib/Ownable.sol";
import {BaseHook} from "./lib/BaseHook.sol";
import {IBunniHub} from "./interfaces/IBunniHub.sol";
import {BunniSwapMath} from "./lib/BunniSwapMath.sol";
import {ReentrancyGuard} from "./lib/ReentrancyGuard.sol";
import {LiquidityAmounts} from "./lib/LiquidityAmounts.sol";
import {AdditionalCurrencyLibrary} from "./lib/AdditionalCurrencyLib.sol";

/// @notice Bunni Hook
contract BunniHook is BaseHook, Ownable, IBunniHook, ReentrancyGuard {
    using SafeCastLib for uint256;
    using PoolIdLibrary for PoolKey;
    using SafeTransferLib for address;
    using CurrencyLibrary for Currency;
    using FixedPointMathLib for int256;
    using FixedPointMathLib for uint256;
    using Oracle for Oracle.Observation[65535];
    using AdditionalCurrencyLibrary for Currency;

    IBunniHub internal immutable hub;

    /// @notice The list of observations for a given pool ID
    mapping(PoolId => Oracle.Observation[65535]) internal _observations;

    /// @notice The current observation array state for the given pool ID
    mapping(PoolId => ObservationState) internal _states;

    mapping(PoolId => VaultSharePrices) public vaultSharePricesAtLastSwap;
    mapping(PoolId => bytes32) public ldfStates;
    mapping(PoolId => Slot0) public slot0s;

    /// @notice Used for computing the hook fee amount. Fee taken is `amount * swapFee / 1e6 * hookFeesModifier / 1e18`.
    uint96 internal _hookFeesModifier;

    /// @notice The recipient of collected hook fees
    address internal _hookFeesRecipient;

    constructor(
        IPoolManager _poolManager,
        IBunniHub hub_,
        address owner_,
        address hookFeesRecipient_,
        uint96 hookFeesModifier_
    ) BaseHook(_poolManager) {
        hub = hub_;
        _hookFeesModifier = hookFeesModifier_;
        _hookFeesRecipient = hookFeesRecipient_;
        _initializeOwner(owner_);
        _poolManager.setOperator(address(hub_), true);

        emit SetHookFeesParams(hookFeesModifier_, hookFeesRecipient_);
    }

    /// -----------------------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function increaseCardinalityNext(PoolKey calldata key, uint16 cardinalityNext)
        external
        override
        returns (uint16 cardinalityNextOld, uint16 cardinalityNextNew)
    {
        PoolId id = key.toId();

        ObservationState storage state = _states[id];

        cardinalityNextOld = state.cardinalityNext;
        cardinalityNextNew = _observations[id].grow(cardinalityNextOld, cardinalityNext);
        state.cardinalityNext = cardinalityNextNew;
    }

    receive() external payable {}

    /// -----------------------------------------------------------------------
    /// Uniswap lock callback
    /// -----------------------------------------------------------------------

    /// @inheritdoc ILockCallback
    function lockAcquired(address lockCaller, bytes calldata data)
        external
        override
        poolManagerOnly
        nonReentrant
        returns (bytes memory)
    {
        if (lockCaller != owner()) revert BunniHook__Unauthorized();

        // decode data
        Currency[] memory currencyList = abi.decode(data, (Currency[]));

        // claim protocol fees
        address recipient = _hookFeesRecipient;
        for (uint256 i; i < currencyList.length; i++) {
            Currency currency = currencyList[i];
            uint256 balance = poolManager.balanceOf(address(this), currency.toId());
            if (balance != 0) {
                poolManager.burn(address(this), currency.toId(), balance);
                poolManager.take(currency, recipient, balance);
            }
        }
        return bytes("");
    }

    /// -----------------------------------------------------------------------
    /// BunniHub functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function updateLdfState(PoolId id, bytes32 newState) external override {
        if (msg.sender != address(hub)) revert BunniHook__Unauthorized();

        ldfStates[id] = newState;
    }

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function setHookFeesParams(uint96 newModifier, address newRecipient) external onlyOwner {
        _hookFeesModifier = newModifier;
        _hookFeesRecipient = newRecipient;

        emit SetHookFeesParams(newModifier, newRecipient);
    }

    /// -----------------------------------------------------------------------
    /// View functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function getHookFeesParams() external view override returns (uint96 modifierVal, address recipient) {
        return (_hookFeesModifier, _hookFeesRecipient);
    }

    /// @inheritdoc IBunniHook
    function getObservation(PoolKey calldata key, uint256 index)
        external
        view
        override
        returns (Oracle.Observation memory observation)
    {
        observation = _observations[key.toId()][index];
    }

    /// @inheritdoc IBunniHook
    function getState(PoolKey calldata key) external view override returns (ObservationState memory state) {
        state = _states[key.toId()];
    }

    /// @inheritdoc IBunniHook
    function observe(PoolKey calldata key, uint32[] calldata secondsAgos)
        external
        view
        override
        returns (int56[] memory tickCumulatives)
    {
        PoolId id = key.toId();
        ObservationState memory state = _states[id];
        Slot0 memory slot0 = slot0s[id];

        return
            _observations[id].observe(uint32(block.timestamp), secondsAgos, slot0.tick, state.index, state.cardinality);
    }

    /// @inheritdoc IBunniHook
    function isValidParams(bytes32 hookParams) external pure override returns (bool) {
        (
            uint24 feeMin,
            uint24 feeMax,
            uint24 feeQuadraticMultiplier,
            uint24 feeTwapSecondsAgo,
            uint24 surgeFee,
            uint16 surgeFeeHalflife,
            ,
            uint16 vaultSurgeThreshold0,
            uint16 vaultSurgeThreshold1
        ) = _decodeParams(hookParams);
        unchecked {
            return (feeMin <= feeMax) && (feeMax < SWAP_FEE_BASE)
                && (feeQuadraticMultiplier == 0 || feeMin == feeMax || feeTwapSecondsAgo != 0) && (surgeFee < SWAP_FEE_BASE)
                && (uint256(surgeFeeHalflife) * uint256(vaultSurgeThreshold0) * uint256(vaultSurgeThreshold1) != 0);
        }
    }

    /// -----------------------------------------------------------------------
    /// Hooks
    /// -----------------------------------------------------------------------

    /// @inheritdoc IDynamicFeeManager
    function getFee(address, /* sender */ PoolKey calldata /* key */ ) external pure override returns (uint24) {
        // always return 0 since the swap fee is taken in the beforeSwap hook
        return 0;
    }

    /// @inheritdoc IHooks
    function afterInitialize(
        address caller,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        int24 tick,
        bytes calldata hookData
    ) external override(BaseHook, IHooks) poolManagerOnly returns (bytes4) {
        if (caller != address(hub)) revert BunniHook__Unauthorized(); // prevents non-BunniHub contracts from initializing a pool using this hook
        PoolId id = key.toId();

        // initialize slot0
        slot0s[id] = Slot0({
            sqrtPriceX96: sqrtPriceX96,
            tick: tick,
            lastSwapTimestamp: uint32(block.timestamp),
            lastSurgeTimestamp: 0
        });

        // initialize first observation to be dated in the past
        // so that we can immediately start querying the oracle
        (uint24 twapSecondsAgo, bytes32 hookParams) = abi.decode(hookData, (uint24, bytes32));
        (,,, uint24 feeTwapSecondsAgo,,,,,) = _decodeParams(hookParams);
        (_states[id].cardinality, _states[id].cardinalityNext) = _observations[id].initialize(
            uint32(block.timestamp - FixedPointMathLib.max(twapSecondsAgo, feeTwapSecondsAgo)), tick
        );

        return BunniHook.afterInitialize.selector;
    }

    /// @inheritdoc IHooks
    function beforeAddLiquidity(address, PoolKey calldata, IPoolManager.ModifyLiquidityParams calldata, bytes calldata)
        external
        view
        override(BaseHook, IHooks)
        poolManagerOnly
        returns (bytes4)
    {
        revert BunniHook__NoAddLiquidity();
    }

    /// @inheritdoc IHooks
    function beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        external
        override(BaseHook, IHooks)
        poolManagerOnly
        nonReentrant
        returns (bytes4)
    {
        PoolId id = key.toId();
        Slot0 memory slot0 = slot0s[id];
        (uint160 sqrtPriceX96, int24 currentTick) = (slot0.sqrtPriceX96, slot0.tick);
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

        // get current tick token balances
        PoolState memory bunniState = hub.poolState(id);
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, key.tickSpacing);
        (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
            (TickMath.getSqrtRatioAtTick(roundedTick), TickMath.getSqrtRatioAtTick(nextRoundedTick));

        // decode hook params
        (
            uint24 feeMin,
            uint24 feeMax,
            uint24 feeQuadraticMultiplier,
            uint24 feeTwapSecondsAgo,
            uint24 surgeFee,
            uint16 surgeFeeHalfLife,
            uint16 surgeFeeAutostartThreshold,
            uint16 vaultSurgeThreshold0,
            uint16 vaultSurgeThreshold1
        ) = _decodeParams(bunniState.hookParams);

        // get pool token balances
        (uint256 reserveBalance0, uint256 reserveBalance1) = (
            getReservesInUnderlying(bunniState.reserve0, bunniState.vault0),
            getReservesInUnderlying(bunniState.reserve1, bunniState.vault1)
        );
        (uint256 balance0, uint256 balance1) =
            (bunniState.rawBalance0 + reserveBalance0, bunniState.rawBalance1 + reserveBalance1);
        bool shouldSurge;

        if (address(bunniState.vault0) != address(0) && address(bunniState.vault1) != address(0)) {
            // compute share prices
            VaultSharePrices memory sharePrices = VaultSharePrices({
                initialized: true,
                sharePrice0: bunniState.reserve0 == 0 ? 0 : reserveBalance0.mulDivUp(WAD, bunniState.reserve0).toUint120(),
                sharePrice1: bunniState.reserve1 == 0 ? 0 : reserveBalance1.mulDivUp(WAD, bunniState.reserve1).toUint120()
            });

            // compare with share prices at last swap to see if we need to apply the surge fee
            VaultSharePrices memory prevSharePrices = vaultSharePricesAtLastSwap[id];
            if (
                prevSharePrices.initialized
                    && (
                        dist(sharePrices.sharePrice0, prevSharePrices.sharePrice0)
                            >= prevSharePrices.sharePrice0 / vaultSurgeThreshold0
                            || dist(sharePrices.sharePrice1, prevSharePrices.sharePrice1)
                                >= prevSharePrices.sharePrice1 / vaultSurgeThreshold1
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
                vaultSharePricesAtLastSwap[id] = sharePrices;
            }
        }

        bool useTwap = bunniState.twapSecondsAgo != 0;

        int24 arithmeticMeanTick;
        int24 feeMeanTick;

        // update TWAP oracle
        // do it before we fetch the arithmeticMeanTick
        {
            (uint16 updatedIndex, uint16 updatedCardinality) = _updateOracle(id, currentTick);

            // (optional) get TWAP value
            if (useTwap) {
                // need to use TWAP
                // compute TWAP value
                arithmeticMeanTick =
                    _getTwap(id, currentTick, bunniState.twapSecondsAgo, updatedIndex, updatedCardinality);
            }

            if (feeMin != feeMax && feeQuadraticMultiplier != 0) {
                // fee calculation needs TWAP
                feeMeanTick = _getTwap(id, currentTick, feeTwapSecondsAgo, updatedIndex, updatedCardinality);
            }
        }

        // get densities
        bytes32 ldfState = bunniState.statefulLdf ? ldfStates[id] : bytes32(0);
        (
            uint256 liquidityDensityOfRoundedTickX96,
            uint256 density0RightOfRoundedTickX96,
            uint256 density1LeftOfRoundedTickX96,
            bytes32 newLdfState,
            bool shouldSurgeLDF
        ) = bunniState.liquidityDensityFunction.query(
            key, roundedTick, arithmeticMeanTick, currentTick, useTwap, bunniState.ldfParams, ldfState
        );
        shouldSurge = shouldSurge || shouldSurgeLDF;
        if (bunniState.statefulLdf) ldfStates[id] = newLdfState;

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
            currentTick: currentTick,
            roundedTickSqrtRatio: roundedTickSqrtRatio,
            nextRoundedTickSqrtRatio: nextRoundedTickSqrtRatio,
            balance0: balance0,
            balance1: balance1,
            liquidityDensityFunction: bunniState.liquidityDensityFunction,
            arithmeticMeanTick: arithmeticMeanTick,
            useTwap: useTwap,
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
                lastSurgeTimestamp = timeSinceLastSwap >= surgeFeeAutostartThreshold
                    ? slot0.lastSwapTimestamp + surgeFeeAutostartThreshold
                    : uint32(block.timestamp);
            }
        }
        slot0s[id] = Slot0({
            sqrtPriceX96: updatedSqrtPriceX96,
            tick: updatedTick,
            lastSwapTimestamp: uint32(block.timestamp),
            lastSurgeTimestamp: lastSurgeTimestamp
        });

        (Currency inputToken, Currency outputToken) =
            params.zeroForOne ? (key.currency0, key.currency1) : (key.currency1, key.currency0);

        // charge LP fee and hook fee
        // we do this by reducing the output token amount
        uint24 swapFee;
        uint256 hookFeesAmount;
        bool exactIn = params.amountSpecified >= 0;
        {
            swapFee = _getFee(
                updatedSqrtPriceX96,
                arithmeticMeanTick,
                lastSurgeTimestamp,
                feeMin,
                feeMax,
                feeQuadraticMultiplier,
                surgeFee,
                surgeFeeHalfLife
            );
            uint256 swapFeeAmount;

            if (exactIn) {
                // deduct swap fee from output
                swapFeeAmount = outputAmount.mulDivUp(swapFee, SWAP_FEE_BASE);
                outputAmount -= swapFeeAmount;
            } else {
                // increase input amount
                // need to modify fee rate to maintain the same average price as exactIn case
                // in / (out * (1 - fee)) = in * (1 + fee') / out => fee' = fee / (1 - fee)
                swapFeeAmount = inputAmount.mulDivUp(swapFee, SWAP_FEE_BASE - swapFee);
                inputAmount += swapFeeAmount;
            }

            uint96 hookFeesModifier = _hookFeesModifier;
            hookFeesAmount = swapFeeAmount.mulDivUp(hookFeesModifier, WAD);
        }

        // take input by minting claim tokens to hook
        poolManager.mint(address(this), inputToken.toId(), inputAmount);

        // call hub to handle swap
        // - pull input claim tokens from hook
        // - push output tokens to pool manager and mint claim tokens to hook
        // - update raw token balances
        if (exactIn) {
            // need to add hookFeesAmount to output so that we can get the hook fees
            hub.hookHandleSwap(key, params.zeroForOne, inputAmount, outputAmount + hookFeesAmount);
        } else {
            // need to subtract hookFeesAmount from input so that we can keep the hook fees
            hub.hookHandleSwap(key, params.zeroForOne, inputAmount - hookFeesAmount, outputAmount);
        }

        // burn output claim tokens
        poolManager.burn(address(this), outputToken.toId(), outputAmount);

        // emit swap event
        unchecked {
            emit Swap(
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
        }

        return Hooks.NO_OP_SELECTOR;
    }

    /// -----------------------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------------------

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
        unchecked {
            uint256 timeSinceLastSurge = block.timestamp - lastSurgeTimestamp;
            fee = uint24(
                uint256(surgeFee).mulWadUp(
                    uint256((-int256(timeSinceLastSurge.mulDiv(LN2_WAD, surgeFeeHalfLife))).expWad())
                )
            );
        }

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
        PoolId id,
        int24 currentTick,
        uint32 twapSecondsAgo,
        uint16 updatedIndex,
        uint16 updatedCardinality
    ) internal view returns (int24 arithmeticMeanTick) {
        (int56 tickCumulative0, int56 tickCumulative1) = _observations[id].observeDouble(
            uint32(block.timestamp), twapSecondsAgo, 0, currentTick, updatedIndex, updatedCardinality
        );
        int56 tickCumulativesDelta = tickCumulative1 - tickCumulative0;
        arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(twapSecondsAgo)));
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
            uint16 vaultSurgeThreshold1
        )
    {
        // | feeMin - 3 bytes | feeMax - 3 bytes | feeQuadraticMultiplier - 3 bytes | feeTwapSecondsAgo - 3 bytes | surgeFee - 3 bytes | surgeFeeHalfLife - 2 bytes | surgeFeeAutostartThreshold - 2 bytes | vaultSurgeThreshold0 - 2 bytes | vaultSurgeThreshold1 - 2 bytes |
        feeMin = uint24(bytes3(hookParams));
        feeMax = uint24(bytes3(hookParams << 24));
        feeQuadraticMultiplier = uint24(bytes3(hookParams << 48));
        feeTwapSecondsAgo = uint24(bytes3(hookParams << 72));
        surgeFee = uint24(bytes3(hookParams << 96));
        surgeFeeHalfLife = uint16(bytes2(hookParams << 120));
        surgeFeeAutostartThreshold = uint16(bytes2(hookParams << 136));
        vaultSurgeThreshold0 = uint16(bytes2(hookParams << 152));
        vaultSurgeThreshold1 = uint16(bytes2(hookParams << 168));
    }

    function _updateOracle(PoolId id, int24 tick) internal returns (uint16 updatedIndex, uint16 updatedCardinality) {
        ObservationState memory state = _states[id];
        (updatedIndex, updatedCardinality) = _observations[id].write(
            state.index, uint32(block.timestamp), tick, state.cardinality, state.cardinalityNext
        );
        (_states[id].index, _states[id].cardinality) = (updatedIndex, updatedCardinality);
    }
}
