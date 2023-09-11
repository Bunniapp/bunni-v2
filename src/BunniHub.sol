// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/contracts/libraries/FullMath.sol";
import {FeeLibrary} from "@uniswap/v4-core/contracts/libraries/FeeLibrary.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {ILockCallback} from "@uniswap/v4-core/contracts/interfaces/callback/ILockCallback.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";

import {CREATE3} from "solady/src/utils/CREATE3.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";

import "./lib/Math.sol";
import {BunniHook} from "./BunniHook.sol";
import {BunniToken} from "./BunniToken.sol";
import {Multicall} from "./lib/Multicall.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {SelfPermit} from "./lib/SelfPermit.sol";
import {IBunniToken} from "./interfaces/IBunniToken.sol";
import {SafeTransferLib} from "./lib/SafeTransferLib.sol";
import {LiquidityAmounts} from "./lib/LiquidityAmounts.sol";
import {IBunniHub, BunniTokenState, ShiftMode, ILiquidityDensityFunction} from "./interfaces/IBunniHub.sol";

/// @title BunniHub
/// @author zefram.eth
/// @notice The main contract LPs interact with. Each BunniKey corresponds to a BunniToken,
/// which is the ERC20 LP token for the Uniswap V4 position specified by the BunniKey.
/// Use deposit()/withdraw() to mint/burn LP tokens, and use compound() to compound the swap fees
/// back into the LP position.
contract BunniHub is IBunniHub, Multicall, SelfPermit, ERC1155TokenReceiver {
    using SafeCastLib for int256;
    using SafeCastLib for uint256;
    using PoolIdLibrary for PoolKey;
    using SafeTransferLib for IERC20;
    using CurrencyLibrary for Currency;
    using BalanceDeltaLibrary for BalanceDelta;

    error BunniHub__ZeroInput();
    error BunniHub__PastDeadline();
    error BunniHub__Unauthorized();
    error BunniHub__InvalidShift();
    error BunniHub__MaxNonceReached();
    error BunniHub__SlippageTooHigh();
    error BunniHub__ZeroSharesMinted();
    error BunniHub__BunniTokenNotInitialized();

    uint256 internal constant WAD = 1e18;
    uint256 internal constant MAX_NONCE = 0x0FFFFF;
    uint256 internal constant MIN_INITIAL_SHARES = 1e3;

    IPoolManager public immutable override poolManager;

    /// -----------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------

    mapping(IBunniToken bunniToken => BunniTokenState) internal _bunniTokenState;
    mapping(bytes32 bunniSubspace => uint24) public override nonce;
    mapping(PoolId poolId => IBunniToken) public override bunniTokenOfPool;

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

    constructor(IPoolManager poolManager_) {
        poolManager = poolManager_;
    }

    /// -----------------------------------------------------------
    /// External functions
    /// -----------------------------------------------------------

    /// @inheritdoc IBunniHub
    function deposit(DepositParams calldata params)
        external
        virtual
        override
        checkDeadline(params.deadline)
        returns (uint256 shares, uint128 addedLiquidity, uint256 amount0, uint256 amount1)
    {
        (BunniTokenState memory state, PoolId poolId) = _getStateAndIdOfBunniToken(params.bunniToken);

        // fetch values from pool
        (uint160 sqrtPriceX96, int24 currentTick,,,,) = poolManager.getSlot0(poolId);
        int24 arithmeticMeanTick;
        if (state.twapSecondsAgo != 0) {
            // LDF uses TWAP
            // compute TWAP value
            uint32[] memory secondsAgos = new uint32[](2);
            secondsAgos[0] = state.twapSecondsAgo;
            secondsAgos[1] = 0;
            BunniHook hook = BunniHook(address(state.poolKey.hooks));
            (int56[] memory tickCumulatives,) = hook.observe(state.poolKey, secondsAgos);
            int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
            arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(state.twapSecondsAgo)));
        }
        uint160 currentTickSqrtRatio = TickMath.getSqrtRatioAtTick(currentTick);
        int24 nextTick = currentTick + state.poolKey.tickSpacing;
        uint160 nextTickSqrtRatio = TickMath.getSqrtRatioAtTick(nextTick);

        // compute density
        (uint256 liquidityDensityOfCurrentTick, uint256 density0LeftOfCurrentTick, uint256 density1RightOfCurrentTick) =
            state.liquidityDensityFunction.query(currentTick, arithmeticMeanTick, state.poolKey.tickSpacing);
        (uint256 density0OfCurrentTick, uint256 density1OfCurrentTick) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96, currentTickSqrtRatio, nextTickSqrtRatio, liquidityDensityOfCurrentTick.toUint128()
        );

        // compute how much liquidity we'd get from the desired token amounts
        uint256 totalLiquidity = min(
            FullMath.mulDiv(params.amount0Desired, WAD, density0LeftOfCurrentTick + density0OfCurrentTick),
            FullMath.mulDiv(params.amount1Desired, WAD, density1RightOfCurrentTick + density1OfCurrentTick)
        );
        addedLiquidity = FullMath.mulDiv(totalLiquidity, liquidityDensityOfCurrentTick, WAD).toUint128();

        // compute token amounts
        uint256 currentTickAmount0 = FullMath.mulDiv(totalLiquidity, density0OfCurrentTick, WAD);
        uint256 currentTickAmount1 = FullMath.mulDiv(totalLiquidity, density1OfCurrentTick, WAD);
        amount0 = FullMath.mulDiv(totalLiquidity, density0LeftOfCurrentTick + density0OfCurrentTick, WAD);
        amount1 = FullMath.mulDiv(totalLiquidity, density1RightOfCurrentTick + density1OfCurrentTick, WAD);

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // mint shares
        (uint256 existingAmount0, uint256 existingAmount1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96,
            currentTickSqrtRatio,
            nextTickSqrtRatio,
            poolManager.getLiquidity(poolId, address(this), currentTick, nextTick)
        );
        shares = _mintShares(
            params.bunniToken,
            params.recipient,
            amount0,
            existingAmount0 + state.reserve0, // current tick tokens + reserve tokens
            amount1,
            existingAmount1 + state.reserve1 // current tick tokens + reserve tokens
        );

        // update reserves
        // reserves represent the amount of tokens not in the current tick
        _bunniTokenState[params.bunniToken].reserve0 = state.reserve0 + (amount0 - currentTickAmount0).toUint128();
        _bunniTokenState[params.bunniToken].reserve1 = state.reserve1 + (amount1 - currentTickAmount1).toUint128();

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // add liquidity and reserves
        _modifyLiquidity(
            ModifyLiquidityParams({
                poolKey: state.poolKey,
                tickLower: currentTick,
                tickUpper: currentTick + state.poolKey.tickSpacing,
                bunniToken: params.bunniToken,
                poolId: poolId,
                user: msg.sender,
                liquidityDelta: uint256(addedLiquidity).toInt256(),
                amount0Min: params.amount0Min,
                amount1Min: params.amount1Min,
                depositAmount0: (amount0 - currentTickAmount0).toInt256(),
                depositAmount1: (amount1 - currentTickAmount1).toInt256()
            })
        );

        // emit event
        emit Deposit(msg.sender, params.recipient, params.bunniToken, addedLiquidity, amount0, amount1, shares);
    }

    /// @inheritdoc IBunniHub
    function withdraw(WithdrawParams calldata params)
        external
        virtual
        override
        checkDeadline(params.deadline)
        returns (uint128 removedLiquidity, uint256 amount0, uint256 amount1)
    {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (params.shares == 0) revert BunniHub__ZeroInput();

        (BunniTokenState memory state, PoolId poolId) = _getStateAndIdOfBunniToken(params.bunniToken);
        uint256 currentTotalSupply = params.bunniToken.totalSupply();
        (, int24 currentTick,,,,) = poolManager.getSlot0(poolId);
        int24 nextTick = currentTick + state.poolKey.tickSpacing;
        uint128 existingLiquidity = poolManager.getLiquidity(poolId, address(this), currentTick, nextTick);

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // burn shares
        params.bunniToken.burn(msg.sender, params.shares);
        // at this point of execution we know params.shares <= currentTotalSupply
        // since otherwise the burn() call would've reverted

        // update reserves
        // reserves represent the amount of tokens not in the current tick
        uint256 removedReserve0 = FullMath.mulDiv(state.reserve0, params.shares, currentTotalSupply);
        uint256 removedReserve1 = FullMath.mulDiv(state.reserve1, params.shares, currentTotalSupply);
        _bunniTokenState[params.bunniToken].reserve0 = state.reserve0 - removedReserve0.toUint128();
        _bunniTokenState[params.bunniToken].reserve1 = state.reserve1 - removedReserve1.toUint128();

        // burn liquidity from pool
        // type cast is safe because we know removedLiquidity <= existingLiquidity
        removedLiquidity = uint128(FullMath.mulDiv(existingLiquidity, params.shares, currentTotalSupply));

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // burn liquidity and withdraw reserves
        (amount0, amount1) = _modifyLiquidity(
            ModifyLiquidityParams({
                poolKey: state.poolKey,
                tickLower: currentTick,
                tickUpper: currentTick + state.poolKey.tickSpacing,
                bunniToken: params.bunniToken,
                poolId: poolId,
                user: params.recipient,
                liquidityDelta: -uint256(removedLiquidity).toInt256(),
                amount0Min: params.amount0Min,
                amount1Min: params.amount1Min,
                depositAmount0: -removedReserve0.toInt256(),
                depositAmount1: -removedReserve1.toInt256()
            })
        );

        emit Withdraw(
            msg.sender, params.recipient, params.bunniToken, removedLiquidity, amount0, amount1, params.shares
        );
    }

    /// @inheritdoc IBunniHub
    function compound(IBunniToken bunniToken) external virtual override returns (uint256 amount0, uint256 amount1) {
        (BunniTokenState memory state, PoolId poolId) = _getStateAndIdOfBunniToken(bunniToken);
        (, int24 currentTick,,,,) = poolManager.getSlot0(poolId);
        int24 nextTick = currentTick + state.poolKey.tickSpacing;
        (amount0, amount1) = _compound(state.poolKey, currentTick, nextTick);

        emit Compound(msg.sender, bunniToken, amount0, amount1);
    }

    /// @inheritdoc IBunniHub
    function deployBunniToken(
        Currency currency0,
        Currency currency1,
        int24 tickSpacing,
        ILiquidityDensityFunction liquidityDensityFunction,
        uint32 twapSecondsAgo,
        IHooks hooks,
        uint160 sqrtPriceX96
    ) external override returns (IBunniToken token) {
        /// -----------------------------------------------------------------------
        /// Verification
        /// -----------------------------------------------------------------------

        // each Uniswap v4 pool corresponds to a single BunniToken
        // since Univ4 pool key is deterministic based on poolKey, we use dynamic fee so that the lower 20 bits of `poolKey.fee` is used
        // as nonce to differentiate the BunniTokens
        // each "subspace" has its own nonce that's incremented whenever a BunniToken is deployed with the same tokens & tick spacing & hooks
        // nonce can be at most 2^20 - 1 = 1048575 after which the deployment will fail
        bytes32 bunniSubspace = keccak256(abi.encode(currency0, currency1, tickSpacing, hooks));
        uint24 nonce_ = nonce[bunniSubspace];
        if (nonce_ + 1 > MAX_NONCE) revert BunniHub__MaxNonceReached();

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // deploy BunniToken
        token = IBunniToken(
            CREATE3.deploy(
                keccak256(abi.encode(bunniSubspace, nonce_)),
                abi.encodePacked(
                    type(BunniToken).creationCode,
                    abi.encode(this, IERC20(Currency.unwrap(currency0)), IERC20(Currency.unwrap(currency1)))
                ),
                0
            )
        );

        // update BunniToken state
        PoolKey memory key = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: uint24(0xC00000) + nonce_, // top nibble is 1100 to enable dynamic fee & hook swap fee, bottom 20 bits are the nonce
            tickSpacing: tickSpacing,
            hooks: hooks
        });
        _bunniTokenState[token] = BunniTokenState({
            poolKey: key,
            liquidityDensityFunction: liquidityDensityFunction,
            twapSecondsAgo: twapSecondsAgo,
            initialized: true,
            reserve0: 0,
            reserve1: 0
        });
        PoolId poolId = key.toId();
        bunniTokenOfPool[poolId] = token;

        // increment nonce
        nonce[bunniSubspace] = nonce_ + 1;

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // initialize Uniswap v4 pool
        poolManager.initialize(key, sqrtPriceX96);

        emit NewBunni(token, poolId);
    }

    /// @inheritdoc IBunniHub
    function bunniTokenState(IBunniToken bunniToken) external view override returns (BunniTokenState memory) {
        return _bunniTokenState[bunniToken];
    }

    /// -----------------------------------------------------------------------
    /// Uniswap callback
    /// -----------------------------------------------------------------------

    enum LockCallbackType {MODIFY_LIQUIDITY}

    function lockAcquired(bytes calldata data) external override returns (bytes memory) {
        // verify sender
        if (msg.sender != address(poolManager)) revert BunniHub__Unauthorized();

        // decode input
        (LockCallbackType t, bytes memory callbackData) = abi.decode(data, (LockCallbackType, bytes));

        // redirect to respective callback
        if (t == LockCallbackType.MODIFY_LIQUIDITY) {
            return abi.encode(_modifyLiquidityLockCallback(abi.decode(callbackData, (ModifyLiquidityInputData))));
        }
    }

    /// -----------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------

    function _compound(PoolKey memory poolKey, int24 tickLower, int24 tickUpper)
        internal
        returns (uint256 feeToAdd0, uint256 feeToAdd1)
    {
        // trigger an update of the position fees owed snapshots

        BalanceDelta feeDelta = poolManager.modifyPosition(
            poolKey, IPoolManager.ModifyPositionParams({tickLower: tickLower, tickUpper: tickUpper, liquidityDelta: 0})
        );

        // negate values to get fees owed
        (feeToAdd0, feeToAdd1) = (uint256(uint128(-feeDelta.amount0())), uint256(uint128(-feeDelta.amount1())));
    }

    /// @param state The state associated with the Bunni token
    /// @param liquidityDelta The amount of liquidity to add/subtract
    /// @param user The address to pay/receive the tokens
    struct ModifyLiquidityInputData {
        PoolKey poolKey;
        int24 tickLower;
        int24 tickUpper;
        int256 liquidityDelta;
        int256 depositAmount0;
        int256 depositAmount1;
        address user;
    }

    struct ModifyLiquidityReturnData {
        uint256 amount0;
        uint256 amount1;
        uint256 compoundAmount0;
        uint256 compoundAmount1;
    }

    function _modifyLiquidityLockCallback(ModifyLiquidityInputData memory input)
        internal
        returns (ModifyLiquidityReturnData memory returnData)
    {
        // compute compound amounts
        (returnData.compoundAmount0, returnData.compoundAmount1) =
            _compound(input.poolKey, input.tickLower, input.tickUpper);

        int128 amount0;
        int128 amount1;
        {
            // update liquidity
            BalanceDelta delta = poolManager.modifyPosition(
                input.poolKey,
                IPoolManager.ModifyPositionParams({
                    tickLower: input.tickLower,
                    tickUpper: input.tickUpper,
                    liquidityDelta: input.liquidityDelta
                })
            );
            (amount0, amount1) = (delta.amount0(), delta.amount1());
        }

        uint256 result0;
        uint256 result1;

        // transfer tokens owed

        // token0
        if (amount0 > 0) {
            // we owe uniswap tokens
            result0 = uint256(uint128(amount0));
            _pay(Currency.unwrap(input.poolKey.currency0), input.user, address(poolManager), result0);
            poolManager.settle(input.poolKey.currency0);
        } else if (amount0 < 0) {
            // uniswap owes us tokens
            result0 = uint256(uint128(-amount0));
            poolManager.take(input.poolKey.currency0, input.user, result0);
        }

        if (input.depositAmount0 > 0) {
            // deposit tokens into PoolManager
            _pay(
                Currency.unwrap(input.poolKey.currency0),
                input.user,
                address(poolManager),
                uint256(input.depositAmount0)
            );
            poolManager.mint(input.poolKey.currency0, address(this), uint256(input.depositAmount0));
        }

        // token1
        if (amount1 > 0) {
            // we owe uniswap tokens
            result1 = uint256(uint128(amount1));
            _pay(Currency.unwrap(input.poolKey.currency1), input.user, address(poolManager), result1);
            poolManager.settle(input.poolKey.currency1);
        } else if (amount0 < 0) {
            // uniswap owes us tokens
            result1 = uint256(uint128(-amount1));
            poolManager.take(input.poolKey.currency1, input.user, result1);
        }

        if (input.depositAmount1 > 0) {
            // deposit tokens into PoolManager
            _pay(
                Currency.unwrap(input.poolKey.currency1),
                input.user,
                address(poolManager),
                uint256(input.depositAmount1)
            );
            poolManager.mint(input.poolKey.currency1, address(this), uint256(input.depositAmount1));
        }

        // withdraw tokens from PoolManager
        if (input.depositAmount0 < 0 && input.depositAmount1 < 0) {
            uint256[] memory ids = new uint256[](2);
            ids[0] = input.poolKey.currency0.toId();
            ids[1] = input.poolKey.currency1.toId();
            uint256[] memory amounts = new uint256[](2);
            ids[0] = uint256(-input.depositAmount0);
            ids[1] = uint256(-input.depositAmount1);
            poolManager.safeBatchTransferFrom(address(this), address(poolManager), ids, amounts, bytes(""));
            poolManager.take(input.poolKey.currency0, input.user, amounts[0]);
            poolManager.take(input.poolKey.currency1, input.user, amounts[1]);
        } else if (input.depositAmount0 < 0) {
            poolManager.safeTransferFrom(
                address(this),
                address(poolManager),
                input.poolKey.currency0.toId(),
                uint256(-input.depositAmount0),
                bytes("")
            );
        } else if (input.depositAmount1 < 0) {
            poolManager.safeTransferFrom(
                address(this),
                address(poolManager),
                input.poolKey.currency1.toId(),
                uint256(-input.depositAmount1),
                bytes("")
            );
        }

        (returnData.amount0, returnData.amount1) = (result0, result1);
    }

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
    ) internal virtual returns (uint256 shares) {
        uint256 existingShareSupply = shareToken.totalSupply();
        if (existingShareSupply == 0) {
            // no existing shares, just give WAD
            shares = WAD - MIN_INITIAL_SHARES;
            // prevent first staker from stealing funds of subsequent stakers
            // see https://code4rena.com/reports/2022-01-sherlock/#h-01-first-user-can-steal-everyone-elses-tokens
            shareToken.mint(address(0), MIN_INITIAL_SHARES);
        } else {
            shares = min(
                FullMath.mulDiv(existingShareSupply, addedAmount0, existingAmount0),
                FullMath.mulDiv(existingShareSupply, addedAmount1, existingAmount1)
            );
            if (shares == 0) revert BunniHub__ZeroSharesMinted();
        }

        // mint shares to sender
        shareToken.mint(recipient, shares);
    }

    struct ModifyLiquidityParams {
        PoolKey poolKey;
        int24 tickLower;
        int24 tickUpper;
        IBunniToken bunniToken;
        PoolId poolId;
        address user;
        int256 liquidityDelta;
        uint256 amount0Min;
        uint256 amount1Min;
        int256 depositAmount0;
        int256 depositAmount1;
    }

    function _modifyLiquidity(ModifyLiquidityParams memory params)
        internal
        returns (uint256 amount0, uint256 amount1)
    {
        ModifyLiquidityReturnData memory returnData = abi.decode(
            poolManager.lock(
                abi.encode(
                    LockCallbackType.MODIFY_LIQUIDITY,
                    abi.encode(
                        ModifyLiquidityInputData({
                            poolKey: params.poolKey,
                            tickLower: params.tickLower,
                            tickUpper: params.tickUpper,
                            liquidityDelta: params.liquidityDelta,
                            user: params.user,
                            depositAmount0: params.depositAmount0,
                            depositAmount1: params.depositAmount1
                        })
                    )
                )
            ),
            (ModifyLiquidityReturnData)
        );

        if (returnData.amount0 < params.amount0Min || returnData.amount1 < params.amount1Min) {
            revert BunniHub__SlippageTooHigh();
        }
        (amount0, amount1) = (returnData.amount0, returnData.amount1);
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function _pay(address token, address payer, address recipient, uint256 value) internal {
        if (payer == address(this)) {
            // pay with tokens already in the contract (for the exact input multihop case)
            IERC20(token).safeTransfer(recipient, value);
        } else {
            // pull payment
            IERC20(token).safeTransferFrom(payer, recipient, value);
        }
    }

    function _getStateAndIdOfBunniToken(IBunniToken bunniToken)
        internal
        view
        returns (BunniTokenState memory state, PoolId poolId)
    {
        state = _bunniTokenState[bunniToken];
        if (!state.initialized) revert BunniHub__BunniTokenNotInitialized();
        poolId = state.poolKey.toId();
    }
}
