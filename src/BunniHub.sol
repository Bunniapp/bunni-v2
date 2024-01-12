// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {WETH} from "solady/src/tokens/WETH.sol";
import {SSTORE2} from "solady/src/utils/SSTORE2.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
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

    /// @inheritdoc IBunniHub
    mapping(PoolId poolId => uint256) public override poolCredit0;

    /// @inheritdoc IBunniHub
    mapping(PoolId poolId => uint256) public override poolCredit1;

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
        return BunniHubLogic.deposit(params, weth, permit2, _poolState, poolCredit0, poolCredit1);
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
        return BunniHubLogic.withdraw(params, poolManager, weth, permit2, _poolState, poolCredit0, poolCredit1);
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
    function hookHandleSwap(
        PoolKey calldata key,
        bool zeroForOne,
        uint256 inputAmount,
        uint256 inputPoolCreditAmount,
        uint256 outputAmount,
        uint256 updatedRawTokenBalance0,
        uint256 updatedRawTokenBalance1
    ) external payable override nonReentrant {
        if (msg.sender != address(key.hooks)) revert BunniHub__Unauthorized();

        // clear pool credits
        PoolKey[] memory keys = new PoolKey[](1);
        keys[0] = key;
        poolManager.lock(address(this), abi.encode(LockCallbackType.CLEAR_POOL_CREDITS, abi.encode(keys)));

        // load state
        PoolId poolId = key.toId();
        PoolState memory state = _getPoolState(poolId);
        (Currency inputToken, Currency outputToken) =
            zeroForOne ? (key.currency0, key.currency1) : (key.currency1, key.currency0);

        // pull input tokens from hook
        if (inputAmount != 0) {
            if (zeroForOne) {
                state.rawBalance0 += inputAmount;
            } else {
                state.rawBalance1 += inputAmount;
            }
            inputToken.safeTransferFrom(address(key.hooks), address(this), inputAmount);
        }

        // pull input pool credit from hook
        if (inputPoolCreditAmount > 0) {
            // increase poolCredit
            mapping(PoolId => uint256) storage poolCredit = zeroForOne ? poolCredit0 : poolCredit1;

            // we just cleared the pool credits, so we can assume it's zero
            // credit zero -> non-zero
            // set flag
            if (zeroForOne) _poolState[poolId].poolCredit0Set = true;
            else _poolState[poolId].poolCredit1Set = true;

            poolCredit[poolId] = inputPoolCreditAmount;

            // transfer claim tokens from hook
            poolManager.transferFrom(address(key.hooks), address(this), inputToken.toId(), inputPoolCreditAmount);
        }

        // push output tokens to pool manager
        if (zeroForOne) {
            if (address(state.vault1) != address(0) && state.rawBalance1 < outputAmount) {
                // insufficient token balance
                // withdraw tokens from reserves
                int256 reserve1Change = _updateVaultReserve(
                    -(outputAmount - state.rawBalance1).toInt256(), outputToken, state.vault1, address(this), false
                );
                state.reserve1 = (state.reserve1.toInt256() + reserve1Change).toUint256();
                state.rawBalance1 = outputAmount;
            }
            state.rawBalance1 -= outputAmount;
        } else {
            if (address(state.vault0) != address(0) && state.rawBalance0 < outputAmount) {
                // insufficient token balance
                // withdraw tokens from reserves
                int256 reserve0Change = _updateVaultReserve(
                    -(outputAmount - state.rawBalance0).toInt256(), outputToken, state.vault0, address(this), false
                );
                state.reserve0 = (state.reserve0.toInt256() + reserve0Change).toUint256();
                state.rawBalance0 = outputAmount;
            }
            state.rawBalance0 -= outputAmount;
        }
        outputToken.transfer(address(poolManager), outputAmount);

        // update raw token balances if we're using vaults
        if (address(state.vault0) != address(0) && updatedRawTokenBalance0 != state.rawBalance0) {
            int256 reserve0Change = _updateVaultReserve(
                state.rawBalance0.toInt256() - updatedRawTokenBalance0.toInt256(),
                key.currency0,
                state.vault0,
                address(this),
                false
            );
            state.reserve0 = (state.reserve0.toInt256() + reserve0Change).toUint256();
            state.rawBalance0 = updatedRawTokenBalance0;
        }
        if (address(state.vault1) != address(0) && updatedRawTokenBalance1 != state.rawBalance1) {
            int256 reserve1Change = _updateVaultReserve(
                state.rawBalance1.toInt256() - updatedRawTokenBalance1.toInt256(),
                key.currency1,
                state.vault1,
                address(this),
                false
            );
            state.reserve1 = (state.reserve1.toInt256() + reserve1Change).toUint256();
            state.rawBalance1 = updatedRawTokenBalance1;
        }

        // update state
        _poolState[poolId].rawBalance0 = state.rawBalance0;
        _poolState[poolId].rawBalance1 = state.rawBalance1;
        if (address(state.vault0) != address(0)) {
            _poolState[poolId].reserve0 = state.reserve0;
        }
        if (address(state.vault1) != address(0)) {
            _poolState[poolId].reserve1 = state.reserve1;
        }
    }

    /// @inheritdoc IBunniHub
    function clearPoolCredits(PoolKey[] calldata keys) external override nonReentrant {
        poolManager.lock(address(this), abi.encode(LockCallbackType.CLEAR_POOL_CREDITS, abi.encode(keys)));
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
        if (t == LockCallbackType.WITHDRAW_POOL_CREDIT) {
            _withdrawPoolCredit(abi.decode(callbackData, (WithdrawPoolCreditInputData)));
        } else if (t == LockCallbackType.CLEAR_POOL_CREDITS) {
            _clearPoolCreditsLockCallback(abi.decode(callbackData, (PoolKey[])));
        } else if (t == LockCallbackType.INITIALIZE_POOL) {
            _initializePoolLockCallback(abi.decode(callbackData, (InitializePoolCallbackInputData)));
        }
        // fallback
        return bytes("");
    }

    /// -----------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------

    function _withdrawPoolCredit(WithdrawPoolCreditInputData memory data) internal {
        mapping(PoolId => uint256) storage poolCredit = data.currencyIdx == 0 ? poolCredit0 : poolCredit1;

        // burn claim tokens
        poolManager.burn(address(this), data.currency.toId(), data.poolCreditAmount);

        // take assets
        poolManager.take(data.currency, data.recipient, data.poolCreditAmount);

        // update credit in state
        uint256 existingPoolCredit = poolCredit[data.poolId];
        poolCredit[data.poolId] = existingPoolCredit - data.poolCreditAmount;
        if (existingPoolCredit == data.poolCreditAmount) {
            // credit non-zero -> zero
            // clear flag
            if (data.currencyIdx == 0) _poolState[data.poolId].poolCredit0Set = false;
            else _poolState[data.poolId].poolCredit1Set = false;
        }
    }

    /// @dev Clears pool credits for the specified pools.
    function _clearPoolCreditsLockCallback(PoolKey[] memory keys) internal {
        for (uint256 i; i < keys.length; i++) {
            PoolKey memory key = keys[i];
            PoolId poolId = key.toId();
            PoolState memory state = _getPoolState(poolId);
            if (state.poolCredit0Set) {
                _clearPoolCredit(poolId, key.currency0, state.vault0, 0);
            }
            if (state.poolCredit1Set) {
                _clearPoolCredit(poolId, key.currency1, state.vault1, 1);
            }
        }
    }

    function _clearPoolCredit(PoolId poolId, Currency currency, ERC4626 vault, uint256 currencyIdx) internal {
        mapping(PoolId => uint256) storage poolCredit = currencyIdx == 0 ? poolCredit0 : poolCredit1;
        uint256 poolCreditAmount = poolCredit[poolId];

        // burn claim tokens
        poolManager.burn(address(this), currency.toId(), poolCreditAmount);

        // take assets
        poolManager.take(currency, address(this), poolCreditAmount);

        if (address(vault) != address(0)) {
            // deposit into reserves
            int256 reserveChange =
                _updateVaultReserve(poolCreditAmount.toInt256(), currency, vault, address(this), false);
            if (currencyIdx == 0) {
                _poolState[poolId].reserve0 = (reserveChange + _poolState[poolId].reserve0.toInt256()).toUint256();
            } else {
                _poolState[poolId].reserve1 = (reserveChange + _poolState[poolId].reserve1.toInt256()).toUint256();
            }
        } else {
            // increment raw balance
            if (currencyIdx == 0) {
                _poolState[poolId].rawBalance0 += poolCreditAmount;
            } else {
                _poolState[poolId].rawBalance1 += poolCreditAmount;
            }
        }

        // clear credit in state
        delete poolCredit[poolId];
        if (currencyIdx == 0) _poolState[poolId].poolCredit0Set = false;
        else _poolState[poolId].poolCredit1Set = false;
    }

    function _initializePoolLockCallback(InitializePoolCallbackInputData memory data) internal {
        poolManager.initialize(data.poolKey, data.sqrtPriceX96, abi.encode(data.twapSecondsAgo, data.hookParams));
    }

    /// @dev Deposits/withdraws tokens from a vault.
    /// @param amount The amount to deposit/withdraw. Positive for deposit, negative for withdraw.
    /// @param currency The currency to deposit/withdraw.
    /// @param vault The vault to deposit/withdraw from.
    /// @param user The user to pull tokens from / withdraw tokens to
    /// @param pullTokensFromUser Whether to pull tokens from the user or not in case of deposit.
    /// @return reserveChange The change in reserves. Positive for deposit, negative for withdraw.
    function _updateVaultReserve(int256 amount, Currency currency, ERC4626 vault, address user, bool pullTokensFromUser)
        internal
        returns (int256 reserveChange)
    {
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
            return vault.deposit(absAmount, address(this)).toInt256();
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
                return -vault.withdraw(absAmount, user, address(this)).toInt256();
            }
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
            rawBalance0: rawState.rawBalance0,
            rawBalance1: rawState.rawBalance1,
            reserve0: rawState.reserve0,
            reserve1: rawState.reserve1
        });
    }
}
