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
import {IBunniHub, BunniTokenState, ShiftMode, ITokenDensityFunction} from "./interfaces/IBunniHub.sol";

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

        // compute how much tokens to add to the current tick
        (uint160 sqrtPriceX96, int24 currentTick,,,,) = poolManager.getSlot0(poolId);
        int24 arithmeticMeanTick;
        {
            uint32[] memory secondsAgos = new uint32[](2);
            secondsAgos[0] = state.twapSecondsAgo;
            secondsAgos[1] = 0;
            BunniHook hook = BunniHook(address(state.poolKey.hooks));
            (int56[] memory tickCumulatives,) = hook.observe(state.poolKey, secondsAgos);
            int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
            arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(state.twapSecondsAgo)));
        }
        uint256 currentTickSqrtRatio = TickMath.getSqrtRatioAtTick(currentTick);
        uint256 nextTickSqrtRatio = TickMath.getSqrtRatioAtTick(currentTick + state.tickSpacing);
        uint256 currentTickDensity =
            state.tokenDensityFunction.tokenDensityOfTick(currentTick, currentTick, arithmeticMeanTick);
        uint256 adjustedCurrentTickToken0Density = currentTickDensity.mulDivDown(
            LiquidityAmounts.getAmount0ForLiquidity(currentTickSqrtRatio, sqrtPriceX96, WAD),
            LiquidityAmounts.getAmount0ForLiquidity(currentTickSqrtRatio, nextTickSqrtRatio, WAD)
        );
        uint256 adjustedCurrentTickToken1Density = currentTickDensity.mulDivDown(
            LiquidityAmounts.getAmount1ForLiquidity(sqrtPriceX96, nextTickSqrtRatio, WAD),
            LiquidityAmounts.getAmount1ForLiquidity(currentTickSqrtRatio, nextTickSqrtRatio, WAD)
        );
        uint256 cumulativeDensity =
            state.tokenDensityFunction.cumulativeTokenDensity(currentTick, currentTick, arithmeticMeanTick);

        {
            uint256 currentTickAmount0 =
                params.amount0Desired.mulDivDown(adjustedCurrentTickToken0Density, cumulativeDensity);
            uint256 currentTickAmount1 = params.amount1Desired.mulDivDown(
                adjustedCurrentTickToken1Density, WAD - cumulativeDensity + currentTickDensity
            );

            // compute how much liquidity we'd get from the tokens
            // tokens are likely imbalanced
            addedLiquidity = LiquidityAmounts.getLiquidityForAmounts(
                sqrtPriceX96, currentTickSqrtRatio, nextTickSqrtRatio, currentTickAmount0, currentTickAmount1
            );
        }

        // compute tokens outside of current tick to pull from user
        (amount0, amount1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96, currentTickSqrtRatio, nextTickSqrtRatio, addedLiquidity
        );
        uint256 totalAmount0 = amount0.mulDivUp(cumulativeDensity, adjustedCurrentTickToken0Density);
        uint256 totalAmount1 = amount1.mulDivUp(cumulativeDensity, adjustedCurrentTickToken1Density);

        // add liquidity
        (amount0, amount1) = _modifyLiquidity(
            ModifyLiquidityParams({
                poolKey: state.poolKey,
                tickLower: currentTick,
                tickUpper: currentTick + state.tickSpacing,
                bunniToken: params.bunniToken,
                poolId: poolId,
                user: msg.sender,
                liquidityDelta: uint256(addedLiquidity).toInt256(),
                amount0Min: params.amount0Min,
                amount1Min: params.amount1Min,
                depositAmount0: totalAmount0 - amount0,
                depositAmount1: totalAmount1 - amount1
            })
        );

        // mint shares
        shares = _mintShares(
            params.bunniToken, params.recipient, totalAmount0, existingAmount0, totalAmount1, existingAmount1
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
                            bunniToken: bunniToken,
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
        ITokenDensityFunction tokenDensityFunction,
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
            tokenDensityFunction: tokenDensityFunction,
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
        if (existingLiquidity == 0) {
            return (0, 0, 0, 0, 0);
        }

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
        PoolKey poolKey;
        int24 tickLower;
        int24 tickUpper;
        int256 liquidityDelta;
        uint256 depositAmount0;
        uint256 depositAmount1;
        address user;
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
                input.poolKey,
                IPoolManager.ModifyPositionParams({
                    tickLower: input.tickLower,
                    tickUpper: input.tickUpper,
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
                poolManager.donate(input.poolKey, donateAmount0, donateAmount1);
            }
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

        if (input.depositAmount0 != 0) {
            _pay(Currency.unwrap(input.poolKey.currency0), input.user, address(poolManager), input.depositAmount0);
            poolManager.mint(input.poolKey.currency0, address(this), input.depositAmount0);
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

        if (input.depositAmount1 != 0) {
            _pay(Currency.unwrap(input.poolKey.currency1), input.user, address(poolManager), input.depositAmount1);
            poolManager.mint(input.poolKey.currency1, address(this), input.depositAmount1);
        }

        (returnData.amount0, returnData.amount1) = (result0, result1);
    }

    struct ShiftInputData {
        BunniTokenState state;
        IBunniToken bunniToken;
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
        ) = _compoundLogic(input.state, input.existingLiquidity, input.bunniToken);

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
            // no existing shares, bootstrap at rate 1:1
            shares = addedLiquidity - MIN_INITIAL_SHARES;
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
        uint256 depositAmount0;
        uint256 depositAmount1;
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
                            bunniToken: params.bunniToken,
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
