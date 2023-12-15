// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {stdMath} from "forge-std/StdMath.sol";

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {SSTORE2} from "solady/src/utils/SSTORE2.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {WETH} from "solmate/tokens/WETH.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
import "./interfaces/IBunniHub.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {BunniHubLogic} from "./lib/BunniHubLogic.sol";
import {IBunniHook} from "./interfaces/IBunniHook.sol";
import {Permit2Enabled} from "./lib/Permit2Enabled.sol";
import {IBunniToken} from "./interfaces/IBunniToken.sol";
import {SafeTransferLib} from "./lib/SafeTransferLib.sol";

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
    using SafeTransferLib for IERC20;
    using SafeTransferLib for address;
    using CurrencyLibrary for Currency;

    uint256 internal constant WAD = 1e18;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
    uint256 internal constant MAX_NONCE = 0x0FFFFF;
    uint256 internal constant MIN_INITIAL_SHARES = 1e3;

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
        returns (uint256 shares, uint128 addedLiquidity, uint256 amount0, uint256 amount1)
    {
        return BunniHubLogic.deposit(params, poolManager, _poolState, poolCredit0, poolCredit1);
    }

    /// @inheritdoc IBunniHub
    function withdraw(WithdrawParams calldata params)
        external
        virtual
        override
        nonReentrant
        checkDeadline(params.deadline)
        returns (uint128 removedLiquidity, uint256 amount0, uint256 amount1)
    {
        return BunniHubLogic.withdraw(params, poolManager, _poolState, poolCredit0, poolCredit1);
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
    function hookModifyLiquidity(PoolKey calldata poolKey, LiquidityDelta[] calldata liquidityDeltas)
        external
        override
        nonReentrant
    {
        if (msg.sender != address(poolKey.hooks)) revert BunniHub__Unauthorized(); // only hook

        PoolId poolId = poolKey.toId();
        PoolState memory state = _getPoolState(poolId);

        HookCallbackReturnData memory returnData = abi.decode(
            poolManager.lock(
                address(this),
                abi.encode(
                    LockCallbackType.HOOK_MODIFY_LIQUIDITY,
                    abi.encode(
                        HookCallbackInputData({
                            poolKey: poolKey,
                            vault0: state.vault0,
                            vault1: state.vault1,
                            poolCredit0Set: state.poolCredit0Set,
                            poolCredit1Set: state.poolCredit1Set,
                            liquidityDeltas: liquidityDeltas
                        })
                    )
                )
            ),
            (HookCallbackReturnData)
        );

        // update reserves
        // reserves represent the amount of tokens not in the current tick
        _poolState[poolId].reserve0 = (state.reserve0.toInt256() + returnData.reserveChange0).toUint256();
        _poolState[poolId].reserve1 = (state.reserve1.toInt256() + returnData.reserveChange1).toUint256();
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

    enum LockCallbackType {
        HOOK_MODIFY_LIQUIDITY,
        MODIFY_LIQUIDITY,
        CLEAR_POOL_CREDITS,
        INITIALIZE_POOL
    }

    function lockAcquired(address lockCaller, bytes calldata data) external override returns (bytes memory) {
        // verify sender
        if (msg.sender != address(poolManager) || lockCaller != address(this)) revert BunniHub__Unauthorized();

        // decode input
        (LockCallbackType t, bytes memory callbackData) = abi.decode(data, (LockCallbackType, bytes));

        // redirect to respective callback
        if (t == LockCallbackType.HOOK_MODIFY_LIQUIDITY) {
            return abi.encode(_hookModifyLiquidityLockCallback(abi.decode(callbackData, (HookCallbackInputData))));
        } else if (t == LockCallbackType.MODIFY_LIQUIDITY) {
            return abi.encode(_modifyLiquidityLockCallback(abi.decode(callbackData, (ModifyLiquidityInputData))));
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

    function _modifyLiquidityLockCallback(ModifyLiquidityInputData memory input)
        internal
        returns (ModifyLiquidityReturnData memory returnData)
    {
        // compound fees into reserve
        IPoolManager.ModifyPositionParams memory params;
        params.tickLower = input.tickLower;
        params.tickUpper = input.tickUpper;
        BalanceDelta poolTokenDelta = input.reserveDeltaInUnderlying;
        if (input.currentLiquidity != 0) {
            // negate pool delta to get fees owed
            BalanceDelta feeDelta =
                BalanceDelta.wrap(0) - poolManager.modifyPosition(input.poolKey, params, abi.encode(true));

            if (BalanceDelta.unwrap(feeDelta) != 0) {
                // add fees to the amount of pool tokens to mint/burn
                poolTokenDelta = poolTokenDelta + feeDelta;

                // emit event
                emit Compound(input.poolKey.toId(), feeDelta);
            }
        }

        // update liquidity
        params.liquidityDelta = input.liquidityDelta;
        BalanceDelta delta = poolManager.modifyPosition(input.poolKey, params, abi.encode(input.currentLiquidity == 0));

        // amount of tokens to pay/take
        BalanceDelta settleDelta = _zeroDeltaIfVault(input.reserveDeltaInUnderlying, input.vault0, input.vault1) + delta;

        // update reserves
        returnData.reserveChange0 =
            _updateReserve(poolTokenDelta.amount0(), input.poolKey.currency0, input.vault0, input.user, true);
        returnData.reserveChange1 =
            _updateReserve(poolTokenDelta.amount1(), input.poolKey.currency1, input.vault1, input.user, true);

        // settle currency payments to zero out delta with PoolManager
        _settleCurrency(input.user, input.poolKey.currency0, settleDelta.amount0());
        _settleCurrency(input.user, input.poolKey.currency1, settleDelta.amount1());

        (returnData.amount0, returnData.amount1) = (abs(delta.amount0()), abs(delta.amount1()));
    }

    /// @dev Adds liquidity using a pool's reserves. Expected to be called by the pool's hook.
    function _hookModifyLiquidityLockCallback(HookCallbackInputData memory data)
        internal
        returns (HookCallbackReturnData memory returnData)
    {
        int256 reserveChange0InUnderlying;
        int256 reserveChange1InUnderlying;

        IPoolManager.ModifyPositionParams memory params;

        // modify the liquidity of all specified ticks
        for (uint256 i; i < data.liquidityDeltas.length; i++) {
            if (data.liquidityDeltas[i].delta == 0) continue;

            params.tickLower = data.liquidityDeltas[i].tickLower;
            params.tickUpper = data.liquidityDeltas[i].tickLower + data.poolKey.tickSpacing;
            params.liquidityDelta = data.liquidityDeltas[i].delta;

            // only update the oracle before the first modifyPosition call
            BalanceDelta balanceDelta = poolManager.modifyPosition(data.poolKey, params, abi.encode(i == 0));

            reserveChange0InUnderlying -= balanceDelta.amount0();
            reserveChange1InUnderlying -= balanceDelta.amount1();
        }

        // update reserves
        PoolId poolId = data.poolKey.toId();
        returnData.reserveChange0 = _updateReserveAndSettle(
            reserveChange0InUnderlying, data.poolKey.currency0, data.vault0, poolId, 0, data.poolCredit0Set
        );
        returnData.reserveChange1 = _updateReserveAndSettle(
            reserveChange1InUnderlying, data.poolKey.currency1, data.vault1, poolId, 1, data.poolCredit1Set
        );
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
        poolManager.burn(currency, poolCreditAmount);

        // take assets
        poolManager.take(currency, address(this), poolCreditAmount);

        // deposit into reserves
        _updateVaultReserve(poolCreditAmount.toInt256(), currency, vault, address(this), false);

        // clear credit in state
        poolCredit[poolId] = 0;
        if (currencyIdx == 0) _poolState[poolId].poolCredit0Set = false;
        else _poolState[poolId].poolCredit1Set = false;
    }

    function _initializePoolLockCallback(InitializePoolCallbackInputData memory data) internal {
        poolManager.initialize(data.poolKey, data.sqrtPriceX96, abi.encode(data.twapSecondsAgo, data.hookParams));
    }

    /// @dev Zero out the delta for a token if the corresponding vault is non-zero.
    function _zeroDeltaIfVault(BalanceDelta delta, ERC4626 vault0, ERC4626 vault1)
        internal
        pure
        returns (BalanceDelta result)
    {
        assembly ("memory-safe") {
            result :=
                and(
                    delta,
                    or(
                        mul(iszero(vault0), 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000),
                        mul(iszero(vault1), 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff)
                    )
                )
        }
    }

    /// @dev Updates the reserve for a token. The returned `reserveChange` must be applied to the corresponding reserve to ensure
    /// we're only using funds belonging to the pool.
    /// @param amount The amount of `currency` to add/subtract from the reserve. Positive for deposit, negative for withdraw.
    /// @param currency The currency to deposit/withdraw.
    /// @param vault The vault to deposit/withdraw from. address(0) if the reserve is stored as PoolManager claim tokens.
    /// @param user The user to pull tokens from / withdraw tokens to
    /// @param pullTokensFromUser Whether to pull tokens from the user or not in case of deposit.
    /// @return reserveChange The change in reserves. Positive for deposit, negative for withdraw. Denominated in vault shares
    /// if a vault is used. Denominated in PoolManager claim tokens otherwise.
    function _updateReserve(int256 amount, Currency currency, ERC4626 vault, address user, bool pullTokensFromUser)
        internal
        returns (int256 reserveChange)
    {
        if (address(vault) == address(0)) {
            // store reserve as PoolManager pool tokens
            return _updateClaimTokenReserve(currency, amount);
        } else {
            // store reserve in ERC4626 vault
            return _updateVaultReserve(amount, currency, vault, user, pullTokensFromUser);
        }
    }

    /// @dev Updates the reserve for a token in a pool by shifting funds from/to PoolManager. The returned `reserveChange` must be applied to the corresponding reserve to ensure
    /// we're only using funds belonging to the pool.
    /// @param amount The amount of `currency` to add/subtract from the reserve. Positive for deposit, negative for withdraw.
    /// @param currency The currency to deposit/withdraw.
    /// @param vault The vault to deposit/withdraw from. address(0) if the reserve is stored as PoolManager claim tokens.
    /// @param poolId The poolId of the pool.
    /// @param currencyIdx The index of the currency in the pool. Should be 0 or 1.
    /// @param poolCreditSet Whether the pool credit is set or not.
    /// @return reserveChange The change in reserves. Positive for deposit, negative for withdraw. Denominated in vault shares
    /// if a vault is used. Denominated in PoolManager claim tokens otherwise.
    function _updateReserveAndSettle(
        int256 amount,
        Currency currency,
        ERC4626 vault,
        PoolId poolId,
        uint256 currencyIdx,
        bool poolCreditSet
    ) internal returns (int256 reserveChange) {
        if (address(vault) != address(0)) {
            if (amount > 0) {
                // we're depositing into the reserve vault using funds in PoolManager
                // take tokens from PoolManager if possible, otherwise mint claim tokens
                uint256 poolManagerBalance = poolManager.reservesOf(currency);
                if (uint256(amount) <= poolManagerBalance) {
                    // PoolManager has enough balance to cover the take() operation
                    poolManager.take(currency, address(this), uint256(amount));
                } else {
                    // PoolManager doesn't have enough balance to cover the take() operation
                    // take as many tokens as we can from PoolManager and mint the rest as claim tokens
                    poolManager.take(currency, address(this), poolManagerBalance);
                    uint256 creditAmount = uint256(amount) - poolManagerBalance;
                    amount = poolManagerBalance.toInt256();
                    poolManager.mint(currency, address(this), creditAmount);

                    // increase poolCredit
                    mapping(PoolId => uint256) storage poolCredit = currencyIdx == 0 ? poolCredit0 : poolCredit1;
                    uint256 existingCredit = poolCredit[poolId];
                    if (existingCredit == 0) {
                        // credit zero -> non-zero
                        // set flag
                        if (currencyIdx == 0) _poolState[poolId].poolCredit0Set = true;
                        else _poolState[poolId].poolCredit1Set = true;
                    }
                    poolCredit[poolId] = existingCredit + creditAmount;
                }
            } else if (amount < 0 && poolCreditSet) {
                // we're withdrawing from the reserve vault to PoolManager and we have pool credit
                // burn the claim tokens first
                mapping(PoolId => uint256) storage poolCredit = currencyIdx == 0 ? poolCredit0 : poolCredit1;
                uint256 existingCredit = poolCredit[poolId];
                poolManager.burn(currency, existingCredit);
                amount += existingCredit.toInt256();

                // credit non-zero -> zero
                // set flag
                if (currencyIdx == 0) _poolState[poolId].poolCredit0Set = false;
                else _poolState[poolId].poolCredit1Set = false;

                if (amount > 0) {
                    // we burnt enough credits such that we will increase the reserve
                    // take tokens from PoolManager so that _updateVaultReserve()
                    // will deposit the tokens into the vault
                    poolManager.take(currency, address(this), uint256(amount));
                }
            }

            reserveChange = _updateVaultReserve({
                amount: amount,
                currency: currency,
                vault: vault,
                user: address(poolManager),
                pullTokensFromUser: false
            });

            if (amount < 0) {
                // we withdrew tokens from the reserve vault to PoolManager
                // settle balances to zero out the delta with PoolManager
                poolManager.settle(currency);
            }
        } else {
            reserveChange = _updateClaimTokenReserve(currency, amount);
        }
    }

    /// @dev Mints/burns PoolManager claim tokens.
    /// @param currency The currency to mint/burn.
    /// @param amount The amount to mint/burn. Positive for mint, negative for burn.
    /// @return reserveChange The change in reserves. Positive for deposit, negative for withdraw.
    /// Denominated in PoolManager claim tokens.
    function _updateClaimTokenReserve(Currency currency, int256 amount) internal returns (int256 reserveChange) {
        if (amount > 0) {
            poolManager.mint(currency, address(this), uint256(amount));
        } else if (amount < 0) {
            poolManager.burn(currency, uint256(-amount));
        }
        return amount;
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
        uint256 absAmount = stdMath.abs(amount);
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

            token.safeApprove(address(vault), absAmount);
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
                return -vault.withdraw(uint256(-amount), user, address(this)).toInt256();
            }
        }
    }

    function _settleCurrency(address user, Currency currency, int256 amount) internal {
        if (amount > 0) {
            if (currency.isNative()) {
                address(poolManager).safeTransferETH(uint256(amount));
            } else {
                permit2.transferFrom(user, address(poolManager), uint256(amount).toUint160(), Currency.unwrap(currency));
            }
            poolManager.settle(currency);
        } else if (amount < 0) {
            poolManager.take(currency, user, uint256(-amount));
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
            reserve0: rawState.reserve0,
            reserve1: rawState.reserve1
        });
    }
}
