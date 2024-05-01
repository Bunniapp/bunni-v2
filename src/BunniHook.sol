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

import {AmAmm} from "biddog/AmAmm.sol";

import "flood-contracts/src/interfaces/IZone.sol";
import "flood-contracts/src/interfaces/IFloodPlain.sol";
import "flood-contracts/src/interfaces/IOnChainOrders.sol";

import {IEIP712} from "permit2/src/interfaces/IEIP712.sol";

import {WETH} from "solady/tokens/WETH.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
import "./lib/VaultMath.sol";
import "./lib/Constants.sol";
import "./lib/AmAmmPayload.sol";
import "./interfaces/IBunniHook.sol";
import {Oracle} from "./lib/Oracle.sol";
import {Ownable} from "./lib/Ownable.sol";
import {BaseHook} from "./lib/BaseHook.sol";
import {IBunniHub} from "./interfaces/IBunniHub.sol";
import {BunniSwapMath} from "./lib/BunniSwapMath.sol";
import {ReentrancyGuard} from "./lib/ReentrancyGuard.sol";
import {OrderHashMemory} from "./lib/OrderHashMemory.sol";
import {LiquidityAmounts} from "./lib/LiquidityAmounts.sol";
import {AdditionalCurrencyLibrary} from "./lib/AdditionalCurrencyLib.sol";

