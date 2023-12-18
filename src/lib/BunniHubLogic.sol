// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {LibMulticaller} from "multicaller/LibMulticaller.sol";

import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import "@uniswap/v4-core/src/libraries/SqrtPriceMath.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {CREATE3} from "solady/src/utils/CREATE3.sol";
import {SSTORE2} from "solady/src/utils/SSTORE2.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {WETH} from "solmate/tokens/WETH.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import "./Math.sol";
import "./Structs.sol";
import "./VaultMath.sol";
import "../interfaces/IBunniHub.sol";
import {BunniToken} from "../BunniToken.sol";
import {SafeTransferLib} from "./SafeTransferLib.sol";
import {IBunniHook} from "../interfaces/IBunniHook.sol";
import {LiquidityAmounts} from "./LiquidityAmounts.sol";
import {IBunniToken} from "../interfaces/IBunniToken.sol";

library BunniHubLogic {
    using SSTORE2 for bytes;
    using SSTORE2 for address;
    using SafeCastLib for int256;
    using SafeCastLib for uint256;
    using PoolIdLibrary for PoolKey;
    using SafeTransferLib for address;
    using CurrencyLibrary for Currency;
    using FixedPointMathLib for uint128;
    using FixedPointMathLib for uint256;

    uint256 internal constant WAD = 1e18;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
    uint256 internal constant MAX_NONCE = 0x0FFFFF;
    uint256 internal constant MIN_INITIAL_SHARES = 1e3;

    enum LockCallbackType {
        HOOK_MODIFY_LIQUIDITY,
        MODIFY_LIQUIDITY,
        CLEAR_POOL_CREDITS,
        INITIALIZE_POOL
    }

    /// -----------------------------------------------------------------------
    /// Deposit
    /// -----------------------------------------------------------------------

    function deposit(
        IBunniHub.DepositParams calldata params,
        IPoolManager poolManager,
        mapping(PoolId => RawPoolState) storage _poolState,
        mapping(PoolId => uint256) storage poolCredit0,
        mapping(PoolId => uint256) storage poolCredit1
    ) external returns (uint256 shares, uint128 addedLiquidity, uint256 amount0, uint256 amount1) {
        address msgSender = LibMulticaller.senderOrSigner();
        PoolId poolId = params.poolKey.toId();
        PoolState memory state = _getPoolState(poolId, _poolState);

        (uint160 sqrtPriceX96, int24 currentTick,) = poolManager.getSlot0(poolId);
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, params.poolKey.tickSpacing);

        uint128 currentLiquidity = poolManager.getLiquidity(poolId);
        DepositLogicReturnData memory depositReturnData = _depositLogic(
            DepositLogicInputData({
                state: state,
                params: params,
                poolId: poolId,
                currentTick: currentTick,
                currentLiquidity: currentLiquidity,
                sqrtPriceX96: sqrtPriceX96,
                roundedTick: roundedTick,
                nextRoundedTick: nextRoundedTick,
                poolCredit0: state.poolCredit0Set ? poolCredit0[poolId] : 0,
                poolCredit1: state.poolCredit1Set ? poolCredit1[poolId] : 0
            })
        );
        addedLiquidity = depositReturnData.addedLiquidity;
        uint256 depositAmount0 = depositReturnData.depositAmount0;
        uint256 depositAmount1 = depositReturnData.depositAmount1;
        amount0 = depositReturnData.amount0;
        amount1 = depositReturnData.amount1;
        shares = depositReturnData.shares;

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // add liquidity and reserves
        BalanceDelta reserveDeltaInUnderlying =
            toBalanceDelta(depositAmount0.toInt256().toInt128(), depositAmount1.toInt256().toInt128());
        ModifyLiquidityInputData memory inputData = ModifyLiquidityInputData({
            poolKey: params.poolKey,
            tickLower: roundedTick,
            tickUpper: nextRoundedTick,
            liquidityDelta: uint256(addedLiquidity).toInt256(),
            user: msgSender,
            reserveDeltaInUnderlying: reserveDeltaInUnderlying,
            currentLiquidity: currentLiquidity,
            vault0: state.vault0,
            vault1: state.vault1
        });
        ModifyLiquidityReturnData memory returnData = abi.decode(
            poolManager.lock(address(this), abi.encode(LockCallbackType.MODIFY_LIQUIDITY, abi.encode(inputData))),
            (ModifyLiquidityReturnData)
        );
        if (amount0 < params.amount0Min || amount1 < params.amount1Min) {
            revert BunniHub__SlippageTooHigh();
        }

        // update reserves
        // reserves represent the amount of tokens not in the current tick
        _poolState[poolId].reserve0 = (state.reserve0.toInt256() + returnData.reserveChange0).toUint256();
        _poolState[poolId].reserve1 = (state.reserve1.toInt256() + returnData.reserveChange1).toUint256();

        // refund excess ETH
        if (address(this).balance != 0) {
            params.refundETHRecipient.safeTransferETH(address(this).balance);
        }

        // emit event
        emit IBunniHub.Deposit(msgSender, params.recipient, poolId, amount0, amount1, shares);
    }

    struct DepositLogicInputData {
        PoolState state;
        IBunniHub.DepositParams params;
        PoolId poolId;
        int24 currentTick;
        uint128 currentLiquidity;
        uint160 sqrtPriceX96;
        int24 roundedTick;
        int24 nextRoundedTick;
        uint256 poolCredit0;
        uint256 poolCredit1;
    }

    struct DepositLogicReturnData {
        uint128 addedLiquidity;
        uint256 depositAmount0;
        uint256 depositAmount1;
        uint256 amount0;
        uint256 amount1;
        uint256 shares;
    }

    struct DepositLogicVariables {
        uint160 roundedTickSqrtRatio;
        uint160 nextRoundedTickSqrtRatio;
        uint256 existingAmount0;
        uint256 existingAmount1;
        uint256 assets0;
        uint256 assets1;
        int24 arithmeticMeanTick;
    }

    /// @dev Separated to avoid stack too deep error
    function _depositLogic(DepositLogicInputData memory inputData)
        private
        returns (DepositLogicReturnData memory returnData)
    {
        DepositLogicVariables memory vars;
        (vars.roundedTickSqrtRatio, vars.nextRoundedTickSqrtRatio) =
            (TickMath.getSqrtRatioAtTick(inputData.roundedTick), TickMath.getSqrtRatioAtTick(inputData.nextRoundedTick));

        // query existing assets
        // assets = urrent tick tokens + reserve tokens + pool credits
        (vars.existingAmount0, vars.existingAmount1) = LiquidityAmounts.getAmountsForLiquidity(
            inputData.sqrtPriceX96,
            vars.roundedTickSqrtRatio,
            vars.nextRoundedTickSqrtRatio,
            inputData.currentLiquidity,
            false
        );
        (vars.assets0, vars.assets1) = (
            vars.existingAmount0 + getReservesInUnderlying(inputData.state.reserve0, inputData.state.vault0)
                + inputData.poolCredit0,
            vars.existingAmount1 + getReservesInUnderlying(inputData.state.reserve1, inputData.state.vault1)
                + inputData.poolCredit1
        );

        // update TWAP oracle and optionally observe
        bool requiresLDF = vars.assets0 == 0 && vars.assets1 == 0;

        if (requiresLDF) {
            // use LDF to initialize token proportions

            IBunniHook hook = IBunniHook(address(inputData.params.poolKey.hooks));

            // update TWAP oracle and optionally observe
            // need to update oracle before using it in the LDF
            {
                uint24 twapSecondsAgo = inputData.state.twapSecondsAgo;
                // we only need to observe the TWAP if currentTotalSupply is zero
                assembly ("memory-safe") {
                    twapSecondsAgo := mul(twapSecondsAgo, requiresLDF)
                }
                vars.arithmeticMeanTick =
                    hook.updateOracleAndObserve(inputData.poolId, inputData.currentTick, twapSecondsAgo);
            }

            // compute density
            bool useTwap = inputData.state.twapSecondsAgo != 0;
            bytes32 ldfState = inputData.state.statefulLdf ? hook.ldfStates(inputData.poolId) : bytes32(0);
            (
                uint256 liquidityDensityOfRoundedTickX96,
                uint256 density0RightOfRoundedTickX96,
                uint256 density1LeftOfRoundedTickX96,
                bytes32 newLdfState
            ) = inputData.state.liquidityDensityFunction.query(
                inputData.params.poolKey,
                inputData.roundedTick,
                vars.arithmeticMeanTick,
                inputData.currentTick,
                useTwap,
                inputData.state.ldfParams,
                ldfState
            );
            if (inputData.state.statefulLdf) hook.updateLdfState(inputData.poolId, newLdfState);
            (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts
                .getAmountsForLiquidity(
                inputData.sqrtPriceX96,
                vars.roundedTickSqrtRatio,
                vars.nextRoundedTickSqrtRatio,
                uint128(liquidityDensityOfRoundedTickX96),
                false
            );

            // compute how much liquidity we'd get from the desired token amounts
            uint256 totalDensity0X96 = density0RightOfRoundedTickX96 + density0OfRoundedTickX96;
            uint256 totalDensity1X96 = density1LeftOfRoundedTickX96 + density1OfRoundedTickX96;
            uint256 totalLiquidity = min(
                totalDensity0X96 == 0
                    ? type(uint256).max
                    : inputData.params.amount0Desired.mulDivDown(Q96, totalDensity0X96),
                totalDensity1X96 == 0
                    ? type(uint256).max
                    : inputData.params.amount1Desired.mulDivDown(Q96, totalDensity1X96)
            );
            // totalLiquidity could exceed uint128 so .toUint128() is used
            returnData.addedLiquidity = ((totalLiquidity * liquidityDensityOfRoundedTickX96) >> 96).toUint128();

            // compute token amounts
            (uint256 addedLiquidityAmount0, uint256 addedLiquidityAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                inputData.sqrtPriceX96,
                vars.roundedTickSqrtRatio,
                vars.nextRoundedTickSqrtRatio,
                returnData.addedLiquidity,
                true
            );
            (returnData.depositAmount0, returnData.depositAmount1) = (
                totalLiquidity.mulDivUp(density0RightOfRoundedTickX96, Q96),
                totalLiquidity.mulDivUp(density1LeftOfRoundedTickX96, Q96)
            );
            (returnData.amount0, returnData.amount1) =
                (addedLiquidityAmount0 + returnData.depositAmount0, addedLiquidityAmount1 + returnData.depositAmount1);

            // sanity check against desired amounts
            // the amounts can exceed the desired amounts due to math errors
            if (
                (returnData.amount0 > inputData.params.amount0Desired)
                    || (returnData.amount1 > inputData.params.amount1Desired)
            ) {
                // scale down amounts and take minimum
                if (returnData.amount0 == 0) {
                    (returnData.amount1, returnData.addedLiquidity) = (
                        inputData.params.amount1Desired,
                        uint128(
                            returnData.addedLiquidity.mulDivDown(inputData.params.amount1Desired, returnData.amount1)
                            )
                    );
                } else if (returnData.amount1 == 0) {
                    (returnData.amount0, returnData.addedLiquidity) = (
                        inputData.params.amount0Desired,
                        uint128(
                            returnData.addedLiquidity.mulDivDown(inputData.params.amount0Desired, returnData.amount0)
                            )
                    );
                } else {
                    // both are non-zero
                    (returnData.amount0, returnData.amount1, returnData.addedLiquidity) = (
                        min(
                            inputData.params.amount0Desired,
                            returnData.amount0.mulDivDown(inputData.params.amount1Desired, returnData.amount1)
                            ),
                        min(
                            inputData.params.amount1Desired,
                            returnData.amount1.mulDivDown(inputData.params.amount0Desired, returnData.amount0)
                            ),
                        uint128(
                            min(
                                returnData.addedLiquidity.mulDivDown(
                                    inputData.params.amount0Desired, returnData.amount0
                                ),
                                returnData.addedLiquidity.mulDivDown(
                                    inputData.params.amount1Desired, returnData.amount1
                                )
                            )
                            )
                    );
                }

                // update token amounts
                (addedLiquidityAmount0, addedLiquidityAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                    inputData.sqrtPriceX96,
                    vars.roundedTickSqrtRatio,
                    vars.nextRoundedTickSqrtRatio,
                    returnData.addedLiquidity,
                    true
                );
                (returnData.depositAmount0, returnData.depositAmount1) =
                    (returnData.amount0 - addedLiquidityAmount0, returnData.amount1 - addedLiquidityAmount1);
            }
        } else {
            // already initialized liquidity shape
            // simply add tokens at the current ratio
            // need to update: addedLiquidity, depositAmount0, depositAmount1, amount0, amount1

            // compute amount0 and amount1 such that the ratio is the same as the current ratio
            returnData.amount0 = vars.assets1 == 0
                ? inputData.params.amount0Desired
                : min(
                    inputData.params.amount0Desired, inputData.params.amount1Desired.mulDivDown(vars.assets0, vars.assets1)
                );
            returnData.amount1 = vars.assets0 == 0
                ? inputData.params.amount1Desired
                : min(
                    inputData.params.amount1Desired, inputData.params.amount0Desired.mulDivDown(vars.assets1, vars.assets0)
                );

            // compute added liquidity using current liquidity
            returnData.addedLiquidity = inputData.currentLiquidity.mulDivDown(
                returnData.amount0 + returnData.amount1, vars.assets0 + vars.assets1
            ).toUint128();

            // remaining tokens will be deposited into the reserves
            (uint256 addedLiquidityAmount0, uint256 addedLiquidityAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                inputData.sqrtPriceX96,
                vars.roundedTickSqrtRatio,
                vars.nextRoundedTickSqrtRatio,
                returnData.addedLiquidity,
                true
            );
            returnData.depositAmount0 = returnData.amount0 - addedLiquidityAmount0;
            returnData.depositAmount1 = returnData.amount1 - addedLiquidityAmount1;
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // mint shares
        returnData.shares = _mintShares(
            inputData.state.bunniToken,
            inputData.params.recipient,
            returnData.amount0,
            vars.assets0,
            returnData.amount1,
            vars.assets1
        );
    }

    /// -----------------------------------------------------------------------
    /// Withdraw
    /// -----------------------------------------------------------------------

    function withdraw(
        IBunniHub.WithdrawParams calldata params,
        IPoolManager poolManager,
        mapping(PoolId => RawPoolState) storage _poolState,
        mapping(PoolId => uint256) storage poolCredit0,
        mapping(PoolId => uint256) storage poolCredit1
    ) external returns (uint128 removedLiquidity, uint256 amount0, uint256 amount1) {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (params.shares == 0) revert BunniHub__ZeroInput();

        PoolId poolId = params.poolKey.toId();
        PoolState memory state = _getPoolState(poolId, _poolState);

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        uint256 currentTotalSupply = state.bunniToken.totalSupply();
        (, int24 currentTick,) = poolManager.getSlot0(poolId);
        uint128 existingLiquidity = poolManager.getLiquidity(poolId);
        address msgSender = LibMulticaller.senderOrSigner();

        // burn shares
        state.bunniToken.burn(msgSender, params.shares);
        // at this point of execution we know params.shares <= currentTotalSupply
        // since otherwise the burn() call would've reverted

        // burn liquidity from pool
        // type cast is safe because we know removedLiquidity <= existingLiquidity
        removedLiquidity = uint128(existingLiquidity.mulDivDown(params.shares, currentTotalSupply));

        uint256 removedReserve0InUnderlying =
            getReservesInUnderlying(state.reserve0.mulDivDown(params.shares, currentTotalSupply), state.vault0);
        uint256 removedReserve1InUnderlying =
            getReservesInUnderlying(state.reserve1.mulDivDown(params.shares, currentTotalSupply), state.vault1);
        if (state.poolCredit0Set) {
            removedReserve0InUnderlying += poolCredit0[poolId].mulDivDown(params.shares, currentTotalSupply);
        }
        if (state.poolCredit1Set) {
            removedReserve1InUnderlying += poolCredit1[poolId].mulDivDown(params.shares, currentTotalSupply);
        }

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // burn liquidity and withdraw reserves
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, params.poolKey.tickSpacing);
        BalanceDelta reserveDeltaInUnderlying = toBalanceDelta(
            -removedReserve0InUnderlying.toInt256().toInt128(), -removedReserve1InUnderlying.toInt256().toInt128()
        );
        ModifyLiquidityInputData memory inputData = ModifyLiquidityInputData({
            poolKey: params.poolKey,
            tickLower: roundedTick,
            tickUpper: nextRoundedTick,
            liquidityDelta: -uint256(removedLiquidity).toInt256(),
            user: msgSender,
            reserveDeltaInUnderlying: reserveDeltaInUnderlying,
            currentLiquidity: existingLiquidity,
            vault0: state.vault0,
            vault1: state.vault1
        });

        ModifyLiquidityReturnData memory returnData = abi.decode(
            poolManager.lock(address(this), abi.encode(LockCallbackType.MODIFY_LIQUIDITY, abi.encode(inputData))),
            (ModifyLiquidityReturnData)
        );
        (amount0, amount1) =
            (returnData.amount0 + removedReserve0InUnderlying, returnData.amount1 + removedReserve1InUnderlying);
        if (amount0 < params.amount0Min || amount1 < params.amount1Min) {
            revert BunniHub__SlippageTooHigh();
        }

        // update reserves
        // reserves represent the amount of tokens not in the current tick
        _poolState[poolId].reserve0 = (state.reserve0.toInt256() + returnData.reserveChange0).toUint256();
        _poolState[poolId].reserve1 = (state.reserve1.toInt256() + returnData.reserveChange1).toUint256();

        emit IBunniHub.Withdraw(msgSender, params.recipient, poolId, amount0, amount1, params.shares);
    }

    /// -----------------------------------------------------------------------
    /// Deploy Bunni Token
    /// -----------------------------------------------------------------------

    function deployBunniToken(
        IBunniHub.DeployBunniTokenParams calldata params,
        IPoolManager poolManager,
        mapping(PoolId => RawPoolState) storage _poolState,
        mapping(bytes32 => uint24) storage nonce,
        mapping(IBunniToken => PoolId) storage poolIdOfBunniToken,
        WETH weth
    ) external returns (IBunniToken token, PoolKey memory key) {
        /// -----------------------------------------------------------------------
        /// Verification
        /// -----------------------------------------------------------------------

        // each Uniswap v4 pool corresponds to a single BunniToken
        // since Univ4 pool key is deterministic based on poolKey, we use dynamic fee so that the lower 20 bits of `poolKey.fee` is used
        // as nonce to differentiate the BunniTokens
        // each "subspace" has its own nonce that's incremented whenever a BunniToken is deployed with the same tokens & tick spacing & hooks
        // nonce can be at most 2^20 - 1 = 1048575 after which the deployment will fail
        bytes32 bunniSubspace =
            keccak256(abi.encode(params.currency0, params.currency1, params.tickSpacing, params.hooks));
        uint24 nonce_ = nonce[bunniSubspace];
        if (nonce_ + 1 > MAX_NONCE) revert BunniHub__MaxNonceReached();

        // ensure LDF params are valid
        if (address(params.liquidityDensityFunction) == address(0)) revert BunniHub__LDFCannotBeZero();
        if (!params.liquidityDensityFunction.isValidParams(params.tickSpacing, params.twapSecondsAgo, params.ldfParams))
        {
            revert BunniHub__InvalidLDFParams();
        }

        // ensure hook params are valid
        if (address(params.hooks) == address(0)) revert BunniHub__HookCannotBeZero();
        if (!params.hooks.isValidParams(params.hookParams)) revert BunniHub__InvalidHookParams();

        // validate vaults
        _validateVault(params.vault0, params.currency0, weth);
        _validateVault(params.vault1, params.currency1, weth);

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // deploy BunniToken
        token = IBunniToken(
            CREATE3.deploy(
                keccak256(abi.encode(bunniSubspace, nonce_)),
                abi.encodePacked(type(BunniToken).creationCode, abi.encode(this, params.currency0, params.currency1)),
                0
            )
        );

        key = PoolKey({
            currency0: params.currency0,
            currency1: params.currency1,
            fee: uint24(0xC00000) + nonce_, // top nibble is 1100 to enable dynamic fee & hook swap fee, bottom 20 bits are the nonce
            tickSpacing: params.tickSpacing,
            hooks: params.hooks
        });
        PoolId poolId = key.toId();
        poolIdOfBunniToken[token] = poolId;

        // increment nonce
        nonce[bunniSubspace] = nonce_ + 1;

        // set immutable params
        _poolState[poolId].immutableParamsPointer = abi.encodePacked(
            params.liquidityDensityFunction,
            token,
            params.twapSecondsAgo,
            params.ldfParams,
            params.hookParams,
            params.vault0,
            params.vault1,
            params.statefulLdf
        ).write();

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // initialize Uniswap v4 pool
        poolManager.lock(
            address(this),
            abi.encode(
                LockCallbackType.INITIALIZE_POOL,
                abi.encode(
                    InitializePoolCallbackInputData(key, params.sqrtPriceX96, params.twapSecondsAgo, params.hookParams)
                )
            )
        );

        // initialize cardinality target
        if (params.cardinalityNext != 0) {
            params.hooks.increaseCardinalityNext(key, params.cardinalityNext);
        }

        emit IBunniHub.NewBunni(token, poolId);
    }

    /// -----------------------------------------------------------------------
    /// Utilities
    /// -----------------------------------------------------------------------

    /// @notice Mints share tokens to the recipient based on the amount of liquidity added.
    /// @param shareToken The BunniToken to mint
    /// @param recipient The recipient of the share tokens
    /// @return shares The amount of share tokens minted to the sender.
    function _mintShares(
        IBunniToken shareToken,
        address recipient,
        uint256 addedAmount0,
        uint256 existingAmount0,
        uint256 addedAmount1,
        uint256 existingAmount1
    ) internal returns (uint256 shares) {
        uint256 existingShareSupply = shareToken.totalSupply();
        if (existingShareSupply == 0) {
            // no existing shares, just give WAD
            shares = WAD - MIN_INITIAL_SHARES;
            // prevent first staker from stealing funds of subsequent stakers
            // see https://code4rena.com/reports/2022-01-sherlock/#h-01-first-user-can-steal-everyone-elses-tokens
            shareToken.mint(address(0), MIN_INITIAL_SHARES);
        } else {
            // given that the position may become single-sided, we need to handle the case where one of the existingAmount values is zero
            shares = min(
                existingAmount0 == 0 ? type(uint256).max : existingShareSupply.mulDivDown(addedAmount0, existingAmount0),
                existingAmount1 == 0 ? type(uint256).max : existingShareSupply.mulDivDown(addedAmount1, existingAmount1)
            );
            if (shares == 0) revert BunniHub__ZeroSharesMinted();
        }

        // mint shares to sender
        shareToken.mint(recipient, shares);
    }

    function _getPoolState(PoolId poolId, mapping(PoolId => RawPoolState) storage _poolState)
        internal
        view
        returns (PoolState memory state)
    {
        RawPoolState memory rawState = _poolState[poolId];
        if (rawState.immutableParamsPointer == address(0)) revert BunniHub__BunniTokenNotInitialized();

        // read params via SSLOAD2
        bytes memory immutableParams = rawState.immutableParamsPointer.read();

        ILiquidityDensityFunction liquidityDensityFunction;
        IBunniToken bunniToken;
        uint24 twapSecondsAgo;
        bytes32 ldfParams;
        bytes32 hookParams;
        ERC4626 vault0;
        ERC4626 vault1;
        bool statefulLdf;

        assembly ("memory-safe") {
            liquidityDensityFunction := shr(96, mload(add(immutableParams, 32)))
            bunniToken := shr(96, mload(add(immutableParams, 52)))
            twapSecondsAgo := shr(232, mload(add(immutableParams, 72)))
            ldfParams := mload(add(immutableParams, 75))
            hookParams := mload(add(immutableParams, 107))
            vault0 := shr(96, mload(add(immutableParams, 139)))
            vault1 := shr(96, mload(add(immutableParams, 159)))
            statefulLdf := shr(248, mload(add(immutableParams, 179)))
        }

        state = PoolState({
            liquidityDensityFunction: liquidityDensityFunction,
            bunniToken: bunniToken,
            twapSecondsAgo: twapSecondsAgo,
            ldfParams: ldfParams,
            hookParams: hookParams,
            vault0: vault0,
            vault1: vault1,
            statefulLdf: statefulLdf,
            poolCredit0Set: rawState.poolCredit0Set,
            poolCredit1Set: rawState.poolCredit1Set,
            reserve0: rawState.reserve0,
            reserve1: rawState.reserve1
        });
    }

    function _validateVault(ERC4626 vault, Currency currency, WETH weth) internal view {
        // if vault is set, make sure the vault asset matches the currency
        // if the currency is ETH, the vault asset must be WETH
        if (address(vault) != address(0)) {
            bool isNative = currency.isNative();
            address vaultAsset = address(vault.asset());
            if ((isNative && vaultAsset != address(weth)) || (!isNative && vaultAsset != Currency.unwrap(currency))) {
                revert BunniHub__VaultAssetMismatch();
            }
        }
    }
}
