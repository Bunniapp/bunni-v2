// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import {stdMath} from "forge-std/StdMath.sol";

import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
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
import {Oracle} from "@uniswap/v4-periphery/contracts/libraries/Oracle.sol";

import {Ownable} from "solady/src/auth/Ownable.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
import "./lib/LDFParams.sol";
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
    error BunniHook__BunniTokenNotInitialized();

    event SetHookSwapFee(uint24 newFee);

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

    uint24 public hookSwapFee;
    uint24 private numTicksToRemove;

    constructor(IPoolManager _poolManager, IBunniHub hub_, address owner_, uint24 hookSwapFee_)
        BaseHook(_poolManager)
    {
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

    function setHookSwapFee(uint24 newFee) external onlyOwner {
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

        (, int24 tick,,) = poolManager.getSlot0(id);

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
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false
        });
    }

    /// @inheritdoc IDynamicFeeManager
    function getFee(
        address, /* sender */
        PoolKey calldata key,
        IPoolManager.SwapParams calldata, /* params */
        bytes calldata /* data */
    ) external pure override returns (uint24) {
        return _getFee(key);
    }

    /// @inheritdoc IHookFeeManager
    function getHookFees(PoolKey calldata key) external view override returns (uint24) {
        return hookSwapFee;
    }

    /// @inheritdoc IHooks
    function afterInitialize(address, PoolKey calldata key, uint160, int24, bytes calldata)
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
    function beforeModifyPosition(
        address caller,
        PoolKey calldata key,
        IPoolManager.ModifyPositionParams calldata,
        bytes calldata
    ) external override poolManagerOnly returns (bytes4) {
        if (caller != address(hub)) revert BunniHook__NotBunniHub();
        _beforeModifyPositionUpdatePool(key);
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
        uint24 numTicksToRemove_ = numTicksToRemove;
        delete numTicksToRemove;

        PoolId id = key.toId();
        (, int24 currentTick,,) = poolManager.getSlot0(id);
        (int24 roundedTick,) = roundTick(currentTick, key.tickSpacing);

        LiquidityDelta[] memory liquidityDeltas = new LiquidityDelta[](numTicksToRemove_);
        for (uint256 i; i < numTicksToRemove_;) {
            unchecked {
                roundedTick = params.zeroForOne ? roundedTick + key.tickSpacing : roundedTick - key.tickSpacing;
                if (roundedTick < TickMath.MIN_TICK) {
                    roundedTick = TickMath.MIN_TICK;
                } else if (roundedTick > TickMath.MAX_TICK) {
                    roundedTick = TickMath.MAX_TICK;
                }
            }

            // buffer remove liquidity
            liquidityDeltas[i] = LiquidityDelta({
                tickLower: roundedTick,
                delta: -uint256(poolManager.getLiquidity(id, address(hub), roundedTick, roundedTick + key.tickSpacing)).toInt256()
            });

            unchecked {
                ++i;
            }
        }

        // call BunniHub to remove liquidity
        // we always do this to compound after every swap
        hub.hookModifyLiquidity({bunniToken: hub.bunniTokenOfPool(id), liquidityDeltas: liquidityDeltas, compound: true});

        return BunniHook.afterSwap.selector;
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
        (, int24 currentTick,,) = poolManager.getSlot0(id);
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
        if (numTicksToRemove != 0) revert BunniHook__SwapAlreadyInProgress();
        PoolId id = key.toId();
        (uint160 sqrtPriceX96, int24 currentTick,,) = poolManager.getSlot0(id);

        // get current tick token balances & reserves
        IBunniToken bunniToken = hub.bunniTokenOfPool(id);
        BunniTokenState memory bunniState = hub.bunniTokenState(bunniToken);
        if (address(bunniState.liquidityDensityFunction) == address(0)) revert BunniHook__BunniTokenNotInitialized();
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, key.tickSpacing);
        uint128 liquidity = poolManager.getLiquidity(id);
        uint160 roundedTickSqrtRatio = TickMath.getSqrtRatioAtTick(roundedTick);
        uint160 nextRoundedTickSqrtRatio = TickMath.getSqrtRatioAtTick(nextRoundedTick);
        (uint256 balance0, uint256 balance1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, liquidity, false
        );
        (balance0, balance1) = (balance0 + bunniState.reserve0, balance1 + bunniState.reserve1);

        // update TWAP oracle
        // do it before we fetch the arithmeticMeanTick
        (uint16 updatedIndex, uint16 updatedCardinality) = observations[id].write(
            states[id].index,
            _blockTimestamp(),
            currentTick,
            liquidity,
            states[id].cardinality,
            states[id].cardinalityNext
        );
        (states[id].index, states[id].cardinality) = (updatedIndex, updatedCardinality);

        // (optional) get TWAP value
        int24 arithmeticMeanTick;
        (bool useTwap, uint8 compoundThreshold, uint24 twapSecondsAgo, bytes11 decodedLDFParams) =
            decodeLDFParams(bunniState.ldfParams);
        if (useTwap) {
            // LDF uses TWAP
            // compute TWAP value
            uint32[] memory secondsAgos = new uint32[](2);
            secondsAgos[0] = twapSecondsAgo;
            secondsAgos[1] = 0;
            (int56[] memory tickCumulatives,) = observations[id].observe(
                _blockTimestamp(), secondsAgos, currentTick, updatedIndex, liquidity, updatedCardinality
            );
            int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
            arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(twapSecondsAgo)));
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
            liquidityDensityOfRoundedTickX96.toUint128(),
            false
        );

        // compute total liquidity
        uint256 totalLiquidity = max(
            balance0.mulDiv(Q96, density0RightOfRoundedTickX96 + density0OfRoundedTickX96),
            balance1.mulDiv(Q96, density1LeftOfRoundedTickX96 + density1OfRoundedTickX96)
        );

        // compute updated current tick liquidity
        uint128 updatedRoundedTickLiquidity = totalLiquidity.mulDiv(liquidityDensityOfRoundedTickX96, Q96).toUint128();

        // update current tick liquidity if necessary
        bytes memory buffer; // buffer for storing dynamic length array of LiquidityDelta structs
        uint256 bufferLength;
        if (
            (compoundThreshold == 0 && updatedRoundedTickLiquidity != liquidity) // always compound if threshold is 0 and there's a liquidity difference
                || stdMath.percentDelta(updatedRoundedTickLiquidity, liquidity) * uint256(compoundThreshold) >= 0.1e18 // compound if delta >= 1 / (compoundThreshold * 10)
        ) {
            buffer = bytes.concat(
                buffer,
                abi.encode(
                    LiquidityDelta({
                        tickLower: roundedTick,
                        delta: uint256(updatedRoundedTickLiquidity).toInt256() - uint256(liquidity).toInt256()
                    })
                )
            );
            unchecked {
                ++bufferLength;
            }
            liquidity = updatedRoundedTickLiquidity;
        }

        // simulate swap to see if current tick liquidity is sufficient
        uint256 amountIn;
        uint256 amountOut;
        uint256 feeAmount;
        uint24 swapFee = _getFee(key);
        bool exactInput = params.amountSpecified > 0;
        uint160 sqrtPriceStartX96 = sqrtPriceX96;
        int24 tick = currentTick;
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
            liquidity,
            params.amountSpecified,
            swapFee
        );
        int256 amountSpecifiedRemaining = params.amountSpecified;
        unchecked {
            if (exactInput) {
                amountSpecifiedRemaining -= (amountIn + feeAmount).toInt256();
            } else {
                amountSpecifiedRemaining += amountOut.toInt256();
            }
        }
        if (sqrtPriceX96 == sqrtPriceNextX96) {
            unchecked {
                tick = params.zeroForOne ? tickNext - 1 : tickNext;
            }
        } else if (sqrtPriceX96 != sqrtPriceStartX96) {
            tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        }
        // if insufficient, add liquidity to the next tick and repeat
        uint24 numTicksToRemove_;
        while (amountSpecifiedRemaining != 0 && sqrtPriceX96 != params.sqrtPriceLimitX96) {
            // update tickNext, liquidity, and buffer
            // we will add `liquidity` to the range zeroForOne ? [tickNext, tickNext + tickSpacing) : [tickNext - tickSpacing, tickNext)
            // (tickNext here refers to the updated tickNext value)
            (tickNext, liquidity, buffer) = _addLiquidityToNextTick({
                zeroForOne: params.zeroForOne,
                tickNext: tickNext,
                tickSpacing: key.tickSpacing,
                arithmeticMeanTick: arithmeticMeanTick,
                useTwap: useTwap,
                decodedLDFParams: decodedLDFParams,
                totalLiquidity: totalLiquidity,
                buffer: buffer,
                liquidityDensityFunction: bunniState.liquidityDensityFunction
            });
            unchecked {
                ++bufferLength;
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
                liquidity,
                params.amountSpecified,
                swapFee
            );
            unchecked {
                if (exactInput) {
                    amountSpecifiedRemaining -= (amountIn + feeAmount).toInt256();
                } else {
                    amountSpecifiedRemaining += amountOut.toInt256();
                }
                ++numTicksToRemove_;
            }

            if (sqrtPriceX96 == sqrtPriceNextX96) {
                unchecked {
                    tick = params.zeroForOne ? tickNext - 1 : tickNext;
                }
            } else if (sqrtPriceX96 != sqrtPriceStartX96) {
                tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
            }
        }

        // handle zeroForOne edge case where we end up at a tick belonging to the next roundedTick
        // this is caused by tick = params.zeroForOne ? tickNext - 1 : tickNext;
        if (
            params.zeroForOne
                && roundTickSingle(tick, key.tickSpacing) == roundedTick - int24(numTicksToRemove_ + 1) * key.tickSpacing
        ) {
            (,, buffer) = _addLiquidityToNextTick({
                zeroForOne: true,
                tickNext: tickNext,
                tickSpacing: key.tickSpacing,
                arithmeticMeanTick: arithmeticMeanTick,
                useTwap: useTwap,
                decodedLDFParams: decodedLDFParams,
                totalLiquidity: totalLiquidity,
                buffer: buffer,
                liquidityDensityFunction: bunniState.liquidityDensityFunction
            });
            unchecked {
                ++bufferLength;
                ++numTicksToRemove_;
            }
        }

        if (numTicksToRemove_ != 0) {
            numTicksToRemove = numTicksToRemove_;
        }

        if (bufferLength != 0) {
            // call BunniHub to update liquidity
            hub.hookModifyLiquidity({
                bunniToken: bunniToken,
                liquidityDeltas: abi.decode(abi.encodePacked(uint256(0x20), bufferLength, buffer), (LiquidityDelta[])), // uint256(0x20) denotes the location of the start of the array in the calldata
                compound: false
            });
        }
    }

    function _getFee(PoolKey calldata key) internal pure returns (uint24) {
        return 100; // TODO
    }

    /// @dev Partial compute step in _beforeSwapUpdatePool factored out to reduce bytecode size
    function _addLiquidityToNextTick(
        bool zeroForOne,
        int24 tickNext,
        int24 tickSpacing,
        int24 arithmeticMeanTick,
        bool useTwap,
        bytes11 decodedLDFParams,
        uint256 totalLiquidity,
        bytes memory buffer,
        ILiquidityDensityFunction liquidityDensityFunction
    ) internal view returns (int24 updatedTickNext, uint128 updatedLiquidity, bytes memory updatedBuffer) {
        // compute tickNext liquidity and store in updatedLiquidity
        updatedTickNext = zeroForOne ? tickNext - tickSpacing : tickNext + tickSpacing;
        if (updatedTickNext < TickMath.MIN_TICK) {
            updatedTickNext = TickMath.MIN_TICK;
        } else if (updatedTickNext > TickMath.MAX_TICK) {
            updatedTickNext = TickMath.MAX_TICK;
        }
        // if swapping token1 to token0, updatedTickNext is the tickUpper of the range to add liquidity to
        // therefore we need to shift left by tickSpacing to get tickLower
        int24 tickLowerToAddLiquidityTo = zeroForOne ? updatedTickNext : updatedTickNext - tickSpacing;
        updatedLiquidity = liquidityDensityFunction.liquidityDensityX96(
            tickLowerToAddLiquidityTo, arithmeticMeanTick, tickSpacing, useTwap, decodedLDFParams
        ).mulDivDown(totalLiquidity, Q96).toUint128();

        // buffer add liquidity to tickLowerToAddLiquidityTo
        updatedBuffer = bytes.concat(
            buffer,
            abi.encode(
                LiquidityDelta({tickLower: tickLowerToAddLiquidityTo, delta: uint256(updatedLiquidity).toInt256()})
            )
        );
    }
}
