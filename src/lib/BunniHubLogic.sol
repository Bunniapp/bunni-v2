// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {LibMulticaller} from "multicaller/LibMulticaller.sol";

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import "@uniswap/v4-core/src/libraries/SqrtPriceMath.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {CREATE3} from "solady/src/utils/CREATE3.sol";
import {SSTORE2} from "solady/src/utils/SSTORE2.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {WETH} from "solady/src/tokens/WETH.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solady/src/utils/FixedPointMathLib.sol";

import "./Math.sol";
import "./Structs.sol";
import "./VaultMath.sol";
import "./Constants.sol";
import "../interfaces/IBunniHub.sol";
import {BunniToken} from "../BunniToken.sol";
import {IBunniHook} from "../interfaces/IBunniHook.sol";
import {LiquidityAmounts} from "./LiquidityAmounts.sol";
import {IBunniToken} from "../interfaces/IBunniToken.sol";
import {AdditionalCurrencyLibrary} from "./AdditionalCurrencyLib.sol";

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
    using AdditionalCurrencyLibrary for Currency;

    /// -----------------------------------------------------------------------
    /// Deposit
    /// -----------------------------------------------------------------------

    function deposit(
        IBunniHub.DepositParams calldata params,
        IPoolManager poolManager,
        WETH weth,
        IPermit2 permit2,
        mapping(PoolId => RawPoolState) storage _poolState
    ) external returns (uint256 shares, uint256 amount0, uint256 amount1) {
        address msgSender = LibMulticaller.senderOrSigner();
        PoolId poolId = params.poolKey.toId();
        PoolState memory state = _getPoolState(poolId, _poolState);

        (uint160 sqrtPriceX96, int24 currentTick) = IBunniHook(address(params.poolKey.hooks)).slot0s(poolId);

        DepositLogicReturnData memory depositReturnData = _depositLogic(
            DepositLogicInputData({
                state: state,
                params: params,
                poolId: poolId,
                currentTick: currentTick,
                sqrtPriceX96: sqrtPriceX96
            })
        );
        uint256 depositAmount0 = depositReturnData.depositAmount0;
        uint256 depositAmount1 = depositReturnData.depositAmount1;
        amount0 = depositReturnData.amount0;
        amount1 = depositReturnData.amount1;
        shares = depositReturnData.shares;

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // update reserves
        if (address(state.vault0) != address(0) && depositAmount0 != 0) {
            int256 reserveChange = _updateVaultReserve(
                depositAmount0.toInt256(), params.poolKey.currency0, state.vault0, msgSender, true, weth, permit2
            );
            _poolState[poolId].reserve0 = (state.reserve0.toInt256() + reserveChange).toUint256();
        }
        if (address(state.vault1) != address(0) && depositAmount1 != 0) {
            int256 reserveChange = _updateVaultReserve(
                depositAmount1.toInt256(), params.poolKey.currency1, state.vault1, msgSender, true, weth, permit2
            );
            _poolState[poolId].reserve1 = (state.reserve1.toInt256() + reserveChange).toUint256();
        }

        // update raw balances
        (uint256 rawAmount0, uint256 rawAmount1) = (
            address(state.vault0) != address(0) ? amount0 - depositAmount0 : amount0,
            address(state.vault1) != address(0) ? amount1 - depositAmount1 : amount1
        );
        poolManager.lock(
            address(this),
            abi.encode(
                LockCallbackType.DEPOSIT,
                abi.encode(
                    DepositCallbackInputData({
                        user: msgSender,
                        poolKey: params.poolKey,
                        msgValue: msg.value,
                        rawAmount0: rawAmount0,
                        rawAmount1: rawAmount1
                    })
                )
            )
        );

        if (amount0 < params.amount0Min || amount1 < params.amount1Min) {
            revert BunniHub__SlippageTooHigh();
        }

        // refund excess ETH
        if (params.poolKey.currency0.isNative()) {
            if (msg.value > amount0) {
                params.refundETHRecipient.safeTransferETH(msg.value - amount0);
            }
        } else if (params.poolKey.currency1.isNative()) {
            if (msg.value > amount1) {
                params.refundETHRecipient.safeTransferETH(msg.value - amount1);
            }
        }

        // emit event
        emit IBunniHub.Deposit(msgSender, params.recipient, poolId, amount0, amount1, shares);
    }

    struct DepositLogicInputData {
        PoolState state;
        IBunniHub.DepositParams params;
        PoolId poolId;
        int24 currentTick;
        uint160 sqrtPriceX96;
    }

    struct DepositLogicReturnData {
        uint256 depositAmount0;
        uint256 depositAmount1;
        uint256 amount0;
        uint256 amount1;
        uint256 shares;
    }

    struct DepositLogicVariables {
        uint160 roundedTickSqrtRatio;
        uint160 nextRoundedTickSqrtRatio;
        uint256 reserveBalance0;
        uint256 reserveBalance1;
        uint256 balance0;
        uint256 balance1;
        int24 arithmeticMeanTick;
    }

    /// @dev Separated to avoid stack too deep error
    function _depositLogic(DepositLogicInputData memory inputData)
        private
        returns (DepositLogicReturnData memory returnData)
    {
        DepositLogicVariables memory vars;

        // query existing assets
        // assets = urrent tick tokens + reserve tokens + pool credits
        (vars.reserveBalance0, vars.reserveBalance1) = (
            getReservesInUnderlying(inputData.state.reserve0, inputData.state.vault0),
            getReservesInUnderlying(inputData.state.reserve1, inputData.state.vault1)
        );
        (vars.balance0, vars.balance1) =
            (inputData.state.rawBalance0 + vars.reserveBalance0, inputData.state.rawBalance1 + vars.reserveBalance1);

        // update TWAP oracle and optionally observe
        bool requiresLDF = vars.balance0 == 0 && vars.balance1 == 0;

        if (requiresLDF) {
            // use LDF to initialize token proportions

            (int24 roundedTick, int24 nextRoundedTick) =
                roundTick(inputData.currentTick, inputData.params.poolKey.tickSpacing);
            (vars.roundedTickSqrtRatio, vars.nextRoundedTickSqrtRatio) =
                (TickMath.getSqrtRatioAtTick(roundedTick), TickMath.getSqrtRatioAtTick(nextRoundedTick));

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
                roundedTick,
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
            uint256 totalLiquidity = FixedPointMathLib.min(
                totalDensity0X96 == 0
                    ? type(uint256).max
                    : inputData.params.amount0Desired.mulDiv(Q96, totalDensity0X96),
                totalDensity1X96 == 0
                    ? type(uint256).max
                    : inputData.params.amount1Desired.mulDiv(Q96, totalDensity1X96)
            );
            // totalLiquidity could exceed uint128 so .toUint128() is used
            uint128 addedLiquidity = ((totalLiquidity * liquidityDensityOfRoundedTickX96) >> 96).toUint128();

            // compute total token amounts
            (uint256 addedLiquidityAmount0, uint256 addedLiquidityAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                inputData.sqrtPriceX96, vars.roundedTickSqrtRatio, vars.nextRoundedTickSqrtRatio, addedLiquidity, true
            );
            (returnData.amount0, returnData.amount1) = (
                addedLiquidityAmount0 + totalLiquidity.mulDivUp(density0RightOfRoundedTickX96, Q96),
                addedLiquidityAmount1 + totalLiquidity.mulDivUp(density1LeftOfRoundedTickX96, Q96)
            );

            // sanity check against desired amounts
            // the amounts can exceed the desired amounts due to math errors
            if (
                (returnData.amount0 > inputData.params.amount0Desired)
                    || (returnData.amount1 > inputData.params.amount1Desired)
            ) {
                // scale down amounts and take minimum
                if (returnData.amount0 == 0) {
                    returnData.amount1 = inputData.params.amount1Desired;
                } else if (returnData.amount1 == 0) {
                    returnData.amount0 = inputData.params.amount0Desired;
                } else {
                    // both are non-zero
                    (returnData.amount0, returnData.amount1) = (
                        FixedPointMathLib.min(
                            inputData.params.amount0Desired,
                            returnData.amount0.mulDiv(inputData.params.amount1Desired, returnData.amount1)
                            ),
                        FixedPointMathLib.min(
                            inputData.params.amount1Desired,
                            returnData.amount1.mulDiv(inputData.params.amount0Desired, returnData.amount0)
                            )
                    );
                }
            }

            // update token amounts to deposit into vaults
            (returnData.depositAmount0, returnData.depositAmount1) = (
                returnData.amount0
                    - returnData.amount0.mulDiv(inputData.state.targetRawTokenRatio0, RAW_TOKEN_RATIO_BASE),
                returnData.amount1
                    - returnData.amount1.mulDiv(inputData.state.targetRawTokenRatio1, RAW_TOKEN_RATIO_BASE)
            );
        } else {
            // already initialized liquidity shape
            // simply add tokens at the current ratio
            // need to update: depositAmount0, depositAmount1, amount0, amount1

            // compute amount0 and amount1 such that the ratio is the same as the current ratio
            returnData.amount0 = vars.balance1 == 0
                ? inputData.params.amount0Desired
                : FixedPointMathLib.min(
                    inputData.params.amount0Desired, inputData.params.amount1Desired.mulDiv(vars.balance0, vars.balance1)
                );
            returnData.amount1 = vars.balance0 == 0
                ? inputData.params.amount1Desired
                : FixedPointMathLib.min(
                    inputData.params.amount1Desired, inputData.params.amount0Desired.mulDiv(vars.balance1, vars.balance0)
                );

            returnData.depositAmount0 =
                vars.balance0 == 0 ? 0 : returnData.amount0.mulDiv(vars.reserveBalance0, vars.balance0);
            returnData.depositAmount1 =
                vars.balance1 == 0 ? 0 : returnData.amount1.mulDiv(vars.reserveBalance1, vars.balance1);
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // mint shares
        returnData.shares = _mintShares(
            inputData.state.bunniToken,
            inputData.params.recipient,
            returnData.amount0,
            vars.balance0,
            returnData.amount1,
            vars.balance1
        );
    }

    /// -----------------------------------------------------------------------
    /// Withdraw
    /// -----------------------------------------------------------------------

    function withdraw(
        IBunniHub.WithdrawParams calldata params,
        IPoolManager poolManager,
        WETH weth,
        IPermit2 permit2,
        mapping(PoolId => RawPoolState) storage _poolState
    ) external returns (uint256 amount0, uint256 amount1) {
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
        address msgSender = LibMulticaller.senderOrSigner();

        // burn shares
        state.bunniToken.burn(msgSender, params.shares);
        // at this point of execution we know params.shares <= currentTotalSupply
        // since otherwise the burn() call would've reverted

        // compute token amount to withdraw and the component amounts
        uint256 reserveAmount0 =
            getReservesInUnderlying(state.reserve0.mulDiv(params.shares, currentTotalSupply), state.vault0);
        uint256 reserveAmount1 =
            getReservesInUnderlying(state.reserve1.mulDiv(params.shares, currentTotalSupply), state.vault1);
        uint256 rawAmount0 = state.rawBalance0.mulDiv(params.shares, currentTotalSupply);
        uint256 rawAmount1 = state.rawBalance1.mulDiv(params.shares, currentTotalSupply);
        amount0 = reserveAmount0 + rawAmount0;
        amount1 = reserveAmount1 + rawAmount1;

        if (amount0 < params.amount0Min || amount1 < params.amount1Min) {
            revert BunniHub__SlippageTooHigh();
        }

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // withdraw reserve tokens
        if (address(state.vault0) != address(0) && reserveAmount0 != 0) {
            // vault used
            // withdraw reserves
            int256 reserveChange = _updateVaultReserve(
                -reserveAmount0.toInt256(),
                params.poolKey.currency0,
                state.vault0,
                params.recipient,
                false,
                weth,
                permit2
            );
            _poolState[poolId].reserve0 = (state.reserve0.toInt256() + reserveChange).toUint256();
        }
        if (address(state.vault1) != address(0) && reserveAmount1 != 0) {
            // vault used
            // withdraw from reserves
            int256 reserveChange = _updateVaultReserve(
                -reserveAmount1.toInt256(),
                params.poolKey.currency1,
                state.vault1,
                params.recipient,
                false,
                weth,
                permit2
            );
            _poolState[poolId].reserve1 = (state.reserve1.toInt256() + reserveChange).toUint256();
        }

        // withdraw raw tokens
        poolManager.lock(
            address(this),
            abi.encode(LockCallbackType.WITHDRAW, abi.encode(params.recipient, params.poolKey, rawAmount0, rawAmount1))
        );

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

        // validate raw token ratio bounds
        if (
            (
                address(params.vault0) != address(0)
                    && !(
                        (params.minRawTokenRatio0 <= params.targetRawTokenRatio0)
                            && (params.targetRawTokenRatio0 <= params.maxRawTokenRatio0)
                            && (params.maxRawTokenRatio0 <= RAW_TOKEN_RATIO_BASE)
                    )
            )
                || (
                    address(params.vault1) != address(0)
                        && !(
                            (params.minRawTokenRatio1 <= params.targetRawTokenRatio1)
                                && (params.targetRawTokenRatio1 <= params.maxRawTokenRatio1)
                                && (params.maxRawTokenRatio1 <= RAW_TOKEN_RATIO_BASE)
                        )
                )
        ) {
            revert BunniHub__InvalidRawTokenRatioBounds();
        }

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
            params.statefulLdf,
            params.minRawTokenRatio0,
            params.targetRawTokenRatio0,
            params.maxRawTokenRatio0,
            params.minRawTokenRatio1,
            params.targetRawTokenRatio1,
            params.maxRawTokenRatio1
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
            shares = FixedPointMathLib.min(
                existingAmount0 == 0 ? type(uint256).max : existingShareSupply.mulDiv(addedAmount0, existingAmount0),
                existingAmount1 == 0 ? type(uint256).max : existingShareSupply.mulDiv(addedAmount1, existingAmount1)
            );
            if (shares == 0) revert BunniHub__ZeroSharesMinted();
        }

        // mint shares to sender
        shareToken.mint(recipient, shares);
    }

    /// @dev Deposits/withdraws tokens from a vault.
    /// @param amount The amount to deposit/withdraw. Positive for deposit, negative for withdraw.
    /// @param currency The currency to deposit/withdraw.
    /// @param vault The vault to deposit/withdraw from.
    /// @param user The user to pull tokens from / withdraw tokens to
    /// @param pullTokensFromUser Whether to pull tokens from the user or not in case of deposit.
    /// @return reserveChange The change in reserves. Positive for deposit, negative for withdraw.
    function _updateVaultReserve(
        int256 amount,
        Currency currency,
        ERC4626 vault,
        address user,
        bool pullTokensFromUser,
        WETH weth,
        IPermit2 permit2
    ) internal returns (int256 reserveChange) {
        uint256 absAmount = FixedPointMathLib.abs(amount);
        if (amount > 0) {
            IERC20 token;
            if (currency.isNative()) {
                // wrap ETH
                // no need to pull tokens from user since WETH is already in the contract
                weth.deposit{value: absAmount}();
                token = IERC20(address(weth));
            } else {
                // normal ERC20
                token = IERC20(Currency.unwrap(currency));
                if (pullTokensFromUser) {
                    permit2.transferFrom(user, address(this), absAmount.toUint160(), address(token));
                }
            }

            address(token).safeApprove(address(vault), absAmount);
            reserveChange = vault.deposit(absAmount, address(this)).toInt256();
        } else if (amount < 0) {
            if (currency.isNative()) {
                // withdraw WETH from vault to address(this)
                reserveChange = -vault.withdraw(absAmount, address(this), address(this)).toInt256();

                // burn WETH for ETH
                weth.withdraw(absAmount);

                // transfer ETH to user
                user.safeTransferETH(absAmount);
            } else {
                // normal ERC20
                reserveChange = -vault.withdraw(absAmount, user, address(this)).toInt256();
            }
        }
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
        uint24 minRawTokenRatio0;
        uint24 targetRawTokenRatio0;
        uint24 maxRawTokenRatio0;
        uint24 minRawTokenRatio1;
        uint24 targetRawTokenRatio1;
        uint24 maxRawTokenRatio1;

        assembly ("memory-safe") {
            liquidityDensityFunction := shr(96, mload(add(immutableParams, 32)))
            bunniToken := shr(96, mload(add(immutableParams, 52)))
            twapSecondsAgo := shr(232, mload(add(immutableParams, 72)))
            ldfParams := mload(add(immutableParams, 75))
            hookParams := mload(add(immutableParams, 107))
            vault0 := shr(96, mload(add(immutableParams, 139)))
            vault1 := shr(96, mload(add(immutableParams, 159)))
            statefulLdf := shr(248, mload(add(immutableParams, 179)))
            minRawTokenRatio0 := shr(232, mload(add(immutableParams, 180)))
            targetRawTokenRatio0 := shr(232, mload(add(immutableParams, 183)))
            maxRawTokenRatio0 := shr(232, mload(add(immutableParams, 186)))
            minRawTokenRatio1 := shr(232, mload(add(immutableParams, 189)))
            targetRawTokenRatio1 := shr(232, mload(add(immutableParams, 192)))
            maxRawTokenRatio1 := shr(232, mload(add(immutableParams, 195)))
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
            minRawTokenRatio0: minRawTokenRatio0,
            targetRawTokenRatio0: targetRawTokenRatio0,
            maxRawTokenRatio0: maxRawTokenRatio0,
            minRawTokenRatio1: minRawTokenRatio1,
            targetRawTokenRatio1: targetRawTokenRatio1,
            maxRawTokenRatio1: maxRawTokenRatio1,
            rawBalance0: rawState.rawBalance0,
            rawBalance1: rawState.rawBalance1,
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
