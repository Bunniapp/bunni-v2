// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {stdMath} from "forge-std/StdMath.sol";

import {Fees} from "@uniswap/v4-core/contracts/Fees.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {Currency} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/contracts/libraries/FullMath.sol";
import {SwapMath} from "@uniswap/v4-core/contracts/libraries/SwapMath.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {IHookFeeManager} from "@uniswap/v4-core/contracts/interfaces/IHookFeeManager.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {IDynamicFeeManager} from "@uniswap/v4-core/contracts/interfaces/IDynamicFeeManager.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";

import {BaseHook} from "@uniswap/v4-periphery/contracts/BaseHook.sol";

import {Ownable} from "solady/src/auth/Ownable.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
import "./lib/LDFParams.sol";
import {Oracle} from "./lib/Oracle.sol";
import {LiquidityAmounts} from "./lib/LiquidityAmounts.sol";
import {IBunniHub, IBunniToken} from "./interfaces/IBunniHub.sol";

/// @notice Bunni Hook
contract BunniHook is BaseHook, IHookFeeManager, IDynamicFeeManager, Ownable {
    using FullMath for uint256;
    using SafeCastLib for uint256;
    using PoolIdLibrary for PoolKey;
    using FixedPointMathLib for uint256;
    using BalanceDeltaLibrary for BalanceDelta;
    using Oracle for Oracle.Observation[65535];

    error BunniHook__NotBunniHub();
    error BunniHook__SwapAlreadyInProgress();

    event SetHookFees(uint24 newFee);
    event SetHookFeesRecipient(address newRecipient);

    uint256 internal constant Q96 = 0x1000000000000000000000000;

    IBunniHub public immutable hub;

    /// @member index The index of the last written observation for the pool
    /// @member cardinality The cardinality of the observations array for the pool
    /// @member cardinalityNext The cardinality target of the observations array for the pool, which will replace cardinality when enough observations are written
    struct ObservationState {
        uint16 index;
        uint16 cardinality;
        uint16 cardinalityNext;
    }

    /// @notice The list of observations for a given pool ID
    mapping(PoolId => Oracle.Observation[65535]) public observations;
    /// @notice The current observation array state for the given pool ID
    mapping(PoolId => ObservationState) public states;

    uint24 public hookFees;
    address public hookFeesRecipient;
    int24 private firstTickToRemove;
    uint24 private numTicksToRemove;
    uint24 private swapFee;

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

    /// @notice Increase the cardinality target for the given pool
    function increaseCardinalityNext(PoolKey calldata key, uint16 cardinalityNext)
        external
        returns (uint16 cardinalityNextOld, uint16 cardinalityNextNew)
    {
        PoolId id = PoolId.wrap(keccak256(abi.encode(key)));

        ObservationState storage state = states[id];

        cardinalityNextOld = state.cardinalityNext;
        cardinalityNextNew = observations[id].grow(cardinalityNextOld, cardinalityNext);
        state.cardinalityNext = cardinalityNextNew;
    }

    function collectHookFees(Currency[] calldata currencyList) external {
        address recipient = hookFeesRecipient;
        for (uint256 i; i < currencyList.length; i++) {
            // setting `amount` to 0 claims all accrued fees
            Fees(address(poolManager)).collectHookFees(recipient, currencyList[i], 0);
        }
    }

    /// -----------------------------------------------------------------------
    /// BunniHub functions
    /// -----------------------------------------------------------------------

    /// @notice Update the TWAP oracle for the given pool. Only callable by BunniHub.
    function updateOracleAndObserve(PoolId id, bool shouldObserve, int24 tick, uint24 twapSecondsAgo)
        external
        returns (int24 arithmeticMeanTick)
    {
        if (msg.sender != address(hub)) revert BunniHook__NotBunniHub();

        // update TWAP oracle
        (uint16 updatedIndex, uint16 updatedCardinality) = observations[id].write(
            states[id].index, uint32(block.timestamp), tick, states[id].cardinality, states[id].cardinalityNext
        );
        (states[id].index, states[id].cardinality) = (updatedIndex, updatedCardinality);

        // observe if needed
        if (shouldObserve) {
            return _getTwap(id, tick, twapSecondsAgo, updatedIndex, updatedCardinality);
        }
        return 0;
    }

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    function setHookFees(uint24 newFee) external onlyOwner {
        hookFees = newFee;
        emit SetHookFees(newFee);
    }

    function setHookFeesRecipient(address newRecipient) external onlyOwner {
        hookFeesRecipient = newRecipient;
        emit SetHookFeesRecipient(newRecipient);
    }

    /// -----------------------------------------------------------------------
    /// View functions
    /// -----------------------------------------------------------------------

    /// @notice Returns the observation for the given pool key and observation index
    function getObservation(PoolKey calldata key, uint256 index)
        external
        view
        returns (Oracle.Observation memory observation)
    {
        observation = observations[key.toId()][index];
    }

    /// @notice Returns the state for the given pool key
    function getState(PoolKey calldata key) external view returns (ObservationState memory state) {
        state = states[key.toId()];
    }

    /// @notice Observe the given pool for the timestamps
    function observe(PoolKey calldata key, uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives)
    {
        PoolId id = key.toId();
        ObservationState memory state = states[id];
        (, int24 tick,,) = poolManager.getSlot0(id);

        return observations[id].observe(uint32(block.timestamp), secondsAgos, tick, state.index, state.cardinality);
    }

    /// -----------------------------------------------------------------------
    /// Hooks
    /// -----------------------------------------------------------------------

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
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
    function getFee(
        address, /* sender */
        PoolKey calldata, /* key */
        IPoolManager.SwapParams calldata, /* params */
        bytes calldata /* data */
    ) external view override returns (uint24) {
        return swapFee;
    }

    /// @inheritdoc IHookFeeManager
    function getHookFees(PoolKey calldata /* key */ ) external view override returns (uint24) {
        return hookFees;
    }

    /// @inheritdoc IHooks
    function afterInitialize(address caller, PoolKey calldata key, uint160, int24, bytes calldata)
        external
        override
        poolManagerOnly
        returns (bytes4)
    {
        if (caller != address(hub)) revert BunniHook__NotBunniHub(); // prevents non-BunniHub contracts from initializing a pool using this hook
        PoolId id = key.toId();
        (states[id].cardinality, states[id].cardinalityNext) = observations[id].initialize(uint32(block.timestamp));
        return BunniHook.afterInitialize.selector;
    }

    /// @inheritdoc IHooks
    function beforeModifyPosition(
        address caller,
        PoolKey calldata, /* key */
        IPoolManager.ModifyPositionParams calldata,
        bytes calldata
    ) external view override poolManagerOnly returns (bytes4) {
        if (caller != address(hub)) revert BunniHook__NotBunniHub(); // prevents non-BunniHub contracts from modifying a position using this hook
        // Note: we don't need to update the oracle here because updateOracle() is called by BunniHub.deposit()
        return BunniHook.beforeModifyPosition.selector;
    }

    /// @inheritdoc IHooks
    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        external
        override
        poolManagerOnly
        returns (bytes4)
    {
        _beforeSwapUpdatePool(key, params);
        return BunniHook.beforeSwap.selector;
    }

    function afterSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta,
        bytes calldata
    ) external override poolManagerOnly returns (bytes4) {
        // withdraw liquidity from inactive ticks
        int24 roundedTick = firstTickToRemove;
        uint24 numTicksToRemove_ = numTicksToRemove;
        if (numTicksToRemove_ != 0) {
            delete firstTickToRemove;
            delete numTicksToRemove;

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
        if (numTicksToRemove != 0) revert BunniHook__SwapAlreadyInProgress();

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
        (uint16 updatedIndex, uint16 updatedCardinality) = observations[id].write(
            states[id].index, uint32(block.timestamp), currentTick, states[id].cardinality, states[id].cardinalityNext
        );
        (states[id].index, states[id].cardinality) = (updatedIndex, updatedCardinality);

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
        (bool useTwap, uint8 compoundThreshold, uint24 twapSecondsAgo, bytes11 decodedLDFParams) =
            decodeLDFParams(bunniState.ldfParams);
        if (useTwap) {
            // need to use TWAP
            // compute TWAP value
            arithmeticMeanTick = _getTwap(id, currentTick, twapSecondsAgo, updatedIndex, updatedCardinality);
        }
        int24 feeMeanTick;
        if (bunniState.feeMin != bunniState.feeMax && bunniState.feeQuadraticMultiplier != 0) {
            // fee calculation needs TWAP
            feeMeanTick = _getTwap(id, currentTick, bunniState.feeTwapSecondsAgo, updatedIndex, updatedCardinality);
        }

        // get densities
        (
            uint256 liquidityDensityOfRoundedTickX96,
            uint256 density0RightOfRoundedTickX96,
            uint256 density1LeftOfRoundedTickX96
        ) = bunniState.liquidityDensityFunction.query(
            roundedTick, arithmeticMeanTick, key.tickSpacing, useTwap, decodedLDFParams
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

        // update current tick liquidity if necessary
        bytes memory buffer; // buffer for storing dynamic length array of LiquidityDelta structs
        uint256 bufferLength;
        bool updatedCurrentTick;
        if (
            (compoundThreshold == 0 && updatedRoundedTickLiquidity != liquidity) // always compound if threshold is 0 and there's a liquidity difference
                || stdMath.percentDelta(updatedRoundedTickLiquidity, liquidity) * uint256(compoundThreshold) >= 0.1e18 // compound if delta >= 1 / (compoundThreshold * 10)
        ) {
            buffer = bytes.concat(
                buffer,
                abi.encode(
                    LiquidityDelta({
                        tickLower: roundedTick,
                        delta: int256(uint256(updatedRoundedTickLiquidity)) - int256(uint256(liquidity)) // both values are uint128 so cast is safe
                    })
                )
            );
            unchecked {
                ++bufferLength;
            }
            liquidity = updatedRoundedTickLiquidity;
            updatedCurrentTick = true;
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
                        tickLowerToAddLiquidityTo, arithmeticMeanTick, key.tickSpacing, useTwap, decodedLDFParams
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
                        tickLowerToAddLiquidityTo, arithmeticMeanTick, key.tickSpacing, useTwap, decodedLDFParams
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

        if (numTicksToRemove_ != 0) {
            // consolidate same-slot storage writes to save gas
            firstTickToRemove = roundedTick;
            numTicksToRemove = numTicksToRemove_;
            swapFee = _getFee(
                sqrtPriceX96, feeMeanTick, bunniState.feeMin, bunniState.feeMax, bunniState.feeQuadraticMultiplier
            );
        } else {
            swapFee = _getFee(
                sqrtPriceX96, feeMeanTick, bunniState.feeMin, bunniState.feeMax, bunniState.feeQuadraticMultiplier
            );
        }

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
        if (feeMin == feeMax || feeQuadraticMultiplier == 0) return feeMin;

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
        (int56 tickCumulative0, int56 tickCumulative1) = observations[id].observeDouble(
            uint32(block.timestamp), twapSecondsAgo, 0, currentTick, updatedIndex, updatedCardinality
        );
        int56 tickCumulativesDelta = tickCumulative1 - tickCumulative0;
        arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(twapSecondsAgo)));
    }
}
