// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "@uniswap/v4-core/src/types/Currency.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {AmAmm} from "biddog/AmAmm.sol";

import "flood-contracts/src/interfaces/IZone.sol";
import "flood-contracts/src/interfaces/IFloodPlain.sol";

import {WETH} from "solady/tokens/WETH.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
import "./lib/Constants.sol";
import "./lib/AmAmmPayload.sol";
import "./interfaces/IBunniHook.sol";
import {Oracle} from "./lib/Oracle.sol";
import {Ownable} from "./lib/Ownable.sol";
import {BaseHook} from "./lib/BaseHook.sol";
import {IBunniHub} from "./interfaces/IBunniHub.sol";
import {BunniSwapMath} from "./lib/BunniSwapMath.sol";
import {BunniHookLogic} from "./lib/BunniHookLogic.sol";
import {ReentrancyGuard} from "./lib/ReentrancyGuard.sol";

/// @notice Bunni Hook
contract BunniHook is BaseHook, Ownable, IBunniHook, ReentrancyGuard, AmAmm {
    using SafeTransferLib for *;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using Oracle for Oracle.Observation[MAX_CARDINALITY];

    WETH internal immutable weth;
    IBunniHub internal immutable hub;
    address internal immutable permit2;
    IFloodPlain internal immutable floodPlain;

    /// @notice The list of observations for a given pool ID
    mapping(PoolId => Oracle.Observation[MAX_CARDINALITY]) internal _observations;

    /// @notice The current observation array state for the given pool ID
    mapping(PoolId => ObservationState) internal _states;

    mapping(PoolId id => bytes32) internal _rebalanceOrderHash;
    mapping(PoolId id => uint256) internal _rebalanceOrderDeadline;
    mapping(PoolId id => bytes32) internal _rebalanceOrderHookArgsHash;

    mapping(PoolId => VaultSharePrices) public vaultSharePricesAtLastSwap;
    mapping(PoolId => bytes32) public ldfStates;
    mapping(PoolId => Slot0) public slot0s;
    mapping(PoolId => BoolOverride) public amAmmEnabledOverride;

    BoolOverride public globalAmAmmEnabledOverride;
    IZone public floodZone;

    uint32 public immutable oracleMinInterval;

    /// @notice Used for computing the hook fee amount. Fee taken is `amount * swapFee / 1e6 * hookFeesModifier / 1e18`.
    uint96 internal _hookFeesModifier;

    /// @notice The recipient of collected hook fees
    address internal _hookFeesRecipient;

    constructor(
        IPoolManager _poolManager,
        IBunniHub hub_,
        IFloodPlain floodPlain_,
        WETH weth_,
        IZone floodZone_,
        address owner_,
        address hookFeesRecipient_,
        uint96 hookFeesModifier_,
        uint32 oracleMinInterval_
    ) BaseHook(_poolManager) {
        hub = hub_;
        floodPlain = floodPlain_;
        permit2 = address(floodPlain_.PERMIT2());
        weth = weth_;
        oracleMinInterval = oracleMinInterval_;
        floodZone = floodZone_;
        _hookFeesModifier = hookFeesModifier_;
        _hookFeesRecipient = hookFeesRecipient_;
        _initializeOwner(owner_);
        _poolManager.setOperator(address(hub_), true);

        emit SetHookFeesParams(hookFeesModifier_, hookFeesRecipient_);
    }

    /// -----------------------------------------------------------------------
    /// EIP-1271 compliance
    /// -----------------------------------------------------------------------

    /// @dev Should return whether the signature provided is valid for the provided data
    /// @param hash      Hash of the data to be signed
    /// @param signature Signature byte array associated with _data
    /// @return magicValue The bytes4 magic value 0x1626ba7e
    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        override
        returns (bytes4 magicValue)
    {
        // verify rebalance order
        PoolId id = abi.decode(signature, (PoolId));
        if (_rebalanceOrderHash[id] == hash) {
            return this.isValidSignature.selector;
        }
    }

    /// -----------------------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function increaseCardinalityNext(PoolKey calldata key, uint32 cardinalityNext)
        public
        override
        returns (uint32 cardinalityNextOld, uint32 cardinalityNextNew)
    {
        PoolId id = key.toId();

        ObservationState storage state = _states[id];

        cardinalityNextOld = state.cardinalityNext;
        cardinalityNextNew = _observations[id].grow(cardinalityNextOld, cardinalityNext);
        state.cardinalityNext = cardinalityNextNew;
    }

    receive() external payable {}

    /// -----------------------------------------------------------------------
    /// Uniswap lock callback
    /// -----------------------------------------------------------------------

    /// @inheritdoc ILockCallback
    function lockAcquired(address lockCaller, bytes calldata data)
        external
        override
        poolManagerOnly
        returns (bytes memory)
    {
        // decode input
        (HookLockCallbackType t, bytes memory callbackData) = abi.decode(data, (HookLockCallbackType, bytes));

        if (t == HookLockCallbackType.BURN_AND_TAKE) {
            _burnAndTake(lockCaller, callbackData);
        } else if (t == HookLockCallbackType.SETTLE_AND_MINT) {
            _settleAndMint(lockCaller, callbackData);
        } else if (t == HookLockCallbackType.CLAIM_FEES) {
            _claimFees(lockCaller, callbackData);
        } else {
            revert BunniHook__InvalidLockCallbackType();
        }
        return bytes("");
    }

    function _burnAndTake(address lockCaller, bytes memory callbackData) internal {
        if (lockCaller != address(this)) revert BunniHook__Unauthorized();

        // decode data
        (Currency currency, uint256 amount) = abi.decode(callbackData, (Currency, uint256));

        // burn and take
        poolManager.burn(address(this), currency.toId(), amount);
        poolManager.take(currency, address(this), amount);
    }

    function _settleAndMint(address lockCaller, bytes memory callbackData) internal {
        if (lockCaller != address(this)) revert BunniHook__Unauthorized();

        // decode data
        Currency currency = abi.decode(callbackData, (Currency));

        // settle and mint
        uint256 paid = poolManager.settle(currency);
        poolManager.mint(address(this), currency.toId(), paid);
    }

    function _claimFees(address lockCaller, bytes memory callbackData) internal {
        if (lockCaller != owner()) revert BunniHook__Unauthorized();

        // decode data
        Currency[] memory currencyList = abi.decode(callbackData, (Currency[]));

        // claim protocol fees
        address recipient = _hookFeesRecipient;
        for (uint256 i; i < currencyList.length; i++) {
            Currency currency = currencyList[i];
            // can claim balance - am-AMM accrued fees
            uint256 balance = poolManager.balanceOf(address(this), currency.toId()) - _totalFees[currency];
            if (balance != 0) {
                poolManager.burn(address(this), currency.toId(), balance);
                poolManager.take(currency, recipient, balance);
            }
        }
    }

    /// -----------------------------------------------------------------------
    /// BunniHub functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function updateLdfState(PoolId id, bytes32 newState) external override {
        if (msg.sender != address(hub)) revert BunniHook__Unauthorized();

        ldfStates[id] = newState;
    }

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function setZone(IZone zone) external onlyOwner {
        floodZone = zone;
        emit SetZone(zone);
    }

    /// @inheritdoc IBunniHook
    function setHookFeesParams(uint96 newModifier, address newRecipient) external onlyOwner {
        _hookFeesModifier = newModifier;
        _hookFeesRecipient = newRecipient;

        emit SetHookFeesParams(newModifier, newRecipient);
    }

    /// @inheritdoc IBunniHook
    function setAmAmmEnabledOverride(PoolId id, BoolOverride boolOverride) external onlyOwner {
        amAmmEnabledOverride[id] = boolOverride;
        emit SetAmAmmEnabledOverride(id, boolOverride);
    }

    /// @inheritdoc IBunniHook
    function setGlobalAmAmmEnabledOverride(BoolOverride boolOverride) external onlyOwner {
        globalAmAmmEnabledOverride = boolOverride;
        emit SetGlobalAmAmmEnabledOverride(boolOverride);
    }

    /// -----------------------------------------------------------------------
    /// View functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function getHookFeesParams() external view override returns (uint96 modifierVal, address recipient) {
        return (_hookFeesModifier, _hookFeesRecipient);
    }

    /// @inheritdoc IBunniHook
    function getObservation(PoolKey calldata key, uint256 index)
        external
        view
        override
        returns (Oracle.Observation memory observation)
    {
        observation = _observations[key.toId()][index];
    }

    /// @inheritdoc IBunniHook
    function getState(PoolKey calldata key) external view override returns (ObservationState memory state) {
        state = _states[key.toId()];
    }

    /// @inheritdoc IBunniHook
    function observe(PoolKey calldata key, uint32[] calldata secondsAgos)
        external
        view
        override
        returns (int56[] memory tickCumulatives)
    {
        PoolId id = key.toId();
        ObservationState memory state = _states[id];
        Slot0 memory slot0 = slot0s[id];

        return _observations[id].observe(
            state.intermediateObservation,
            uint32(block.timestamp),
            secondsAgos,
            slot0.tick,
            state.index,
            state.cardinality
        );
    }

    /// @inheritdoc IBunniHook
    function isValidParams(bytes32 hookParams) external pure override returns (bool) {
        DecodedHookParams memory p = BunniHookLogic.decodeHookParams(hookParams);
        unchecked {
            return (p.feeMin <= p.feeMax) && (p.feeMax < SWAP_FEE_BASE)
                && (p.feeQuadraticMultiplier == 0 || p.feeMin == p.feeMax || p.feeTwapSecondsAgo != 0)
                && (p.surgeFee < SWAP_FEE_BASE)
                && (uint256(p.surgeFeeHalfLife) * uint256(p.vaultSurgeThreshold0) * uint256(p.vaultSurgeThreshold1) != 0)
                && (
                    (
                        p.rebalanceThreshold == 0 && p.rebalanceMaxSlippage == 0 && p.rebalanceTwapSecondsAgo == 0
                            && p.rebalanceOrderTTL == 0
                    )
                        || (
                            p.rebalanceThreshold != 0 && p.rebalanceMaxSlippage != 0 && p.rebalanceTwapSecondsAgo != 0
                                && p.rebalanceOrderTTL != 0
                        )
                );
        }
    }

    /// @inheritdoc IBunniHook
    function getAmAmmEnabled(PoolId id) external view override returns (bool) {
        return _amAmmEnabled(id);
    }

    /// -----------------------------------------------------------------------
    /// Hooks
    /// -----------------------------------------------------------------------

    /// @inheritdoc IDynamicFeeManager
    function getFee(address, /* sender */ PoolKey calldata /* key */ ) external pure override returns (uint24) {
        // always return 0 since the swap fee is taken in the beforeSwap hook
        return 0;
    }

    /// @inheritdoc IHooks
    function afterInitialize(
        address caller,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        int24 tick,
        bytes calldata hookData
    ) external override(BaseHook, IHooks) poolManagerOnly returns (bytes4) {
        BunniHookLogic.afterInitialize(
            caller, key, sqrtPriceX96, tick, hookData, slot0s, _observations, _states, hub, oracleMinInterval
        );
        return BunniHook.afterInitialize.selector;
    }

    /// @inheritdoc IHooks
    function beforeAddLiquidity(address, PoolKey calldata, IPoolManager.ModifyLiquidityParams calldata, bytes calldata)
        external
        view
        override(BaseHook, IHooks)
        poolManagerOnly
        returns (bytes4)
    {
        revert BunniHook__NoAddLiquidity();
    }

    /// @inheritdoc IHooks
    function beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        external
        override(BaseHook, IHooks)
        poolManagerOnly
        nonReentrant
        returns (bytes4)
    {
        (bool useAmAmmFee, address amAmmManager, Currency amAmmFeeCurrency, uint256 amAmmFeeAmount) = BunniHookLogic
            .beforeSwap(
            sender,
            key,
            params,
            slot0s,
            _observations,
            _states,
            vaultSharePricesAtLastSwap,
            ldfStates,
            _rebalanceOrderDeadline,
            _rebalanceOrderHash,
            _rebalanceOrderHookArgsHash,
            BunniHookLogic.Env({
                _hookFeesModifier: _hookFeesModifier,
                hub: hub,
                poolManager: poolManager,
                floodPlain: floodPlain,
                floodZone: floodZone,
                weth: weth,
                permit2: permit2,
                oracleMinInterval: oracleMinInterval
            })
        );

        if (useAmAmmFee) {
            _accrueFees(amAmmManager, amAmmFeeCurrency, amAmmFeeAmount);
        }

        return Hooks.NO_OP_SELECTOR;
    }

    /// -----------------------------------------------------------------------
    /// Rebalancing functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function rebalanceOrderPreHook(RebalanceOrderHookArgs calldata hookArgs) external override nonReentrant {
        // verify call came from Flood
        if (msg.sender != address(floodPlain)) {
            revert BunniHook__Unauthorized();
        }

        // ensure args can be trusted
        if (keccak256(abi.encode(hookArgs)) != _rebalanceOrderHookArgsHash[hookArgs.key.toId()]) {
            revert BunniHook__InvalidRebalanceOrderHookArgs();
        }

        RebalanceOrderPreHookArgs calldata args = hookArgs.preHookArgs;

        // pull input tokens from BunniHub to BunniHook
        // received in the form of PoolManager claim tokens
        hub.hookHandleSwap({
            key: hookArgs.key,
            zeroForOne: hookArgs.key.currency1 == args.currency,
            inputAmount: 0,
            outputAmount: args.amount
        });

        // unwrap claim tokens
        // NOTE: tax-on-transfer tokens are not supported due to this unwrap since we need exactly args.amount tokens upon return
        poolManager.lock(
            address(this), abi.encode(HookLockCallbackType.BURN_AND_TAKE, abi.encode(args.currency, args.amount))
        );

        // ensure we have exactly args.amount tokens
        if (args.currency.balanceOfSelf() != args.amount) {
            revert BunniHook__PrehookPostConditionFailed();
        }

        // wrap native ETH input to WETH
        // we're implicitly trusting the WETH contract won't charge a fee which is OK in practice
        if (args.currency.isNative()) {
            weth.deposit{value: args.amount}();
        }
    }

    /// @inheritdoc IBunniHook
    function rebalanceOrderPostHook(RebalanceOrderHookArgs calldata hookArgs) external override nonReentrant {
        // verify call came from Flood
        if (msg.sender != address(floodPlain)) {
            revert BunniHook__Unauthorized();
        }

        // ensure args can be trusted
        if (keccak256(abi.encode(hookArgs)) != _rebalanceOrderHookArgsHash[hookArgs.key.toId()]) {
            revert BunniHook__InvalidRebalanceOrderHookArgs();
        }

        // invalidate the rebalance order hash
        // don't delete the deadline to maintain a min rebalance interval
        PoolId id = hookArgs.key.toId();
        delete _rebalanceOrderHash[id];
        delete _rebalanceOrderHookArgsHash[id];

        // surge fee should be applied after the rebalance has been executed
        // since totalLiquidity will be increased
        // no need to check surgeFeeAutostartThreshold sincewe just increased the liquidity in this tx
        // so block.timestamp is the exact time when the surge should occur
        slot0s[id].lastSwapTimestamp = uint32(block.timestamp);
        slot0s[id].lastSurgeTimestamp = uint32(block.timestamp);

        RebalanceOrderPostHookArgs calldata args = hookArgs.postHookArgs;

        uint256 orderOutputAmount;
        if (args.currency.isNative()) {
            // unwrap WETH output to native ETH
            orderOutputAmount = weth.balanceOf(address(this));
            weth.withdraw(orderOutputAmount);
        } else {
            orderOutputAmount = args.currency.balanceOfSelf();
        }

        // wrap claim tokens
        // NOTE: tax-on-transfer tokens are not supported because we need exactly orderOutputAmount tokens
        if (args.currency.isNative()) {
            address(poolManager).safeTransferETH(orderOutputAmount);
        } else {
            Currency.unwrap(args.currency).safeTransfer(address(poolManager), orderOutputAmount);
        }
        poolManager.lock(address(this), abi.encode(HookLockCallbackType.SETTLE_AND_MINT, abi.encode(args.currency)));

        // posthook should push output tokens from BunniHook to BunniHub and update pool balances
        // BunniHub receives output tokens in the form of PoolManager claim tokens
        hub.hookHandleSwap({
            key: hookArgs.key,
            zeroForOne: hookArgs.key.currency0 == args.currency,
            inputAmount: orderOutputAmount,
            outputAmount: 0
        });
    }

    /// -----------------------------------------------------------------------
    /// AmAmm support
    /// -----------------------------------------------------------------------

    /// @dev precedence is poolOverride > globalOverride > poolEnabled
    function _amAmmEnabled(PoolId id) internal view virtual override returns (bool) {
        BoolOverride poolOverride = amAmmEnabledOverride[id];

        if (poolOverride != BoolOverride.UNSET) return poolOverride == BoolOverride.TRUE;

        BoolOverride globalOverride = globalAmAmmEnabledOverride;

        if (globalOverride != BoolOverride.UNSET) return globalOverride == BoolOverride.TRUE;

        bytes32 hookParams = hub.hookParams(id);
        bool poolEnabled = uint8(bytes1(hookParams << 248)) != 0;
        return poolEnabled;
    }

    function _payloadIsValid(PoolId id, bytes7 payload) internal view virtual override returns (bool) {
        // use feeMax from hookParams
        bytes32 hookParams = hub.hookParams(id);
        uint24 maxSwapFee = uint24(bytes3(hookParams << 24));

        // payload is valid if swapFee0For1 and swapFee1For0 are at most maxSwapFee
        (uint24 swapFee0For1, uint24 swapFee1For0,) = decodeAmAmmPayload(payload);
        return swapFee0For1 <= maxSwapFee && swapFee1For0 <= maxSwapFee;
    }

    function _burnBidToken(PoolId id, uint256 amount) internal virtual override {
        hub.bunniTokenOfPool(id).burn(amount);
    }

    function _pullBidToken(PoolId id, address from, uint256 amount) internal virtual override {
        hub.bunniTokenOfPool(id).transferFrom(from, address(this), amount);
    }

    function _pushBidToken(PoolId id, address to, uint256 amount) internal virtual override {
        hub.bunniTokenOfPool(id).transfer(to, amount);
    }

    function _transferFeeToken(Currency currency, address to, uint256 amount) internal virtual override {
        poolManager.transfer(to, currency.toId(), amount);
    }
}
