// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {stdMath} from "forge-std/StdMath.sol";

import {Fees} from "@uniswap/v4-core/src/Fees.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/src/libraries/FullMath.sol";
import {SwapMath} from "@uniswap/v4-core/src/libraries/SwapMath.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/src/types/BalanceDelta.sol";

import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
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
    using BalanceDeltaLibrary for BalanceDelta;
    using Oracle for Oracle.Observation[65535];

    uint256 internal constant Q96 = 0x1000000000000000000000000;

    /// @inheritdoc IBunniHook
    IBunniHub public immutable override hub;

    /// @notice The list of observations for a given pool ID
    mapping(PoolId => Oracle.Observation[65535]) internal _observations;

    /// @notice The current observation array state for the given pool ID
    mapping(PoolId => ObservationState) internal _states;

    /// @inheritdoc IBunniHook
    uint24 public override hookFees;

    /// @inheritdoc IBunniHook
    address public override hookFeesRecipient;
    /* int24 private firstTickToRemove;
    uint24 private numTicksToRemove;
    uint24 private swapFee; */
    uint256 private constant SWAP_VALS_SLOT = uint256(keccak256("SwapVals")) - 1;

    constructor(IPoolManager _poolManager, IBunniHub hub_, address owner_, address hookFeesRecipient_, uint24 hookFees_)
        BaseHook(_poolManager)
    {
        hub = hub_;
        hookFees = hookFees_;
        hookFeesRecipient = hookFeesRecipient_;
        _initializeOwner(owner_);

        emit SetHookFees(hookFees_);
        emit SetHookFeesRecipient(hookFeesRecipient_);
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
        PoolId id = PoolId.wrap(keccak256(abi.encode(key)));

        ObservationState storage state = _states[id];

        cardinalityNextOld = state.cardinalityNext;
        cardinalityNextNew = _observations[id].grow(cardinalityNextOld, cardinalityNext);
        state.cardinalityNext = cardinalityNextNew;
    }

    /// @inheritdoc IBunniHook
    function collectHookFees(Currency[] calldata currencyList) external override {
        address recipient = hookFeesRecipient;
        for (uint256 i; i < currencyList.length; i++) {
            // setting `amount` to 0 claims all accrued fees
            Fees(address(poolManager)).collectHookFees(recipient, currencyList[i], 0);
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
        if (msg.sender != address(hub)) revert BunniHook__NotBunniHub();

        // update TWAP oracle
        (uint16 updatedIndex, uint16 updatedCardinality) = _observations[id].write(
            _states[id].index, uint32(block.timestamp), tick, _states[id].cardinality, _states[id].cardinalityNext
        );
        (_states[id].index, _states[id].cardinality) = (updatedIndex, updatedCardinality);

        // observe if needed
        if (twapSecondsAgo != 0) {
            return _getTwap(id, tick, twapSecondsAgo, updatedIndex, updatedCardinality);
        }
        return 0;
    }

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function setHookFees(uint24 newFee) external onlyOwner {
        hookFees = newFee;
        emit SetHookFees(newFee);
    }

    /// @inheritdoc IBunniHook
    function setHookFeesRecipient(address newRecipient) external onlyOwner {
        hookFeesRecipient = newRecipient;
        emit SetHookFeesRecipient(newRecipient);
    }

    /// -----------------------------------------------------------------------
    /// View functions
    /// -----------------------------------------------------------------------

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
        (, int24 tick,,) = poolManager.getSlot0(id);

        return _observations[id].observe(uint32(block.timestamp), secondsAgos, tick, state.index, state.cardinality);
    }

    /// @inheritdoc IBunniHook
    function isValidParams(bytes32 hookParams) external pure override returns (bool) {
        (, uint24 feeMin, uint24 feeMax, uint24 feeQuadraticMultiplier, uint24 feeTwapSecondsAgo) =
            _decodeParams(hookParams);
        return (feeMin <= feeMax) && (feeMax <= 1e6)
            && (feeQuadraticMultiplier == 0 || feeMin == feeMax || feeTwapSecondsAgo != 0);
    }

    /// -----------------------------------------------------------------------
    /// Hooks
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBaseHook
    function getHooksCalls() public pure override(BaseHook, IBaseHook) returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: true,
            beforeModifyPosition: true,
            afterModifyPosition: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false
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
        assembly {
            swapVals := tload(swapValsSlot)
            swapFee := shr(232, shl(48, swapVals))
        }
    }

    /// @inheritdoc IHookFeeManager
    function getHookFees(PoolKey calldata /* key */ ) external view override returns (uint24) {
        return hookFees;
    }

    /// @inheritdoc IHooks
    function afterInitialize(address caller, PoolKey calldata key, uint160, int24, bytes calldata)
        external
        override(BaseHook, IHooks)
        poolManagerOnly
        returns (bytes4)
    {
        if (caller != address(hub)) revert BunniHook__NotBunniHub(); // prevents non-BunniHub contracts from initializing a pool using this hook
        PoolId id = key.toId();
        (, int24 tick,,) = poolManager.getSlot0(id);
        (_states[id].cardinality, _states[id].cardinalityNext) =
            _observations[id].initialize(uint32(block.timestamp), tick);
        return BunniHook.afterInitialize.selector;
    }

    /// @inheritdoc IHooks
    function beforeModifyPosition(
        address caller,
        PoolKey calldata, /* key */
        IPoolManager.ModifyPositionParams calldata,
        bytes calldata
    ) external view override(BaseHook, IHooks) poolManagerOnly returns (bytes4) {
        if (caller != address(hub)) revert BunniHook__NotBunniHub(); // prevents non-BunniHub contracts from modifying a position using this hook
        // Note: we don't need to update the oracle here because updateOracle() is called by BunniHub.deposit()
        return BunniHook.beforeModifyPosition.selector;
    }

    /// @inheritdoc IHooks
    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        external
        override(BaseHook, IHooks)
        poolManagerOnly
        returns (bytes4)
    {
        _beforeSwapUpdatePool(key, params);
        return BunniHook.beforeSwap.selector;
    }

    /// @inheritdoc IHooks
    function afterSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta,
        bytes calldata
    ) external override(BaseHook, IHooks) poolManagerOnly returns (bytes4) {
        // withdraw liquidity from inactive ticks
        uint256 swapValsSlot = SWAP_VALS_SLOT;
        int24 roundedTick;
        uint24 numTicksToRemove_;

        assembly {
            let swapVals := tload(swapValsSlot)
            roundedTick := shr(232, swapVals)
            numTicksToRemove_ := shr(232, shl(24, swapVals))
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

        return BunniHook.afterSwap.selector;
    }

    /// -----------------------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------------------

    function _beforeSwapUpdatePool(PoolKey calldata key, IPoolManager.SwapParams calldata params) private {
        uint256 swapValsSlot = SWAP_VALS_SLOT;
        uint256 swapVals;
        assembly {
            swapVals := tload(swapValsSlot)
        }
        if (swapVals != 0) revert BunniHook__SwapAlreadyInProgress();

        PoolId id = key.toId();
        (uint160 sqrtPriceX96, int24 currentTick,,) = poolManager.getSlot0(id);
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
            return;
        }

        // update TWAP oracle
        // do it before we fetch the arithmeticMeanTick
        (uint16 updatedIndex, uint16 updatedCardinality) = _observations[id].write(
            _states[id].index,
            uint32(block.timestamp),
            currentTick,
            _states[id].cardinality,
            _states[id].cardinalityNext
        );
        (_states[id].index, _states[id].cardinality) = (updatedIndex, updatedCardinality);

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
        (balance0, balance1) = (balance0 + bunniState.reserve0, balance1 + bunniState.reserve1);

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
        (
            uint256 liquidityDensityOfRoundedTickX96,
            uint256 density0RightOfRoundedTickX96,
            uint256 density1LeftOfRoundedTickX96
        ) = bunniState.liquidityDensityFunction.query(
            roundedTick, arithmeticMeanTick, key.tickSpacing, useTwap, bunniState.ldfParams
        );
        (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96,
            roundedTickSqrtRatio,
            nextRoundedTickSqrtRatio,
            uint128(liquidityDensityOfRoundedTickX96),
            false
        );

        // compute total liquidity
        uint256 totalLiquidity = max(
            balance0.mulDiv(Q96, density0RightOfRoundedTickX96 + density0OfRoundedTickX96),
            balance1.mulDiv(Q96, density1LeftOfRoundedTickX96 + density1OfRoundedTickX96)
        );

        // compute updated current tick liquidity
        // totalLiquidity could exceed uint128 so .toUint128() is used
        uint128 updatedRoundedTickLiquidity = ((totalLiquidity * liquidityDensityOfRoundedTickX96) >> 96).toUint128();

        bytes memory buffer; // buffer for storing dynamic length array of LiquidityDelta structs
        uint256 bufferLength;
        bool updatedCurrentTick;

        // update current tick liquidity if necessary
        if (
            (compoundThreshold == 0 && updatedRoundedTickLiquidity != liquidity) // always compound if threshold is 0 and there's a liquidity difference
                || stdMath.percentDelta(updatedRoundedTickLiquidity, liquidity) * uint256(compoundThreshold) >= 0.1e18 // compound if delta >= 1 / (compoundThreshold * 10)
        ) {
            // ensure we have enough reserves to satisfy the delta
            // round up updated balances to ensure that we can satisfy the delta
            (uint256 updatedBalance0, uint256 updatedBalance1) = LiquidityAmounts.getAmountsForLiquidity(
                sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, updatedRoundedTickLiquidity, true
            );
            if (updatedBalance0 <= bunniState.reserve0 + balance0 || updatedBalance1 <= bunniState.reserve1 + balance1)
            {
                int256 delta = int256(uint256(updatedRoundedTickLiquidity)) - int256(uint256(liquidity)); // both values are uint128 so cast is safe
                buffer = bytes.concat(buffer, abi.encode(LiquidityDelta({tickLower: roundedTick, delta: delta})));
                unchecked {
                    ++bufferLength;
                }
                liquidity = updatedRoundedTickLiquidity;
                updatedCurrentTick = true;
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
        while (true) {
            // compute sqrtPriceX96 and amountSpecifiedRemaining
            sqrtPriceStartX96 = sqrtPriceX96;
            sqrtPriceNextX96 = TickMath.getSqrtRatioAtTick(tickNext);
            (sqrtPriceX96, amountIn, amountOut,) = SwapMath.computeSwapStep(
                sqrtPriceX96,
                (
                    params.zeroForOne
                        ? sqrtPriceNextX96 < params.sqrtPriceLimitX96
                        : sqrtPriceNextX96 > params.sqrtPriceLimitX96
                ) ? params.sqrtPriceLimitX96 : sqrtPriceNextX96,
                liquidity,
                params.amountSpecified,
                0
            );
            unchecked {
                if (exactInput) {
                    amountSpecifiedRemaining -= amountIn.toInt256();
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
            if (amountSpecifiedRemaining == 0 || sqrtPriceX96 == params.sqrtPriceLimitX96) break;

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
                        tickLowerToAddLiquidityTo, arithmeticMeanTick, key.tickSpacing, useTwap, bunniState.ldfParams
                    ) * totalLiquidity
                ) >> 96
            ).toUint128();

            // buffer add liquidity to tickLowerToAddLiquidityTo
            buffer = bytes.concat(
                buffer,
                abi.encode(LiquidityDelta({tickLower: tickLowerToAddLiquidityTo, delta: int256(uint256(liquidity))})) // updatedLiquidity is uint128 so cast is safe
            );

            unchecked {
                ++bufferLength;
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
                        tickLowerToAddLiquidityTo, arithmeticMeanTick, key.tickSpacing, useTwap, bunniState.ldfParams
                    ) * totalLiquidity
                ) >> 96
            ).toUint128();

            // buffer add liquidity to tickLowerToAddLiquidityTo
            buffer = bytes.concat(
                buffer,
                abi.encode(LiquidityDelta({tickLower: tickLowerToAddLiquidityTo, delta: int256(uint256(liquidity))})) // updatedLiquidity is uint128 so cast is safe
            );

            unchecked {
                ++bufferLength;
                ++numTicksToRemove_;
            }
        }

        uint256 swapFee = _getFee(sqrtPriceX96, feeMeanTick, feeMin, feeMax, feeQuadraticMultiplier);
        assembly {
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
    }

    function _getFee(
        uint160 postSwapSqrtPriceX96,
        int24 arithmeticMeanTick,
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier
    ) internal pure returns (uint24) {
        // special case for fixed fee pools
        if (feeQuadraticMultiplier == 0 || feeMin == feeMax) return feeMin;

        uint256 ratio = uint256(postSwapSqrtPriceX96).mulDivDown(1e6, TickMath.getSqrtRatioAtTick(arithmeticMeanTick));
        ratio = ratio.mulDivDown(ratio, 1e6); // square the sqrtPrice ratio to get the price ratio
        uint256 delta = absDiffSimple(ratio, 1e6);
        // unchecked is safe since we're using uint256 to store the result and the return value is bounded in the range [feeMin, feeMax]
        unchecked {
            uint256 quadraticTerm = uint256(feeQuadraticMultiplier).mulDivUp(delta * delta, 1e12);
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
}
