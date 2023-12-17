// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {stdMath} from "forge-std/StdMath.sol";

import {Fees} from "@uniswap/v4-core/src/Fees.sol";
import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import "@uniswap/v4-core/src/libraries/SqrtPriceMath.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {SwapMath} from "@uniswap/v4-core/src/libraries/SwapMath.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
import "./lib/VaultMath.sol";
import "./interfaces/IBunniHook.sol";
import {Oracle} from "./lib/Oracle.sol";
import {Ownable} from "./lib/Ownable.sol";
import {BaseHook} from "./lib/BaseHook.sol";
import {IBunniHub} from "./interfaces/IBunniHub.sol";
import {LiquidityAmounts} from "./lib/LiquidityAmounts.sol";

/// @notice Bunni Hook
contract BunniHook is BaseHook, Ownable, IBunniHook {
    using FullMath for uint256;
    using SafeCastLib for uint256;
    using PoolIdLibrary for PoolKey;
    using FixedPointMathLib for uint256;
    using Oracle for Oracle.Observation[65535];

    uint256 internal constant Q96 = 0x1000000000000000000000000;
    uint256 internal constant SWAP_FEE_BASE = 1e6;
    uint256 internal constant SWAP_FEE_BASE_SQUARED = 1e12;

    IBunniHub internal immutable hub;

    /// @notice The list of observations for a given pool ID
    mapping(PoolId => Oracle.Observation[65535]) internal _observations;

    /// @notice The current observation array state for the given pool ID
    mapping(PoolId => ObservationState) internal _states;

    mapping(PoolId => bytes32) public ldfStates;

    /// @notice Used for computing the hook fee amount. Fee taken is `amount * swapFee / 1e6 * hookFeesModifier / 1e18`.
    uint96 internal _hookFeesModifier;

    /// @notice The recipient of collected hook fees
    address internal _hookFeesRecipient;

    /* int24 private firstTickToRemove;
    uint24 private numTicksToRemove;
    uint24 private swapFee; */
    uint256 private constant SWAP_VALS_SLOT = uint256(keccak256("SwapVals")) - 1;

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
            uint256 balance = poolManager.balanceOf(address(this), currency);
            if (balance != 0) {
                poolManager.burn(currency, balance);
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
        (, int24 tick,) = poolManager.getSlot0(id);

        return _observations[id].observe(uint32(block.timestamp), secondsAgos, tick, state.index, state.cardinality);
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
            beforeModifyPosition: true,
            afterModifyPosition: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            noOp: false,
            accessLock: true
        });
    }

    /// @inheritdoc IDynamicFeeManager
    function getFee(address, /* sender */ PoolKey calldata /* key */ )
        external
        view
        override
        returns (uint24 swapFee)
    {
        uint256 swapVals;
        uint256 swapValsSlot = SWAP_VALS_SLOT;
        assembly ("memory-safe") {
            swapVals := tload(swapValsSlot)
            swapFee := shr(232, shl(48, swapVals))
        }
    }

    /// @inheritdoc IHooks
    function afterInitialize(address caller, PoolKey calldata key, uint160, int24 tick, bytes calldata hookData)
        external
        override(BaseHook, IHooks)
        poolManagerOnly
        returns (bytes4)
    {
        if (caller != address(hub)) revert BunniHook__Unauthorized(); // prevents non-BunniHub contracts from initializing a pool using this hook
        PoolId id = key.toId();

        // initialize first observation to be dated in the past
        // so that we can immediately start querying the oracle
        (uint24 twapSecondsAgo, bytes32 hookParams) = abi.decode(hookData, (uint24, bytes32));
        (,,,, uint24 feeTwapSecondsAgo) = _decodeParams(hookParams);
        (_states[id].cardinality, _states[id].cardinalityNext) =
            _observations[id].initialize(uint32(block.timestamp - max(twapSecondsAgo, feeTwapSecondsAgo)), tick);

        return BunniHook.afterInitialize.selector;
    }

    /// @inheritdoc IHooks
    function beforeModifyPosition(
        address caller,
        PoolKey calldata key,
        IPoolManager.ModifyPositionParams calldata,
        bytes calldata hookData
    ) external override(BaseHook, IHooks) poolManagerOnly returns (bytes4) {
        if (caller != address(hub)) revert BunniHook__Unauthorized(); // prevents non-BunniHub contracts from modifying a position using this hook

        // update TWAP oracle
        bool shouldUpdateOracle = abi.decode(hookData, (bool));
        if (shouldUpdateOracle) {
            PoolId id = key.toId();
            (, int24 tick,) = poolManager.getSlot0(id);
            _updateOracle(id, tick);
        }

        return BunniHook.beforeModifyPosition.selector;
    }

    /// @inheritdoc IHooks
    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        external
        override(BaseHook, IHooks)
        poolManagerOnly
        returns (bytes4)
    {
        uint256 swapValsSlot = SWAP_VALS_SLOT;
        uint256 swapVals;
        assembly ("memory-safe") {
            swapVals := tload(swapValsSlot)
        }
        if (swapVals != 0) return bytes4(0); // swap already in progress, tell PoolManager to revert

        PoolId id = key.toId();
        (uint160 sqrtPriceX96, int24 currentTick,) = poolManager.getSlot0(id);
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
            // if the swap is invalid, do nothing and let PoolManager handle the revert
            return BunniHook.beforeSwap.selector;
        }

        // update TWAP oracle
        // do it before we fetch the arithmeticMeanTick
        (uint16 updatedIndex, uint16 updatedCardinality) = _updateOracle(id, currentTick);

        // get current tick token balances
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, key.tickSpacing);
        (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
            (TickMath.getSqrtRatioAtTick(roundedTick), TickMath.getSqrtRatioAtTick(nextRoundedTick));
        uint128 liquidity = poolManager.getLiquidity(id);
        (uint256 balance0, uint256 balance1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, liquidity, false
        );

        // get reserves and add to balance
        PoolState memory bunniState = hub.poolState(id);
        (uint256 reserve0InUnderlying, uint256 reserve1InUnderlying) = (
            getReservesInUnderlying(bunniState.reserve0, bunniState.vault0),
            getReservesInUnderlying(bunniState.reserve1, bunniState.vault1)
        );
        if (bunniState.poolCredit0Set) reserve0InUnderlying += hub.poolCredit0(id);
        if (bunniState.poolCredit1Set) reserve1InUnderlying += hub.poolCredit1(id);
        (balance0, balance1) = (balance0 + reserve0InUnderlying, balance1 + reserve1InUnderlying);

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
            uint256 totalLiquidityEstimate0 = totalDensity0X96 == 0 ? 0 : balance0.mulDiv(Q96, totalDensity0X96);
            uint256 totalLiquidityEstimate1 = totalDensity1X96 == 0 ? 0 : balance1.mulDiv(Q96, totalDensity1X96);

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

        // compute updated current tick liquidity
        // totalLiquidity could exceed uint128 so .toUint128() is used
        uint128 updatedRoundedTickLiquidity = ((totalLiquidity * liquidityDensityOfRoundedTickX96) >> 96).toUint128();

        bytes memory buffer; // buffer for storing dynamic length array of LiquidityDelta structs
        uint256 bufferLength;
        bool updatedCurrentTick;

        // update current tick liquidity if necessary
        if (
            (compoundThreshold == 0 && updatedRoundedTickLiquidity != liquidity) // always compound if threshold is 0 and there's a liquidity difference
                || _percentDelta(updatedRoundedTickLiquidity, liquidity) * uint256(compoundThreshold) >= 0.1e18 // compound if delta >= 1 / (compoundThreshold * 10)
        ) {
            // ensure we have enough reserves to satisfy the delta
            // round up updated balances to ensure that we can satisfy the delta
            (uint256 updatedCurrentTickBalance0, uint256 updatedCurrentTickBalance1) = LiquidityAmounts
                .getAmountsForLiquidity(
                sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, updatedRoundedTickLiquidity, true
            );
            if (updatedCurrentTickBalance0 <= balance0 && updatedCurrentTickBalance1 <= balance1) {
                int256 delta = int256(uint256(updatedRoundedTickLiquidity)) - int256(uint256(liquidity)); // both values are uint128 so cast is safe
                buffer = _appendLiquidityDeltaToBuffer(buffer, roundedTick, delta);
                unchecked {
                    ++bufferLength;
                }
                liquidity = updatedRoundedTickLiquidity;
                updatedCurrentTick = true;

                unchecked {
                    reserve0InUnderlying = balance0 - updatedCurrentTickBalance0;
                    reserve1InUnderlying = balance1 - updatedCurrentTickBalance1;
                }
            }
        }

        // simulate swap to see if current tick liquidity is sufficient
        uint256 amountIn;
        uint256 amountOut;
        int24 tick = currentTick;
        int24 tickNext = boundTick(params.zeroForOne ? roundedTick : nextRoundedTick, key.tickSpacing);
        int256 amountSpecifiedRemaining = params.amountSpecified;
        bool exactInput = amountSpecifiedRemaining > 0;
        uint160 sqrtPriceStartX96;
        uint160 sqrtPriceNextX96;
        uint256 feeAmount;
        while (true) {
            // compute sqrtPriceX96 and amountSpecifiedRemaining
            sqrtPriceStartX96 = sqrtPriceX96;
            sqrtPriceNextX96 = TickMath.getSqrtRatioAtTick(tickNext);
            (sqrtPriceX96, amountIn, amountOut, feeAmount) = SwapMath.computeSwapStep(
                sqrtPriceX96,
                (
                    params.zeroForOne
                        ? sqrtPriceNextX96 < params.sqrtPriceLimitX96
                        : sqrtPriceNextX96 > params.sqrtPriceLimitX96
                ) ? params.sqrtPriceLimitX96 : sqrtPriceNextX96,
                liquidity,
                params.amountSpecified,
                feeMin // use min possible fee to overestimate the number of ticks we need to add liquidity to
            );
            unchecked {
                if (exactInput) {
                    amountSpecifiedRemaining -= (amountIn + feeAmount).toInt256();
                } else {
                    amountSpecifiedRemaining += amountOut.toInt256();
                }
            }
            if (params.zeroForOne) {
                // only need to keep track of the tick if we're swapping token0 to token1
                // since otherwise there's no edge case to handle
                if (sqrtPriceX96 == sqrtPriceNextX96) {
                    unchecked {
                        tick = params.zeroForOne ? tickNext - 1 : tickNext;
                    }
                } else if (sqrtPriceX96 != sqrtPriceStartX96) {
                    tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
                }
            }

            // break if the input has been exhausted or the price limit has been reached
            // or if we have no reserves left to add to the next tick
            if (
                amountSpecifiedRemaining == 0 || sqrtPriceX96 == params.sqrtPriceLimitX96
                    || (params.zeroForOne && reserve1InUnderlying == 0) || (!params.zeroForOne && reserve0InUnderlying == 0)
            ) break;

            // current tick liquidity insufficient, add liquidity to the next tick and repeat
            // update tickNext, liquidity, and buffer
            // we will add `liquidity` to the range zeroForOne ? [tickNext, tickNext + tickSpacing) : [tickNext - tickSpacing, tickNext)
            // (tickNext here refers to the updated tickNext value)
            int24 tickLowerToAddLiquidityTo;
            // unchecked is safe since ticks are bounded by TickMath.MIN_TICK and TickMath.MAX_TICK
            unchecked {
                if (params.zeroForOne) {
                    tickNext = boundTick(tickNext - key.tickSpacing, key.tickSpacing);
                    tickLowerToAddLiquidityTo = tickNext;
                } else {
                    tickNext = boundTick(tickNext + key.tickSpacing, key.tickSpacing);
                    // if swapping token1 to token0, updatedTickNext is the tickUpper of the range to add liquidity to
                    // therefore we need to shift left by tickSpacing to get tickLower
                    tickLowerToAddLiquidityTo = tickNext - key.tickSpacing;
                }
            }

            // compute `tickNext` liquidity and store in `liquidity`
            // `totalLiquidity` could exceed uint128 so .toUint128() is used
            liquidity = (
                (
                    bunniState.liquidityDensityFunction.liquidityDensityX96(
                        key,
                        tickLowerToAddLiquidityTo,
                        arithmeticMeanTick,
                        currentTick,
                        useTwap,
                        bunniState.ldfParams,
                        ldfState
                    ) * totalLiquidity
                ) >> 96
            ).toUint128();

            // ensure we have sufficient reserves
            unchecked {
                (uint160 sqrtPriceLowerX96, uint160 sqrtPriceUpperX96) = (
                    TickMath.getSqrtRatioAtTick(tickLowerToAddLiquidityTo),
                    TickMath.getSqrtRatioAtTick(tickLowerToAddLiquidityTo + key.tickSpacing)
                );
                if (params.zeroForOne) {
                    // ensure token1 reserves are sufficient
                    uint256 amount1ToAddToLiquidity =
                        SqrtPriceMath.getAmount1Delta(sqrtPriceLowerX96, sqrtPriceUpperX96, liquidity, true);
                    if (reserve1InUnderlying < amount1ToAddToLiquidity) {
                        // insufficient reserves
                        // add as much as possible liquidity
                        liquidity = LiquidityAmounts.getLiquidityForAmount1(
                            sqrtPriceLowerX96, sqrtPriceUpperX96, reserve1InUnderlying
                        );
                        reserve1InUnderlying = 0;
                    } else {
                        // sufficient reserves
                        // deduct amount1ToAddToLiquidity from reserve1InUnderlying
                        reserve1InUnderlying -= amount1ToAddToLiquidity;
                    }
                } else {
                    // ensure token0 reserves are sufficient
                    uint256 amount0ToAddToLiquidity =
                        SqrtPriceMath.getAmount0Delta(sqrtPriceLowerX96, sqrtPriceUpperX96, liquidity, true);
                    if (reserve0InUnderlying < amount0ToAddToLiquidity) {
                        // insufficient reserves
                        // add as much as possible liquidity
                        liquidity = LiquidityAmounts.getLiquidityForAmount0(
                            sqrtPriceLowerX96, sqrtPriceUpperX96, reserve0InUnderlying
                        );
                        reserve0InUnderlying = 0;
                    } else {
                        // sufficient reserves
                        // deduct amount0ToAddToLiquidity from reserve0InUnderlying
                        reserve0InUnderlying -= amount0ToAddToLiquidity;
                    }
                }
            }

            if (liquidity != 0) {
                // buffer add liquidity to tickLowerToAddLiquidityTo
                buffer = _appendLiquidityDeltaToBuffer(
                    buffer,
                    tickLowerToAddLiquidityTo,
                    int256(uint256(liquidity)) // updatedLiquidity is uint128 so cast is safe
                );

                unchecked {
                    ++bufferLength;
                }
            }
        }

        uint24 numTicksToRemove_ = uint24(updatedCurrentTick ? bufferLength - 1 : bufferLength);

        // handle zeroForOne edge case where we end up at a tick belonging to the next roundedTick
        // this is caused by tick = params.zeroForOne ? tickNext - 1 : tickNext;
        if (
            params.zeroForOne
                && roundTickSingle(tick, key.tickSpacing) == roundedTick - int24(numTicksToRemove_ + 1) * key.tickSpacing
        ) {
            // unchecked is safe since ticks are bounded by TickMath.MIN_TICK and TickMath.MAX_TICK
            unchecked {
                tickNext = boundTick(tickNext - key.tickSpacing, key.tickSpacing);
            }

            // if swapping token1 to token0, updatedTickNext is the tickUpper of the range to add liquidity to
            // therefore we need to shift left by tickSpacing to get tickLower
            int24 tickLowerToAddLiquidityTo = tickNext;
            // totalLiquidity could exceed uint128 so .toUint128() is used
            liquidity = (
                (
                    bunniState.liquidityDensityFunction.liquidityDensityX96(
                        key,
                        tickLowerToAddLiquidityTo,
                        arithmeticMeanTick,
                        currentTick,
                        useTwap,
                        bunniState.ldfParams,
                        ldfState
                    ) * totalLiquidity
                ) >> 96
            ).toUint128();

            // ensure we have sufficient reserves
            unchecked {
                (uint160 sqrtPriceLowerX96, uint160 sqrtPriceUpperX96) = (
                    TickMath.getSqrtRatioAtTick(tickLowerToAddLiquidityTo),
                    TickMath.getSqrtRatioAtTick(tickLowerToAddLiquidityTo + key.tickSpacing)
                );
                // ensure token1 reserves are sufficient
                uint256 amount1ToAddToLiquidity =
                    SqrtPriceMath.getAmount1Delta(sqrtPriceLowerX96, sqrtPriceUpperX96, liquidity, true);
                if (reserve1InUnderlying < amount1ToAddToLiquidity) {
                    // insufficient reserves
                    // add as much as possible liquidity
                    liquidity = LiquidityAmounts.getLiquidityForAmount1(
                        sqrtPriceLowerX96, sqrtPriceUpperX96, reserve1InUnderlying
                    );
                }
            }

            if (liquidity != 0) {
                // buffer add liquidity to tickLowerToAddLiquidityTo
                buffer = _appendLiquidityDeltaToBuffer(
                    buffer,
                    tickLowerToAddLiquidityTo,
                    int256(uint256(liquidity)) // updatedLiquidity is uint128 so cast is safe
                );

                unchecked {
                    ++bufferLength;
                    ++numTicksToRemove_;
                }
            }
        }

        uint256 swapFee = _getFee(sqrtPriceX96, feeMeanTick, feeMin, feeMax, feeQuadraticMultiplier);
        assembly ("memory-safe") {
            swapVals := or(swapVals, shl(232, roundedTick))
            swapVals := or(swapVals, shl(208, numTicksToRemove_))
            swapVals := or(swapVals, shl(184, swapFee))
            tstore(swapValsSlot, swapVals)
        }

        // update dynamic fee
        poolManager.updateDynamicSwapFee(key);

        if (bufferLength != 0) {
            // call BunniHub to update liquidity
            hub.hookModifyLiquidity({
                poolKey: key,
                liquidityDeltas: abi.decode(abi.encodePacked(uint256(0x20), bufferLength, buffer), (LiquidityDelta[])) // uint256(0x20) denotes the location of the start of the array in the calldata
            });
        }
        return BunniHook.beforeSwap.selector;
    }

    /// @inheritdoc IHooks
    function afterSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata
    ) external override(BaseHook, IHooks) poolManagerOnly returns (bytes4) {
        // withdraw liquidity from inactive ticks
        uint256 swapValsSlot = SWAP_VALS_SLOT;
        int24 roundedTick;
        uint24 numTicksToRemove_;
        uint24 swapFee;

        assembly ("memory-safe") {
            let swapVals := tload(swapValsSlot)
            roundedTick := shr(232, swapVals)
            numTicksToRemove_ := shr(232, shl(24, swapVals))
            swapFee := shr(232, shl(48, swapVals))
            tstore(swapValsSlot, 0)
        }

        if (numTicksToRemove_ != 0) {
            PoolId id = key.toId();
            LiquidityDelta[] memory liquidityDeltas = new LiquidityDelta[](numTicksToRemove_);
            for (uint256 i; i < numTicksToRemove_; i++) {
                // buffer remove liquidity
                liquidityDeltas[i] = LiquidityDelta({
                    tickLower: roundedTick,
                    delta: -uint256(poolManager.getLiquidity(id, address(hub), roundedTick, roundedTick + key.tickSpacing)).toInt256(
                    )
                });

                unchecked {
                    roundedTick = boundTick(
                        params.zeroForOne ? roundedTick - key.tickSpacing : roundedTick + key.tickSpacing,
                        key.tickSpacing
                    );
                }
            }

            // call BunniHub to remove liquidity
            hub.hookModifyLiquidity({poolKey: key, liquidityDeltas: liquidityDeltas});
        }

        // charge hook fees by minting claim tokens to the hook
        uint256 hookFeesModifier_ = _hookFeesModifier;
        if (hookFeesModifier_ != 0) {
            // fee is taken in output token for exact input swaps and input token for exact output swaps
            Currency currency;
            int256 amount;
            bool exactInput = params.amountSpecified > 0;
            if (exactInput) {
                // exact input swap
                // take fee by minting output currency claim tokens
                if (params.zeroForOne) {
                    currency = key.currency1;
                    amount = -delta.amount1();
                } else {
                    currency = key.currency0;
                    amount = -delta.amount0();
                }
            } else {
                // exact output swap
                // take fee by minting input currency claim tokens
                if (params.zeroForOne) {
                    currency = key.currency0;
                    amount = delta.amount0();
                } else {
                    currency = key.currency1;
                    amount = delta.amount1();
                }
            }
            if (amount > 0) {
                uint256 hookFeeAmount = uint256(amount).mulDivDown(swapFee, SWAP_FEE_BASE).mulWadDown(hookFeesModifier_);
                if (hookFeeAmount != 0) {
                    poolManager.mint(currency, address(this), hookFeeAmount);
                }
            }
        }

        return BunniHook.afterSwap.selector;
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
            uint256(postSwapSqrtPriceX96).mulDivDown(SWAP_FEE_BASE, TickMath.getSqrtRatioAtTick(arithmeticMeanTick));
        ratio = ratio.mulDivDown(ratio, SWAP_FEE_BASE); // square the sqrtPrice ratio to get the price ratio
        uint256 delta = stdMath.delta(ratio, SWAP_FEE_BASE);
        // unchecked is safe since we're using uint256 to store the result and the return value is bounded in the range [feeMin, feeMax]
        unchecked {
            uint256 quadraticTerm = uint256(feeQuadraticMultiplier).mulDivUp(delta * delta, SWAP_FEE_BASE_SQUARED);
            return uint24(min(feeMin + quadraticTerm, feeMax));
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

    function _appendLiquidityDeltaToBuffer(bytes memory buffer, int24 tickLower, int256 liquidityDelta)
        internal
        pure
        returns (bytes memory)
    {
        return bytes.concat(buffer, abi.encode(LiquidityDelta({tickLower: tickLower, delta: liquidityDelta})));
    }

    function _percentDelta(uint256 a, uint256 b) internal pure returns (uint256 delta) {
        if (b == 0) return a != 0 ? 1e18 : 0;
        return stdMath.percentDelta(a, b);
    }
}
