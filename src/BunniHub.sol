// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {TransientStateLibrary} from "@uniswap/v4-core/src/libraries/TransientStateLibrary.sol";

import {WETH} from "solady/tokens/WETH.sol";
import {SSTORE2} from "solady/utils/SSTORE2.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import "./lib/Math.sol";
import "./base/Errors.sol";
import "./lib/VaultMath.sol";
import "./base/Constants.sol";
import "./base/SharedStructs.sol";
import "./interfaces/IBunniHub.sol";
import {Ownable} from "./base/Ownable.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {BunniHubLogic} from "./lib/BunniHubLogic.sol";
import {IBunniHook} from "./interfaces/IBunniHook.sol";
import {Permit2Enabled} from "./base/Permit2Enabled.sol";
import {IBunniToken} from "./interfaces/IBunniToken.sol";
import {AdditionalCurrencyLibrary} from "./lib/AdditionalCurrencyLib.sol";
import {PoolState, getPoolState, getPoolParams} from "./types/PoolState.sol";

/// @title BunniHub
/// @author zefram.eth
/// @notice The main contract LPs interact with. Each BunniKey corresponds to a BunniToken,
/// which is the ERC20 LP token for the Uniswap V4 position specified by the BunniKey.
/// Use deposit()/withdraw() to mint/burn LP tokens, and use compound() to compound the swap fees
/// back into the LP position.
contract BunniHub is IBunniHub, Permit2Enabled, Ownable {
    using SafeCastLib for *;
    using SSTORE2 for address;
    using FixedPointMathLib for *;
    using PoolIdLibrary for PoolKey;
    using SafeTransferLib for address;
    using CurrencyLibrary for Currency;
    using AdditionalCurrencyLibrary for Currency;
    using TransientStateLibrary for IPoolManager;

    WETH internal immutable weth;
    IPoolManager internal immutable poolManager;
    IBunniToken internal immutable bunniTokenImplementation;

    /// -----------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------

    /// @dev The storage content of BunniHub. Useful for passing storage to BunniHubLogic.
    HubStorage internal s;

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

    constructor(
        IPoolManager poolManager_,
        WETH weth_,
        IPermit2 permit2_,
        IBunniToken bunniTokenImplementation_,
        address initialOwner
    ) Permit2Enabled(permit2_) {
        require(
            address(poolManager_) != address(0) && address(weth_) != address(0)
                && address(bunniTokenImplementation_) != address(0) && initialOwner != address(0)
        );
        poolManager = poolManager_;
        weth = weth_;
        bunniTokenImplementation = bunniTokenImplementation_;
        _initializeOwner(initialOwner);
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
        return BunniHubLogic.deposit(
            s,
            BunniHubLogic.Env({
                weth: weth,
                permit2: permit2,
                poolManager: poolManager,
                bunniTokenImplementation: bunniTokenImplementation
            }),
            params
        );
    }

    /// @inheritdoc IBunniHub
    function queueWithdraw(QueueWithdrawParams calldata params) external virtual override nonReentrant {
        BunniHubLogic.queueWithdraw(s, params);
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
        return BunniHubLogic.withdraw(
            s,
            BunniHubLogic.Env({
                weth: weth,
                permit2: permit2,
                poolManager: poolManager,
                bunniTokenImplementation: bunniTokenImplementation
            }),
            params
        );
    }

    /// @inheritdoc IBunniHub
    function deployBunniToken(DeployBunniTokenParams calldata params)
        external
        override
        nonReentrant
        returns (IBunniToken token, PoolKey memory key)
    {
        return BunniHubLogic.deployBunniToken(
            s,
            BunniHubLogic.Env({
                weth: weth,
                permit2: permit2,
                poolManager: poolManager,
                bunniTokenImplementation: bunniTokenImplementation
            }),
            params
        );
    }

    /// @inheritdoc IBunniHub
    function hookHandleSwap(PoolKey calldata key, bool zeroForOne, uint256 inputAmount, uint256 outputAmount)
        external
        override
        nonReentrant
    {
        if (msg.sender != address(key.hooks)) revert BunniHub__Unauthorized();

        // load state
        PoolId poolId = key.toId();
        PoolState memory state = getPoolState(s, poolId);
        (Currency inputToken, Currency outputToken) =
            zeroForOne ? (key.currency0, key.currency1) : (key.currency1, key.currency0);
        (uint256 initialReserve0, uint256 initialReserve1) = (state.reserve0, state.reserve1);

        // pull input claim tokens from hook
        if (inputAmount != 0) {
            zeroForOne ? state.rawBalance0 += inputAmount : state.rawBalance1 += inputAmount;
            poolManager.transferFrom(address(key.hooks), address(this), inputToken.toId(), inputAmount);
        }

        // push output claim tokens to hook
        if (outputAmount != 0) {
            (uint256 outputRawBalance, ERC4626 outputVault) =
                zeroForOne ? (state.rawBalance1, state.vault1) : (state.rawBalance0, state.vault0);
            if (address(outputVault) != address(0) && outputRawBalance < outputAmount) {
                // insufficient token balance
                // withdraw tokens from reserves
                (int256 reserveChange, int256 rawBalanceChange) = _updateVaultReserveViaClaimTokens(
                    (outputAmount - outputRawBalance).toInt256(), outputToken, outputVault
                );
                zeroForOne
                    ? (state.reserve1, state.rawBalance1) =
                        (_updateBalance(state.reserve1, reserveChange), _updateBalance(state.rawBalance1, rawBalanceChange))
                    : (state.reserve0, state.rawBalance0) =
                        (_updateBalance(state.reserve0, reserveChange), _updateBalance(state.rawBalance0, rawBalanceChange));
            }
            zeroForOne ? state.rawBalance1 -= outputAmount : state.rawBalance0 -= outputAmount;
            poolManager.transfer(address(key.hooks), outputToken.toId(), outputAmount);
        }

        // update raw token balances if we're using vaults and the (rawBalance / balance) ratio is outside the bounds
        if (address(state.vault0) != address(0)) {
            (state.reserve0, state.rawBalance0) = _updateRawBalanceIfNeeded(
                key.currency0,
                state.vault0,
                state.rawBalance0,
                state.reserve0,
                state.minRawTokenRatio0,
                state.maxRawTokenRatio0,
                state.targetRawTokenRatio0
            );
        }
        if (address(state.vault1) != address(0)) {
            (state.reserve1, state.rawBalance1) = _updateRawBalanceIfNeeded(
                key.currency1,
                state.vault1,
                state.rawBalance1,
                state.reserve1,
                state.minRawTokenRatio1,
                state.maxRawTokenRatio1,
                state.targetRawTokenRatio1
            );
        }

        // update state
        s.poolState[poolId].rawBalance0 = state.rawBalance0;
        s.poolState[poolId].rawBalance1 = state.rawBalance1;
        if (address(state.vault0) != address(0) && initialReserve0 != state.reserve0) {
            s.reserve0[poolId] = state.reserve0;
        }
        if (address(state.vault1) != address(0) && initialReserve1 != state.reserve1) {
            s.reserve1[poolId] = state.reserve1;
        }
    }

    receive() external payable {}

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHub
    function setReferrerAddress(uint24 referrer, address referrerAddress) external {
        if (msg.sender != owner() && msg.sender != s.referrerAddress[referrer]) revert BunniHub__Unauthorized();
        if (referrer > MAX_REFERRER) revert BunniHub__InvalidReferrer();
        s.referrerAddress[referrer] = referrerAddress;
        emit SetReferrerAddress(referrer, referrerAddress);
    }

    /// -----------------------------------------------------------------------
    /// View functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHub
    function poolState(PoolId poolId) external view returns (PoolState memory) {
        return getPoolState(s, poolId);
    }

    /// @inheritdoc IBunniHub
    function poolParams(PoolId poolId) external view returns (PoolState memory) {
        return getPoolParams(s.poolState[poolId].immutableParamsPointer);
    }

    /// @inheritdoc IBunniHub
    function bunniTokenOfPool(PoolId poolId) external view returns (IBunniToken) {
        return _getBunniTokenOfPool(poolId);
    }

    /// @inheritdoc IBunniHub
    function hookParams(PoolId poolId) external view returns (bytes memory) {
        return _getHookParams(poolId);
    }

    /// @inheritdoc IBunniHub
    function poolBalances(PoolId poolId) external view returns (uint256 balance0, uint256 balance1) {
        PoolState memory state = getPoolState(s, poolId);
        balance0 = state.rawBalance0 + getReservesInUnderlying(state.reserve0, state.vault0);
        balance1 = state.rawBalance1 + getReservesInUnderlying(state.reserve1, state.vault1);
    }

    /// @inheritdoc IBunniHub
    function nonce(bytes32 bunniSubspace) external view override returns (uint24) {
        return s.nonce[bunniSubspace];
    }

    /// @inheritdoc IBunniHub
    function poolIdOfBunniToken(IBunniToken bunniToken) external view override returns (PoolId) {
        return s.poolIdOfBunniToken[bunniToken];
    }

    /// @inheritdoc IBunniHub
    function getReferrerAddress(uint24 referrer) external view override returns (address) {
        return s.referrerAddress[referrer];
    }

    /// -----------------------------------------------------------------------
    /// Uniswap callback
    /// -----------------------------------------------------------------------

    enum UnlockCallbackType {
        DEPOSIT,
        WITHDRAW
    }

    struct DepositCallbackInputData {
        address user;
        PoolKey poolKey;
        uint256 msgValue;
        uint256 rawAmount0;
        uint256 rawAmount1;
    }

    struct WithdrawCallbackInputData {
        address user;
        PoolKey poolKey;
        uint256 rawAmount0;
        uint256 rawAmount1;
    }

    /// @inheritdoc IUnlockCallback
    function unlockCallback(bytes calldata data) external override returns (bytes memory) {
        // verify sender
        if (msg.sender != address(poolManager)) revert BunniHub__Unauthorized();

        // decode input
        (UnlockCallbackType t, bytes memory callbackData) = abi.decode(data, (UnlockCallbackType, bytes));

        // redirect to respective callback
        if (t == UnlockCallbackType.DEPOSIT) {
            return _depositUnlockCallback(abi.decode(callbackData, (DepositCallbackInputData)));
        } else if (t == UnlockCallbackType.WITHDRAW) {
            _withdrawUnlockCallback(abi.decode(callbackData, (WithdrawCallbackInputData)));
        }
        // fallback
        return bytes("");
    }

    function _depositUnlockCallback(DepositCallbackInputData memory data) internal returns (bytes memory) {
        (address msgSender, PoolKey memory key, uint256 msgValue, uint256 rawAmount0, uint256 rawAmount1) =
            (data.user, data.poolKey, data.msgValue, data.rawAmount0, data.rawAmount1);

        PoolId poolId = key.toId();
        uint256 paid0;
        uint256 paid1;
        if (rawAmount0 != 0) {
            poolManager.sync(key.currency0);

            // transfer tokens to poolManager
            if (key.currency0.isNative()) {
                if (msgValue < rawAmount0) revert BunniHub__MsgValueInsufficient();
                paid0 = poolManager.settle{value: rawAmount0}();
            } else {
                key.currency0.safeTransferFromPermit2(permit2, msgSender, address(poolManager), rawAmount0);
                paid0 = poolManager.settle();
            }

            poolManager.mint(address(this), key.currency0.toId(), paid0);
            s.poolState[poolId].rawBalance0 += paid0;
        }
        if (rawAmount1 != 0) {
            poolManager.sync(key.currency1);

            // transfer tokens to poolManager
            if (key.currency1.isNative()) {
                if (msgValue < rawAmount1) revert BunniHub__MsgValueInsufficient();
                paid1 = poolManager.settle{value: rawAmount1}();
            } else {
                key.currency1.safeTransferFromPermit2(permit2, msgSender, address(poolManager), rawAmount1);
                paid1 = poolManager.settle();
            }

            poolManager.mint(address(this), key.currency1.toId(), paid1);
            s.poolState[poolId].rawBalance1 += paid1;
        }
        return abi.encode(paid0, paid1);
    }

    function _withdrawUnlockCallback(WithdrawCallbackInputData memory data) internal {
        (address recipient, PoolKey memory key, uint256 rawAmount0, uint256 rawAmount1) =
            (data.user, data.poolKey, data.rawAmount0, data.rawAmount1);

        PoolId poolId = key.toId();
        if (rawAmount0 != 0) {
            s.poolState[poolId].rawBalance0 -= rawAmount0;
            poolManager.burn(address(this), key.currency0.toId(), rawAmount0);
            poolManager.take(key.currency0, recipient, rawAmount0);
        }
        if (rawAmount1 != 0) {
            s.poolState[poolId].rawBalance1 -= rawAmount1;
            poolManager.burn(address(this), key.currency1.toId(), rawAmount1);
            poolManager.take(key.currency1, recipient, rawAmount1);
        }
    }

    /// -----------------------------------------------------------------------
    /// Internal utilities
    /// -----------------------------------------------------------------------

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
            uint256 maxDepositAmount = vault.maxDeposit(address(this));
            // if poolManager doesn't have enough tokens or we're trying to deposit more than the vault accepts
            // then we only deposit what we can
            // we're only maintaining the raw balance ratio so it's fine to deposit less than requested
            uint256 poolManagerReserve = currency.balanceOf(address(poolManager));
            absAmount = FixedPointMathLib.min(FixedPointMathLib.min(absAmount, maxDepositAmount), poolManagerReserve);

            // burn claim tokens from this
            poolManager.burn(address(this), currency.toId(), absAmount);

            // take tokens from poolManager
            poolManager.take(currency, address(this), absAmount);

            // deposit tokens into vault
            IERC20 token;
            if (currency.isNative()) {
                // wrap ETH
                weth.deposit{value: absAmount}();
                token = IERC20(address(weth));
            } else {
                token = IERC20(Currency.unwrap(currency));
            }
            address(token).safeApproveWithRetry(address(vault), absAmount);
            reserveChange = vault.deposit(absAmount, address(this)).toInt256();

            // it's safe to use absAmount here since at worst the vault.deposit() call pulled less token
            // than requested
            actualRawBalanceChange = -absAmount.toInt256();

            // revoke token approval to vault if necessary
            if (token.allowance(address(this), address(vault)) != 0) {
                address(token).safeApprove(address(vault), 0);
            }
        } else if (rawBalanceChange > 0) {
            // sync poolManager balance before transferring assets to it
            poolManager.sync(currency);

            uint256 settleMsgValue;
            if (currency.isNative()) {
                // withdraw WETH from vault to address(this)
                reserveChange = -vault.withdraw(absAmount, address(this), address(this)).toInt256();

                // burn WETH for ETH
                weth.withdraw(absAmount);

                // transfer ETH to poolManager
                settleMsgValue = absAmount;
            } else {
                // normal ERC20
                // withdraw tokens to poolManager
                reserveChange = -vault.withdraw(absAmount, address(poolManager), address(this)).toInt256();
            }

            // settle with poolManager
            // check actual settled amount to prevent malicious vaults from giving us less than we asked for
            uint256 settleAmount = poolManager.settle{value: settleMsgValue}();
            actualRawBalanceChange = settleAmount.toInt256();

            // mint claim tokens to this
            poolManager.mint(address(this), currency.toId(), settleAmount);
        }
    }

    /// @dev Uses the reserve to update the raw balance so that the (rawBalance / balance) ratio is within bounds.
    function _updateRawBalanceIfNeeded(
        Currency currency,
        ERC4626 vault,
        uint256 rawBalance,
        uint256 reserve,
        uint256 minRatio,
        uint256 maxRatio,
        uint256 targetRatio
    ) internal returns (uint256 newReserve, uint256 newRawBalance) {
        uint256 balance = rawBalance + getReservesInUnderlying(reserve, vault);
        uint256 minRawBalance = balance.mulDiv(minRatio, RAW_TOKEN_RATIO_BASE);
        uint256 maxRawBalance = balance.mulDiv(maxRatio, RAW_TOKEN_RATIO_BASE);

        if (rawBalance < minRawBalance || rawBalance > maxRawBalance) {
            uint256 targetRawBalance = balance.mulDiv(targetRatio, RAW_TOKEN_RATIO_BASE);
            (int256 reserveChange, int256 rawBalanceChange) =
                _updateVaultReserveViaClaimTokens(targetRawBalance.toInt256() - rawBalance.toInt256(), currency, vault);
            newReserve = _updateBalance(reserve, reserveChange);
            newRawBalance = _updateBalance(rawBalance, rawBalanceChange);
        } else {
            (newReserve, newRawBalance) = (reserve, rawBalance);
        }
    }

    function _getBunniTokenOfPool(PoolId poolId) internal view returns (IBunniToken bunniToken) {
        address ptr = s.poolState[poolId].immutableParamsPointer;
        if (ptr == address(0)) return IBunniToken(address(0));
        bytes memory rawValue = ptr.read({start: 20, end: 40});
        bunniToken = IBunniToken(address(bytes20(rawValue)));
    }

    function _getHookParams(PoolId poolId) internal view returns (bytes memory result) {
        address ptr = s.poolState[poolId].immutableParamsPointer;
        if (ptr == address(0)) return bytes("");
        result = ptr.read({start: 156});
    }

    function _updateBalance(uint256 balance, int256 delta) internal pure returns (uint256) {
        return (balance.toInt256() + delta).toUint256();
    }
}
