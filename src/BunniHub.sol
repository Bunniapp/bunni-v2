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

import {BunniToken} from "./BunniToken.sol";
import {Multicall} from "./lib/Multicall.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {SelfPermit} from "./lib/SelfPermit.sol";
import {IBunniToken} from "./interfaces/IBunniToken.sol";
import {SafeTransferLib} from "./lib/SafeTransferLib.sol";
import {LiquidityAmounts} from "./lib/LiquidityAmounts.sol";
import {IBunniHub, BunniTokenState, ShiftMode} from "./interfaces/IBunniHub.sol";

/// @title BunniHub
/// @author zefram.eth
/// @notice The main contract LPs interact with. Each BunniKey corresponds to a BunniToken,
/// which is the ERC20 LP token for the Uniswap V4 position specified by the BunniKey.
/// Use deposit()/withdraw() to mint/burn LP tokens, and use compound() to compound the swap fees
/// back into the LP position.
contract BunniHub is IBunniHub, Multicall, SelfPermit {
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
        payable
        virtual
        override
        checkDeadline(params.deadline)
        returns (uint256 shares, uint128 addedLiquidity, uint256 amount0, uint256 amount1)
    {
        (BunniTokenState memory state, PoolId poolId) = _getStateAndIdOfBunniToken(params.bunniToken);
        uint128 existingLiquidity = poolManager.getLiquidity(poolId, address(this), state.tickLower, state.tickUpper);

        // compute the liquidity amount
        {
            (uint160 sqrtPriceX96,,,,,) = poolManager.getSlot0(poolId);
            addedLiquidity = LiquidityAmounts.getLiquidityForAmounts(
                sqrtPriceX96,
                TickMath.getSqrtRatioAtTick(state.tickLower),
                TickMath.getSqrtRatioAtTick(state.tickUpper),
                params.amount0Desired,
                params.amount1Desired
            );
        }

        // add liquidity
        (amount0, amount1) = _modifyLiquidity(
            ModifyLiquidityParams({
                state: state,
                bunniToken: params.bunniToken,
                poolId: poolId,
                user: msg.sender,
                liquidityDelta: uint256(addedLiquidity).toInt256(),
                amount0Min: params.amount0Min,
                amount1Min: params.amount1Min,
                existingLiquidity: existingLiquidity
            })
        );

        // mint shares
        shares = _mintShares(params.bunniToken, params.recipient, addedLiquidity, existingLiquidity);

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
        if (params.shares == 0) revert BunniHub__ZeroInput();

        (BunniTokenState memory state, PoolId poolId) = _getStateAndIdOfBunniToken(params.bunniToken);
        uint256 currentTotalSupply = params.bunniToken.totalSupply();
        uint128 existingLiquidity = poolManager.getLiquidity(poolId, address(this), state.tickLower, state.tickUpper);

        // burn shares
        params.bunniToken.burn(msg.sender, params.shares);
        // at this point of execution we know params.shares <= currentTotalSupply
        // since otherwise the burn() call would've reverted

        // burn liquidity from pool
        // type cast is safe because we know removedLiquidity <= existingLiquidity
        removedLiquidity = uint128(FullMath.mulDiv(existingLiquidity, params.shares, currentTotalSupply));
        // burn liquidity
        (amount0, amount1) = _modifyLiquidity(
            ModifyLiquidityParams({
                state: state,
                bunniToken: params.bunniToken,
                poolId: poolId,
                user: params.recipient,
                liquidityDelta: -uint256(removedLiquidity).toInt256(),
                amount0Min: params.amount0Min,
                amount1Min: params.amount1Min,
                existingLiquidity: existingLiquidity
            })
        );

        emit Withdraw(
            msg.sender, params.recipient, params.bunniToken, removedLiquidity, amount0, amount1, params.shares
        );
    }

    /// @inheritdoc IBunniHub
    function compound(IBunniToken bunniToken)
        external
        virtual
        override
        returns (uint128 addedLiquidity, uint256 amount0, uint256 amount1)
    {
        (BunniTokenState memory state, PoolId poolId) = _getStateAndIdOfBunniToken(bunniToken);
        uint128 existingLiquidity = poolManager.getLiquidity(poolId, address(this), state.tickLower, state.tickUpper);

        ModifyLiquidityReturnData memory returnData = abi.decode(
            poolManager.lock(
                abi.encode(
                    LockCallbackType.MODIFY_LIQUIDITY,
                    abi.encode(
                        ModifyLiquidityInputData({
                            state: state,
                            liquidityDelta: 0,
                            user: msg.sender,
                            existingLiquidity: existingLiquidity
                        })
                    )
                )
            ),
            (ModifyLiquidityReturnData)
        );
        (addedLiquidity, amount0, amount1) = (returnData.compoundLiquidity, returnData.amount0, returnData.amount1);

        emit Compound(msg.sender, bunniToken, addedLiquidity, amount0, amount1);
    }

    /// @inheritdoc IBunniHub
    function deployBunniToken(
        Currency currency0,
        Currency currency1,
        int24 tickSpacing,
        int24 tickLower,
        int24 tickUpper,
        ShiftMode mode,
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
            tickLower: tickLower,
            tickUpper: tickUpper,
            mode: mode,
            twapSecondsAgo: twapSecondsAgo,
            initialized: true
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

        emit NewBunni(token, poolId, tickLower, tickUpper, mode);
    }

    /// @inheritdoc IBunniHub
    function hookShiftPosition(PoolKey calldata poolKey, int24 shift) external override {
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        // no useless shifts
        if (shift == 0) {
            revert BunniHub__InvalidShift();
        }

        // only hooks contract can call this
        if (msg.sender != address(poolKey.hooks)) revert BunniHub__Unauthorized();

        // load BunniToken state
        PoolId poolId = poolKey.toId();
        IBunniToken bunniToken = bunniTokenOfPool[poolId];
        BunniTokenState memory state = _bunniTokenState[bunniToken];
        if (!state.initialized) revert BunniHub__BunniTokenNotInitialized();

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        _bunniTokenState[bunniToken] = BunniTokenState({
            poolKey: poolKey,
            tickLower: state.tickLower + shift,
            tickUpper: state.tickUpper + shift,
            mode: state.mode,
            twapSecondsAgo: state.twapSecondsAgo,
            initialized: true
        });

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // query existing liquidity
        uint128 liquidity = poolManager.getLiquidity(poolId, address(this), state.tickLower, state.tickUpper);

        // get lock from pool manager
        ShiftReturnData memory returnData = abi.decode(
            poolManager.lock(
                abi.encode(
                    LockCallbackType.SHIFT,
                    ShiftInputData({state: state, liquidity: liquidity, shift: shift, existingLiquidity: liquidity})
                )
            ),
            (ShiftReturnData)
        );

        // emit compound event
        if (returnData.compoundLiquidity != 0) {
            emit Compound(
                msg.sender,
                bunniToken,
                returnData.compoundLiquidity,
                returnData.compoundAmount0,
                returnData.compoundAmount1
            );
        }
    }

    /// @inheritdoc IBunniHub
    function bunniTokenState(IBunniToken bunniToken) external view override returns (BunniTokenState memory) {
        return _bunniTokenState[bunniToken];
    }

    /// -----------------------------------------------------------------------
    /// Uniswap callback
    /// -----------------------------------------------------------------------

    enum LockCallbackType {
        MODIFY_LIQUIDITY,
        SHIFT
    }

    function lockAcquired(bytes calldata data) external override returns (bytes memory) {
        // verify sender
        if (msg.sender != address(poolManager)) revert BunniHub__Unauthorized();

        // decode input
        (LockCallbackType t, bytes memory callbackData) = abi.decode(data, (LockCallbackType, bytes));

        // redirect to respective callback
        if (t == LockCallbackType.MODIFY_LIQUIDITY) {
            return abi.encode(_modifyLiquidityLockCallback(abi.decode(callbackData, (ModifyLiquidityInputData))));
        } else {
            return abi.encode(_shiftLockCallback(abi.decode(callbackData, (ShiftInputData))));
        }
    }

    /// -----------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------

    function _compoundLogic(BunniTokenState memory state, uint128 existingLiquidity)
        internal
        returns (
            uint256 feeToAdd0,
            uint256 feeToAdd1,
            uint128 liquidityToAdd,
            uint256 donateAmount0,
            uint256 donateAmount1
        )
    {
        if (existingLiquidity == 0) return (0, 0, 0, 0, 0);

        // claim accrued fees and compound
        uint256 feeAmount0;
        uint256 feeAmount1;

        // trigger an update of the position fees owed snapshots
        {
            BalanceDelta feeDelta = poolManager.modifyPosition(
                state.poolKey,
                IPoolManager.ModifyPositionParams({
                    tickLower: state.tickLower,
                    tickUpper: state.tickUpper,
                    liquidityDelta: 0
                })
            );

            // negate values to get fees owed
            (feeAmount0, feeAmount1) = (uint256(uint128(-feeDelta.amount0())), uint256(uint128(-feeDelta.amount1())));
        }

        if (feeAmount0 != 0 || feeAmount1 != 0) {
            // the fee is likely not balanced (i.e. tokens will be left over after adding liquidity)
            // so here we compute which token to fully claim and which token to partially claim
            // so that we only claim the amounts we need

            (uint160 sqrtPriceX96,,,,,) = poolManager.getSlot0(state.poolKey.toId());
            uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(state.tickLower);
            uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(state.tickUpper);

            // compute the maximum liquidity addable using the accrued fees
            liquidityToAdd = LiquidityAmounts.getLiquidityForAmounts(
                sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, feeAmount0, feeAmount1
            );

            // compute the token amounts corresponding to the max addable liquidity
            (feeToAdd0, feeToAdd1) =
                LiquidityAmounts.getAmountsForLiquidity(sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, liquidityToAdd);

            // the first modifyPosition() call already added all accrued fees to our balance
            // so we donate the difference
            (donateAmount0, donateAmount1) = (feeAmount0 - feeToAdd0, feeAmount1 - feeToAdd1);
        }
    }

    /// @param state The state associated with the Bunni token
    /// @param liquidityDelta The amount of liquidity to add/subtract
    /// @param user The address to pay/receive the tokens
    struct ModifyLiquidityInputData {
        BunniTokenState state;
        int256 liquidityDelta;
        address user;
        uint128 existingLiquidity;
    }

    struct ModifyLiquidityReturnData {
        uint256 amount0;
        uint256 amount1;
        uint256 compoundAmount0;
        uint256 compoundAmount1;
        uint128 compoundLiquidity;
    }

    function _modifyLiquidityLockCallback(ModifyLiquidityInputData memory input)
        internal
        returns (ModifyLiquidityReturnData memory returnData)
    {
        int128 amount0;
        int128 amount1;
        uint256 donateAmount0;
        uint256 donateAmount1;
        {
            // compute compound amounts
            (
                returnData.compoundAmount0,
                returnData.compoundAmount1,
                returnData.compoundLiquidity,
                donateAmount0,
                donateAmount1
            ) = _compoundLogic(input.state, input.existingLiquidity);

            // update liquidity
            BalanceDelta delta = poolManager.modifyPosition(
                input.state.poolKey,
                IPoolManager.ModifyPositionParams({
                    tickLower: input.state.tickLower,
                    tickUpper: input.state.tickUpper,
                    liquidityDelta: input.liquidityDelta + uint256(returnData.compoundLiquidity).toInt256()
                })
            );

            // deduct compounded fee amount to get the user token amounts
            (amount0, amount1) = (
                delta.amount0() - returnData.compoundAmount0.toInt256().toInt128(),
                delta.amount1() - returnData.compoundAmount1.toInt256().toInt128()
            );

            // donate leftover fees back to LPs
            // must be after the last modifyPosition() call to avoid claiming donated amount
            if (donateAmount0 != 0 || donateAmount1 != 0) {
                poolManager.donate(input.state.poolKey, donateAmount0, donateAmount1);
            }
        }

        uint256 result0;
        uint256 result1;

        // transfer tokens owed

        // token0
        if (amount0 > 0) {
            // we owe uniswap tokens
            result0 = uint256(uint128(amount0));
            _pay(Currency.unwrap(input.state.poolKey.currency0), input.user, address(poolManager), result0);
            poolManager.settle(input.state.poolKey.currency0);
        } else if (amount0 < 0) {
            // uniswap owes us tokens
            result0 = uint256(uint128(-amount0));
            poolManager.take(input.state.poolKey.currency0, input.user, result0);
        }

        // token1
        if (amount1 > 0) {
            // we owe uniswap tokens
            result1 = uint256(uint128(amount1));
            _pay(Currency.unwrap(input.state.poolKey.currency1), input.user, address(poolManager), result1);
            poolManager.settle(input.state.poolKey.currency1);
        } else if (amount0 < 0) {
            // uniswap owes us tokens
            result1 = uint256(uint128(-amount1));
            poolManager.take(input.state.poolKey.currency1, input.user, result1);
        }

        (returnData.amount0, returnData.amount1) = (result0, result1);
    }

    struct ShiftInputData {
        BunniTokenState state;
        uint128 liquidity;
        int24 shift;
        uint128 existingLiquidity;
    }

    struct ShiftReturnData {
        uint256 compoundAmount0;
        uint256 compoundAmount1;
        uint128 compoundLiquidity;
    }

    function _shiftLockCallback(ShiftInputData memory input) internal returns (ShiftReturnData memory returnData) {
        uint256 donateAmount0;
        uint256 donateAmount1;

        // compute compound amounts
        (
            returnData.compoundAmount0,
            returnData.compoundAmount1,
            returnData.compoundLiquidity,
            donateAmount0,
            donateAmount1
        ) = _compoundLogic(input.state, input.existingLiquidity);

        // remove existing liquidity and add to new range
        poolManager.modifyPosition(
            input.state.poolKey,
            IPoolManager.ModifyPositionParams({
                tickLower: input.state.tickLower,
                tickUpper: input.state.tickUpper,
                liquidityDelta: -uint256(input.liquidity).toInt256()
            })
        );
        poolManager.modifyPosition(
            input.state.poolKey,
            IPoolManager.ModifyPositionParams({
                tickLower: input.state.tickLower + input.shift,
                tickUpper: input.state.tickUpper + input.shift,
                liquidityDelta: uint256(input.liquidity + returnData.compoundLiquidity).toInt256()
            })
        );

        // donate leftover fees back to LPs
        // must be after the last modifyPosition() call to avoid claiming donated amount
        if (donateAmount0 != 0 || donateAmount1 != 0) {
            poolManager.donate(input.state.poolKey, donateAmount0, donateAmount1);
        }
    }

    /// @notice Mints share tokens to the recipient based on the amount of liquidity added.
    /// @param shareToken The BunniToken to mint
    /// @param recipient The recipient of the share tokens
    /// @param addedLiquidity The amount of liquidity added
    /// @param existingLiquidity The amount of existing liquidity before the add
    /// @return shares The amount of share tokens minted to the sender.
    function _mintShares(IBunniToken shareToken, address recipient, uint128 addedLiquidity, uint128 existingLiquidity)
        internal
        virtual
        returns (uint256 shares)
    {
        uint256 existingShareSupply = shareToken.totalSupply();
        if (existingShareSupply == 0) {
            // no existing shares, bootstrap at rate 1:1
            shares = addedLiquidity - MIN_INITIAL_SHARES;
            // prevent first staker from stealing funds of subsequent stakers
            // see https://code4rena.com/reports/2022-01-sherlock/#h-01-first-user-can-steal-everyone-elses-tokens
            shareToken.mint(address(0), MIN_INITIAL_SHARES);
        } else {
            // shares = existingShareSupply * addedLiquidity / existingLiquidity;
            shares = FullMath.mulDiv(existingShareSupply, addedLiquidity, existingLiquidity);
            if (shares == 0) revert BunniHub__ZeroSharesMinted();
        }

        // mint shares to sender
        shareToken.mint(recipient, shares);
    }

    struct ModifyLiquidityParams {
        BunniTokenState state;
        IBunniToken bunniToken;
        PoolId poolId;
        address user;
        int256 liquidityDelta;
        uint256 amount0Min;
        uint256 amount1Min;
        uint128 existingLiquidity;
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
                            state: params.state,
                            liquidityDelta: params.liquidityDelta,
                            user: params.user,
                            existingLiquidity: params.existingLiquidity
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

        if (returnData.compoundLiquidity != 0) {
            emit Compound(
                msg.sender,
                params.bunniToken,
                returnData.compoundLiquidity,
                returnData.compoundAmount0,
                returnData.compoundAmount1
            );
        }
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
