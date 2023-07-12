// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.19;

import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/contracts/libraries/FullMath.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts/libraries/CurrencyLibrary.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/libraries/PoolId.sol";
import {IPoolManager, PoolKey, ModifyPositionParams} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {ILockCallback} from "@uniswap/v4-core/contracts/interfaces/callback/ILockCallback.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";

import {Ownable} from "solady/src/auth/Ownable.sol";
import {CREATE3} from "solady/src/utils/CREATE3.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {BunniToken} from "./BunniToken.sol";
import {Multicall} from "./lib/Multicall.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {SelfPermit} from "./lib/SelfPermit.sol";
import {IBunniHub} from "./interfaces/IBunniHub.sol";
import {IBunniToken} from "./interfaces/IBunniToken.sol";
import {SafeTransferLib} from "./lib/SafeTransferLib.sol";
import {LiquidityAmounts} from "./uniswap/LiquidityAmounts.sol";

/// @title BunniHub
/// @author zefram.eth
/// @notice The main contract LPs interact with. Each BunniKey corresponds to a BunniToken,
/// which is the ERC20 LP token for the Uniswap V4 position specified by the BunniKey.
/// Use deposit()/withdraw() to mint/burn LP tokens, and use compound() to compound the swap fees
/// back into the LP position.
contract BunniHub is IBunniHub, Ownable, Multicall, SelfPermit {
    using PoolIdLibrary for PoolKey;
    using SafeTransferLib for IERC20;
    using CurrencyLibrary for Currency;
    using BalanceDeltaLibrary for BalanceDelta;
    using SafeCastLib for uint256;
    using SafeCastLib for int256;

    uint256 internal constant WAD = 1e18;
    uint256 internal constant MIN_INITIAL_SHARES = 1e3;

    IPoolManager public immutable override poolManager;

    /// -----------------------------------------------------------
    /// Storage variables
    /// -----------------------------------------------------------

    enum ShiftMode {
        STATIC,
        LEFT,
        RIGHT,
        BOTH
    }

    struct BunniTokenState {
        PoolKey poolKey;
        int24 tickLower;
        int24 tickUpper;
        bool initialized;
        ShiftMode mode;
    }

    mapping(IBunniToken bunniToken => BunniTokenState) public bunniTokenState;

    /// -----------------------------------------------------------
    /// Modifiers
    /// -----------------------------------------------------------

    modifier checkDeadline(uint256 deadline) {
        require(block.timestamp <= deadline, "OLD");
        _;
    }

    /// -----------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------

    constructor(IPoolManager poolManager_, address owner_) LiquidityManagement(poolManager_) {
        poolManager = poolManager_;

        _initializeOwner(owner_);
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
        (addedLiquidity, amount0, amount1) = _addLiquidity(
            LiquidityManagement.AddLiquidityParams({
                state: state,
                poolId: poolId,
                payer: msg.sender,
                amount0Desired: params.amount0Desired,
                amount1Desired: params.amount1Desired,
                amount0Min: params.amount0Min,
                amount1Min: params.amount1Min
            })
        );
        shares = _mintShares(params.key, params.recipient, addedLiquidity, existingLiquidity);

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
        (BunniTokenState memory state, PoolId poolId) = _getStateAndIdOfBunniToken(params.bunniToken);
        uint256 currentTotalSupply = params.bunniToken.totalSupply();
        uint128 existingLiquidity = poolManager.getLiquidity(poolId, address(this), state.tickLower, state.tickUpper);

        // burn shares
        require(params.shares > 0, "0");
        params.bunniToken.burn(msg.sender, params.shares);
        // at this point of execution we know params.shares <= currentTotalSupply
        // since otherwise the burn() call would've reverted

        // burn liquidity from pool
        // type cast is safe because we know removedLiquidity <= existingLiquidity
        removedLiquidity = uint128(FullMath.mulDiv(existingLiquidity, params.shares, currentTotalSupply));
        // burn liquidity
        (amount0, amount1) = _removeLiquidity(
            LiquidityManagement.RemoveLiquidityParams({
                state: state,
                poolId: poolId,
                recipient: params.recipient,
                liquidity: removedLiquidity,
                amount0Min: params.amount0Min,
                amount1Min: params.amount1Min
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
        (BunniTokenState memory state, PoolId poolId) = _getStateAndIdOfBunniToken(params.bunniToken);
        (uint160 sqrtPriceX96,,,,,) = poolManager.getSlot0(poolId);
        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(state.tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(state.tickUpper);

        LockCallbackReturnData memory returnData = abi.decode(
            poolManager.lock(
                abi.encode(
                    LockCallbackInputData({
                        state: state,
                        liquidityDelta: 0,
                        payer: msg.sender,
                        sqrtPriceX96: sqrtPriceX96,
                        sqrtRatioAX96: sqrtRatioAX96,
                        sqrtRatioBX96: sqrtRatioBX96
                    })
                )
            ),
            (LockCallbackReturnData)
        );

        emit Compound(msg.sender, bunniToken, addedLiquidity, amount0, amount1);
    }

    /// @inheritdoc IBunniHub
    function deployBunniToken(PoolKey calldata poolKey, int24 tickLower, int24 tickUpper)
        external
        override
        returns (IBunniToken token)
    {
        bytes32 bunniKeyHash = keccak256(abi.encode(key));

        token = IBunniToken(
            CREATE3.deploy(bunniKeyHash, abi.encodePacked(type(BunniToken).creationCode, abi.encode(this, key)), 0)
        );

        emit NewBunni(token, bunniKeyHash, key.pool, key.tickLower, key.tickUpper);
    }

    /// -----------------------------------------------------------------------
    /// Uniswap callback
    /// -----------------------------------------------------------------------

    /// @param state The state associated with the Bunni token
    /// @param liquidityDelta The amount of liquidity to add/subtract
    /// @param user The address to pay/receive the tokens
    struct LockCallbackInputData {
        BunniTokenState state;
        int256 liquidityDelta;
        address user;
        uint160 sqrtPriceX96;
        uint160 sqrtPriceAX96;
        uint160 sqrtPriceBX96;
    }

    struct LockCallbackReturnData {
        uint256 amount0;
        uint256 amount1;
    }

    function lockAcquired(uint256 id, bytes calldata data) external override returns (bytes memory) {
        // verify sender
        require(msg.sender == address(poolManager), "WHO");

        // decode input
        LockCallbackInputData memory input = abi.decode(data, (LockCallbackInputData));

        int128 amount0;
        int128 amount1;
        {
            // claim accrued fees and compound
            uint256 feeToAdd0;
            uint256 feeToAdd1;
            {
                uint256 feeAmount0;
                uint256 feeAmount1;

                // trigger an update of the position fees owed snapshots
                {
                    BalanceDelta delta = poolManager.modifyPosition(
                        input.state.poolKey,
                        ModifyPositionParams({
                            tickLower: input.state.tickLower,
                            tickUpper: input.state.tickUpper,
                            liquidityDelta: 0
                        })
                    );

                    // negate values to get fees owed
                    (feeAmount0, feeAmount1) = (uint256(uint128(-delta.amount0())), uint256(uint128(-delta.amount1())));
                }

                if (feeAmount0 != 0 || feeAmount1 != 0) {
                    // the fee is likely not balanced (i.e. tokens will be left over after adding liquidity)
                    // so here we compute which token to fully claim and which token to partially claim
                    // so that we only claim the amounts we need

                    {
                        // compute the maximum liquidity addable using the accrued fees
                        uint128 maxAddLiquidity = LiquidityAmounts.getLiquidityForAmounts(
                            input.sqrtRatioX96, input.sqrtRatioAX96, input.sqrtRatioBX96, amount0, amount1
                        );

                        // compute the token amounts corresponding to the max addable liquidity
                        (feeToAdd0, feeToAdd1) = LiquidityAmounts.getAmountsForLiquidity(
                            input.sqrtRatioX96, input.sqrtRatioAX96, input.sqrtRatioBX96, maxAddLiquidity
                        );

                        // add the liquidity to compound to the liquidity delta of the second modifyPosition() call
                        input.liquidityDelta += uint256(maxAddLiquidity).toInt256();
                    }

                    // the first modifyPosition() call already added all accrued fees to our balance
                    // so we donate the difference
                    (uint256 donateAmount0, uint256 donateAmount1) = (feeAmount0 - feeToAdd0, feeAmount1 - feeToAdd1);
                    if (donateAmount0 != 0 || donateAmount1 != 0) {
                        poolManager.donate(input.state.poolKey, donateAmount0, donateAmount1);
                    }
                }
            }

            // update liquidity
            BalanceDelta delta = poolManager.modifyPosition(
                input.state.poolKey,
                ModifyPositionParams({
                    tickLower: input.state.tickLower,
                    tickUpper: input.state.tickUpper,
                    liquidityDelta: input.liquidityDelta
                })
            );

            // deduct compounded fee amount to get the user token amounts
            (amount0, amount1) =
                (delta.amount0() - feeToAdd0.toInt256().toInt128(), delta.amount1() - feeToAdd1.toInt256().toInt128());
        }

        uint256 result0;
        uint256 result1;

        // transfer tokens owed

        // token0
        if (amount0 > 0) {
            // we owe uniswap tokens
            result0 = uint256(uint128(amount0));
            pay(Currency.unwrap(input.poolKey.currency0), input.user, address(poolManager), result0);
            poolManager.settle(input.poolKey.currency0);
        } else if (amount0 < 0) {
            // uniswap owes us tokens
            result0 = uint256(uint128(-amount0));
            poolManager.take(input.poolKey.currency0, input.user, result0);
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

        return abi.encode(LockCallbackReturnData({amount0: result0, amount1: result1}));
    }

    /// -----------------------------------------------------------------------
    /// Owner functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHub
    function sweepTokens(IERC20[] calldata tokenList, address recipient) external override onlyOwner {
        uint256 tokenListLength = tokenList.length;
        for (uint256 i; i < tokenListLength;) {
            SafeTransferLib.safeTransfer(tokenList[i], recipient, tokenList[i].balanceOf(address(this)));

            unchecked {
                ++i;
            }
        }
    }

    /// -----------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------

    /// @notice Mints share tokens to the recipient based on the amount of liquidity added.
    /// @param key The Bunni position's key
    /// @param recipient The recipient of the share tokens
    /// @param addedLiquidity The amount of liquidity added
    /// @param existingLiquidity The amount of existing liquidity before the add
    /// @return shares The amount of share tokens minted to the sender.
    function _mintShares(BunniKey calldata key, address recipient, uint128 addedLiquidity, uint128 existingLiquidity)
        internal
        virtual
        returns (uint256 shares)
    {
        IBunniToken shareToken = getBunniToken(key);
        require(address(shareToken) != address(0), "WHAT");

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
            require(shares != 0, "0");
        }

        // mint shares to sender
        shareToken.mint(recipient, shares);
    }

    /// @param state The state of the BunniToken
    /// @param payer The address that will pay the tokens
    /// @param amount0Desired The token0 amount to use
    /// @param amount1Desired The token1 amount to use
    /// @param amount0Min The minimum token0 amount to use
    /// @param amount1Min The minimum token1 amount to use
    struct AddLiquidityParams {
        BunniTokenState state;
        PoolId poolId;
        address payer;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
    }

    /// @notice Add liquidity to an initialized pool
    function _addLiquidity(AddLiquidityParams memory params)
        internal
        returns (uint128 liquidity, uint256 amount0, uint256 amount1)
    {
        // compute the liquidity amount
        (uint160 sqrtPriceX96,,,,,) = poolManager.getSlot0(params.poolId);
        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(params.state.tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(params.state.tickUpper);

        liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, params.amount0Desired, params.amount1Desired
        );

        LockCallbackReturnData memory returnData = abi.decode(
            poolManager.lock(
                abi.encode(
                    LockCallbackInputData({
                        state: params.state,
                        liquidityDelta: uint256(liquidity).toInt256(),
                        user: params.payer,
                        sqrtPriceX96: sqrtPriceX96,
                        sqrtRatioAX96: sqrtRatioAX96,
                        sqrtRatioBX96: sqrtRatioBX96
                    })
                )
            ),
            (LockCallbackReturnData)
        );

        require(returnData.amount0 >= params.amount0Min && returnData.amount1 >= params.amount1Min, "SLIP");
    }

    /// @param state The state of the BunniToken
    /// @param payer The address that will pay the tokens
    /// @param amount0Desired The token0 amount to use
    /// @param amount1Desired The token1 amount to use
    /// @param amount0Min The minimum token0 amount to use
    /// @param amount1Min The minimum token1 amount to use
    struct RemoveLiquidityParams {
        BunniTokenState state;
        PoolId poolId;
        address recipient;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
    }

    /// @notice Add liquidity to an initialized pool
    function _removeLiquidity(RemoveLiquidityParams memory params)
        internal
        returns (uint256 amount0, uint256 amount1)
    {
        // compute the liquidity amount
        (uint160 sqrtPriceX96,,,,,) = poolManager.getSlot0(params.poolId);
        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(params.state.tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(params.state.tickUpper);

        LockCallbackReturnData memory returnData = abi.decode(
            poolManager.lock(
                abi.encode(
                    LockCallbackInputData({
                        state: params.state,
                        liquidityDelta: -uint256(liquidity).toInt256(),
                        user: params.recipient,
                        sqrtPriceX96: sqrtPriceX96,
                        sqrtRatioAX96: sqrtRatioAX96,
                        sqrtRatioBX96: sqrtRatioBX96
                    })
                )
            ),
            (LockCallbackReturnData)
        );

        require(returnData.amount0 >= params.amount0Min && returnData.amount1 >= params.amount1Min, "SLIP");
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
        state = bunniTokenState[bunniToken];
        require(state.initialized, "WHAT");
        poolId = state.poolKey.toId();
    }
}
