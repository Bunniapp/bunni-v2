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
        BunniSwapMath.BunniComputeSwapInput memory input1 = _compute_swap(
            tickSpacing,
            balance0,
            balance1,
            amountSpecified,
            sqrtPriceLimit,
            tickLower,
            tickUpper,
            currentTick
        );

        input1.swapParams.zeroForOne = zeroForOne;
        try this.swap(input1, balance0, balance1) returns (
            uint160 updatedSqrtPriceX96,
            int24 updatedTick,
            uint256 inputAmount0,
            uint256 outputAmount0
        ) {
            require(inputAmount0 != 0 && outputAmount0 != 0);

            if (
                inputAmount0 != uint64(inputAmount0) ||
                outputAmount0 != uint64(outputAmount0)
            ) return;

            BunniSwapMath.BunniComputeSwapInput memory input2 = _compute_swap(
                tickSpacing,
                balance0,
                balance1,
                -amountSpecified,
                sqrtPriceLimit,
                tickLower,
                tickUpper,
                currentTick
            );
            input2.swapParams.amountSpecified = amountSpecified < 0
                ? int256(outputAmount0)
                : -int256(inputAmount0);
            input2.swapParams.zeroForOne = zeroForOne;

            (, , uint256 inputAmount1, uint256 outputAmount1) = BunniSwapMath
                .computeSwap(input2, balance0, balance1);

            if (amountSpecified < 0)
                assertWithMsg(
                    inputAmount0 >= inputAmount1,
                    "Users can profit from Exact In and Exact Out combination"
                );
            else
                assertWithMsg(
                    outputAmount0 >= outputAmount1,
                    "Users can profit from Exact In and Exact Out combination"
                );
        } catch Panic(uint /*errorCode*/) {
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
        BunniSwapMath.BunniComputeSwapInput memory input1 = _compute_swap(
            tickSpacing,
            balance0,
            balance1,
            amountSpecified,
            sqrtPriceLimit,
            tickLower,
            tickUpper,
            currentTick
        );

        input1.swapParams.zeroForOne = zeroForOne;
        try this.swap(input1, balance0, balance1) returns (
            uint160 updatedSqrtPriceX96,
            int24 updatedTick,
            uint256 inputAmount0,
            uint256 outputAmount0
        ) {
            if (outputAmount0 > 0 && inputAmount0 == 0) {
                assertWithMsg(false, "Users get free tokens");
            }
        } catch Panic(uint /*errorCode*/) {
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
        BunniSwapMath.BunniComputeSwapInput memory input1 = _compute_swap(
            tickSpacing,
            balance0,
            balance1,
            amountSpecified,
            sqrtPriceLimit,
            tickLower,
            tickUpper,
            currentTick
        );

        input1.swapParams.zeroForOne = true;
        try this.swap(input1, balance0, balance1) returns (
            uint160 updatedSqrtPriceX96,
            int24 updatedTick,
            uint256 inputAmount0,
            uint256 outputAmount0
        ) {
            require(outputAmount0 != 0 && inputAmount0 != 0);
            if (
                inputAmount0 != uint64(inputAmount0) ||
                outputAmount0 != uint64(outputAmount0)
            ) return;

            BunniSwapMath.BunniComputeSwapInput memory input2 = _compute_swap(
                tickSpacing,
                uint64(balance0 + inputAmount0),
                uint64(balance1 - outputAmount0),
                -amountSpecified,
                sqrtPriceLimit,
                tickLower,
                tickUpper,
                updatedTick
            );
            input2.swapParams.amountSpecified = amountSpecified < 0
                ? -int256(outputAmount0)
                : int256(inputAmount0);
            input2.swapParams.zeroForOne = false;

            (
                uint160 updatedSqrtPriceX960,
                int24 updatedTick0,
                uint256 inputAmount1,
                uint256 outputAmount1
            ) = BunniSwapMath.computeSwap(
                    input2,
                    uint64(balance0 + inputAmount0),
                    uint64(balance1 - outputAmount0)
                );

            if (amountSpecified < 0)
                assertWithMsg(
                    inputAmount0 >= outputAmount1,
                    "Round trips swaps are profitable"
                );
            else
                assertWithMsg(
                    outputAmount0 <= inputAmount1,
                    "Round trips swaps are profitable"
                );
        } catch Panic(uint /*errorCode*/) {
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
    function swap(
        BunniSwapMath.BunniComputeSwapInput calldata input,
        uint256 balance0,
        uint256 balance1
    )
        public
        returns (
            uint160 updatedSqrtPriceX96,
            int24 updatedTick,
            uint256 inputAmount0,
            uint256 outputAmount0
        )
    {
        require(msg.sender == address(this));
        (
            updatedSqrtPriceX96,
            updatedTick,
            inputAmount0,
            outputAmount0
        ) = BunniSwapMath.computeSwap(input, balance0, balance1);
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
        int24 currentTick
    ) internal returns (BunniSwapMath.BunniComputeSwapInput memory input) {
        tickSpacing = int24(
            clampBetween(tickSpacing, MIN_TICK_SPACING, MAX_TICK_SPACING)
        );
        (int24 minUsableTick, int24 maxUsableTick) = (
            TickMath.minUsableTick(tickSpacing),
            TickMath.maxUsableTick(tickSpacing)
        );

        tickLower = roundTickSingle(
            int24(
                clampBetween(
                    tickLower,
                    minUsableTick,
                    maxUsableTick - tickSpacing
                )
            ),
            tickSpacing
        );
        tickUpper = roundTickSingle(
            int24(
                clampBetween(tickUpper, tickLower + tickSpacing, maxUsableTick)
            ),
            tickSpacing
        );
        currentTick = roundTickSingle(
            int24(clampBetween(currentTick, minUsableTick, maxUsableTick)),
            tickSpacing
        );

        bytes32 ldfParams = bytes32(
            abi.encodePacked(ShiftMode.STATIC, tickLower, tickUpper)
        );
        // set up pool key
        PoolKey memory key;
        key.tickSpacing = tickSpacing;

        if (!ldf.isValidParams(key, 0, ldfParams)) revert();

        // set up BunniComputeSwapInput
        input.key = key;
        input.sqrtPriceX96 = TickMath.getSqrtPriceAtTick(currentTick);
        input.currentTick = currentTick;
        input.liquidityDensityFunction = ldf;
        input.arithmeticMeanTick = int24(0);
        input.ldfParams = ldfParams;
        input.ldfState = LDF_STATE;

        // initialize swap params
        input.swapParams.amountSpecified = clampBetween(
            amountSpecified,
            type(int64).min,
            type(int64).max
        );
        input.swapParams.sqrtPriceLimitX96 = uint160(
            clampBetween(sqrtPriceLimitX96, MIN_SQRT_PRICE, MAX_SQRT_PRICE)
        );

        // query the LDF to get total liquidity and token densities
        (
            uint256 totalLiquidity,
            uint256 totalDensity0X96,
            uint256 totalDensity1X96,
            uint256 liquidityDensityOfRoundedTickX96,
            bytes32 newLdfState,
            bool shouldSurge
        ) = queryLDF({
                key: key,
                sqrtPriceX96: input.sqrtPriceX96,
                tick: input.currentTick,
                arithmeticMeanTick: input.arithmeticMeanTick,
                ldf: ldf,
                ldfParams: ldfParams,
                ldfState: LDF_STATE,
                balance0: balance0,
                balance1: balance1
            });

        input.totalLiquidity = totalLiquidity;
        input.totalDensity0X96 = totalDensity0X96;
        input.totalDensity1X96 = totalDensity1X96;
        input
            .liquidityDensityOfRoundedTickX96 = liquidityDensityOfRoundedTickX96;

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
        BunniSwapMath.BunniComputeSwapInput memory input1 = _compute_swap(
            tickSpacing,
            balance0,
            balance1,
            amountSpecified,
            sqrtPriceLimit,
            tickLower,
            tickUpper,
            currentTick
        );

        input1.swapParams.zeroForOne = zeroForOne;
        try this.swap(input1, balance0, balance1) returns (
            uint160 updatedSqrtPriceX96,
            int24 updatedTick,
            uint256 inputAmount0,
            uint256 outputAmount0
        ) {
            require(outputAmount0 != 0 && inputAmount0 != 0);
            assertWithMsg(
                updatedSqrtPriceX96 >= MIN_SQRT_PRICE &&
                    updatedSqrtPriceX96 <= MAX_SQRT_PRICE,
                "sqrtPrice is outside the Limit"
            );
        } catch Panic(uint /*errorCode*/) {
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
        BunniSwapMath.BunniComputeSwapInput memory input1 = _compute_swap(
            tickSpacing,
            balance0,
            balance1,
            amountSpecified,
            sqrtPriceLimit,
            tickLower,
            tickUpper,
            currentTick
        );

        input1.swapParams.zeroForOne = zeroForOne;
        try this.swap(input1, balance0, balance1) returns (
            uint160 updatedSqrtPriceX96,
            int24 updatedTick,
            uint256 inputAmount0,
            uint256 outputAmount0
        ) {} catch Panic(uint /*errorCode*/) {
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
