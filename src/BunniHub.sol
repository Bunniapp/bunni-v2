// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import "forge-std/console2.sol";

import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/contracts/libraries/FullMath.sol";
import {FeeLibrary} from "@uniswap/v4-core/contracts/libraries/FeeLibrary.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {FixedPoint96} from "@uniswap/v4-core/contracts/libraries/FixedPoint96.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {ILockCallback} from "@uniswap/v4-core/contracts/interfaces/callback/ILockCallback.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";

import {CREATE3} from "solady/src/utils/CREATE3.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
import "./lib/LDFParams.sol";
import {BunniHook} from "./BunniHook.sol";
import {BunniToken} from "./BunniToken.sol";
import {Multicall} from "./lib/Multicall.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {SelfPermit} from "./lib/SelfPermit.sol";
import {IBunniToken} from "./interfaces/IBunniToken.sol";
import {SafeTransferLib} from "./lib/SafeTransferLib.sol";
import {LiquidityAmounts} from "./lib/LiquidityAmounts.sol";
import {IBunniHub, ILiquidityDensityFunction} from "./interfaces/IBunniHub.sol";

/// @title BunniHub
/// @author zefram.eth
/// @notice The main contract LPs interact with. Each BunniKey corresponds to a BunniToken,
/// which is the ERC20 LP token for the Uniswap V4 position specified by the BunniKey.
/// Use deposit()/withdraw() to mint/burn LP tokens, and use compound() to compound the swap fees
/// back into the LP position.
contract BunniHub is IBunniHub, Multicall, SelfPermit, ERC1155TokenReceiver {
    using FullMath for uint128;
    using FullMath for uint256;
    using SafeCastLib for int256;
    using SafeCastLib for uint256;
    using PoolIdLibrary for PoolKey;
    using SafeTransferLib for IERC20;
    using CurrencyLibrary for Currency;
    using FixedPointMathLib for uint128;
    using FixedPointMathLib for uint256;
    using BalanceDeltaLibrary for BalanceDelta;

    error BunniHub__ZeroInput();
    error BunniHub__PastDeadline();
    error BunniHub__Unauthorized();
    error BunniHub__LDFCannotBeZero();
    error BunniHub__MaxNonceReached();
    error BunniHub__SlippageTooHigh();
    error BunniHub__ZeroSharesMinted();
    error BunniHub__BunniTokenNotInitialized();

    uint256 internal constant WAD = 1e18;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
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
        (bool useTwap, uint24 twapSecondsAgo, bytes11 decodedLDFParams) = decodeLDFParams(state.ldfParams);
        if (useTwap) {
            // LDF uses TWAP
            // compute TWAP value
            uint32[] memory secondsAgos = new uint32[](2);
            secondsAgos[0] = twapSecondsAgo;
            secondsAgos[1] = 0;
            BunniHook hook = BunniHook(address(state.poolKey.hooks));
            (int56[] memory tickCumulatives,) = hook.observe(state.poolKey, secondsAgos);
            int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
            arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(twapSecondsAgo)));
        }
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, state.poolKey.tickSpacing);
        uint160 roundedTickSqrtRatio = TickMath.getSqrtRatioAtTick(roundedTick);
        uint160 nextRoundedTickSqrtRatio = TickMath.getSqrtRatioAtTick(nextRoundedTick);

        // compute density
        (
            uint256 liquidityDensityOfRoundedTickX96,
            uint256 density0RightOfRoundedTickX96,
            uint256 density1LeftOfRoundedTickX96
        ) = state.liquidityDensityFunction.query(
            roundedTick, arithmeticMeanTick, state.poolKey.tickSpacing, useTwap, decodedLDFParams
        );
        (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96,
            roundedTickSqrtRatio,
            nextRoundedTickSqrtRatio,
            liquidityDensityOfRoundedTickX96.toUint128(),
            false
        );

        // compute how much liquidity we'd get from the desired token amounts
        uint256 totalLiquidity = min(
            params.amount0Desired.mulDiv(Q96, density0RightOfRoundedTickX96 + density0OfRoundedTickX96),
            params.amount1Desired.mulDiv(Q96, density1LeftOfRoundedTickX96 + density1OfRoundedTickX96)
        );
        addedLiquidity = totalLiquidity.mulDiv(liquidityDensityOfRoundedTickX96, Q96).toUint128();

        // compute token amounts
        (uint256 roundedTickAmount0, uint256 roundedTickAmount1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, addedLiquidity, true
        );
        uint256 depositAmount0 = totalLiquidity.mulDivRoundingUp(density0RightOfRoundedTickX96, Q96);
        uint256 depositAmount1 = totalLiquidity.mulDivRoundingUp(density1LeftOfRoundedTickX96, Q96);
        amount0 = roundedTickAmount0 + depositAmount0;
        amount1 = roundedTickAmount1 + depositAmount1;

        // sanity check against desired amounts
        if ((amount0 > params.amount0Desired) && (amount1 > params.amount1Desired)) {
            // scale down amounts and take minimum
            (amount0, amount1, addedLiquidity) = (
                min(params.amount0Desired, amount0.mulDiv(params.amount1Desired, amount1)),
                min(params.amount1Desired, amount1.mulDiv(params.amount0Desired, amount0)),
                uint128(
                    min(
                        addedLiquidity.mulDivDown(params.amount0Desired, amount0),
                        addedLiquidity.mulDivDown(params.amount1Desired, amount1)
                    )
                    )
            );

            (roundedTickAmount0, roundedTickAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, addedLiquidity, true
            );
            (depositAmount0, depositAmount1) = (amount0 - roundedTickAmount0, amount1 - roundedTickAmount1);
        } else if (amount0 > params.amount0Desired) {
            // scale down amounts based on amount0
            (amount0, amount1, addedLiquidity) = (
                params.amount0Desired,
                amount1.mulDiv(params.amount0Desired, amount0),
                uint128(addedLiquidity.mulDivDown(params.amount0Desired, amount0))
            );

            (roundedTickAmount0, roundedTickAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, addedLiquidity, true
            );
            (depositAmount0, depositAmount1) = (amount0 - roundedTickAmount0, amount1 - roundedTickAmount1);
        } else if (amount1 > params.amount1Desired) {
            // scale down amounts based on amount1
            (amount0, amount1, addedLiquidity) = (
                amount0.mulDiv(params.amount1Desired, amount1),
                params.amount1Desired,
                uint128(addedLiquidity.mulDivDown(params.amount1Desired, amount1))
            );

            (roundedTickAmount0, roundedTickAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, addedLiquidity, true
            );
            (depositAmount0, depositAmount1) = (amount0 - roundedTickAmount0, amount1 - roundedTickAmount1);
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // mint shares
        (uint256 existingAmount0, uint256 existingAmount1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, poolManager.getLiquidity(poolId), false
        );
        shares = _mintShares(
            params.bunniToken,
            params.recipient,
            amount0,
            existingAmount0 + state.reserve0, // current tick tokens + reserve tokens
            amount1,
            existingAmount1 + state.reserve1 // current tick tokens + reserve tokens
        );

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // add liquidity and reserves
        ModifyLiquidityReturnData memory returnData = abi.decode(
            poolManager.lock(
                abi.encode(
                    LockCallbackType.MODIFY_LIQUIDITY,
                    abi.encode(
                        ModifyLiquidityInputData({
                            poolKey: state.poolKey,
                            tickLower: roundedTick,
                            tickUpper: nextRoundedTick,
                            liquidityDelta: uint256(addedLiquidity).toInt256(),
                            user: msg.sender,
                            reserveAmount0: depositAmount0,
                            reserveAmount1: depositAmount1,
                            isDeposit: true
                        })
                    )
                )
            ),
            (ModifyLiquidityReturnData)
        );
        if (amount0 < params.amount0Min || amount1 < params.amount1Min) {
            revert BunniHub__SlippageTooHigh();
        }

        // update reserves
        // reserves represent the amount of tokens not in the current tick
        _bunniTokenState[params.bunniToken].reserve0 = state.reserve0 + depositAmount0.toUint128();
        _bunniTokenState[params.bunniToken].reserve1 = state.reserve1 + depositAmount1.toUint128();

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
        uint128 existingLiquidity = poolManager.getLiquidity(poolId);

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // burn shares
        params.bunniToken.burn(msg.sender, params.shares);
        // at this point of execution we know params.shares <= currentTotalSupply
        // since otherwise the burn() call would've reverted

        // burn liquidity from pool
        // type cast is safe because we know removedLiquidity <= existingLiquidity
        removedLiquidity = uint128(existingLiquidity.mulDiv(params.shares, currentTotalSupply));

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // burn liquidity and withdraw reserves
        uint256 removedReserve0 = state.reserve0.mulDiv(params.shares, currentTotalSupply);
        uint256 removedReserve1 = state.reserve1.mulDiv(params.shares, currentTotalSupply);
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, state.poolKey.tickSpacing);
        ModifyLiquidityReturnData memory returnData = abi.decode(
            poolManager.lock(
                abi.encode(
                    LockCallbackType.MODIFY_LIQUIDITY,
                    abi.encode(
                        ModifyLiquidityInputData({
                            poolKey: state.poolKey,
                            tickLower: roundedTick,
                            tickUpper: nextRoundedTick,
                            liquidityDelta: -uint256(removedLiquidity).toInt256(),
                            user: msg.sender,
                            reserveAmount0: removedReserve0,
                            reserveAmount1: removedReserve1,
                            isDeposit: false
                        })
                    )
                )
            ),
            (ModifyLiquidityReturnData)
        );
        (amount0, amount1) = (returnData.amount0 + removedReserve0, returnData.amount1 + removedReserve1);
        if (amount0 < params.amount0Min || amount1 < params.amount1Min) {
            revert BunniHub__SlippageTooHigh();
        }

        // update reserves
        // reserves represent the amount of tokens not in the current tick
        _bunniTokenState[params.bunniToken].reserve0 = state.reserve0 - removedReserve0.toUint128();
        _bunniTokenState[params.bunniToken].reserve1 = state.reserve1 - removedReserve1.toUint128();

        emit Withdraw(
            msg.sender, params.recipient, params.bunniToken, removedLiquidity, amount0, amount1, params.shares
        );
    }

    /// @inheritdoc IBunniHub
    function deployBunniToken(
        Currency currency0,
        Currency currency1,
        int24 tickSpacing,
        ILiquidityDensityFunction liquidityDensityFunction,
        bytes12 ldfParams,
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

        // we also use ldf to check if the state is initialized so we ensure the ldf is nonzero
        if (address(liquidityDensityFunction) == address(0)) revert BunniHub__LDFCannotBeZero();

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
            ldfParams: ldfParams,
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
    function hookModifyLiquidity(IBunniToken bunniToken, LiquidityDelta[] calldata liquidityDeltas, bool compound)
        external
        override
    {
        (BunniTokenState memory state, PoolId poolId) = _getStateAndIdOfBunniToken(bunniToken);
        if (msg.sender != address(state.poolKey.hooks)) revert BunniHub__Unauthorized(); // only hook

        poolManager.lock(
            abi.encode(
                LockCallbackType.HOOK_MODIFY_LIQUIDITY,
                abi.encode(
                    HookCallbackInputData({
                        bunniToken: bunniToken,
                        state: state,
                        poolId: poolId,
                        compound: compound,
                        liquidityDeltas: liquidityDeltas
                    })
                )
            )
        );
    }

    /// -----------------------------------------------------------------------
    /// View functions
    /// -----------------------------------------------------------------------

    /// @inheritdoc IBunniHub
    function bunniTokenState(IBunniToken bunniToken) external view override returns (BunniTokenState memory) {
        return _bunniTokenState[bunniToken];
    }

    /// -----------------------------------------------------------------------
    /// Uniswap callback
    /// -----------------------------------------------------------------------

    enum LockCallbackType {
        MODIFY_LIQUIDITY,
        HOOK_MODIFY_LIQUIDITY
    }

    function lockAcquired(bytes calldata data) external override returns (bytes memory) {
        // verify sender
        if (msg.sender != address(poolManager)) revert BunniHub__Unauthorized();

        // decode input
        (LockCallbackType t, bytes memory callbackData) = abi.decode(data, (LockCallbackType, bytes));

        // redirect to respective callback
        if (t == LockCallbackType.MODIFY_LIQUIDITY) {
            return abi.encode(_modifyLiquidityLockCallback(abi.decode(callbackData, (ModifyLiquidityInputData))));
        } else if (t == LockCallbackType.HOOK_MODIFY_LIQUIDITY) {
            _hookModifyLiquidityLockCallback(abi.decode(callbackData, (HookCallbackInputData)));
        }
        // fallback
        return bytes("");
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
        uint256 reserveAmount0;
        uint256 reserveAmount1;
        address user;
        bool isDeposit;
    }

    struct ModifyLiquidityReturnData {
        uint256 amount0;
        uint256 amount1;
    }

    function _modifyLiquidityLockCallback(ModifyLiquidityInputData memory input)
        internal
        returns (ModifyLiquidityReturnData memory returnData)
    {
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

        if (input.isDeposit) {
            // deposit
            uint256 payAmount0;
            uint256 payAmount1;

            // we owe uniswap tokens
            (result0, result1) = (uint256(uint128(amount0)), uint256(uint128(amount1)));
            payAmount0 += result0;
            payAmount1 += result1;

            // deposit tokens into PoolManager
            if (input.reserveAmount0 != 0) {
                payAmount0 += input.reserveAmount0;
                poolManager.mint(input.poolKey.currency0, address(this), input.reserveAmount0);
            }
            if (input.reserveAmount1 != 0) {
                payAmount1 += input.reserveAmount1;
                poolManager.mint(input.poolKey.currency1, address(this), input.reserveAmount1);
            }

            // settle currencies
            if (payAmount0 != 0) {
                _pay(Currency.unwrap(input.poolKey.currency0), input.user, address(poolManager), payAmount0);
                poolManager.settle(input.poolKey.currency0);
            }
            if (payAmount1 != 0) {
                _pay(Currency.unwrap(input.poolKey.currency1), input.user, address(poolManager), payAmount1);
                poolManager.settle(input.poolKey.currency1);
            }
        } else {
            // withdraw
            uint256 takeAmount0;
            uint256 takeAmount1;

            // uniswap owes us tokens
            (result0, result1) = (uint256(uint128(-amount0)), uint256(uint128(-amount1)));
            takeAmount0 += result0;
            takeAmount1 += result1;

            // withdraw tokens from PoolManager
            if (input.reserveAmount0 != 0 && input.reserveAmount1 != 0) {
                uint256[] memory ids = new uint256[](2);
                ids[0] = input.poolKey.currency0.toId();
                ids[1] = input.poolKey.currency1.toId();
                uint256[] memory amounts = new uint256[](2);
                amounts[0] = input.reserveAmount0;
                amounts[1] = input.reserveAmount1;
                poolManager.safeBatchTransferFrom(address(this), address(poolManager), ids, amounts, bytes(""));
                takeAmount0 += input.reserveAmount0;
                takeAmount1 += input.reserveAmount1;
            } else if (input.reserveAmount0 != 0) {
                poolManager.safeTransferFrom(
                    address(this), address(poolManager), input.poolKey.currency0.toId(), input.reserveAmount0, bytes("")
                );
                takeAmount0 += input.reserveAmount0;
            } else if (input.reserveAmount1 != 0) {
                poolManager.safeTransferFrom(
                    address(this), address(poolManager), input.poolKey.currency1.toId(), input.reserveAmount1, bytes("")
                );
                takeAmount1 += input.reserveAmount1;
            }

            // settle currencies
            if (takeAmount0 != 0) {
                poolManager.take(input.poolKey.currency0, input.user, takeAmount0);
            }
            if (takeAmount1 != 0) {
                poolManager.take(input.poolKey.currency1, input.user, takeAmount1);
            }
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
                existingShareSupply.mulDiv(addedAmount0, existingAmount0),
                existingShareSupply.mulDiv(addedAmount1, existingAmount1)
            );
            if (shares == 0) revert BunniHub__ZeroSharesMinted();
        }

        // mint shares to sender
        shareToken.mint(recipient, shares);
    }

    struct HookCallbackInputData {
        IBunniToken bunniToken;
        BunniTokenState state;
        PoolId poolId;
        bool compound;
        LiquidityDelta[] liquidityDeltas;
    }

    /// @dev Adds liquidity using a pool's reserves. Expected to be called by the pool's hook.
    function _hookModifyLiquidityLockCallback(HookCallbackInputData memory data) internal {
        // compound fees
        // we do this after every swap (assuming hook is honest)
        // which means it's not necessary to compound before/after depositing/withdrawing
        if (data.compound) {
            (, int24 currentTick,,,,) = poolManager.getSlot0(data.poolId);
            (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, data.state.poolKey.tickSpacing);
            // TODO: settle compounded amounts by minting ERC-1155
            (uint256 compoundAmount0, uint256 compoundAmount1) =
                _compound(data.state.poolKey, roundedTick, nextRoundedTick);

            // emit event
            emit Compound(data.bunniToken, compoundAmount0, compoundAmount1);
        }

        // modify the liquidity of all specified ticks
        uint256 numTicks = data.liquidityDeltas.length;
        (uint128 initialReserve0, uint128 initialReserve1) = (data.state.reserve0, data.state.reserve1);
        for (uint256 i; i < numTicks;) {
            BalanceDelta balanceDelta = poolManager.modifyPosition(
                data.state.poolKey,
                IPoolManager.ModifyPositionParams({
                    tickLower: data.liquidityDeltas[i].tickLower,
                    tickUpper: data.liquidityDeltas[i].tickLower + data.state.poolKey.tickSpacing,
                    liquidityDelta: data.liquidityDeltas[i].delta
                })
            );

            // update pool reserves
            // this prevents malicious hooks from adding liquidity using other pools' reserves
            if (data.liquidityDeltas[i].delta > 0) {
                data.state.reserve0 -= int256(balanceDelta.amount0()).toUint256().toUint128();
                data.state.reserve1 -= int256(balanceDelta.amount1()).toUint256().toUint128();
            } else if (data.liquidityDeltas[i].delta < 0) {
                data.state.reserve0 += int256(balanceDelta.amount0()).toUint256().toUint128();
                data.state.reserve1 += int256(balanceDelta.amount1()).toUint256().toUint128();
            }

            unchecked {
                ++i;
            }
        }

        // store updated pool reserves
        _bunniTokenState[data.bunniToken].reserve0 = data.state.reserve0;
        _bunniTokenState[data.bunniToken].reserve1 = data.state.reserve1;

        // cannot have positive balance of one currency and negative balance of the other
        // since we either add or remove liquidity
        if (initialReserve0 > data.state.reserve0 && initialReserve1 > data.state.reserve1) {
            // batch transfer ERC1155 tokens to PoolManager to settle debts
            uint256[] memory ids = new uint256[](2);
            ids[0] = data.state.poolKey.currency0.toId();
            ids[1] = data.state.poolKey.currency1.toId();
            uint256[] memory amounts = new uint256[](2);
            amounts[0] = initialReserve0 - data.state.reserve0;
            amounts[1] = initialReserve1 - data.state.reserve1;
            poolManager.safeBatchTransferFrom(address(this), address(poolManager), ids, amounts, bytes(""));
        } else if (initialReserve0 > data.state.reserve0) {
            // transfer ERC1155 tokens to PoolManager to settle debts
            poolManager.safeTransferFrom(
                address(this),
                address(poolManager),
                data.state.poolKey.currency0.toId(),
                initialReserve0 - data.state.reserve0,
                bytes("")
            );
        } else if (initialReserve1 > data.state.reserve1) {
            // transfer ERC1155 tokens to PoolManager to settle debts
            poolManager.safeTransferFrom(
                address(this),
                address(poolManager),
                data.state.poolKey.currency1.toId(),
                initialReserve1 - data.state.reserve1,
                bytes("")
            );
        } else {
            // mint ERC1155 tokens for new reserves
            if (initialReserve0 < data.state.reserve0) {
                poolManager.mint(data.state.poolKey.currency0, address(this), data.state.reserve0 - initialReserve0);
            }
            if (initialReserve1 < data.state.reserve1) {
                poolManager.mint(data.state.poolKey.currency1, address(this), data.state.reserve1 - initialReserve1);
            }
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
        if (address(state.liquidityDensityFunction) == address(0)) revert BunniHub__BunniTokenNotInitialized();
        poolId = state.poolKey.toId();
    }
}