/// @notice Bunni Hook
contract BunniHook is BaseHook, Ownable, IBunniHook, ReentrancyGuard, AmAmm {
    using SafeCastLib for *;
    using SafeTransferLib for *;
    using FixedPointMathLib for *;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using Oracle for Oracle.Observation[MAX_CARDINALITY];
    using AdditionalCurrencyLibrary for Currency;

    WETH internal immutable weth;
    IBunniHub internal immutable hub;
    address internal immutable permit2;
    IFloodPlain internal immutable floodPlain;

    /// @notice The list of observations for a given pool ID
    mapping(PoolId => Oracle.Observation[MAX_CARDINALITY]) internal _observations;

    /// @notice The current observation array state for the given pool ID
    mapping(PoolId => ObservationState) internal _states;

    mapping(PoolId id => bytes32) internal _rebalanceOrderHash;
    mapping(PoolId id => uint256) internal _rebalanceOrderDeadline;
    mapping(PoolId id => bytes32) internal _rebalanceOrderHookArgsHash;

    mapping(PoolId => VaultSharePrices) public vaultSharePricesAtLastSwap;
    mapping(PoolId => bytes32) public ldfStates;
    mapping(PoolId => Slot0) public slot0s;
    mapping(PoolId => BoolOverride) public amAmmEnabledOverride;

    BoolOverride public globalAmAmmEnabledOverride;
    IZone public floodZone;

    uint32 public immutable oracleMinInterval;

    /// @notice Used for computing the hook fee amount. Fee taken is `amount * swapFee / 1e6 * hookFeesModifier / 1e18`.
    uint96 internal _hookFeesModifier;

    /// @notice The recipient of collected hook fees
    address internal _hookFeesRecipient;

    constructor(
        IPoolManager _poolManager,
        IBunniHub hub_,
        IFloodPlain floodPlain_,
        WETH weth_,
        IZone floodZone_,
        address owner_,
        address hookFeesRecipient_,
        uint96 hookFeesModifier_,
        uint32 oracleMinInterval_
    ) BaseHook(_poolManager) {
        hub = hub_;
        floodPlain = floodPlain_;
        permit2 = address(floodPlain_.PERMIT2());
        weth = weth_;
        oracleMinInterval = oracleMinInterval_;
        floodZone = floodZone_;
        _hookFeesModifier = hookFeesModifier_;
        _hookFeesRecipient = hookFeesRecipient_;
        _initializeOwner(owner_);
        _poolManager.setOperator(address(hub_), true);

        emit SetHookFeesParams(hookFeesModifier_, hookFeesRecipient_);
    }

    /// -----------------------------------------------------------------------
    /// EIP-1271 compliance
    /// -----------------------------------------------------------------------

    /// @dev Should return whether the signature provided is valid for the provided data
    /// @param hash      Hash of the data to be signed
    /// @param signature Signature byte array associated with _data
    /// @return magicValue The bytes4 magic value 0x1626ba7e
    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        override
        returns (bytes4 magicValue)
    {
        // verify rebalance order
        PoolId id = abi.decode(signature, (PoolId));
        if (_rebalanceOrderHash[id] == hash) {
            return this.isValidSignature.selector;
        }
    }

    /// -----------------------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function increaseCardinalityNext(PoolKey calldata key, uint32 cardinalityNext)
        external
        override
        returns (uint32 cardinalityNextOld, uint32 cardinalityNextNew)
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
        returns (bytes memory)
    {
        // decode input
        (HookLockCallbackType t, bytes memory callbackData) = abi.decode(data, (HookLockCallbackType, bytes));

        if (t == HookLockCallbackType.BURN_AND_TAKE) {
            _burnAndTake(lockCaller, callbackData);
        } else if (t == HookLockCallbackType.SETTLE_AND_MINT) {
            _settleAndMint(lockCaller, callbackData);
        } else if (t == HookLockCallbackType.CLAIM_FEES) {
            _claimFees(lockCaller, callbackData);
        } else {
            revert BunniHook__InvalidLockCallbackType();
        }
        return bytes("");
    }

    function _burnAndTake(address lockCaller, bytes memory callbackData) internal {
        if (lockCaller != address(this)) revert BunniHook__Unauthorized();

        // decode data
        (Currency currency, uint256 amount) = abi.decode(callbackData, (Currency, uint256));

        // burn and take
        poolManager.burn(address(this), currency.toId(), amount);
        poolManager.take(currency, address(this), amount);
    }

    function _settleAndMint(address lockCaller, bytes memory callbackData) internal {
        if (lockCaller != address(this)) revert BunniHook__Unauthorized();

        // decode data
        Currency currency = abi.decode(callbackData, (Currency));

        // settle and mint
        uint256 paid = poolManager.settle(currency);
        poolManager.mint(address(this), currency.toId(), paid);
    }

    function _claimFees(address lockCaller, bytes memory callbackData) internal {
        if (lockCaller != owner()) revert BunniHook__Unauthorized();

        // decode data
        Currency[] memory currencyList = abi.decode(callbackData, (Currency[]));

        // claim protocol fees
        address recipient = _hookFeesRecipient;
        for (uint256 i; i < currencyList.length; i++) {
            Currency currency = currencyList[i];
            // can claim balance - am-AMM accrued fees
            uint256 balance = poolManager.balanceOf(address(this), currency.toId()) - _totalFees[currency];
            if (balance != 0) {
                poolManager.burn(address(this), currency.toId(), balance);
                poolManager.take(currency, recipient, balance);
            }
        }
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
    function setZone(IZone zone) external onlyOwner {
        floodZone = zone;
        emit SetZone(zone);
    }

    /// @inheritdoc IBunniHook
    function setHookFeesParams(uint96 newModifier, address newRecipient) external onlyOwner {
        _hookFeesModifier = newModifier;
        _hookFeesRecipient = newRecipient;

        emit SetHookFeesParams(newModifier, newRecipient);
    }

    /// @inheritdoc IBunniHook
    function setAmAmmEnabledOverride(PoolId id, BoolOverride boolOverride) external onlyOwner {
        amAmmEnabledOverride[id] = boolOverride;
        emit SetAmAmmEnabledOverride(id, boolOverride);
    }

    /// @inheritdoc IBunniHook
    function setGlobalAmAmmEnabledOverride(BoolOverride boolOverride) external onlyOwner {
        globalAmAmmEnabledOverride = boolOverride;
        emit SetGlobalAmAmmEnabledOverride(boolOverride);
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

        return _observations[id].observe(
            state.intermediateObservation,
            uint32(block.timestamp),
            secondsAgos,
            slot0.tick,
            state.index,
            state.cardinality
        );
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
            uint16 vaultSurgeThreshold1,
            uint16 rebalanceThreshold,
            uint16 rebalanceMaxSlippage,
            uint16 rebalanceTwapSecondsAgo,
            uint16 rebalanceOrderTTL,
        ) = _decodeParams(hookParams);
        unchecked {
            return (feeMin <= feeMax) && (feeMax < SWAP_FEE_BASE)
                && (feeQuadraticMultiplier == 0 || feeMin == feeMax || feeTwapSecondsAgo != 0) && (surgeFee < SWAP_FEE_BASE)
                && (uint256(surgeFeeHalflife) * uint256(vaultSurgeThreshold0) * uint256(vaultSurgeThreshold1) != 0)
                && (
                    (
                        rebalanceThreshold == 0 && rebalanceMaxSlippage == 0 && rebalanceTwapSecondsAgo == 0
                            && rebalanceOrderTTL == 0
                    )
                        || (
                            rebalanceThreshold != 0 && rebalanceMaxSlippage != 0 && rebalanceTwapSecondsAgo != 0
                                && rebalanceOrderTTL != 0
                        )
                );
        }
    }

    /// @inheritdoc IBunniHook
    function getAmAmmEnabled(PoolId id) external view override returns (bool) {
        return _amAmmEnabled(id);
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
        uint24 feeTwapSecondsAgo = uint24(bytes3(hookParams << 72));
        uint16 rebalanceTwapSecondsAgo = uint16(bytes2(hookParams << 216));
        (_states[id].intermediateObservation, _states[id].cardinality, _states[id].cardinalityNext) = _observations[id]
            .initialize(
            uint32(
                block.timestamp
                    - FixedPointMathLib.max(
                        FixedPointMathLib.max(twapSecondsAgo, feeTwapSecondsAgo), rebalanceTwapSecondsAgo
                    )
            ),
            tick
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
            uint16 vaultSurgeThreshold1,
            uint16 rebalanceThreshold,
            uint16 rebalanceMaxSlippage,
            uint16 rebalanceTwapSecondsAgo,
            uint16 rebalanceOrderTTL,
            bool amAmmEnabled
        ) = _decodeParams(bunniState.hookParams);

        // update am-AMM state
        address amAmmManager;
        uint24 amAmmSwapFee;
        bool amAmmEnableSurgeFee;
        if (amAmmEnabled) {
            bytes7 payload;
            (amAmmManager, payload) = _updateAmAmmWrite(id);
            uint24 swapFee0For1;
            uint24 swapFee1For0;
            (swapFee0For1, swapFee1For0, amAmmEnableSurgeFee) = decodeAmAmmPayload(payload);
            amAmmSwapFee = params.zeroForOne ? swapFee0For1 : swapFee1For0;
        }

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
        (Oracle.Observation memory updatedIntermediate, uint32 updatedIndex, uint32 updatedCardinality) =
            _updateOracle(id, currentTick);

        // (optional) get TWAP value
        if (useTwap) {
            // need to use TWAP
            // compute TWAP value
            arithmeticMeanTick = _getTwap(
                id, currentTick, bunniState.twapSecondsAgo, updatedIntermediate, updatedIndex, updatedCardinality
            );
        }
        if (!amAmmEnabled && feeMin != feeMax && feeQuadraticMultiplier != 0) {
            // fee calculation needs TWAP
            feeMeanTick =
                _getTwap(id, currentTick, feeTwapSecondsAgo, updatedIntermediate, updatedIndex, updatedCardinality);
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

        // charge swap fee
        uint24 swapFee;
        uint256 swapFeeAmount;
        uint256 hookFeesAmount;
        bool exactIn = params.amountSpecified >= 0;
        bool useAmAmmFee = amAmmEnabled && amAmmManager != address(0);
        if (useAmAmmFee) {
            // give swap fee to am-AMM manager
            // apply surge fee if manager enabled it
            swapFee = amAmmEnableSurgeFee
                ? uint24(
                    FixedPointMathLib.max(amAmmSwapFee, computeSurgeFee(lastSurgeTimestamp, surgeFee, surgeFeeHalfLife))
                )
                : amAmmSwapFee;

            if (exactIn) {
                swapFeeAmount = outputAmount.mulDivUp(swapFee, SWAP_FEE_BASE);
                _accrueFees(amAmmManager, outputToken, swapFeeAmount);
            } else {
                // increase input amount
                // need to modify fee rate to maintain the same average price as exactIn case
                // in / (out * (1 - fee)) = in * (1 + fee') / out => fee' = fee / (1 - fee)
                swapFeeAmount = inputAmount.mulDivUp(swapFee, SWAP_FEE_BASE - swapFee);
                _accrueFees(amAmmManager, inputToken, swapFeeAmount);
            }
        } else {
            // use default dynamic fee model
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

            if (exactIn) {
                // deduct swap fee from output
                swapFeeAmount = outputAmount.mulDivUp(swapFee, SWAP_FEE_BASE);
            } else {
                // increase input amount
                // need to modify fee rate to maintain the same average price as exactIn case
                // in / (out * (1 - fee)) = in * (1 + fee') / out => fee' = fee / (1 - fee)
                swapFeeAmount = inputAmount.mulDivUp(swapFee, SWAP_FEE_BASE - swapFee);
            }
        }

        {
            // take hook fees from swap fee
            uint96 hookFeesModifier = _hookFeesModifier;
            hookFeesAmount = swapFeeAmount.mulDivUp(hookFeesModifier, WAD);
            swapFeeAmount -= hookFeesAmount;
        }

        // modify input/output amount with fees
        if (exactIn) {
            outputAmount -= swapFeeAmount + hookFeesAmount;
        } else {
            inputAmount += swapFeeAmount + hookFeesAmount;
        }

        // take input by minting claim tokens to hook
        poolManager.mint(address(this), inputToken.toId(), inputAmount);

        // call hub to handle swap
        // - pull input claim tokens from hook
        // - push output tokens to pool manager and mint claim tokens to hook
        // - update raw token balances
        if (exactIn) {
            hub.hookHandleSwap(
                key,
                params.zeroForOne,
                inputAmount,
                // if am-AMM is used, the swap fee needs to be taken from BunniHub, else it stays in BunniHub with the LPs
                useAmAmmFee ? outputAmount + swapFeeAmount + hookFeesAmount : outputAmount + hookFeesAmount
            );
        } else {
            hub.hookHandleSwap(
                key,
                params.zeroForOne,
                // if am-AMM is not used, the swap fee needs to be sent to BunniHub to the LPs, else it stays in BunniHook with the am-AMM manager
                useAmAmmFee ? inputAmount - swapFeeAmount - hookFeesAmount : inputAmount - hookFeesAmount,
                outputAmount
            );
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

        // we should rebalance if:
        // - rebalanceThreshold != 0, i.e. rebalancing is enabled
        // - shouldSurge == true, since tokens can only go out of balance due to shifting or vault returns
        // - the deadline of the last rebalance order has passed
        if (rebalanceThreshold != 0 && shouldSurge && block.timestamp > _rebalanceOrderDeadline[id]) {
            _rebalance(
                id,
                key,
                updatedTick,
                updatedSqrtPriceX96,
                arithmeticMeanTick,
                useTwap,
                newLdfState,
                rebalanceThreshold,
                rebalanceMaxSlippage,
                rebalanceTwapSecondsAgo,
                rebalanceOrderTTL,
                updatedIntermediate,
                updatedIndex,
                updatedCardinality
            );
        }

        return Hooks.NO_OP_SELECTOR;
    }

    /// -----------------------------------------------------------------------
    /// Rebalancing functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function rebalanceOrderPreHook(RebalanceOrderHookArgs calldata hookArgs) external override nonReentrant {
        // verify call came from Flood
        if (msg.sender != address(floodPlain)) {
            revert BunniHook__Unauthorized();
        }

        // ensure args can be trusted
        if (keccak256(abi.encode(hookArgs)) != _rebalanceOrderHookArgsHash[hookArgs.key.toId()]) {
            revert BunniHook__InvalidRebalanceOrderHookArgs();
        }

        RebalanceOrderPreHookArgs calldata args = hookArgs.preHookArgs;

        // pull input tokens from BunniHub to BunniHook
        // received in the form of PoolManager claim tokens
        hub.hookHandleSwap({
            key: hookArgs.key,
            zeroForOne: hookArgs.key.currency1 == args.currency,
            inputAmount: 0,
            outputAmount: args.amount
        });

        // unwrap claim tokens
        // NOTE: tax-on-transfer tokens are not supported due to this unwrap since we need exactly args.amount tokens upon return
        poolManager.lock(
            address(this), abi.encode(HookLockCallbackType.BURN_AND_TAKE, abi.encode(args.currency, args.amount))
        );

        // ensure we have exactly args.amount tokens
        if (args.currency.balanceOfSelf() != args.amount) {
            revert BunniHook__PrehookPostConditionFailed();
        }

        // wrap native ETH input to WETH
        // we're implicitly trusting the WETH contract won't charge a fee which is OK in practice
        if (args.currency.isNative()) {
            weth.deposit{value: args.amount}();
        }
    }

    /// @inheritdoc IBunniHook
    function rebalanceOrderPostHook(RebalanceOrderHookArgs calldata hookArgs) external override nonReentrant {
        // verify call came from Flood
        if (msg.sender != address(floodPlain)) {
            revert BunniHook__Unauthorized();
        }

        // ensure args can be trusted
        if (keccak256(abi.encode(hookArgs)) != _rebalanceOrderHookArgsHash[hookArgs.key.toId()]) {
            revert BunniHook__InvalidRebalanceOrderHookArgs();
        }

        // invalidate the rebalance order hash
        // don't delete the deadline to maintain a min rebalance interval
        PoolId id = hookArgs.key.toId();
        delete _rebalanceOrderHash[id];
        delete _rebalanceOrderHookArgsHash[id];

        // surge fee should be applied after the rebalance has been executed
        // since totalLiquidity will be increased
        // no need to check surgeFeeAutostartThreshold sincewe just increased the liquidity in this tx
        // so block.timestamp is the exact time when the surge should occur
        slot0s[id].lastSwapTimestamp = uint32(block.timestamp);
        slot0s[id].lastSurgeTimestamp = uint32(block.timestamp);

        RebalanceOrderPostHookArgs calldata args = hookArgs.postHookArgs;

        uint256 orderOutputAmount;
        if (args.currency.isNative()) {
            // unwrap WETH output to native ETH
            orderOutputAmount = weth.balanceOf(address(this));
            weth.withdraw(orderOutputAmount);
        } else {
            orderOutputAmount = args.currency.balanceOfSelf();
        }

        // wrap claim tokens
        // NOTE: tax-on-transfer tokens are not supported because we need exactly orderOutputAmount tokens
        if (args.currency.isNative()) {
            address(poolManager).safeTransferETH(orderOutputAmount);
        } else {
            Currency.unwrap(args.currency).safeTransfer(address(poolManager), orderOutputAmount);
        }
        poolManager.lock(address(this), abi.encode(HookLockCallbackType.SETTLE_AND_MINT, abi.encode(args.currency)));

        // posthook should push output tokens from BunniHook to BunniHub and update pool balances
        // BunniHub receives output tokens in the form of PoolManager claim tokens
        hub.hookHandleSwap({
            key: hookArgs.key,
            zeroForOne: hookArgs.key.currency0 == args.currency,
            inputAmount: orderOutputAmount,
            outputAmount: 0
        });
    }

    function _rebalance(
        PoolId id,
        PoolKey calldata key,
        int24 updatedTick,
        uint160 updatedSqrtPriceX96,
        int24 arithmeticMeanTick,
        bool useTwap,
        bytes32 newLdfState,
        uint16 rebalanceThreshold,
        uint16 rebalanceMaxSlippage,
        uint16 rebalanceTwapSecondsAgo,
        uint16 rebalanceOrderTTL,
        Oracle.Observation memory updatedIntermediate,
        uint32 updatedIndex,
        uint32 updatedCardinality
    ) internal {
        // compute rebalance params
        (bool success, Currency inputToken, Currency outputToken, uint256 inputAmount, uint256 outputAmount) =
        _computeRebalanceParams(
            id,
            key,
            updatedTick,
            updatedSqrtPriceX96,
            arithmeticMeanTick,
            useTwap,
            newLdfState,
            rebalanceThreshold,
            rebalanceMaxSlippage,
            rebalanceTwapSecondsAgo,
            updatedIntermediate,
            updatedIndex,
            updatedCardinality
        );
        if (!success) return;

        // create rebalance order
        _createRebalanceOrder(id, key, rebalanceOrderTTL, inputToken, outputToken, inputAmount, outputAmount);
    }

    function _computeRebalanceParams(
        PoolId id,
        PoolKey calldata key,
        int24 updatedTick,
        uint160 updatedSqrtPriceX96,
        int24 arithmeticMeanTick,
        bool useTwap,
        bytes32 newLdfState,
        uint16 rebalanceThreshold,
        uint16 rebalanceMaxSlippage,
        uint16 rebalanceTwapSecondsAgo,
        Oracle.Observation memory updatedIntermediate,
        uint32 updatedIndex,
        uint32 updatedCardinality
    )
        internal
        view
        returns (bool success, Currency inputToken, Currency outputToken, uint256 inputAmount, uint256 outputAmount)
    {
        // compute the ratio (excessLiquidity / totalLiquidity)
        // excessLiquidity is the minimum amount of liquidity that can be supported by the excess tokens

        // load fresh state
        PoolState memory bunniState = hub.poolState(id);

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
        {
            (int24 roundedTick, int24 nextRoundedTick) = roundTick(updatedTick, key.tickSpacing);
            (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
                (TickMath.getSqrtRatioAtTick(roundedTick), TickMath.getSqrtRatioAtTick(nextRoundedTick));
            (
                uint256 liquidityDensityOfRoundedTickX96,
                uint256 density0RightOfRoundedTickX96,
                uint256 density1LeftOfRoundedTickX96,
                ,
            ) = bunniState.liquidityDensityFunction.query(
                key, roundedTick, arithmeticMeanTick, updatedTick, useTwap, bunniState.ldfParams, newLdfState
            );
            {
                (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts
                    .getAmountsForLiquidity(
                    updatedSqrtPriceX96,
                    roundedTickSqrtRatio,
                    nextRoundedTickSqrtRatio,
                    uint128(liquidityDensityOfRoundedTickX96),
                    false
                );
                uint256 totalDensity0X96_ = density0RightOfRoundedTickX96 + density0OfRoundedTickX96;
                uint256 totalDensity1X96_ = density1LeftOfRoundedTickX96 + density1OfRoundedTickX96;
                uint256 totalLiquidityEstimate0 =
                    totalDensity0X96_ == 0 ? 0 : balance0.fullMulDiv(Q96, totalDensity0X96_);
                uint256 totalLiquidityEstimate1 =
                    totalDensity1X96_ == 0 ? 0 : balance1.fullMulDiv(Q96, totalDensity1X96_);
                if (totalLiquidityEstimate0 == 0) {
                    totalLiquidity = totalLiquidityEstimate1;
                } else if (totalLiquidityEstimate1 == 0) {
                    totalLiquidity = totalLiquidityEstimate0;
                } else {
                    totalLiquidity = FixedPointMathLib.min(totalLiquidityEstimate0, totalLiquidityEstimate1);
                }
            }

            // compute active balance, which is the balance implied by the total liquidity & the LDF
            {
                uint128 updatedRoundedTickLiquidity =
                    ((totalLiquidity * liquidityDensityOfRoundedTickX96) >> 96).toUint128();
                (currentActiveBalance0, currentActiveBalance1) = LiquidityAmounts.getAmountsForLiquidity(
                    updatedSqrtPriceX96,
                    roundedTickSqrtRatio,
                    nextRoundedTickSqrtRatio,
                    updatedRoundedTickLiquidity,
                    false
                );
                (currentActiveBalance0, currentActiveBalance1) = (
                    currentActiveBalance0 + ((density0RightOfRoundedTickX96 * totalLiquidity) >> 96),
                    currentActiveBalance1 + ((density1LeftOfRoundedTickX96 * totalLiquidity) >> 96)
                );
            }

            // compute excess liquidity if there's any
            (int24 minUsableTick, int24 maxUsableTick) =
                (TickMath.minUsableTick(key.tickSpacing), TickMath.maxUsableTick(key.tickSpacing) - key.tickSpacing);
            excessLiquidity0 = balance0 > currentActiveBalance0
                ? (balance0 - currentActiveBalance0).divWad(
                    bunniState.liquidityDensityFunction.cumulativeAmount0(
                        key, minUsableTick, WAD, arithmeticMeanTick, updatedTick, useTwap, bunniState.ldfParams, newLdfState
                    )
                )
                : 0;
            excessLiquidity1 = balance1 > currentActiveBalance1
                ? (balance1 - currentActiveBalance1).divWad(
                    bunniState.liquidityDensityFunction.cumulativeAmount1(
                        key, maxUsableTick, WAD, arithmeticMeanTick, updatedTick, useTwap, bunniState.ldfParams, newLdfState
                    )
                )
                : 0;
        }

        // should rebalance if excessLiquidity / totalLiquidity >= 1 / rebalanceThreshold
        bool shouldRebalance0 = excessLiquidity0 != 0 && excessLiquidity0 >= totalLiquidity / rebalanceThreshold;
        bool shouldRebalance1 = excessLiquidity1 != 0 && excessLiquidity1 >= totalLiquidity / rebalanceThreshold;
        if (!shouldRebalance0 && !shouldRebalance1) return (false, inputToken, outputToken, inputAmount, outputAmount);

        console2.log("balance0", balance0);
        console2.log("balance1", balance1);
        console2.log("currentActiveBalance0", currentActiveBalance0);
        console2.log("currentActiveBalance1", currentActiveBalance1);
        console2.log("excessLiquidity0", excessLiquidity0);
        console2.log("excessLiquidity1", excessLiquidity1);
        console2.log("totalLiquidity", totalLiquidity);

        // compute density of token0 and token1 after excess liquidity has been rebalanced
        // this is done by querying the LDF using a TWAP as the spot price to prevent manipulation
        uint256 totalDensity0X96;
        uint256 totalDensity1X96;
        {
            int24 rebalanceSpotPriceTick = _getTwap(
                id, updatedTick, rebalanceTwapSecondsAgo, updatedIntermediate, updatedIndex, updatedCardinality
            );
            uint160 rebalanceSpotPriceSqrtRatioX96 = TickMath.getSqrtRatioAtTick(rebalanceSpotPriceTick);
            (int24 roundedTick, int24 nextRoundedTick) = roundTick(rebalanceSpotPriceTick, key.tickSpacing);
            (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
                (TickMath.getSqrtRatioAtTick(roundedTick), TickMath.getSqrtRatioAtTick(nextRoundedTick));
            (
                uint256 liquidityDensityOfRoundedTickX96,
                uint256 density0RightOfRoundedTickX96,
                uint256 density1LeftOfRoundedTickX96,
                ,
            ) = bunniState.liquidityDensityFunction.query(
                key, roundedTick, arithmeticMeanTick, rebalanceSpotPriceTick, useTwap, bunniState.ldfParams, newLdfState
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
            if (excessLiquidity0 > excessLiquidity1) {
                willRebalanceToken0 = true;
            } else {
                willRebalanceToken0 = false;
            }
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

        console2.log("targetAmount0", targetAmount0);
        console2.log("targetAmount1", targetAmount1);

        // determin input & output
        if (willRebalanceToken0) {
            (inputToken, outputToken) = (key.currency0, key.currency1);
            if (balance0 - currentActiveBalance0 < targetAmount0) {
                return (false, inputToken, outputToken, inputAmount, outputAmount);
            } // should never happen
            inputAmount = balance0 - currentActiveBalance0 - targetAmount0;
            outputAmount = targetAmount1.mulDivUp(1e5 - rebalanceMaxSlippage, 1e5);
        } else {
            (inputToken, outputToken) = (key.currency1, key.currency0);
            if (balance1 - currentActiveBalance1 < targetAmount1) {
                return (false, inputToken, outputToken, inputAmount, outputAmount);
            } // should never happen
            inputAmount = balance1 - currentActiveBalance1 - targetAmount1;
            outputAmount = targetAmount0.mulDivUp(1e5 - rebalanceMaxSlippage, 1e5);
        }

        success = true;
    }

    function _createRebalanceOrder(
        PoolId id,
        PoolKey calldata key,
        uint16 rebalanceOrderTTL,
        Currency inputToken,
        Currency outputToken,
        uint256 inputAmount,
        uint256 outputAmount
    ) internal {
        // create Flood order
        ERC20 inputERC20Token = inputToken.isNative() ? weth : ERC20(Currency.unwrap(inputToken));
        ERC20 outputERC20Token = outputToken.isNative() ? weth : ERC20(Currency.unwrap(outputToken));
        IFloodPlain.Item[] memory offer = new IFloodPlain.Item[](1);
        offer[0] = IFloodPlain.Item({token: address(inputERC20Token), amount: inputAmount});
        IFloodPlain.Item memory consideration =
            IFloodPlain.Item({token: address(outputERC20Token), amount: outputAmount});

        RebalanceOrderHookArgs memory hookArgs = RebalanceOrderHookArgs({
            key: key,
            preHookArgs: RebalanceOrderPreHookArgs({currency: inputToken, amount: inputAmount}),
            postHookArgs: RebalanceOrderPostHookArgs({currency: outputToken})
        });

        // prehook should pull input tokens from BunniHub to BunniHook and update pool balances
        IFloodPlain.Hook[] memory preHooks = new IFloodPlain.Hook[](1);
        preHooks[0] =
            IFloodPlain.Hook({target: address(this), data: abi.encodeCall(this.rebalanceOrderPreHook, (hookArgs))});

        // posthook should push output tokens from BunniHook to BunniHub and update pool balances
        IFloodPlain.Hook[] memory postHooks = new IFloodPlain.Hook[](1);
        postHooks[0] =
            IFloodPlain.Hook({target: address(this), data: abi.encodeCall(this.rebalanceOrderPostHook, (hookArgs))});

        IFloodPlain.Order memory order = IFloodPlain.Order({
            offerer: address(this),
            zone: address(floodZone),
            recipient: address(this),
            offer: offer,
            consideration: consideration,
            deadline: block.timestamp + rebalanceOrderTTL,
            nonce: block.number,
            preHooks: preHooks,
            postHooks: postHooks
        });

        // record order for verification later
        _rebalanceOrderHash[id] = _newOrderHash(order);
        _rebalanceOrderDeadline[id] = order.deadline;
        _rebalanceOrderHookArgsHash[id] = keccak256(abi.encode(hookArgs));

        // approve input token to permit2
        if (inputERC20Token.allowance(address(this), permit2) < inputAmount) {
            address(inputERC20Token).safeApproveWithRetry(permit2, type(uint256).max);
        }

        // etch order so fillers can pick it up
        // use PoolId as signature to enable isValidSignature() to find the correct order hash
        IOnChainOrders(address(floodPlain)).etchOrder(
            IFloodPlain.SignedOrder({order: order, signature: abi.encode(id)})
        );
    }

    /// -----------------------------------------------------------------------
    /// AmAmm support
    /// -----------------------------------------------------------------------

    /// @dev precedence is poolOverride > globalOverride > poolEnabled
    function _amAmmEnabled(PoolId id) internal view virtual override returns (bool) {
        BoolOverride poolOverride = amAmmEnabledOverride[id];

        if (poolOverride != BoolOverride.UNSET) return poolOverride == BoolOverride.TRUE;

        BoolOverride globalOverride = globalAmAmmEnabledOverride;

        if (globalOverride != BoolOverride.UNSET) return globalOverride == BoolOverride.TRUE;

        bytes32 hookParams = hub.hookParams(id);
        bool poolEnabled = uint8(bytes1(hookParams << 248)) != 0;
        return poolEnabled;
    }

    function _payloadIsValid(PoolId id, bytes7 payload) internal view virtual override returns (bool) {
        // use feeMax from hookParams
        bytes32 hookParams = hub.hookParams(id);
        uint24 maxSwapFee = uint24(bytes3(hookParams << 24));

        // payload is valid if swapFee0For1 and swapFee1For0 are at most maxSwapFee
        (uint24 swapFee0For1, uint24 swapFee1For0,) = decodeAmAmmPayload(payload);
        return swapFee0For1 <= maxSwapFee && swapFee1For0 <= maxSwapFee;
    }

    function _burnBidToken(PoolId id, uint256 amount) internal virtual override {
        hub.bunniTokenOfPool(id).burn(amount);
    }

    function _pullBidToken(PoolId id, address from, uint256 amount) internal virtual override {
        hub.bunniTokenOfPool(id).transferFrom(from, address(this), amount);
    }

    function _pushBidToken(PoolId id, address to, uint256 amount) internal virtual override {
        hub.bunniTokenOfPool(id).transfer(to, amount);
    }

    function _transferFeeToken(Currency currency, address to, uint256 amount) internal virtual override {
        poolManager.transfer(to, currency.toId(), amount);
    }

    /// -----------------------------------------------------------------------
    /// Utility functions
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
        PoolId id,
        int24 currentTick,
        uint32 twapSecondsAgo,
        Oracle.Observation memory updatedIntermediate,
        uint32 updatedIndex,
        uint32 updatedCardinality
    ) internal view returns (int24 arithmeticMeanTick) {
        (int56 tickCumulative0, int56 tickCumulative1) = _observations[id].observeDouble(
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

    function _updateOracle(PoolId id, int24 tick)
        internal
        returns (Oracle.Observation memory updatedIntermediate, uint32 updatedIndex, uint32 updatedCardinality)
    {
        ObservationState memory state = _states[id];
        (updatedIntermediate, updatedIndex, updatedCardinality) = _observations[id].write(
            state.intermediateObservation,
            state.index,
            uint32(block.timestamp),
            tick,
            state.cardinality,
            state.cardinalityNext,
            oracleMinInterval
        );
        (_states[id].intermediateObservation, _states[id].index, _states[id].cardinality) =
            (updatedIntermediate, updatedIndex, updatedCardinality);
    }

    /// @dev The hash that Permit2 uses when verifying the order's signature.
    /// See https://github.com/Uniswap/permit2/blob/cc56ad0f3439c502c246fc5cfcc3db92bb8b7219/src/SignatureTransfer.sol#L65
    /// Always calls permit2 for the domain separator to maintain cross-chain replay protection in the event of a fork
    function _newOrderHash(IFloodPlain.Order memory order) internal view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                IEIP712(permit2).DOMAIN_SEPARATOR(),
                OrderHashMemory.hashAsWitness(order, address(floodPlain))
            )
        );
    }
}
