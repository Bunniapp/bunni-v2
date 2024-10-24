// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";

import {IAmAmm} from "biddog/interfaces/IAmAmm.sol";

import {ClonesWithImmutableArgs} from "clones-with-immutable-args/ClonesWithImmutableArgs.sol";

import {LibMulticaller} from "multicaller/LibMulticaller.sol";

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import "@uniswap/v4-core/src/libraries/SqrtPriceMath.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {SSTORE2} from "solady/utils/SSTORE2.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";

import {WETH} from "solady/tokens/WETH.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./Math.sol";
import "./QueryTWAP.sol";
import "./VaultMath.sol";
import "../base/Errors.sol";
import "../base/Constants.sol";
import "../types/PoolState.sol";
import "../base/SharedStructs.sol";
import "../interfaces/IBunniHub.sol";
import {BunniHub} from "../BunniHub.sol";
import {HookletLib} from "./HookletLib.sol";
import {queryLDF} from "../lib/QueryLDF.sol";
import {BunniToken} from "../BunniToken.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IHooklet} from "../interfaces/IHooklet.sol";
import {IBunniHook} from "../interfaces/IBunniHook.sol";
import {LiquidityAmounts} from "./LiquidityAmounts.sol";
import {IBunniToken} from "../interfaces/IBunniToken.sol";
import {AdditionalCurrencyLibrary} from "./AdditionalCurrencyLib.sol";

