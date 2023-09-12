// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/contracts/libraries/FullMath.sol";
import {SwapMath} from "@uniswap/v4-core/contracts/libraries/SwapMath.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {IHookFeeManager} from "@uniswap/v4-core/contracts/interfaces/IHookFeeManager.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {IDynamicFeeManager} from "@uniswap/v4-core/contracts/interfaces/IDynamicFeeManager.sol";

import {BaseHook} from "@uniswap/v4-periphery/contracts/BaseHook.sol";
import {Oracle} from "@uniswap/v4-periphery/contracts/libraries/Oracle.sol";

import {Ownable} from "solady/src/auth/Ownable.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import "./lib/Math.sol";
import {LiquidityAmounts} from "./lib/LiquidityAmounts.sol";
import {IBunniHub, BunniTokenState} from "./interfaces/IBunniHub.sol";

/// @notice Bunni Hook
contract BunniHook is BaseHook, IHookFeeManager, IDynamicFeeManager, Ownable {
    using Oracle for Oracle.Observation[65535];
    using PoolIdLibrary for PoolKey;
    using SafeCastLib for uint256;

    error BunniHook__BunniTokenNotInitialized();

    event SetHookSwapFee(uint8 newFee);

    uint256 internal constant WAD = 1e18;

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

    uint8 public hookSwapFee;

    constructor(IPoolManager _poolManager, IBunniHub hub_, address owner_, uint8 hookSwapFee_) BaseHook(_poolManager) {
        hub = hub_;
        hookSwapFee = hookSwapFee_;
        _initializeOwner(owner_);

        emit SetHookSwapFee(hookSwapFee_);
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

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    function setHookSwapFee(uint8 newFee) external onlyOwner {
        hookSwapFee = newFee;
        emit SetHookSwapFee(newFee);
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
        observation = observations[PoolId.wrap(keccak256(abi.encode(key)))][index];
    }

    /// @notice Returns the state for the given pool key
    function getState(PoolKey calldata key) external view returns (ObservationState memory state) {
        state = states[PoolId.wrap(keccak256(abi.encode(key)))];
    }

    /// @notice Observe the given pool for the timestamps
    function observe(PoolKey calldata key, uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s)
    {
        PoolId id = key.toId();

        ObservationState memory state = states[id];

        (, int24 tick,,,,) = poolManager.getSlot0(id);

        uint128 liquidity = poolManager.getLiquidity(id);

        return observations[id].observe(_blockTimestamp(), secondsAgos, tick, state.index, liquidity, state.cardinality);
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
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }

    /// @inheritdoc IDynamicFeeManager
    function getFee(PoolKey calldata key) external pure override returns (uint24) {
        return _getFee(key);
    }

    /// @inheritdoc IHookFeeManager
    function getHookSwapFee(PoolKey calldata) external view override returns (uint8) {
        return hookSwapFee;
    }

    /// @inheritdoc IHookFeeManager
    function getHookWithdrawFee(PoolKey calldata) external pure override returns (uint8) {
        return 0;
    }

    /// @inheritdoc IHooks
    function afterInitialize(address, PoolKey calldata key, uint160, int24)
        external
        override
        poolManagerOnly
        returns (bytes4)
    {
        PoolId id = key.toId();
        (states[id].cardinality, states[id].cardinalityNext) = observations[id].initialize(_blockTimestamp());
        return BunniHook.afterInitialize.selector;
    }

    /// @inheritdoc IHooks
    function beforeModifyPosition(address, PoolKey calldata key, IPoolManager.ModifyPositionParams calldata)
        external
        override
        poolManagerOnly
        returns (bytes4)
    {
        _beforeModifyPositionUpdatePool(key);
        return BunniHook.beforeModifyPosition.selector;
    }

    /// @inheritdoc IHooks
    function beforeSwap(address, PoolKey calldata key, IPoolManager.SwapParams calldata params)
        external
        override
        poolManagerOnly
        returns (bytes4)
    {
        _beforeSwapUpdatePool(key, params);
        return BunniHook.beforeSwap.selector;
    }

    /// -----------------------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------------------

    /// @dev For mocking
    function _blockTimestamp() internal view virtual returns (uint32) {
        return uint32(block.timestamp);
    }

    function _beforeModifyPositionUpdatePool(PoolKey calldata key) private {
        PoolId id = key.toId();
        (, int24 currentTick,,,,) = poolManager.getSlot0(id);
        uint128 liquidity = poolManager.getLiquidity(id);

        // update TWAP oracle
        (states[id].index, states[id].cardinality) = observations[id].write(
            states[id].index,
            _blockTimestamp(),
            currentTick,
            liquidity,
            states[id].cardinality,
            states[id].cardinalityNext
        );
    }

    function _beforeSwapUpdatePool(PoolKey calldata key, IPoolManager.SwapParams calldata params) private {
        PoolId id = key.toId();
        (uint160 sqrtPriceX96, int24 currentTick,,,,) = poolManager.getSlot0(id);

        // get current tick token balances & reserves
        BunniTokenState memory bunniState = hub.bunniTokenState(hub.bunniTokenOfPool(id));
        if (!bunniState.initialized) revert BunniHook__BunniTokenNotInitialized();
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, key.tickSpacing);
        uint128 liquidity = poolManager.getLiquidity(id);
        uint160 roundedTickSqrtRatio = TickMath.getSqrtRatioAtTick(roundedTick);
        uint160 nextRoundedTickSqrtRatio = TickMath.getSqrtRatioAtTick(nextRoundedTick);
        (uint256 balance0, uint256 balance1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, liquidity
        );
        (balance0, balance1) = (balance0 + bunniState.reserve0, balance1 + bunniState.reserve1);

        // (optional) get TWAP value
        int24 arithmeticMeanTick;
        if (bunniState.twapSecondsAgo != 0) {
            // LDF uses TWAP
            // compute TWAP value
            ObservationState memory state = states[id];
            uint32[] memory secondsAgos = new uint32[](2);
            secondsAgos[0] = bunniState.twapSecondsAgo;
            secondsAgos[1] = 0;
            (int56[] memory tickCumulatives,) = observations[id].observe(
                _blockTimestamp(), secondsAgos, currentTick, state.index, liquidity, state.cardinality
            );
            int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
            arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(bunniState.twapSecondsAgo)));
        }

        // get densities
        (uint256 liquidityDensityOfRoundedTick, uint256 density0RightOfRoundedTick, uint256 density1LeftOfRoundedTick) =
            bunniState.liquidityDensityFunction.query(currentTick, arithmeticMeanTick, key.tickSpacing);
        (uint256 density0OfRoundedTick, uint256 density1OfRoundedTick) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, liquidityDensityOfRoundedTick.toUint128()
        );

        // compute total liquidity
        uint256 totalLiquidity = max(
            FullMath.mulDiv(balance0, WAD, density0RightOfRoundedTick + density0OfRoundedTick),
            FullMath.mulDiv(balance1, WAD, density1LeftOfRoundedTick + density1OfRoundedTick)
        );

        // compute updated current tick liquidity
        uint128 updatedRoundedTickLiquidity =
            FullMath.mulDiv(totalLiquidity, liquidityDensityOfRoundedTick, WAD).toUint128();

        // update current tick liquidity if necessary
        // TODO

        // simulate swap to see if current tick liquidity is sufficient
        uint256 amountIn;
        uint256 amountOut;
        uint256 feeAmount;
        uint24 swapFee = _getFee(key);
        bool exactInput = params.amountSpecified > 0;
        uint160 sqrtPriceStartX96 = sqrtPriceX96;
        int24 tickNext = params.zeroForOne ? roundedTick : nextRoundedTick;
        if (tickNext < TickMath.MIN_TICK) {
            tickNext = TickMath.MIN_TICK;
        } else if (tickNext > TickMath.MAX_TICK) {
            tickNext = TickMath.MAX_TICK;
        }
        uint160 sqrtPriceNextX96 = TickMath.getSqrtRatioAtTick(tickNext);
        (sqrtPriceX96, amountIn, amountOut, feeAmount) = SwapMath.computeSwapStep(
            sqrtPriceX96,
            (
                params.zeroForOne
                    ? sqrtPriceNextX96 < params.sqrtPriceLimitX96
                    : sqrtPriceNextX96 > params.sqrtPriceLimitX96
            ) ? params.sqrtPriceLimitX96 : sqrtPriceNextX96,
            updatedRoundedTickLiquidity,
            params.amountSpecified,
            swapFee
        );
        int256 amountSpecifiedRemaining;
        unchecked {
            if (exactInput) {
                amountSpecifiedRemaining -= (amountIn + feeAmount).toInt256();
            } else {
                amountSpecifiedRemaining += amountOut.toInt256();
            }
        }
        // if insufficient, add liquidity to the next tick and repeat
        int24 stateTick;
        while (amountSpecifiedRemaining != 0 && sqrtPriceX96 != params.sqrtPriceLimitX96) {
            // shift tick if we reached the next price
            if (sqrtPriceX96 == sqrtPriceNextX96) {
                unchecked {
                    stateTick = params.zeroForOne ? tickNext - 1 : tickNext;
                }
            } else if (sqrtPriceX96 != sqrtPriceStartX96) {
                // recompute unless we're on a lower tick boundary (i.e. already transitioned ticks), and haven't moved
                stateTick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
            }

            // add liquidity to tickNext
            // TODO
            tickNext = params.zeroForOne ? tickNext - key.tickSpacing : tickNext + key.tickSpacing;
            if (tickNext < TickMath.MIN_TICK) {
                tickNext = TickMath.MIN_TICK;
            } else if (tickNext > TickMath.MAX_TICK) {
                tickNext = TickMath.MAX_TICK;
            }

            // recompute sqrtPriceX96 and amountSpecifiedRemaining
            sqrtPriceStartX96 = sqrtPriceX96;
            sqrtPriceNextX96 = TickMath.getSqrtRatioAtTick(tickNext);
            (sqrtPriceX96, amountIn, amountOut, feeAmount) = SwapMath.computeSwapStep(
                sqrtPriceX96,
                (
                    params.zeroForOne
                        ? sqrtPriceNextX96 < params.sqrtPriceLimitX96
                        : sqrtPriceNextX96 > params.sqrtPriceLimitX96
                ) ? params.sqrtPriceLimitX96 : sqrtPriceNextX96,
                updatedRoundedTickLiquidity,
                params.amountSpecified,
                swapFee
            );
            unchecked {
                if (exactInput) {
                    amountSpecifiedRemaining -= (amountIn + feeAmount).toInt256();
                } else {
                    amountSpecifiedRemaining += amountOut.toInt256();
                }
            }
        }

        // update TWAP oracle
        // do it at the end since we likely updated liquidity
        (states[id].index, states[id].cardinality) = observations[id].write(
            states[id].index,
            _blockTimestamp(),
            currentTick,
            poolManager.getLiquidity(id),
            states[id].cardinality,
            states[id].cardinalityNext
        );
    }

    function _getFee(PoolKey calldata key) internal pure returns (uint24) {
        return 100; // TODO
    }
}
