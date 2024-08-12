// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "@uniswap/v4-core/src/types/PoolId.sol";
import "@uniswap/v4-core/src/types/Currency.sol";
import "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {AmAmm} from "biddog/AmAmm.sol";

import "flood-contracts/src/interfaces/IZone.sol";
import "flood-contracts/src/interfaces/IFloodPlain.sol";

import {IERC1271} from "permit2/src/interfaces/IERC1271.sol";

import {WETH} from "solady/tokens/WETH.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

import "./lib/Math.sol";
import "./base/Errors.sol";
import "./base/Constants.sol";
import "./lib/AmAmmPayload.sol";
import "./base/SharedStructs.sol";
import "./interfaces/IBunniHook.sol";
import {Oracle} from "./lib/Oracle.sol";
import {Ownable} from "./base/Ownable.sol";
import {BaseHook} from "./base/BaseHook.sol";
import {IBunniHub} from "./interfaces/IBunniHub.sol";
import {BunniSwapMath} from "./lib/BunniSwapMath.sol";
import {BunniHookLogic} from "./lib/BunniHookLogic.sol";
import {ReentrancyGuard} from "./base/ReentrancyGuard.sol";

/// @title BunniHook
/// @author zefram.eth
/// @notice Uniswap v4 hook responsible for handling swaps on Bunni. Implements auto-rebalancing
/// executed via FloodPlain. Uses am-AMM to recapture LVR & MEV.
contract BunniHook is BaseHook, Ownable, IBunniHook, ReentrancyGuard, AmAmm {
    /// -----------------------------------------------------------------------
    /// Library usage
    /// -----------------------------------------------------------------------

    using SafeTransferLib for *;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using Oracle for Oracle.Observation[MAX_CARDINALITY];

    /// -----------------------------------------------------------------------
    /// Immutable args
    /// -----------------------------------------------------------------------

    WETH internal immutable weth;
    IBunniHub internal immutable hub;
    address internal immutable permit2;
    IFloodPlain internal immutable floodPlain;

    /// -----------------------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------------------

    /// @dev Contains mappings used by both BunniHook and BunniLogic. Makes passing
    /// mappings to BunniHookLogic easier & cheaper.
    HookStorage internal s;

    /// @notice The poolwise amAmmEnabled override. Top precedence.
    mapping(PoolId => BoolOverride) internal amAmmEnabledOverride;

    /// @notice Used for computing the hook fee amount. Fee taken is `amount * swapFee / 1e6 * hookFeesModifier / 1e6`.
    uint32 internal hookFeeModifier;

    /// @notice Used for computing the referral reward amount. Reward is `hookFee * referralRewardModifier / 1e6`.
    uint32 internal referralRewardModifier;

    /// @notice The FloodZone contract used in rebalance orders.
    IZone internal floodZone;

    /// @notice Enables/disables am-AMM globally. Takes precedence over amAmmEnabled in hookParams, overriden by amAmmEnabledOverride.
    BoolOverride internal globalAmAmmEnabledOverride;

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(
        IPoolManager poolManager_,
        IBunniHub hub_,
        IFloodPlain floodPlain_,
        WETH weth_,
        IZone floodZone_,
        address owner_,
        uint32 hookFeeModifier_,
        uint32 referralRewardModifier_
    ) BaseHook(poolManager_) {
        if (hookFeeModifier_ > MODIFIER_BASE || referralRewardModifier_ > MODIFIER_BASE) {
            revert BunniHook__InvalidModifier();
        }

        hub = hub_;
        floodPlain = floodPlain_;
        permit2 = address(floodPlain_.PERMIT2());
        weth = weth_;

        hookFeeModifier = hookFeeModifier_;
        referralRewardModifier = referralRewardModifier_;
        floodZone = floodZone_;

        _initializeOwner(owner_);
        poolManager_.setOperator(address(hub_), true);

        emit SetModifiers(hookFeeModifier_, referralRewardModifier_);
    }

    /// -----------------------------------------------------------------------
    /// EIP-1271 compliance
    /// -----------------------------------------------------------------------

    /// @inheritdoc IERC1271
    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        override
        returns (bytes4 magicValue)
    {
        // verify rebalance order
        PoolId id = abi.decode(signature, (PoolId)); // we use the signature field to store the pool id
        if (s.rebalanceOrderHash[id] == hash) {
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

        ObservationState storage state = s.states[id];

        cardinalityNextOld = state.cardinalityNext;
        cardinalityNextNew = s.observations[id].grow(cardinalityNextOld, cardinalityNext);
        state.cardinalityNext = cardinalityNextNew;
    }

    receive() external payable {}

    /// -----------------------------------------------------------------------
    /// Uniswap lock callback
    /// -----------------------------------------------------------------------

    enum HookUnlockCallbackType {
        REBALANCE_PREHOOK,
        REBALANCE_POSTHOOK,
        CLAIM_FEES
    }

    /// @inheritdoc IUnlockCallback
    function unlockCallback(bytes calldata data) external override poolManagerOnly returns (bytes memory) {
        // decode input
        (HookUnlockCallbackType t, bytes memory callbackData) = abi.decode(data, (HookUnlockCallbackType, bytes));

        if (t == HookUnlockCallbackType.REBALANCE_PREHOOK) {
            _rebalancePrehookCallback(callbackData);
        } else if (t == HookUnlockCallbackType.REBALANCE_POSTHOOK) {
            _rebalancePosthookCallback(callbackData);
        } else if (t == HookUnlockCallbackType.CLAIM_FEES) {
            _claimFees(callbackData);
        }
        return bytes("");
    }

    /// @dev Calls hub.hookHandleSwap to pull the rebalance swap input tokens from BunniHub.
    /// Then burns PoolManager claim tokens and takes the underlying tokens from PoolManager.
    /// Used while executing rebalance orders.
    function _rebalancePrehookCallback(bytes memory callbackData) internal {
        // decode data
        (Currency currency, uint256 amount, PoolKey memory key, bool zeroForOne) =
            abi.decode(callbackData, (Currency, uint256, PoolKey, bool));

        // pull claim tokens from BunniHub
        hub.hookHandleSwap({key: key, zeroForOne: zeroForOne, inputAmount: 0, outputAmount: amount});

        // burn and take
        poolManager.burn(address(this), currency.toId(), amount);
        poolManager.take(currency, address(this), amount);
    }

    /// @dev Settles tokens sent to PoolManager and mints the corresponding claim tokens.
    /// Then calls hub.hookHandleSwap to update pool balances with rebalance swap output.
    /// Used while executing rebalance orders.
    function _rebalancePosthookCallback(bytes memory callbackData) internal {
        // decode data
        (Currency currency, uint256 amount, PoolKey memory key, bool zeroForOne) =
            abi.decode(callbackData, (Currency, uint256, PoolKey, bool));

        // settle and mint
        uint256 paid = poolManager.settle{value: currency.isNative() ? amount : 0}();
        poolManager.mint(address(this), currency.toId(), paid);

        // push claim tokens to BunniHub
        hub.hookHandleSwap({key: key, zeroForOne: zeroForOne, inputAmount: paid, outputAmount: 0});
    }

    /// @dev Claims protocol fees earned and sends it to the recipient.
    function _claimFees(bytes memory callbackData) internal {
        // decode data
        (Currency[] memory currencyList, address recipient) = abi.decode(callbackData, (Currency[], address));

        // claim protocol fees
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

        s.ldfStates[id] = newState;
    }

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHook
    function claimProtocolFees(Currency[] calldata currencyList, address recipient) external override onlyOwner {
        poolManager.unlock(abi.encode(HookUnlockCallbackType.CLAIM_FEES, abi.encode(currencyList, recipient)));
    }

    /// @inheritdoc IBunniHook
    function setZone(IZone zone) external onlyOwner {
        floodZone = zone;
        emit SetZone(zone);
    }

    /// @inheritdoc IBunniHook
    function setModifiers(uint32 newHookFeeModifier, uint32 newReferralRewardModifier) external onlyOwner {
        if (newHookFeeModifier > MODIFIER_BASE || newReferralRewardModifier > MODIFIER_BASE) {
            revert BunniHook__InvalidModifier();
        }

        hookFeeModifier = newHookFeeModifier;
        referralRewardModifier = newReferralRewardModifier;

        emit SetModifiers(newHookFeeModifier, newReferralRewardModifier);
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
    function getObservation(PoolKey calldata key, uint256 index)
        external
        view
        override
        returns (Oracle.Observation memory observation)
    {
        observation = s.observations[key.toId()][index];
    }

    /// @inheritdoc IBunniHook
    function getState(PoolKey calldata key) external view override returns (ObservationState memory state) {
        state = s.states[key.toId()];
    }

    /// @inheritdoc IBunniHook
    function observe(PoolKey calldata key, uint32[] calldata secondsAgos)
        external
        view
        override
        returns (int56[] memory tickCumulatives)
    {
        PoolId id = key.toId();
        ObservationState memory state = s.states[id];
        Slot0 memory slot0 = s.slot0s[id];

        return s.observations[id].observe(
            state.intermediateObservation,
            uint32(block.timestamp),
            secondsAgos,
            slot0.tick,
            state.index,
            state.cardinality
        );
    }

    /// @inheritdoc IBunniHook
    function isValidParams(bytes calldata hookParams) external pure override returns (bool) {
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
                ) && (p.oracleMinInterval != 0);
        }
    }

    /// @inheritdoc IBunniHook
    function getAmAmmEnabled(PoolId id) external view override returns (bool) {
        return _amAmmEnabled(id);
    }

    /// @inheritdoc IBunniHook
    function ldfStates(PoolId id) external view returns (bytes32) {
        return s.ldfStates[id];
    }

    /// @inheritdoc IBunniHook
    function slot0s(PoolId id)
        external
        view
        returns (uint160 sqrtPriceX96, int24 tick, uint32 lastSwapTimestamp, uint32 lastSurgeTimestamp)
    {
        Slot0 memory slot0 = s.slot0s[id];
        return (slot0.sqrtPriceX96, slot0.tick, slot0.lastSwapTimestamp, slot0.lastSurgeTimestamp);
    }

    /// @inheritdoc IBunniHook
    function vaultSharePricesAtLastSwap(PoolId id)
        external
        view
        returns (bool initialized, uint120 sharePrice0, uint120 sharePrice1)
    {
        VaultSharePrices memory prices = s.vaultSharePricesAtLastSwap[id];
        return (prices.initialized, prices.sharePrice0, prices.sharePrice1);
    }

    /// -----------------------------------------------------------------------
    /// Hooks
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBaseHook
    function afterInitialize(
        address caller,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        int24 tick,
        bytes calldata hookData
    ) external override(BaseHook, IBaseHook) poolManagerOnly returns (bytes4) {
        BunniHookLogic.afterInitialize(s, caller, key, sqrtPriceX96, tick, hookData, hub);
        return BunniHook.afterInitialize.selector;
    }

    /// @inheritdoc IBaseHook
    function beforeSwap(address sender, PoolKey calldata key, IPoolManager.SwapParams calldata params, bytes calldata)
        external
        override(BaseHook, IBaseHook)
        poolManagerOnly
        nonReentrant
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        (
            bool useAmAmmFee,
            address amAmmManager,
            Currency amAmmFeeCurrency,
            uint256 amAmmFeeAmount,
            BeforeSwapDelta beforeSwapDelta
        ) = BunniHookLogic.beforeSwap(
            s,
            BunniHookLogic.Env({
                hookFeeModifier: hookFeeModifier,
                referralRewardModifier: referralRewardModifier,
                floodZone: floodZone,
                hub: hub,
                poolManager: poolManager,
                floodPlain: floodPlain,
                weth: weth,
                permit2: permit2
            }),
            sender,
            key,
            params
        );

        // accrue swap fee to the am-AMM manager if present
        if (useAmAmmFee) {
            _accrueFees(amAmmManager, amAmmFeeCurrency, amAmmFeeAmount);
        }

        return (BunniHook.beforeSwap.selector, beforeSwapDelta, 0);
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
        if (keccak256(abi.encode(hookArgs)) != s.rebalanceOrderHookArgsHash[hookArgs.key.toId()]) {
            revert BunniHook__InvalidRebalanceOrderHookArgs();
        }

        RebalanceOrderPreHookArgs calldata args = hookArgs.preHookArgs;

        // pull input tokens from BunniHub to BunniHook
        // received in the form of PoolManager claim tokens
        // then unwrap claim tokens
        poolManager.unlock(
            abi.encode(
                HookUnlockCallbackType.REBALANCE_PREHOOK,
                abi.encode(args.currency, args.amount, hookArgs.key, hookArgs.key.currency1 == args.currency)
            )
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
        if (keccak256(abi.encode(hookArgs)) != s.rebalanceOrderHookArgsHash[hookArgs.key.toId()]) {
            revert BunniHook__InvalidRebalanceOrderHookArgs();
        }

        // invalidate the rebalance order hash
        // don't delete the deadline to maintain a min rebalance interval
        PoolId id = hookArgs.key.toId();
        delete s.rebalanceOrderHash[id];
        delete s.rebalanceOrderHookArgsHash[id];

        // surge fee should be applied after the rebalance has been executed
        // since totalLiquidity will be increased
        // no need to check surgeFeeAutostartThreshold since we just increased the liquidity in this tx
        // so block.timestamp is the exact time when the surge should occur
        s.slot0s[id].lastSwapTimestamp = uint32(block.timestamp);
        s.slot0s[id].lastSurgeTimestamp = uint32(block.timestamp);

        RebalanceOrderPostHookArgs calldata args = hookArgs.postHookArgs;

        uint256 orderOutputAmount;
        if (args.currency.isNative()) {
            // unwrap WETH output to native ETH
            orderOutputAmount = weth.balanceOf(address(this));
            weth.withdraw(orderOutputAmount);
        } else {
            orderOutputAmount = args.currency.balanceOfSelf();
        }

        // posthook should wrap output tokens as claim tokens and push it from BunniHook to BunniHub and update pool balances
        poolManager.sync(args.currency);
        if (!args.currency.isNative()) {
            Currency.unwrap(args.currency).safeTransfer(address(poolManager), orderOutputAmount);
        }
        poolManager.unlock(
            abi.encode(
                HookUnlockCallbackType.REBALANCE_POSTHOOK,
                abi.encode(args.currency, orderOutputAmount, hookArgs.key, hookArgs.key.currency0 == args.currency)
            )
        );
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

        bytes memory hookParams = hub.hookParams(id);
        bytes32 firstWord;
        /// @solidity memory-safe-assembly
        assembly {
            firstWord := mload(add(hookParams, 32))
        }
        bool poolEnabled = uint8(bytes1(firstWord << 248)) != 0;
        return poolEnabled;
    }

    function _payloadIsValid(PoolId id, bytes7 payload) internal view virtual override returns (bool) {
        // use feeMax from hookParams
        bytes memory hookParams = hub.hookParams(id);
        bytes32 firstWord;
        /// @solidity memory-safe-assembly
        assembly {
            firstWord := mload(add(hookParams, 32))
        }
        uint24 maxSwapFee = uint24(bytes3(firstWord << 24));

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