library BunniHubLogic {
    using SSTORE2 for bytes;
    using SSTORE2 for address;
    using SafeCastLib for int256;
    using SafeCastLib for uint256;
    using HookletLib for IHooklet;
    using PoolIdLibrary for PoolKey;
    using SafeTransferLib for address;
    using CurrencyLibrary for Currency;
    using FixedPointMathLib for uint128;
    using FixedPointMathLib for uint256;
    using ClonesWithImmutableArgs for address;
    using AdditionalCurrencyLibrary for Currency;

    struct Env {
        WETH weth;
        IPermit2 permit2;
        IPoolManager poolManager;
        IBunniToken bunniTokenImplementation;
    }

    /// -----------------------------------------------------------------------
    /// Deposit
    /// -----------------------------------------------------------------------

    function deposit(HubStorage storage s, Env calldata env, IBunniHub.DepositParams calldata params)
        external
        returns (uint256 shares, uint256 amount0, uint256 amount1)
    {
        address msgSender = LibMulticaller.senderOrSigner();
        PoolId poolId = params.poolKey.toId();
        PoolState memory state = getPoolState(s, poolId);

        /// -----------------------------------------------------------------------
        /// Hooklet call
        /// -----------------------------------------------------------------------

        state.hooklet.hookletBeforeDeposit(msgSender, params);

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        IBunniHook hook = IBunniHook(address(params.poolKey.hooks));
        (uint160 sqrtPriceX96, int24 currentTick,,) = hook.slot0s(poolId);
        hook.updateStateMachine(poolId); // trigger am-AMM state machine update to avoid sandwiching rent burns

        DepositLogicReturnData memory depositReturnData = _depositLogic(
            DepositLogicInputData({
                state: state,
                params: params,
                poolId: poolId,
                currentTick: currentTick,
                sqrtPriceX96: sqrtPriceX96
            })
        );
        uint256 reserveAmount0 = depositReturnData.reserveAmount0;
        uint256 reserveAmount1 = depositReturnData.reserveAmount1;
        amount0 = depositReturnData.amount0;
        amount1 = depositReturnData.amount1;

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // update raw balances
        (uint256 rawAmount0, uint256 rawAmount1) = (
            address(state.vault0) != address(0) ? amount0 - reserveAmount0 : amount0,
            address(state.vault1) != address(0) ? amount1 - reserveAmount1 : amount1
        );
        (rawAmount0, rawAmount1) = abi.decode(
            env.poolManager.unlock(
                abi.encode(
                    BunniHub.UnlockCallbackType.DEPOSIT,
                    abi.encode(
                        BunniHub.DepositCallbackInputData({
                            user: msgSender,
                            poolKey: params.poolKey,
                            msgValue: msg.value,
                            rawAmount0: rawAmount0,
                            rawAmount1: rawAmount1
                        })
                    )
                )
            ),
            (uint256, uint256)
        );

        // update reserves
        if (address(state.vault0) != address(0) && reserveAmount0 != 0) {
            (uint256 reserveChange, uint256 reserveChangeInUnderlying) = _depositVaultReserve(
                env, reserveAmount0, params.poolKey.currency0, state.vault0, msgSender, params.vaultFee0
            );
            s.reserve0[poolId] = state.reserve0 + reserveChange;

            // use actual withdrawable value to handle vaults with withdrawal fees
            reserveAmount0 = reserveChangeInUnderlying;
        }
        if (address(state.vault1) != address(0) && reserveAmount1 != 0) {
            (uint256 reserveChange, uint256 reserveChangeInUnderlying) = _depositVaultReserve(
                env, reserveAmount1, params.poolKey.currency1, state.vault1, msgSender, params.vaultFee1
            );
            s.reserve1[poolId] = state.reserve1 + reserveChange;

            // use actual withdrawable value to handle vaults with withdrawal fees
            reserveAmount1 = reserveChangeInUnderlying;
        }

        // mint shares using actual token amounts
        shares = _mintShares(
            state.bunniToken,
            params.recipient,
            address(state.vault0) != address(0) ? rawAmount0 + reserveAmount0 : rawAmount0,
            depositReturnData.balance0,
            address(state.vault1) != address(0) ? rawAmount1 + reserveAmount1 : rawAmount1,
            depositReturnData.balance1,
            params.referrer
        );

        if (amount0 < params.amount0Min || amount1 < params.amount1Min) {
            revert BunniHub__SlippageTooHigh();
        }

        // refund excess ETH
        if (params.poolKey.currency0.isNative()) {
            if (address(this).balance != 0) {
                params.refundRecipient.safeTransferETH(
                    FixedPointMathLib.min(address(this).balance, msg.value - amount0)
                );
            }
        } else if (params.poolKey.currency1.isNative()) {
            if (address(this).balance != 0) {
                params.refundRecipient.safeTransferETH(
                    FixedPointMathLib.min(address(this).balance, msg.value - amount1)
                );
            }
        }

        // emit event
        emit IBunniHub.Deposit(msgSender, params.recipient, poolId, amount0, amount1, shares);

        /// -----------------------------------------------------------------------
        /// Hooklet call
        /// -----------------------------------------------------------------------

        state.hooklet.hookletAfterDeposit(
            msgSender, params, IHooklet.DepositReturnData({shares: shares, amount0: amount0, amount1: amount1})
        );
    }

    struct DepositLogicInputData {
        PoolState state;
        IBunniHub.DepositParams params;
        PoolId poolId;
        int24 currentTick;
        uint160 sqrtPriceX96;
    }

    struct DepositLogicReturnData {
        uint256 reserveAmount0;
        uint256 reserveAmount1;
        uint256 amount0;
        uint256 amount1;
        uint256 balance0;
        uint256 balance1;
    }

    /// @dev Separated to avoid stack too deep error
    function _depositLogic(DepositLogicInputData memory inputData)
        private
        returns (DepositLogicReturnData memory returnData)
    {
        // query existing assets
        // assets = urrent tick tokens + reserve tokens + pool credits
        (uint256 reserveBalance0, uint256 reserveBalance1) = (
            getReservesInUnderlying(inputData.state.reserve0, inputData.state.vault0),
            getReservesInUnderlying(inputData.state.reserve1, inputData.state.vault1)
        );
        (returnData.balance0, returnData.balance1) =
            (inputData.state.rawBalance0 + reserveBalance0, inputData.state.rawBalance1 + reserveBalance1);

        // update TWAP oracle and optionally observe
        bool requiresLDF = returnData.balance0 == 0 && returnData.balance1 == 0;

        if (requiresLDF) {
            // use LDF to initialize token proportions

            // compute total liquidity & token densities
            bool useTwap = inputData.state.twapSecondsAgo != 0;
            int24 arithmeticMeanTick =
                useTwap ? queryTwap(inputData.params.poolKey, inputData.state.twapSecondsAgo) : int24(0);
            IBunniHook hook = IBunniHook(address(inputData.params.poolKey.hooks));
            bytes32 ldfState = inputData.state.statefulLdf ? hook.ldfStates(inputData.poolId) : bytes32(0);
            (uint256 totalLiquidity, uint256 totalDensity0X96, uint256 totalDensity1X96,, bytes32 newLdfState,) =
            queryLDF({
                key: inputData.params.poolKey,
                sqrtPriceX96: inputData.sqrtPriceX96,
                tick: inputData.currentTick,
                arithmeticMeanTick: arithmeticMeanTick,
                ldf: inputData.state.liquidityDensityFunction,
                ldfParams: inputData.state.ldfParams,
                ldfState: ldfState,
                balance0: inputData.params.amount0Desired, // use amount0Desired since we're initializing liquidity
                balance1: inputData.params.amount1Desired // use amount1Desired since we're initializing liquidity
            });
            if (inputData.state.statefulLdf) hook.updateLdfState(inputData.poolId, newLdfState);

            // compute token amounts to add
            (returnData.amount0, returnData.amount1) =
                (totalLiquidity.mulDivUp(totalDensity0X96, Q96), totalLiquidity.mulDivUp(totalDensity1X96, Q96));

            // sanity check against desired amounts
            // the amounts can exceed the desired amounts due to math errors
            if (
                returnData.amount0 > inputData.params.amount0Desired
                    || returnData.amount1 > inputData.params.amount1Desired
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
            (returnData.reserveAmount0, returnData.reserveAmount1) = (
                returnData.amount0
                    - returnData.amount0.mulDiv(inputData.state.targetRawTokenRatio0, RAW_TOKEN_RATIO_BASE),
                returnData.amount1
                    - returnData.amount1.mulDiv(inputData.state.targetRawTokenRatio1, RAW_TOKEN_RATIO_BASE)
            );
        } else {
            // already initialized liquidity shape
            // simply add tokens at the current ratio
            // need to update: reserveAmount0, reserveAmount1, amount0, amount1

            // compute amount0 and amount1 such that the ratio is the same as the current ratio
            uint256 amount0Desired = inputData.params.amount0Desired;
            uint256 amount1Desired = inputData.params.amount1Desired;
            uint256 balance0 = returnData.balance0;
            uint256 balance1 = returnData.balance1;

            returnData.amount0 = balance1 == 0
                ? amount0Desired
                : FixedPointMathLib.min(amount0Desired, amount1Desired.mulDiv(balance0, balance1));
            returnData.amount1 = balance0 == 0
                ? amount1Desired
                : FixedPointMathLib.min(amount1Desired, amount0Desired.mulDiv(balance1, balance0));

            returnData.reserveAmount0 = balance0 == 0 ? 0 : returnData.amount0.mulDiv(reserveBalance0, balance0);
            returnData.reserveAmount1 = balance1 == 0 ? 0 : returnData.amount1.mulDiv(reserveBalance1, balance1);
        }
    }

    /// -----------------------------------------------------------------------
    /// Withdraw
    /// -----------------------------------------------------------------------

    function queueWithdraw(HubStorage storage s, IBunniHub.QueueWithdrawParams calldata params) external {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        PoolId id = params.poolKey.toId();
        IBunniToken bunniToken = _getBunniTokenOfPool(s, id);
        if (address(bunniToken) == address(0)) revert BunniHub__BunniTokenNotInitialized();

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        address msgSender = LibMulticaller.senderOrSigner();
        QueuedWithdrawal memory queued = s.queuedWithdrawals[id][msgSender];

        // update queued withdrawal
        // use unchecked to get unlockTimestamp to overflow back to 0 if overflow occurs
        // which is fine since we only care about relative time
        uint56 newUnlockTimestamp;
        unchecked {
            newUnlockTimestamp = uint56(block.timestamp) + WITHDRAW_DELAY;
        }
        if (queued.shareAmount != 0) {
            // requeue expired queued withdrawal
            if (queued.unlockTimestamp + WITHDRAW_GRACE_PERIOD >= block.timestamp) {
                revert BunniHub__NoExpiredWithdrawal();
            }
            s.queuedWithdrawals[id][msgSender].unlockTimestamp = newUnlockTimestamp;
        } else {
            // create new queued withdrawal
            if (params.shares == 0) revert BunniHub__ZeroInput();
            s.queuedWithdrawals[id][msgSender] =
                QueuedWithdrawal({shareAmount: params.shares, unlockTimestamp: newUnlockTimestamp});
        }

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        if (queued.shareAmount == 0) {
            // transfer shares from msgSender to address(this)
            bunniToken.transferFrom(msgSender, address(this), params.shares);
        }

        emit IBunniHub.QueueWithdraw(msgSender, id, params.shares);
    }

    function withdraw(HubStorage storage s, Env calldata env, IBunniHub.WithdrawParams calldata params)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (params.shares == 0) revert BunniHub__ZeroInput();

        PoolId poolId = params.poolKey.toId();
        PoolState memory state = getPoolState(s, poolId);
        IBunniHook hook = IBunniHook(address(params.poolKey.hooks));

        IAmAmm.Bid memory topBid = hook.getTopBidWrite(poolId);
        if (hook.getAmAmmEnabled(poolId) && topBid.manager != address(0) && !params.useQueuedWithdrawal) {
            revert BunniHub__NeedToUseQueuedWithdrawal();
        }

        /// -----------------------------------------------------------------------
        /// Hooklet call
        /// -----------------------------------------------------------------------

        address msgSender = LibMulticaller.senderOrSigner();
        state.hooklet.hookletBeforeWithdraw(msgSender, params);

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        uint256 currentTotalSupply = state.bunniToken.totalSupply();
        uint256 shares;

        // burn shares
        if (params.useQueuedWithdrawal) {
            // use queued withdrawal
            // need to withdraw the full queued amount
            QueuedWithdrawal memory queued = s.queuedWithdrawals[poolId][msgSender];
            if (queued.shareAmount == 0 || queued.unlockTimestamp == 0) revert BunniHub__QueuedWithdrawalNonexistent();
            if (block.timestamp < queued.unlockTimestamp) revert BunniHub__QueuedWithdrawalNotReady();
            if (queued.unlockTimestamp + WITHDRAW_GRACE_PERIOD < block.timestamp) revert BunniHub__GracePeriodExpired();
            shares = queued.shareAmount;
            s.queuedWithdrawals[poolId][msgSender].shareAmount = 0; // don't delete the struct to save gas later
            state.bunniToken.burn(address(this), shares); // BunniTokens were deposited to address(this) earlier with queueWithdraw()
        } else {
            shares = params.shares;
            state.bunniToken.burn(msgSender, shares);
        }
        // at this point of execution we know shares <= currentTotalSupply
        // since otherwise the burn() call would've reverted

        // compute token amount to withdraw and the component amounts
        uint256 reserveAmount0 =
            getReservesInUnderlying(state.reserve0.mulDiv(shares, currentTotalSupply), state.vault0);
        uint256 reserveAmount1 =
            getReservesInUnderlying(state.reserve1.mulDiv(shares, currentTotalSupply), state.vault1);
        uint256 rawAmount0 = state.rawBalance0.mulDiv(shares, currentTotalSupply);
        uint256 rawAmount1 = state.rawBalance1.mulDiv(shares, currentTotalSupply);
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
            uint256 reserveChange = _withdrawVaultReserve(
                reserveAmount0, params.poolKey.currency0, state.vault0, params.recipient, env.weth
            );
            s.reserve0[poolId] = state.reserve0 - reserveChange;
        }
        if (address(state.vault1) != address(0) && reserveAmount1 != 0) {
            // vault used
            // withdraw from reserves
            uint256 reserveChange = _withdrawVaultReserve(
                reserveAmount1, params.poolKey.currency1, state.vault1, params.recipient, env.weth
            );
            s.reserve1[poolId] = state.reserve1 - reserveChange;
        }

        // withdraw raw tokens
        env.poolManager.unlock(
            abi.encode(
                BunniHub.UnlockCallbackType.WITHDRAW,
                abi.encode(params.recipient, params.poolKey, rawAmount0, rawAmount1)
            )
        );

        emit IBunniHub.Withdraw(msgSender, params.recipient, poolId, amount0, amount1, shares);

        /// -----------------------------------------------------------------------
        /// Hooklet call
        /// -----------------------------------------------------------------------

        state.hooklet.hookletAfterWithdraw(
            msgSender, params, IHooklet.WithdrawReturnData({amount0: amount0, amount1: amount1})
        );
    }

    /// -----------------------------------------------------------------------
    /// Deploy Bunni Token
    /// -----------------------------------------------------------------------

    function deployBunniToken(HubStorage storage s, Env calldata env, IBunniHub.DeployBunniTokenParams calldata params)
        external
        returns (IBunniToken token, PoolKey memory key)
    {
        /// -----------------------------------------------------------------------
        /// Verification
        /// -----------------------------------------------------------------------

        // each Uniswap v4 pool corresponds to a single BunniToken
        // since Univ4 pool key is deterministic based on poolKey, we use dynamic fee so that the lower 20 bits of `poolKey.fee` is used
        // as nonce to differentiate the BunniTokens
        // each "subspace" has its own nonce that's incremented whenever a BunniToken is deployed with the same tokens & tick spacing & hooks
        // nonce can be at most 1e6 after which the deployment will fail
        bytes32 bunniSubspace =
            keccak256(abi.encode(params.currency0, params.currency1, params.tickSpacing, params.hooks));
        uint24 nonce_ = s.nonce[bunniSubspace];
        if (nonce_ > MAX_NONCE) revert BunniHub__MaxNonceReached();

        // ensure LDF params are valid
        key = PoolKey({
            currency0: params.currency0,
            currency1: params.currency1,
            fee: nonce_,
            tickSpacing: params.tickSpacing,
            hooks: IHooks(address(params.hooks))
        });
        if (address(params.liquidityDensityFunction) == address(0)) revert BunniHub__LDFCannotBeZero();
        if (!params.liquidityDensityFunction.isValidParams(key, params.twapSecondsAgo, params.ldfParams)) {
            revert BunniHub__InvalidLDFParams();
        }

        // ensure hook params are valid
        if (address(params.hooks) == address(0)) revert BunniHub__HookCannotBeZero();
        if (!params.hooks.isValidParams(params.hookParams)) revert BunniHub__InvalidHookParams();

        // validate vaults
        _validateVault(params.vault0, params.currency0, env.weth);
        _validateVault(params.vault1, params.currency1, env.weth);

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
        /// Hooklet call
        /// -----------------------------------------------------------------------

        address msgSender = LibMulticaller.senderOrSigner();
        params.hooklet.hookletBeforeInitialize(msgSender, params);

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // deploy BunniToken
        token = IBunniToken(
            address(env.bunniTokenImplementation).clone3({
                data: abi.encodePacked(
                    address(this), params.currency0, params.currency1, params.name, params.symbol, env.poolManager
                ),
                salt: keccak256(abi.encodePacked(msgSender, params.salt)) // hash sender into salt to prevent griefing via frontrunning
            })
        );
        token.initialize(params.owner, params.metadataURI);

        PoolId poolId = key.toId();
        s.poolIdOfBunniToken[token] = poolId;

        // increment nonce
        s.nonce[bunniSubspace] = nonce_ + 1;

        // set immutable params
        bytes memory immutableParams = abi.encodePacked(
            params.liquidityDensityFunction,
            token,
            params.twapSecondsAgo,
            params.ldfParams,
            params.vault0,
            params.vault1,
            params.statefulLdf,
            params.minRawTokenRatio0,
            params.targetRawTokenRatio0,
            params.maxRawTokenRatio0,
            params.minRawTokenRatio1,
            params.targetRawTokenRatio1,
            params.maxRawTokenRatio1
        );
        immutableParams = bytes.concat(
            immutableParams, abi.encodePacked(params.hooklet, params.hookParams.length.toUint16(), params.hookParams)
        );
        s.poolState[poolId].immutableParamsPointer = immutableParams.write();

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // initialize Uniswap v4 pool
        env.poolManager.initialize(key, params.sqrtPriceX96, abi.encode(params.twapSecondsAgo, params.hookParams));

        emit IBunniHub.NewBunni(token, poolId);

        /// -----------------------------------------------------------------------
        /// Hooklet call
        /// -----------------------------------------------------------------------

        params.hooklet.hookletAfterInitialize(
            msgSender, params, IHooklet.InitializeReturnData({bunniToken: token, key: key})
        );
    }

    /// -----------------------------------------------------------------------
    /// Utilities
    /// -----------------------------------------------------------------------

    /// @notice Mints share tokens to the recipient based on the amount of liquidity added.
    /// @param shareToken The BunniToken to mint
    /// @param recipient The recipient of the share tokens
    /// @param addedAmount0 The amount of token0 added to the pool
    /// @param existingAmount0 The existing amount of token0 in the pool
    /// @param addedAmount1 The amount of token1 added to the pool
    /// @param existingAmount1 The existing amount of token1 in the pool
    /// @param referrer The referrer of the liquidity provider
    /// @return shares The amount of share tokens minted to the sender.
    function _mintShares(
        IBunniToken shareToken,
        address recipient,
        uint256 addedAmount0,
        uint256 existingAmount0,
        uint256 addedAmount1,
        uint256 existingAmount1,
        uint24 referrer
    ) internal returns (uint256 shares) {
        uint256 existingShareSupply = shareToken.totalSupply();
        if (existingShareSupply == 0) {
            // no existing shares, just give WAD
            shares = WAD - MIN_INITIAL_SHARES;
            // prevent first staker from stealing funds of subsequent stakers
            // see https://code4rena.com/reports/2022-01-sherlock/#h-01-first-user-can-steal-everyone-elses-tokens
            shareToken.mint(address(0), MIN_INITIAL_SHARES, 0);
        } else {
            // given that the position may become single-sided, we need to handle the case where one of the existingAmount values is zero
            if (existingAmount0 == 0 && existingAmount1 == 0) revert BunniHub__ZeroSharesMinted();
            shares = FixedPointMathLib.min(
                existingAmount0 == 0 ? type(uint256).max : existingShareSupply.mulDiv(addedAmount0, existingAmount0),
                existingAmount1 == 0 ? type(uint256).max : existingShareSupply.mulDiv(addedAmount1, existingAmount1)
            );
            if (shares == 0) revert BunniHub__ZeroSharesMinted();
        }

        // mint shares to sender
        shareToken.mint(recipient, shares, referrer);
    }

    /// @dev Deposits tokens into a vault.
    /// @param env The environment vars.
    /// @param amount The amount to deposit.
    /// @param currency The currency to deposit.
    /// @param vault The vault to deposit into.
    /// @param user The user to deposit tokens from.
    /// @param vaultFee The vault's withdrawal fee, in 18 decimals.
    /// @return reserveChange The change in reserve balance.
    /// @return reserveChangeInUnderlying The change in reserve balance in underlying tokens.
    function _depositVaultReserve(
        Env calldata env,
        uint256 amount,
        Currency currency,
        ERC4626 vault,
        address user,
        uint256 vaultFee
    ) internal returns (uint256 reserveChange, uint256 reserveChangeInUnderlying) {
        // use the pre-fee amount to ensure `amount` is the amount of tokens
        // that we'll be able to withdraw from the vault
        // it's safe to rely on the user provided fee value here
        // since if user provides fee=0 when it's actually not the amount of bunni shares minted goes down
        // and if user provide fee!=0 when the fee is some other value (0 or non-zero) the validation will revert
        uint256 postFeeAmount = amount; // cache amount to use for validation later
        amount = amount.divWadUp(WAD - vaultFee);

        IERC20 token;
        if (currency.isNative()) {
            // wrap ETH
            // no need to pull tokens from user since WETH is already in the contract
            env.weth.deposit{value: amount}();
            token = IERC20(address(env.weth));
        } else {
            // normal ERC20
            token = IERC20(Currency.unwrap(currency));
            env.permit2.transferFrom(user, address(this), amount.toUint160(), address(token));
        }

        // do vault deposit
        address(token).safeApproveWithRetry(address(vault), amount);
        reserveChange = vault.deposit(amount, address(this));
        reserveChangeInUnderlying = vault.previewRedeem(reserveChange);

        // validate vault fee value
        if (
            vaultFee != 0 && dist(reserveChangeInUnderlying, postFeeAmount) > 1 // avoid reverting from normal rounding error
                && percentDelta(reserveChangeInUnderlying, postFeeAmount) > MAX_VAULT_FEE_ERROR
        ) {
            revert BunniHub__VaultFeeIncorrect();
        }
    }

    /// @dev Withdraws tokens from a vault.
    /// @param amount The amount to withdraw.
    /// @param currency The currency to withdraw.
    /// @param vault The vault to withdraw from.
    /// @param user The user to withdraw tokens to.
    /// @param weth The WETH contract.
    /// @return reserveChange The change in reserve balance.
    function _withdrawVaultReserve(uint256 amount, Currency currency, ERC4626 vault, address user, WETH weth)
        internal
        returns (uint256 reserveChange)
    {
        if (currency.isNative()) {
            // withdraw WETH from vault to address(this)
            reserveChange = vault.withdraw(amount, address(this), address(this));

            // burn WETH for ETH
            weth.withdraw(amount);

            // transfer ETH to user
            user.safeTransferETH(amount);
        } else {
            // normal ERC20
            reserveChange = vault.withdraw(amount, user, address(this));
        }
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

    function _getBunniTokenOfPool(HubStorage storage s, PoolId poolId) internal view returns (IBunniToken bunniToken) {
        address ptr = s.poolState[poolId].immutableParamsPointer;
        if (ptr == address(0)) return IBunniToken(address(0));
        bytes memory rawValue = ptr.read({start: 20, end: 40});
        bunniToken = IBunniToken(address(bytes20(rawValue)));
    }
}
