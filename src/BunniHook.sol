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

import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";

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
import {LiquidityAmounts} from "./lib/LiquidityAmounts.sol";
import {AdditionalCurrencyLibrary} from "./lib/AdditionalCurrencyLib.sol";

/// @notice Bunni Hook
contract BunniHook is BaseHook, Ownable, IBunniHook {
    using SafeCastLib for uint256;
    using PoolIdLibrary for PoolKey;
    using SafeTransferLib for address;
    using CurrencyLibrary for Currency;
    using FixedPointMathLib for uint256;
    using Oracle for Oracle.Observation[65535];
    using AdditionalCurrencyLibrary for Currency;

    IBunniHub internal immutable hub;

    /// @notice The list of observations for a given pool ID
    mapping(PoolId => Oracle.Observation[65535]) internal _observations;

    /// @notice The current observation array state for the given pool ID
    mapping(PoolId => ObservationState) internal _states;

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
    function lockAcquired(address, /* lockCaller */ bytes calldata data)
        external
        override
        poolManagerOnly
        returns (bytes memory)
    {
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
    }

    /// -----------------------------------------------------------------------
    /// BunniHub functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function updateOracleAndObserve(PoolId id, int24 tick, uint24 twapSecondsAgo)
        external
        override
        returns (int24 arithmeticMeanTick)
    {
        if (msg.sender != address(hub)) revert BunniHook__Unauthorized();

        // update TWAP oracle
        (uint16 updatedIndex, uint16 updatedCardinality) = _updateOracle(id, tick);

        // observe if needed
        if (twapSecondsAgo != 0) {
            return _getTwap(id, tick, twapSecondsAgo, updatedIndex, updatedCardinality);
        }
        return 0;
    }

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
        (, uint24 feeMin, uint24 feeMax, uint24 feeQuadraticMultiplier, uint24 feeTwapSecondsAgo) =
            _decodeParams(hookParams);
        return (feeMin <= feeMax) && (feeMax <= SWAP_FEE_BASE)
            && (feeQuadraticMultiplier == 0 || feeMin == feeMax || feeTwapSecondsAgo != 0);
    }

    /// -----------------------------------------------------------------------
    /// Hooks
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBaseHook
    function getHooksCalls() public pure override(BaseHook, IBaseHook) returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: true,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            noOp: true,
            accessLock: true
        });
    }

    /// @inheritdoc IDynamicFeeManager
    function getFee(address, /* sender */ PoolKey calldata /* key */ ) external pure override returns (uint24) {
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
        slot0s[id] = Slot0({sqrtPriceX96: sqrtPriceX96, tick: tick});

        // initialize first observation to be dated in the past
        // so that we can immediately start querying the oracle
        (uint24 twapSecondsAgo, bytes32 hookParams) = abi.decode(hookData, (uint24, bytes32));
        (,,,, uint24 feeTwapSecondsAgo) = _decodeParams(hookParams);
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
    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        external
        override(BaseHook, IHooks)
        poolManagerOnly
        returns (bytes4)
    {
        PoolId id = key.toId();
        Slot0 memory slot0 = slot0s[id];
        (uint160 sqrtPriceX96, int24 currentTick) = (slot0.sqrtPriceX96, slot0.tick);
        console2.log("sqrtPriceX96", sqrtPriceX96);
        console2.log("currentTick", currentTick);
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

        // update TWAP oracle
        // do it before we fetch the arithmeticMeanTick
        (uint16 updatedIndex, uint16 updatedCardinality) = _updateOracle(id, currentTick);

        // get current tick token balances
        PoolState memory bunniState = hub.poolState(id);
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, key.tickSpacing);
        (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
            (TickMath.getSqrtRatioAtTick(roundedTick), TickMath.getSqrtRatioAtTick(nextRoundedTick));

        // get reserves and add to balance
        (uint256 reserve0InUnderlying, uint256 reserve1InUnderlying) = (
            getReservesInUnderlying(bunniState.reserve0, bunniState.vault0),
            getReservesInUnderlying(bunniState.reserve1, bunniState.vault1)
        );
        if (bunniState.poolCredit0Set) reserve0InUnderlying += hub.poolCredit0(id);
        if (bunniState.poolCredit1Set) reserve1InUnderlying += hub.poolCredit1(id);
        (uint256 balance0, uint256 balance1) =
            (bunniState.rawBalance0 + reserve0InUnderlying, bunniState.rawBalance1 + reserve1InUnderlying);

        // (optional) get TWAP value
        int24 arithmeticMeanTick;
        bool useTwap = bunniState.twapSecondsAgo != 0;
        if (useTwap) {
            // need to use TWAP
            // compute TWAP value
            arithmeticMeanTick = _getTwap(id, currentTick, bunniState.twapSecondsAgo, updatedIndex, updatedCardinality);
        }
        (uint8 compoundThreshold, uint24 feeMin, uint24 feeMax, uint24 feeQuadraticMultiplier, uint24 feeTwapSecondsAgo)
        = _decodeParams(bunniState.hookParams);
        int24 feeMeanTick;
        if (feeMin != feeMax && feeQuadraticMultiplier != 0) {
            // fee calculation needs TWAP
            feeMeanTick = _getTwap(id, currentTick, feeTwapSecondsAgo, updatedIndex, updatedCardinality);
        }

        // get densities
        bytes32 ldfState = bunniState.statefulLdf ? ldfStates[id] : bytes32(0);
        (
            uint256 liquidityDensityOfRoundedTickX96,
            uint256 density0RightOfRoundedTickX96,
            uint256 density1LeftOfRoundedTickX96,
            bytes32 newLdfState
        ) = bunniState.liquidityDensityFunction.query(
            key, roundedTick, arithmeticMeanTick, currentTick, useTwap, bunniState.ldfParams, ldfState
        );
        if (bunniState.statefulLdf) ldfStates[id] = newLdfState;
        (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96,
            roundedTickSqrtRatio,
            nextRoundedTickSqrtRatio,
            uint128(liquidityDensityOfRoundedTickX96),
            false
        );

        // compute total liquidity
        uint256 totalLiquidity;
        {
            uint256 totalDensity0X96 = density0RightOfRoundedTickX96 + density0OfRoundedTickX96;
            uint256 totalDensity1X96 = density1LeftOfRoundedTickX96 + density1OfRoundedTickX96;
            uint256 totalLiquidityEstimate0 = totalDensity0X96 == 0 ? 0 : balance0.fullMulDiv(Q96, totalDensity0X96);
            uint256 totalLiquidityEstimate1 = totalDensity1X96 == 0 ? 0 : balance1.fullMulDiv(Q96, totalDensity1X96);

            // Strategy: If one of the two liquidity estimates is 0, use the other one;
            // if both are non-zero, use the average of the two.
            // This is because if we simply used max(), shifting the LDF does not change the
            // current tick liquidity (at least for exponential LDFs) making the shifting kind of
            // useless, while using min() can lead to underutilization of the reserves we have.
            // Taking the average gives us a middle ground.
            if (totalLiquidityEstimate0 == 0) {
                totalLiquidity = totalLiquidityEstimate1;
            } else if (totalLiquidityEstimate1 == 0) {
                totalLiquidity = totalLiquidityEstimate0;
            } else {
                totalLiquidity = (totalLiquidityEstimate0 + totalLiquidityEstimate1) / 2;
            }
        }

        // compute swap result
        (
            uint160 updatedSqrtPriceX96,
            int24 updatedTick,
            uint256 inputAmount,
            uint256 outputAmount,
            uint256 updatedRoundedTickBalance0,
            uint256 updatedRoundedTickBalance1
        ) = BunniSwapMath.computeSwap({
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

        // update slot0
        slot0s[id] = Slot0({sqrtPriceX96: updatedSqrtPriceX96, tick: updatedTick});

        (Currency inputToken, Currency outputToken) =
            params.zeroForOne ? (key.currency0, key.currency1) : (key.currency1, key.currency0);

        // clear pool credits of hub
        if (bunniState.poolCredit0Set || bunniState.poolCredit1Set) {
            PoolKey[] memory keys = new PoolKey[](1);
            keys[0] = key;
            hub.clearPoolCredits(keys);
        }

        // take input tokens from pool manager
        // swapper will have to pay this debt to pool manager (since we're using access lock)
        uint256 inputPoolCreditAmount;
        uint256 poolManagerBalance = poolManager.reservesOf(inputToken);
        if (poolManagerBalance >= inputAmount) {
            // pool manager has enough balance for us to take
            poolManager.take(inputToken, address(this), inputAmount);
        } else {
            // pool manager doesn't have enough balance for us to take
            // mint difference as pool credits
            if (poolManagerBalance != 0) {
                poolManager.take(inputToken, address(this), poolManagerBalance);
            }
            inputPoolCreditAmount = inputAmount - poolManagerBalance;
            poolManager.mint(address(this), inputToken.toId(), inputPoolCreditAmount);

            // update inputAmount so hub.hookHandleSwap() pulls the correct amount of input tokens
            inputAmount = poolManagerBalance;
        }

        // input token approval
        if (inputAmount != 0) {
            inputToken.safeApprove(address(hub), inputAmount);
        }

        // call hub to handle swap
        // - pull input tokens from hook
        // - push output tokens to pool manager
        // - update raw token balances
        hub.hookHandleSwap{value: inputToken.isNative() ? inputAmount : 0}(
            key,
            params.zeroForOne,
            inputAmount,
            inputPoolCreditAmount,
            outputAmount,
            updatedRoundedTickBalance0,
            updatedRoundedTickBalance1
        );

        // settle output tokens with pool manager
        poolManager.settle(outputToken);

        return Hooks.NO_OP_SELECTOR;
    }

    /// -----------------------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------------------

    function _getFee(
        uint160 postSwapSqrtPriceX96,
        int24 arithmeticMeanTick,
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier
    ) internal pure returns (uint24) {
        // special case for fixed fee pools
        if (feeQuadraticMultiplier == 0 || feeMin == feeMax) return feeMin;

        uint256 ratio =
            uint256(postSwapSqrtPriceX96).mulDiv(SWAP_FEE_BASE, TickMath.getSqrtRatioAtTick(arithmeticMeanTick));
        ratio = ratio.mulDiv(ratio, SWAP_FEE_BASE); // square the sqrtPrice ratio to get the price ratio
        uint256 delta = dist(ratio, SWAP_FEE_BASE);
        // unchecked is safe since we're using uint256 to store the result and the return value is bounded in the range [feeMin, feeMax]
        unchecked {
            uint256 quadraticTerm = uint256(feeQuadraticMultiplier).mulDivUp(delta * delta, SWAP_FEE_BASE_SQUARED);
            return uint24(FixedPointMathLib.min(feeMin + quadraticTerm, feeMax));
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

    function _decodeParams(bytes32 hookParams)
        internal
        pure
        returns (
            uint8 compoundThreshold,
            uint24 feeMin,
            uint24 feeMax,
            uint24 feeQuadraticMultiplier,
            uint24 feeTwapSecondsAgo
        )
    {
        // | compoundThreshold - 1 byte | feeMin - 3 bytes | feeMax - 3 bytes | feeQuadraticMultiplier - 3 bytes | feeTwapSecondsAgo - 3 bytes |
        compoundThreshold = uint8(bytes1(hookParams));
        feeMin = uint24(bytes3(hookParams << 8));
        feeMax = uint24(bytes3(hookParams << 32));
        feeQuadraticMultiplier = uint24(bytes3(hookParams << 56));
        feeTwapSecondsAgo = uint24(bytes3(hookParams << 80));
    }

    function _updateOracle(PoolId id, int24 tick) internal returns (uint16 updatedIndex, uint16 updatedCardinality) {
        ObservationState memory state = _states[id];
        (updatedIndex, updatedCardinality) = _observations[id].write(
            state.index, uint32(block.timestamp), tick, state.cardinality, state.cardinalityNext
        );
        (_states[id].index, _states[id].cardinality) = (updatedIndex, updatedCardinality);
    }
}
