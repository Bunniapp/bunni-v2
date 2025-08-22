// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "./BaseTest.sol";
import {BunniStateLibrary} from "../src/lib/BunniStateLibrary.sol";

contract BunniStateLibraryTest is BaseTest {
    using BunniStateLibrary for *;

    function test_getVaultSharePricesAtLastSwap() public {
        // deploy pool
        (, PoolKey memory key) =
            _deployPoolAndInitLiquidity(Currency.wrap(address(token0)), Currency.wrap(address(token1)), vault0, vault1);
        PoolId id = key.toId();

        // check that the share prices are not initialized
        (bool initialized, uint120 sharePrice0, uint120 sharePrice1) = bunniHook.getVaultSharePricesAtLastSwap(id);
        assertEq(initialized, false, "share prices should not be initialized");
        assertEq(sharePrice0, 0, "share price 0 should be 0");
        assertEq(sharePrice1, 0, "share price 1 should be 0");

        // make a swap
        _mint(key.currency0, address(this), 1 ether);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(1 ether),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });
        _swap(key, params, 0, "");

        // check that the share prices are initialized
        (initialized, sharePrice0, sharePrice1) = bunniHook.getVaultSharePricesAtLastSwap(id);
        assertEq(initialized, true, "share prices should be initialized");
        assertApproxEqAbs(sharePrice0, 2e18, 10, "share price 0 should be 2e18");
        assertApproxEqAbs(sharePrice1, 2e18, 10, "share price 1 should be 2e18");

        // mint tokens to vault0 and vault1 to update the share prices
        // initial price is 2e18, so after minting vault0's price becomes 4e18 and vault1's price becomes 6e18
        _mint(key.currency0, address(vault0), token0.balanceOf(address(vault0)));
        _mint(key.currency1, address(vault1), token1.balanceOf(address(vault1)) * 2);

        // make a swap
        _mint(key.currency0, address(this), 1 ether);
        _swap(key, params, 0, "");

        // check that the share prices are updated
        (initialized, sharePrice0, sharePrice1) = bunniHook.getVaultSharePricesAtLastSwap(id);
        assertEq(initialized, true, "share prices should be initialized");
        assertApproxEqAbs(sharePrice0, 4e18, 10, "share price 0 should be 4e18");
        assertApproxEqAbs(sharePrice1, 6e18, 10, "share price 1 should be 6e18");
    }

    function test_getCuratorFees() public {
        // deploy pool
        (, PoolKey memory key) =
            _deployPoolAndInitLiquidity(Currency.wrap(address(token0)), Currency.wrap(address(token1)), vault0, vault1);
        PoolId id = key.toId();

        // check that the curator fees are not initialized
        (uint16 feeRate, uint120 accruedFee0, uint120 accruedFee1) = bunniHook.getCuratorFees(id);
        assertEq(feeRate, 0, "fee rate should be 0");
        assertEq(accruedFee0, 0, "accrued fee 0 should be 0");
        assertEq(accruedFee1, 0, "accrued fee 1 should be 0");

        // set the curator fee rate
        bunniHook.curatorSetFeeRate(id, 100);

        // check that the curator fee rate is set
        (feeRate, accruedFee0, accruedFee1) = bunniHook.getCuratorFees(id);
        assertEq(feeRate, 100, "fee rate should be 100");
        assertEq(accruedFee0, 0, "accrued fee 0 should be 0");
        assertEq(accruedFee1, 0, "accrued fee 1 should be 0");

        // make a swap
        // exactIn == true, zeroForOne == true, thus fee will be in token1
        _mint(key.currency0, address(this), 1 ether);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(1 ether),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });
        _swap(key, params, 0, "");

        // check that the curator fees are updated
        (feeRate, accruedFee0, accruedFee1) = bunniHook.getCuratorFees(id);
        assertEq(feeRate, 100, "fee rate should be 100");
        assertEq(accruedFee0, 0, "accrued fee 0 should be 0");
        assertGt(accruedFee1, 0, "accrued fee 1 should be greater than 0");
    }

    /// @notice Comprehensive test for BunniStateLibrary::getCardinalityNext() function
    /// @dev Tests various scenarios including initial state, cardinality increases, edge cases, and boundary conditions
    function test_getCardinalityNext() public {
        // Deploy pool and initialize liquidity
        (, PoolKey memory key) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)), Currency.wrap(address(token1)), bytes32(uint256(1))
        );
        PoolId id = key.toId();

        // Test 1: Check initial cardinality next value after pool deployment
        // The pool should be initialized with a default cardinality next value
        uint32 initialCardinalityNext = bunniHook.getCardinalityNext(id);
        assertGt(initialCardinalityNext, 0, "Initial cardinality next should be greater than 0");

        // Test 2: Increase cardinality next to a moderate value
        uint32 targetCardinality1 = 100;
        (uint32 oldCardinality1, uint32 newCardinality1) = bunniHook.increaseCardinalityNext(key, targetCardinality1);

        // Verify the returned values from increaseCardinalityNext
        assertEq(oldCardinality1, initialCardinalityNext, "Old cardinality should match initial value");
        assertGe(newCardinality1, targetCardinality1, "New cardinality should be at least the target value");

        // Verify getCardinalityNext returns the updated value
        uint32 retrievedCardinality1 = bunniHook.getCardinalityNext(id);
        assertEq(retrievedCardinality1, newCardinality1, "Retrieved cardinality should match the new value");

        // Test 3: Attempt to set cardinality to a lower value (should be no-op)
        uint32 lowerTarget = 50;
        (uint32 oldCardinality2, uint32 newCardinality2) = bunniHook.increaseCardinalityNext(key, lowerTarget);

        assertEq(oldCardinality2, newCardinality1, "Old cardinality should be the previous new value");
        assertEq(newCardinality2, newCardinality1, "Cardinality should not decrease");

        uint32 retrievedCardinality2 = bunniHook.getCardinalityNext(id);
        assertEq(retrievedCardinality2, newCardinality1, "Cardinality should remain unchanged");

        // Test 4: Increase cardinality to a larger value
        uint32 targetCardinality3 = 1000;
        (uint32 oldCardinality3, uint32 newCardinality3) = bunniHook.increaseCardinalityNext(key, targetCardinality3);

        assertEq(oldCardinality3, newCardinality1, "Old cardinality should be the previous value");
        assertGe(newCardinality3, targetCardinality3, "New cardinality should be at least the target");
        assertGt(newCardinality3, newCardinality1, "New cardinality should be greater than previous");

        uint32 retrievedCardinality3 = bunniHook.getCardinalityNext(id);
        assertEq(retrievedCardinality3, newCardinality3, "Retrieved cardinality should match the new value");

        // Test 5: Test with maximum safe cardinality value
        // MAX_CARDINALITY is 2^24 - 1 = 16777215, but we'll test with a large but safe value
        uint32 largeCardinality = 10000;
        (uint32 oldCardinality4, uint32 newCardinality4) = bunniHook.increaseCardinalityNext(key, largeCardinality);

        assertEq(oldCardinality4, newCardinality3, "Old cardinality should be the previous value");
        assertGe(newCardinality4, largeCardinality, "New cardinality should be at least the large target");

        uint32 retrievedCardinality4 = bunniHook.getCardinalityNext(id);
        assertEq(retrievedCardinality4, newCardinality4, "Retrieved cardinality should match the large value");

        // Test 6: Verify cardinality next persists across multiple operations
        // Make a swap to trigger oracle updates
        _mint(key.currency0, address(this), 1 ether);
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(1 ether),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });
        _swap(key, params, 0, "");

        // Cardinality next should remain unchanged after swap
        uint32 cardinalityAfterSwap = bunniHook.getCardinalityNext(id);
        assertEq(cardinalityAfterSwap, newCardinality4, "Cardinality next should persist after swap");

        // Test 7: Test with a different pool to ensure isolation
        (, PoolKey memory key2) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)), Currency.wrap(address(token1)), bytes32(uint256(2))
        );
        PoolId id2 = key2.toId();

        uint32 secondPoolCardinality = bunniHook.getCardinalityNext(id2);
        assertGt(secondPoolCardinality, 0, "Second pool should have initial cardinality");
        assertNotEq(secondPoolCardinality, cardinalityAfterSwap, "Different pools should have independent cardinality");

        // Modify second pool's cardinality
        uint32 targetForSecondPool = 500;
        bunniHook.increaseCardinalityNext(key2, targetForSecondPool);
        uint32 secondPoolNewCardinality = bunniHook.getCardinalityNext(id2);

        // Verify first pool's cardinality is unaffected
        uint32 firstPoolFinalCardinality = bunniHook.getCardinalityNext(id);
        assertEq(firstPoolFinalCardinality, cardinalityAfterSwap, "First pool cardinality should be unaffected");
        assertNotEq(secondPoolNewCardinality, firstPoolFinalCardinality, "Pools should have different cardinalities");

        // Test 8: Edge case - cardinality value of 1 (minimum valid cardinality)
        (, PoolKey memory key3) = _deployPoolAndInitLiquidity(
            Currency.wrap(address(token0)), Currency.wrap(address(token1)), bytes32(uint256(3))
        );

        PoolId id3 = key3.toId();

        // Try to set cardinality to 1 (should work as it's the minimum)
        bunniHook.increaseCardinalityNext(key3, 1);
        uint32 minCardinality = bunniHook.getCardinalityNext(id3);
        assertGe(minCardinality, 1, "Cardinality should be at least 1");
    }
}
