// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {WETH} from "solady/tokens/WETH.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
import "./lib/VaultMath.sol";
import "./lib/Constants.sol";
import "./interfaces/IBunniHub.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {BunniHubLogic} from "./lib/BunniHubLogic.sol";
import {IBunniHook} from "./interfaces/IBunniHook.sol";
import {Permit2Enabled} from "./lib/Permit2Enabled.sol";
import {IBunniToken} from "./interfaces/IBunniToken.sol";
import {AdditionalCurrencyLibrary} from "./lib/AdditionalCurrencyLib.sol";

/// @title BunniHub
/// @author zefram.eth
/// @notice The main contract LPs interact with. Each BunniKey corresponds to a BunniToken,
/// which is the ERC20 LP token for the Uniswap V4 position specified by the BunniKey.
/// Use deposit()/withdraw() to mint/burn LP tokens, and use compound() to compound the swap fees
/// back into the LP position.
contract BunniHub is IBunniHub, Permit2Enabled {
    using SSTORE2 for address;
    using SafeCastLib for int256;
    using SafeCastLib for uint256;
    using PoolIdLibrary for PoolKey;
    using SafeTransferLib for address;
    using CurrencyLibrary for Currency;
    using FixedPointMathLib for uint256;
    using AdditionalCurrencyLibrary for Currency;

    WETH internal immutable weth;
    IPoolManager internal immutable poolManager;

    /// -----------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------

    mapping(PoolId poolId => RawPoolState) internal _poolState;

    /// @inheritdoc IBunniHub
    mapping(bytes32 bunniSubspace => uint24) public override nonce;

    /// @inheritdoc IBunniHub
    mapping(IBunniToken bunniToken => PoolId) public override poolIdOfBunniToken;

    /// -----------------------------------------------------------
    /// Modifiers
    /// -----------------------------------------------------------

    modifier checkDeadline(uint256 deadline) {
        if (block.timestamp > deadline) revert BunniHub__PastDeadline();
        _;
    }

    /// -----------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------

    constructor(IPoolManager poolManager_, WETH weth_, IPermit2 permit2_) Permit2Enabled(permit2_) {
        poolManager = poolManager_;
        weth = weth_;
    }

    /// -----------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------

    /// @inheritdoc IBunniHub
    function deposit(DepositParams calldata params)
        external
        payable
        virtual
        override
        nonReentrant
        checkDeadline(params.deadline)
        returns (uint256 shares, uint256 amount0, uint256 amount1)
    {
        return BunniHubLogic.deposit(params, poolManager, weth, permit2, _poolState);
    }

    /// @inheritdoc IBunniHub
    function withdraw(WithdrawParams calldata params)
        external
        virtual
        override
        nonReentrant
        checkDeadline(params.deadline)
        returns (uint256 amount0, uint256 amount1)
    {
        return BunniHubLogic.withdraw(params, poolManager, weth, permit2, _poolState);
    }

    /// @inheritdoc IBunniHub
    function deployBunniToken(DeployBunniTokenParams calldata params)
        external
        override
        nonReentrant
        returns (IBunniToken token, PoolKey memory key)
    {
        return BunniHubLogic.deployBunniToken(params, poolManager, _poolState, nonce, poolIdOfBunniToken, weth);
    }

    /// @inheritdoc IBunniHub
    function hookHandleSwap(PoolKey calldata key, bool zeroForOne, uint256 inputAmount, uint256 outputAmount)
        external
        override
        nonReentrant
    {
        if (msg.sender != address(key.hooks)) revert BunniHub__Unauthorized();

        poolManager.lock(
            address(this),
            abi.encode(
                LockCallbackType.SWAP,
                abi.encode(
                    HookHandleSwapCallbackInputData({
                        key: key,
                        zeroForOne: zeroForOne,
                        inputAmount: inputAmount,
                        outputAmount: outputAmount
                    })
                )
            )
        );
    }

    receive() external payable {}

    /// -----------------------------------------------------------------------
    /// View functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHub
    function poolState(PoolId poolId) external view returns (PoolState memory) {
        return _getPoolState(poolId);
    }

    /// -----------------------------------------------------------------------
    /// Uniswap callback
    /// -----------------------------------------------------------------------

    function lockAcquired(address lockCaller, bytes calldata data) external override returns (bytes memory) {
        // verify sender
        if (msg.sender != address(poolManager) || lockCaller != address(this)) revert BunniHub__Unauthorized();

        // decode input
        (LockCallbackType t, bytes memory callbackData) = abi.decode(data, (LockCallbackType, bytes));

        // redirect to respective callback
        if (t == LockCallbackType.SWAP) {
            _hookHandleSwapLockCallback(abi.decode(callbackData, (HookHandleSwapCallbackInputData)));
        } else if (t == LockCallbackType.DEPOSIT) {
            _depositLockCallback(abi.decode(callbackData, (DepositCallbackInputData)));
        } else if (t == LockCallbackType.WITHDRAW) {
            _withdrawLockCallback(abi.decode(callbackData, (WithdrawCallbackInputData)));
        } else if (t == LockCallbackType.INITIALIZE_POOL) {
            _initializePoolLockCallback(abi.decode(callbackData, (InitializePoolCallbackInputData)));
        }
        // fallback
        return bytes("");
    }

    /// -----------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------

    function _hookHandleSwapLockCallback(HookHandleSwapCallbackInputData memory data) internal {
        (PoolKey memory key, bool zeroForOne, uint256 inputAmount, uint256 outputAmount) =
            (data.key, data.zeroForOne, data.inputAmount, data.outputAmount);

        // load state
        PoolId poolId = key.toId();
        PoolState memory state = _getPoolState(poolId);
        (Currency inputToken, Currency outputToken) =
            zeroForOne ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        (uint256 initialReserve0, uint256 initialReserve1) = (state.reserve0, state.reserve1);

        // pull input claim tokens from hook
        if (inputAmount != 0) {
            if (zeroForOne) {
                state.rawBalance0 += inputAmount;
            } else {
                state.rawBalance1 += inputAmount;
            }
            poolManager.transferFrom(address(key.hooks), address(this), inputToken.toId(), inputAmount);
        }

        // push output claim tokens to hook
        if (zeroForOne) {
            if (address(state.vault1) != address(0) && state.rawBalance1 < outputAmount) {
                // insufficient token balance
                // withdraw tokens from reserves
                (int256 reserve1Change, int256 rawBalance1Change) = _updateVaultReserveViaClaimTokens(
                    (outputAmount - state.rawBalance1).toInt256(), outputToken, state.vault1
                );
                state.reserve1 = (state.reserve1.toInt256() + reserve1Change).toUint256();
                state.rawBalance1 = (state.rawBalance1.toInt256() + rawBalance1Change).toUint256();
            }
            state.rawBalance1 -= outputAmount;
        } else {
            if (address(state.vault0) != address(0) && state.rawBalance0 < outputAmount) {
                // insufficient token balance
                // withdraw tokens from reserves
                (int256 reserve0Change, int256 rawBalance0Change) = _updateVaultReserveViaClaimTokens(
                    (outputAmount - state.rawBalance0).toInt256(), outputToken, state.vault0
                );
                state.reserve0 = (state.reserve0.toInt256() + reserve0Change).toUint256();
                state.rawBalance0 = (state.rawBalance0.toInt256() + rawBalance0Change).toUint256();
            }
            state.rawBalance0 -= outputAmount;
        }
        poolManager.transfer(address(key.hooks), outputToken.toId(), outputAmount);

        // update raw token balances if we're using vaults and the (rawBalance / balance) ratio is outside the bounds
        if (address(state.vault0) != address(0)) {
            uint256 balance0 = state.rawBalance0 + getReservesInUnderlying(state.reserve0, state.vault0);
            (uint256 minRawBalance0, uint256 maxRawBalance0) = (
                balance0.mulDiv(state.minRawTokenRatio0, RAW_TOKEN_RATIO_BASE),
                balance0.mulDiv(state.maxRawTokenRatio0, RAW_TOKEN_RATIO_BASE)
            );
            if (state.rawBalance0 < minRawBalance0 || state.rawBalance0 > maxRawBalance0) {
                // update raw balance to target
                uint256 targetRawBalance0 = balance0.mulDiv(state.targetRawTokenRatio0, RAW_TOKEN_RATIO_BASE);
                (int256 reserve0Change, int256 rawBalance0Change) = _updateVaultReserveViaClaimTokens(
                    targetRawBalance0.toInt256() - state.rawBalance0.toInt256(), key.currency0, state.vault0
                );
                state.reserve0 = (state.reserve0.toInt256() + reserve0Change).toUint256();
                state.rawBalance0 = (state.rawBalance0.toInt256() + rawBalance0Change).toUint256();
            }
        }
        if (address(state.vault1) != address(0)) {
            uint256 balance1 = state.rawBalance1 + getReservesInUnderlying(state.reserve1, state.vault1);
            (uint256 minRawBalance1, uint256 maxRawBalance1) = (
                balance1.mulDiv(state.minRawTokenRatio1, RAW_TOKEN_RATIO_BASE),
                balance1.mulDiv(state.maxRawTokenRatio1, RAW_TOKEN_RATIO_BASE)
            );
            if (state.rawBalance1 < minRawBalance1 || state.rawBalance1 > maxRawBalance1) {
                // update raw balance to target
                uint256 targetRawBalance1 = balance1.mulDiv(state.targetRawTokenRatio1, RAW_TOKEN_RATIO_BASE);
                (int256 reserve1Change, int256 rawBalance1Change) = _updateVaultReserveViaClaimTokens(
                    targetRawBalance1.toInt256() - state.rawBalance1.toInt256(), key.currency1, state.vault1
                );
                state.reserve1 = (state.reserve1.toInt256() + reserve1Change).toUint256();
                state.rawBalance1 = (state.rawBalance1.toInt256() + rawBalance1Change).toUint256();
            }
        }

        // update state
        _poolState[poolId].rawBalance0 = state.rawBalance0;
        _poolState[poolId].rawBalance1 = state.rawBalance1;
        if (address(state.vault0) != address(0) && initialReserve0 != state.reserve0) {
            _poolState[poolId].reserve0 = state.reserve0;
        }
        if (address(state.vault1) != address(0) && initialReserve1 != state.reserve1) {
            _poolState[poolId].reserve1 = state.reserve1;
        }
    }

    function _depositLockCallback(DepositCallbackInputData memory data) internal {
        (address msgSender, PoolKey memory key, uint256 msgValue, uint256 rawAmount0, uint256 rawAmount1) =
            (data.user, data.poolKey, data.msgValue, data.rawAmount0, data.rawAmount1);

        PoolId poolId = key.toId();
        if (rawAmount0 != 0) {
            key.currency0.safeTransferFromPermit2(msgSender, address(poolManager), rawAmount0, permit2, msgValue);
            poolManager.settle(key.currency0);
            poolManager.mint(address(this), key.currency0.toId(), rawAmount0);
            _poolState[poolId].rawBalance0 += rawAmount0;
        }
        if (rawAmount1 != 0) {
            key.currency1.safeTransferFromPermit2(msgSender, address(poolManager), rawAmount1, permit2, msgValue);
            poolManager.settle(key.currency1);
            poolManager.mint(address(this), key.currency1.toId(), rawAmount1);
            _poolState[poolId].rawBalance1 += rawAmount1;
        }
    }

    function _withdrawLockCallback(WithdrawCallbackInputData memory data) internal {
        (address recipient, PoolKey memory key, uint256 rawAmount0, uint256 rawAmount1) =
            (data.user, data.poolKey, data.rawAmount0, data.rawAmount1);

        PoolId poolId = key.toId();
        if (rawAmount0 != 0) {
            _poolState[poolId].rawBalance0 -= rawAmount0;
            poolManager.burn(address(this), key.currency0.toId(), rawAmount0);
            poolManager.take(key.currency0, recipient, rawAmount0);
        }
        if (rawAmount1 != 0) {
            _poolState[poolId].rawBalance1 -= rawAmount1;
            poolManager.burn(address(this), key.currency1.toId(), rawAmount1);
            poolManager.take(key.currency1, recipient, rawAmount1);
        }
    }

    function _initializePoolLockCallback(InitializePoolCallbackInputData memory data) internal {
        poolManager.initialize(data.poolKey, data.sqrtPriceX96, abi.encode(data.twapSecondsAgo, data.hookParams));
    }

    /// @dev Deposits/withdraws tokens from a vault via claim tokens.
    /// @param rawBalanceChange The amount to deposit/withdraw. Positive for withdraw, negative for deposit.
    /// @param currency The currency to deposit/withdraw.
    /// @param vault The vault to deposit/withdraw from.
    /// @return reserveChange The change in reserves. Positive for deposit, negative for withdraw.
    /// @return actualRawBalanceChange The actual amount of raw tokens deposited/withdrawn. Positive for withdraw, negative for deposit.
    function _updateVaultReserveViaClaimTokens(int256 rawBalanceChange, Currency currency, ERC4626 vault)
        internal
        returns (int256 reserveChange, int256 actualRawBalanceChange)
    {
        uint256 absAmount = FixedPointMathLib.abs(rawBalanceChange);
        if (rawBalanceChange < 0) {
            // take tokens from poolManager
            uint256 poolManagerReserve = poolManager.reservesOf(currency);
            if (absAmount > poolManagerReserve) {
                // poolManager doesn't have enough tokens
                // only take what we can
                // we're only maintaining the raw balance ratio so it's fine to take less
                absAmount = poolManagerReserve;
            }
            poolManager.take(currency, address(this), absAmount);

            // burn claim tokens from this
            poolManager.burn(address(this), currency.toId(), absAmount);

            // deposit tokens into vault
            IERC20 token;
            if (currency.isNative()) {
                // wrap ETH
                weth.deposit{value: absAmount}();
                token = IERC20(address(weth));
            } else {
                // normal ERC20
                token = IERC20(Currency.unwrap(currency));
            }
            uint256 beforeTokenBalance = token.balanceOf(address(this));
            address(token).safeApprove(address(vault), absAmount);
            reserveChange = vault.deposit(absAmount, address(this)).toInt256();
            uint256 depositedAmount = beforeTokenBalance - token.balanceOf(address(this));
            if (depositedAmount != absAmount) revert BunniHub__VaultDepositedAmountIncorrect();
            actualRawBalanceChange = -depositedAmount.toInt256();
        } else if (rawBalanceChange > 0) {
            if (currency.isNative()) {
                // withdraw WETH from vault to address(this)
                reserveChange = -vault.withdraw(absAmount, address(this), address(this)).toInt256();

                // burn WETH for ETH
                weth.withdraw(absAmount);

                // transfer ETH to poolManager
                address(poolManager).safeTransferETH(absAmount);
            } else {
                // normal ERC20
                // withdraw tokens to poolManager
                reserveChange = -vault.withdraw(absAmount, address(poolManager), address(this)).toInt256();
            }

            // settle with poolManager
            // check actual settled amount to prevent malicious vaults from giving us less than we asked for
            uint256 settleAmount = poolManager.settle(currency);
            if (settleAmount != absAmount) revert BunniHub__VaultWithdrawnAmountIncorrect();
            actualRawBalanceChange = settleAmount.toInt256();

            // mint claim tokens to this
            poolManager.mint(address(this), currency.toId(), absAmount);
        }
    }

    function _getPoolState(PoolId poolId) internal view returns (PoolState memory state) {
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
}
