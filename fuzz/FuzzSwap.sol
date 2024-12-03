pragma solidity ^0.8.20;

import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {FixedPoint96} from "@uniswap/v4-core/src/libraries/FixedPoint96.sol";

import "../src/lib/Math.sol";
import {ShiftMode} from "../src/ldf/ShiftMode.sol";
import {ILiquidityDensityFunction} from "../src/interfaces/ILiquidityDensityFunction.sol";
import {LibUniformDistribution} from "../src/ldf/LibUniformDistribution.sol";
import {UniformDistribution} from "../src/ldf/UniformDistribution.sol";

import "./FuzzHelper.sol";
import "../src/lib/BunniSwapMath.sol";
import "./PropertiesAsserts.sol";
import "forge-std/console.sol";

import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

error Overflow();

// Before running this with medusa, change the external functions of BunniSwapMath to internals
// and calldata arguments to memory
contract FuzzSwap is FuzzHelper, PropertiesAsserts {
    using FixedPointMathLib for *;
    using IdleBalanceLibrary for *;

    // Invariant: computeSwap in BunniSwapMath should output the same amount of input
    //            and output tokens both in ExactIn and ExactOut configurations given
    //            the same pool state.
    // Issue: TOB-BUNNI-17
    function compare_exact_in_swap_with_exact_out_swap(
        int24 tickSpacing,
        uint64 balance0,
        uint64 balance1,
        int64 amountSpecified,
        uint160 sqrtPriceLimit,
        int24 tickLower,
        int24 tickUpper,
        int24 currentTick,
        bool zeroForOne
    ) public {
        // Initialize LDF to Uniform distribution
        ldf = ILiquidityDensityFunction(address(new UniformDistribution()));

        // Initialize parameters before swapinng
        (BunniSwapMath.BunniComputeSwapInput memory input1,) = _compute_swap(
            tickSpacing,
            balance0,
            balance1,
            amountSpecified,
            sqrtPriceLimit,
            tickLower,
            tickUpper,
            currentTick,
            zeroForOne
        );

        try this.swap(input1) returns (
            uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount0, uint256 outputAmount0
        ) {
            if (inputAmount0 == 0 || outputAmount0 == 0) return;

            if (inputAmount0 != uint64(inputAmount0) || outputAmount0 != uint64(outputAmount0)) return;

            (BunniSwapMath.BunniComputeSwapInput memory input2,) = _compute_swap(
                tickSpacing,
                balance0,
                balance1,
                -amountSpecified,
                sqrtPriceLimit,
                tickLower,
                tickUpper,
                currentTick,
                zeroForOne
            );
            input2.swapParams.amountSpecified = amountSpecified < 0 ? int256(outputAmount0) : -int256(inputAmount0);

            (uint160 updatedSqrtPriceX960, int24 updatedTick0, uint256 inputAmount1, uint256 outputAmount1) =
                BunniSwapMath.computeSwap(input2);

            console2.log("input1 amountSpecified", amountSpecified);
            console2.log("input2 amountSpecified", input2.swapParams.amountSpecified);
            console2.log("updatedSqrtPriceX96", updatedSqrtPriceX96);
            console2.log("updatedTick", updatedTick);
            console2.log("inputAmount0", inputAmount0);
            console2.log("outputAmount0", outputAmount0);
            console2.log("updatedSqrtPriceX960", updatedSqrtPriceX960);
            console2.log("updatedTick0", updatedTick0);
            console2.log("inputAmount1", inputAmount1);
            console2.log("outputAmount1", outputAmount1);

            if (amountSpecified < 0) {
                assertWithMsg(inputAmount0 >= inputAmount1, "Users can profit from Exact In and Exact Out combination");
            } else {
                assertWithMsg(
                    outputAmount0 >= outputAmount1, "Users can profit from Exact In and Exact Out combination"
                );
            }
        } catch Panic(uint256) /*errorCode*/ {
            return;
        } catch (bytes memory reason) {
            emit LogBytes(reason);
            return;
        }
    }

    // Invariant: Users should not be able to get free output tokens
    //            for zero input tokens when amountSpecified is non-zero
    //            for a given valid pool state.
    // Issue: TOB-BUNNI-15
    function test_free_or_loss_of_tokens_during_swap(
        int24 tickSpacing,
        uint64 balance0,
        uint64 balance1,
        int64 amountSpecified,
        uint160 sqrtPriceLimit,
        int24 tickLower,
        int24 tickUpper,
        int24 currentTick,
        bool zeroForOne
    ) public {
        // Initialize LDF to Uniform distribution
        ldf = ILiquidityDensityFunction(address(new UniformDistribution()));

        // Initialize parameters before swapinng
        (BunniSwapMath.BunniComputeSwapInput memory input1,) = _compute_swap(
            tickSpacing,
            balance0,
            balance1,
            amountSpecified,
            sqrtPriceLimit,
            tickLower,
            tickUpper,
            currentTick,
            zeroForOne
        );

        try this.swap(input1) returns (
            uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount0, uint256 outputAmount0
        ) {
            if (outputAmount0 > 0 && inputAmount0 == 0) {
                assertWithMsg(false, "Users get free tokens");
            }
        } catch Panic(uint256) /*errorCode*/ {
            // This is executed in case of a panic,
            // i.e. a serious error like division by zero
            // or overflow. The error code can be used
            // to determine the kind of error.
            return;
        } catch (bytes memory reason) {
            emit LogBytes(reason);
            return;
        }
    }

    // Invariant: Users should not be able to gain any tokens through round trip swaps.
    // Issue: TOB-BUNNI-16
    function compare_swap_with_reverse_swap_with_zeroForOne_vs_oneForZero(
        int24 tickSpacing,
        uint64 balance0,
        uint64 balance1,
        int64 amountSpecified,
        uint160 sqrtPriceLimit,
        int24 tickLower,
        int24 tickUpper,
        int24 currentTick
    ) public {
        // Initialize LDF to Uniform distribution
        ldf = ILiquidityDensityFunction(address(new UniformDistribution()));

        // Initialize parameters before swapinng
        (BunniSwapMath.BunniComputeSwapInput memory input1, IdleBalance idleBalance) = _compute_swap(
            tickSpacing, balance0, balance1, amountSpecified, sqrtPriceLimit, tickLower, tickUpper, currentTick, true
        );

        try this.swap(input1) returns (
            uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount0, uint256 outputAmount0
        ) {
            require(outputAmount0 != 0 && inputAmount0 != 0);
            if (inputAmount0 != uint64(inputAmount0) || outputAmount0 != uint64(outputAmount0)) return;

            BunniSwapMath.BunniComputeSwapInput memory input2 = _compute_swap(
                tickSpacing,
                uint64(balance0 + inputAmount0),
                uint64(balance1 - outputAmount0),
                -amountSpecified,
                input1.sqrtPriceX96, // sqrtPriceLimit
                tickLower,
                tickUpper,
                updatedTick,
                false,
                updatedSqrtPriceX96,
                idleBalance
            );
            input2.swapParams.amountSpecified = amountSpecified < 0 ? -int256(outputAmount0) : int256(inputAmount0);

            (uint160 updatedSqrtPriceX960, int24 updatedTick0, uint256 inputAmount1, uint256 outputAmount1) =
                BunniSwapMath.computeSwap(input2);

            if (
                (amountSpecified < 0 && outputAmount0 > inputAmount1)
                    || (amountSpecified > 0 && inputAmount0 > outputAmount1)
            ) {
                // not valid roundtrip swap since the swap amounts don't chain together
                return;
            }

            if (amountSpecified < 0) {
                assertWithMsg(inputAmount0 >= outputAmount1, "Round trips swaps are profitable");
            } else {
                assertWithMsg(outputAmount0 <= inputAmount1, "Round trips swaps are profitable");
            }
        } catch Panic(uint256) /*errorCode*/ {
            // This is executed in case of a panic,
            // i.e. a serious error like division by zero
            // or overflow. The error code can be used
            // to determine the kind of error.
            //assert(false);
            return;
        } catch (bytes memory reason) {
            emit LogBytes(reason);
            return;
        }
    }

    // Internal helper function
    function swap(BunniSwapMath.BunniComputeSwapInput calldata input)
        public
        view
        returns (uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount0, uint256 outputAmount0)
    {
        require(msg.sender == address(this));
        (updatedSqrtPriceX96, updatedTick, inputAmount0, outputAmount0) = BunniSwapMath.computeSwap(input);
    }

    function _compute_idle_balance(
        int24 tickSpacing,
        uint64 balance0,
        uint64 balance1,
        int24 tickLower,
        int24 tickUpper,
        int24 currentTick,
        uint160 sqrtPriceX96
    ) internal view returns (IdleBalance idleBalance) {
        uint256 totalLiquidity;
        uint256 totalDensity0X96;
        uint256 totalDensity1X96;
        uint256 liquidityDensityOfRoundedTickX96;
        {
            PoolKey memory key;
            key.tickSpacing = tickSpacing;
            (totalLiquidity, totalDensity0X96, totalDensity1X96, liquidityDensityOfRoundedTickX96,,) = queryLDF({
                key: key,
                sqrtPriceX96: sqrtPriceX96,
                tick: currentTick,
                arithmeticMeanTick: int24(0),
                ldf: ldf,
                ldfParams: bytes32(abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper)),
                ldfState: LDF_STATE,
                balance0: balance0,
                balance1: balance1,
                idleBalance: IdleBalanceLibrary.ZERO
            });
        }

        (uint256 currentActiveBalance0, uint256 currentActiveBalance1) =
            (totalDensity0X96.fullMulDiv(totalLiquidity, Q96), totalDensity1X96.fullMulDiv(totalLiquidity, Q96));
        (uint256 extraBalance0, uint256 extraBalance1) = (
            balance0 > currentActiveBalance0 ? balance0 - currentActiveBalance0 : 0,
            balance1 > currentActiveBalance1 ? balance1 - currentActiveBalance1 : 0
        );
        return FixedPointMathLib.max(extraBalance0, extraBalance1).toIdleBalance(extraBalance0 >= extraBalance1);
    }

    function _compute_swap(
        int24 tickSpacing,
        uint64 balance0,
        uint64 balance1,
        int64 amountSpecified,
        uint160 sqrtPriceLimitX96,
        int24 tickLower,
        int24 tickUpper,
        int24 currentTick,
        bool zeroForOne
    ) internal returns (BunniSwapMath.BunniComputeSwapInput memory input, IdleBalance idleBalance) {
        tickSpacing = int24(clampBetween(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
        (int24 minUsableTick, int24 maxUsableTick) =
            (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));
        currentTick = int24(clampBetween(currentTick, minUsableTick, maxUsableTick));
        tickLower =
            roundTickSingle(int24(clampBetween(tickLower, minUsableTick, maxUsableTick - tickSpacing)), tickSpacing);
        tickUpper = roundTickSingle(int24(clampBetween(tickUpper, tickLower + tickSpacing, maxUsableTick)), tickSpacing);

        // compute sqrtPriceX96 and idleBalance
        uint160 sqrtPriceX96 = TickMath.getSqrtPriceAtTick(currentTick);
        idleBalance =
            _compute_idle_balance(tickSpacing, balance0, balance1, tickLower, tickUpper, currentTick, sqrtPriceX96);

        input = _compute_swap(
            tickSpacing,
            balance0,
            balance1,
            amountSpecified,
            sqrtPriceLimitX96,
            tickLower,
            tickUpper,
            currentTick,
            zeroForOne,
            sqrtPriceX96,
            idleBalance
        );
    }

    // Helper function to initialize the parameters for the swap
    function _compute_swap(
        int24 tickSpacing,
        uint64 balance0,
        uint64 balance1,
        int64 amountSpecified,
        uint160 sqrtPriceLimitX96,
        int24 tickLower,
        int24 tickUpper,
        int24 currentTick,
        bool zeroForOne,
        uint160 sqrtPriceX96,
        IdleBalance idleBalance
    ) internal returns (BunniSwapMath.BunniComputeSwapInput memory input) {
        {
            tickSpacing = int24(clampBetween(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING));
            (int24 minUsableTick, int24 maxUsableTick) =
                (TickMath.minUsableTick(tickSpacing), TickMath.maxUsableTick(tickSpacing));

            tickLower =
                roundTickSingle(int24(clampBetween(tickLower, minUsableTick, maxUsableTick - tickSpacing)), tickSpacing);
            tickUpper =
                roundTickSingle(int24(clampBetween(tickUpper, tickLower + tickSpacing, maxUsableTick)), tickSpacing);
            currentTick = int24(clampBetween(currentTick, minUsableTick, maxUsableTick));
        }

        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper));
        // set up pool key
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        if (!ldf.isValidParams(key, 0, ldfParams)) revert();

        // set up BunniComputeSwapInput
        input.key = key;
        input.sqrtPriceX96 = sqrtPriceX96;
        input.currentTick = currentTick;
        input.liquidityDensityFunction = ldf;
        input.arithmeticMeanTick = int24(0);
        input.ldfParams = ldfParams;
        input.ldfState = LDF_STATE;

        // initialize swap params
        input.swapParams.amountSpecified = clampBetween(amountSpecified, type(int64).min, type(int64).max);
        input.swapParams.sqrtPriceLimitX96 = zeroForOne
            ? uint160(clampBetween(sqrtPriceLimitX96, MIN_SQRT_PRICE, sqrtPriceX96))
            : uint160(clampBetween(sqrtPriceLimitX96, sqrtPriceX96, MAX_SQRT_PRICE));
        input.swapParams.zeroForOne = zeroForOne;

        // query the LDF to get total liquidity and token densities
        (
            uint256 totalLiquidity,
            uint256 totalDensity0X96,
            uint256 totalDensity1X96,
            uint256 liquidityDensityOfRoundedTickX96,
            ,
        ) = queryLDF({
            key: key,
            sqrtPriceX96: input.sqrtPriceX96,
            tick: input.currentTick,
            arithmeticMeanTick: input.arithmeticMeanTick,
            ldf: ldf,
            ldfParams: ldfParams,
            ldfState: LDF_STATE,
            balance0: balance0,
            balance1: balance1,
            idleBalance: idleBalance
        });

        input.totalLiquidity = totalLiquidity;
        input.totalDensity0X96 = totalDensity0X96;
        input.totalDensity1X96 = totalDensity1X96;
        input.liquidityDensityOfRoundedTickX96 = liquidityDensityOfRoundedTickX96;

        return input;
    }

    // Invariant: computeSwap in BunniSwapMath should output a valid sqrtPrice of the pool after the swap.
    function test_sqrtPrice_after_the_swap_is_valid(
        int24 tickSpacing,
        uint64 balance0,
        uint64 balance1,
        int64 amountSpecified,
        uint160 sqrtPriceLimit,
        int24 tickLower,
        int24 tickUpper,
        int24 currentTick,
        bool zeroForOne
    ) public {
        // Initialize LDF to Uniform distribution
        ldf = ILiquidityDensityFunction(address(new UniformDistribution()));

        // Initialize parameters before swapinng
        (BunniSwapMath.BunniComputeSwapInput memory input1,) = _compute_swap(
            tickSpacing,
            balance0,
            balance1,
            amountSpecified,
            sqrtPriceLimit,
            tickLower,
            tickUpper,
            currentTick,
            zeroForOne
        );

        try this.swap(input1) returns (
            uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount0, uint256 outputAmount0
        ) {
            require(outputAmount0 != 0 && inputAmount0 != 0);
            assertWithMsg(
                updatedSqrtPriceX96 >= MIN_SQRT_PRICE && updatedSqrtPriceX96 <= MAX_SQRT_PRICE,
                "sqrtPrice is outside the Limit"
            );
        } catch Panic(uint256) /*errorCode*/ {
            // This is executed in case of a panic,
            // i.e. a serious error like division by zero
            // or overflow. The error code can be used
            // to determine the kind of error.
            //assert(false);
            return;
        } catch (bytes memory reason) {
            emit LogBytes(reason);
            return;
        }
    }

    // Invariant: computeSwap in BunniSwapMath should not raise any panics
    //            during a swap on a valid pool state.
    // Issue: TOB-BUNNI-18
    function test_swap_panics(
        int24 tickSpacing,
        uint64 balance0,
        uint64 balance1,
        int64 amountSpecified,
        uint160 sqrtPriceLimit,
        int24 tickLower,
        int24 tickUpper,
        int24 currentTick,
        bool zeroForOne
    ) public {
        // Initialize LDF to Uniform distribution
        ldf = ILiquidityDensityFunction(address(new UniformDistribution()));

        // Initialize parameters before swapinng
        (BunniSwapMath.BunniComputeSwapInput memory input1,) = _compute_swap(
            tickSpacing,
            balance0,
            balance1,
            amountSpecified,
            sqrtPriceLimit,
            tickLower,
            tickUpper,
            currentTick,
            zeroForOne
        );

        try this.swap(input1) returns (
            uint160 updatedSqrtPriceX96, int24 updatedTick, uint256 inputAmount0, uint256 outputAmount0
        ) {} catch Panic(uint256) /*errorCode*/ {
            // This is executed in case of a panic,
            // i.e. a serious error like division by zero
            // or overflow. The error code can be used
            // to determine the kind of error.
            assertWithMsg(false, "panic");
        } catch (bytes memory reason) {
            emit LogBytes(reason);
            return;
        }
    }
}
