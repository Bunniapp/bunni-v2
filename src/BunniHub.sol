// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import "forge-std/console2.sol";

import "@uniswap/v4-core/contracts/types/BalanceDelta.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v4-core/contracts/libraries/FullMath.sol";
import {FeeLibrary} from "@uniswap/v4-core/contracts/libraries/FeeLibrary.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {FixedPoint96} from "@uniswap/v4-core/contracts/libraries/FixedPoint96.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {ILockCallback} from "@uniswap/v4-core/contracts/interfaces/callback/ILockCallback.sol";

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
contract BunniHub is IBunniHub, Multicall, ERC1155TokenReceiver {
    using FullMath for uint128;
    using FullMath for uint256;
    using SafeCastLib for int256;
    using SafeCastLib for uint256;
    using PoolIdLibrary for PoolKey;
    using SafeTransferLib for IERC20;
    using SafeTransferLib for address;
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
    error BunniHub__InvalidLDFParams();
    error BunniHub__InvalidFeeParams();
    error BunniHub__PoolKeyDoesNotMatchId();
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
        payable
        virtual
        override
        checkDeadline(params.deadline)
        returns (uint256 shares, uint128 addedLiquidity, uint256 amount0, uint256 amount1)
    {
        BunniTokenState memory state = _getStateOfBunniToken(params.bunniToken);
        if (PoolId.unwrap(params.poolKey.toId()) != PoolId.unwrap(state.poolId)) {
            revert BunniHub__PoolKeyDoesNotMatchId();
        }

        // update TWAP oracle and optionally observe
        BunniHook hook = BunniHook(address(params.poolKey.hooks));
        (uint160 sqrtPriceX96, int24 currentTick,,) = poolManager.getSlot0(state.poolId);
        (bool useTwap,, uint24 twapSecondsAgo, bytes11 decodedLDFParams) = decodeLDFParams(state.ldfParams);
        int24 arithmeticMeanTick = hook.updateOracleAndObserve(state.poolId, useTwap, currentTick, twapSecondsAgo);

        // compute sqrt ratios
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, params.poolKey.tickSpacing);
        (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
            (TickMath.getSqrtRatioAtTick(roundedTick), TickMath.getSqrtRatioAtTick(nextRoundedTick));

        // compute density
        (
            uint256 liquidityDensityOfRoundedTickX96,
            uint256 density0RightOfRoundedTickX96,
            uint256 density1LeftOfRoundedTickX96
        ) = state.liquidityDensityFunction.query(
            roundedTick, arithmeticMeanTick, params.poolKey.tickSpacing, useTwap, decodedLDFParams
        );
        (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96,
            roundedTickSqrtRatio,
            nextRoundedTickSqrtRatio,
            uint128(liquidityDensityOfRoundedTickX96),
            false
        );

        // compute how much liquidity we'd get from the desired token amounts
        uint256 totalLiquidity = min(
            params.amount0Desired.mulDiv(Q96, density0RightOfRoundedTickX96 + density0OfRoundedTickX96),
            params.amount1Desired.mulDiv(Q96, density1LeftOfRoundedTickX96 + density1OfRoundedTickX96)
        );
        // totalLiquidity could exceed uint128 so .toUint128() is used
        addedLiquidity = ((totalLiquidity * liquidityDensityOfRoundedTickX96) >> 96).toUint128();

        // compute token amounts
        (uint256 roundedTickAmount0, uint256 roundedTickAmount1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, addedLiquidity, true
        );
        (uint256 depositAmount0, uint256 depositAmount1) = (
            totalLiquidity.mulDivRoundingUp(density0RightOfRoundedTickX96, Q96),
            totalLiquidity.mulDivRoundingUp(density1LeftOfRoundedTickX96, Q96)
        );
        (amount0, amount1) = (roundedTickAmount0 + depositAmount0, roundedTickAmount1 + depositAmount1);

        // sanity check against desired amounts
        if ((amount0 > params.amount0Desired) || (amount1 > params.amount1Desired)) {
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
            } else if (amount0 > params.amount0Desired) {
                // scale down amounts based on amount0
                (amount0, amount1, addedLiquidity) = (
                    params.amount0Desired,
                    amount1.mulDiv(params.amount0Desired, amount0),
                    uint128(addedLiquidity.mulDivDown(params.amount0Desired, amount0))
                );
            } /* else if (amount1 > params.amount1Desired) */ else {
                // scale down amounts based on amount1
                (amount0, amount1, addedLiquidity) = (
                    amount0.mulDiv(params.amount1Desired, amount1),
                    params.amount1Desired,
                    uint128(addedLiquidity.mulDivDown(params.amount1Desired, amount1))
                );
            }

            // update token amounts
            (roundedTickAmount0, roundedTickAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, addedLiquidity, true
            );
            (depositAmount0, depositAmount1) = (amount0 - roundedTickAmount0, amount1 - roundedTickAmount1);
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // mint shares
        uint128 currentLiquidity = poolManager.getLiquidity(state.poolId);
        (uint256 existingAmount0, uint256 existingAmount1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, currentLiquidity, false
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
        _bunniTokenState[params.bunniToken].reserve0 = state.reserve0 + depositAmount0;
        _bunniTokenState[params.bunniToken].reserve1 = state.reserve1 + depositAmount1;

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // add liquidity and reserves
        poolManager.lock(
            abi.encode(
                LockCallbackType.MODIFY_LIQUIDITY,
                abi.encode(
                    ModifyLiquidityInputData({
                        poolKey: params.poolKey,
                        tickLower: roundedTick,
                        tickUpper: nextRoundedTick,
                        liquidityDelta: uint256(addedLiquidity).toInt256(),
                        user: msg.sender,
                        reserveDelta: toBalanceDelta(
                            depositAmount0.toInt256().toInt128(), depositAmount1.toInt256().toInt128()
                            ),
                        currentLiquidity: currentLiquidity
                    })
                )
            )
        );
        if (amount0 < params.amount0Min || amount1 < params.amount1Min) {
            revert BunniHub__SlippageTooHigh();
        }

        // refund excess ETH
        // Note: since we transfer the entire balance, multicalls can only contain a single
        // deposit() call that uses ETH.
        if (address(this).balance != 0) {
            payable(msg.sender).transfer(address(this).balance);
        }

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

        BunniTokenState memory state = _getStateOfBunniToken(params.bunniToken);
        if (PoolId.unwrap(params.poolKey.toId()) != PoolId.unwrap(state.poolId)) {
            revert BunniHub__PoolKeyDoesNotMatchId();
        }

        uint256 currentTotalSupply = params.bunniToken.totalSupply();
        (, int24 currentTick,,) = poolManager.getSlot0(state.poolId);
        uint128 existingLiquidity = poolManager.getLiquidity(state.poolId);

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

        // update reserves
        // reserves represent the amount of tokens not in the current tick
        uint256 removedReserve0 = state.reserve0.mulDiv(params.shares, currentTotalSupply);
        uint256 removedReserve1 = state.reserve1.mulDiv(params.shares, currentTotalSupply);
        _bunniTokenState[params.bunniToken].reserve0 = state.reserve0 - removedReserve0;
        _bunniTokenState[params.bunniToken].reserve1 = state.reserve1 - removedReserve1;

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // burn liquidity and withdraw reserves
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, params.poolKey.tickSpacing);
        ModifyLiquidityReturnData memory returnData = abi.decode(
            poolManager.lock(
                abi.encode(
                    LockCallbackType.MODIFY_LIQUIDITY,
                    abi.encode(
                        ModifyLiquidityInputData({
                            poolKey: params.poolKey,
                            tickLower: roundedTick,
                            tickUpper: nextRoundedTick,
                            liquidityDelta: -uint256(removedLiquidity).toInt256(),
                            user: msg.sender,
                            reserveDelta: toBalanceDelta(
                                -removedReserve0.toInt256().toInt128(), -removedReserve1.toInt256().toInt128()
                                ),
                            currentLiquidity: existingLiquidity
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
        uint24 feeMin,
        uint24 feeMax,
        uint24 feeQuadraticMultiplier,
        uint24 feeTwapSecondsAgo,
        IHooks hooks,
        uint160 sqrtPriceX96
    ) external override returns (IBunniToken token, PoolKey memory key) {
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

        {
            (bool useTwap,, uint24 twapSecondsAgo,) = decodeLDFParams(ldfParams);
            if (useTwap && twapSecondsAgo == 0) revert BunniHub__InvalidLDFParams();
        }

        if (
            feeMin > feeMax || feeMin > 1e6 || feeMax > 1e6
                || (feeTwapSecondsAgo == 0 && feeMin != feeMax && feeQuadraticMultiplier != 0)
        ) revert BunniHub__InvalidFeeParams();

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
        key = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: uint24(0xC00000) + nonce_, // top nibble is 1100 to enable dynamic fee & hook swap fee, bottom 20 bits are the nonce
            tickSpacing: tickSpacing,
            hooks: hooks
        });
        _bunniTokenState[token] = BunniTokenState({
            poolId: key.toId(),
            liquidityDensityFunction: liquidityDensityFunction,
            ldfParams: ldfParams,
            feeMin: feeMin,
            feeMax: feeMax,
            feeQuadraticMultiplier: feeQuadraticMultiplier,
            feeTwapSecondsAgo: feeTwapSecondsAgo,
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
        poolManager.initialize(key, sqrtPriceX96, bytes(""));

        emit NewBunni(token, poolId);
    }

    /// @inheritdoc IBunniHub
    function hookModifyLiquidity(
        PoolKey calldata poolKey,
        IBunniToken bunniToken,
        LiquidityDelta[] calldata liquidityDeltas
    ) external override {
        BunniTokenState memory state = _getStateOfBunniToken(bunniToken);
        if (PoolId.unwrap(poolKey.toId()) != PoolId.unwrap(state.poolId)) {
            revert BunniHub__PoolKeyDoesNotMatchId();
        }
        if (msg.sender != address(poolKey.hooks)) revert BunniHub__Unauthorized(); // only hook

        poolManager.lock(
            abi.encode(
                LockCallbackType.HOOK_MODIFY_LIQUIDITY,
                abi.encode(
                    HookCallbackInputData({
                        poolKey: poolKey,
                        bunniToken: bunniToken,
                        state: state,
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

    /// @param state The state associated with the Bunni token
    /// @param liquidityDelta The amount of liquidity to add/subtract
    /// @param user The address to pay/receive the tokens
    struct ModifyLiquidityInputData {
        PoolKey poolKey;
        int24 tickLower;
        int24 tickUpper;
        int256 liquidityDelta;
        BalanceDelta reserveDelta;
        uint128 currentLiquidity;
        address user;
    }

    struct ModifyLiquidityReturnData {
        uint256 amount0;
        uint256 amount1;
    }

    function _modifyLiquidityLockCallback(ModifyLiquidityInputData memory input)
        internal
        returns (ModifyLiquidityReturnData memory returnData)
    {
        // compound fees into reserve
        IPoolManager.ModifyPositionParams memory params;
        params.tickLower = input.tickLower;
        params.tickUpper = input.tickUpper;
        BalanceDelta poolTokenDelta = input.reserveDelta;
        if (input.currentLiquidity != 0) {
            // negate pool delta to get fees owed
            BalanceDelta feeDelta = BalanceDelta.wrap(0) - poolManager.modifyPosition(input.poolKey, params, bytes(""));

            // add fees to the amount of pool tokens to mint/burn
            poolTokenDelta = poolTokenDelta + feeDelta;

            // emit event
            emit Compound(input.poolKey.toId(), feeDelta);
        }

        // update liquidity
        params.liquidityDelta = input.liquidityDelta;
        BalanceDelta delta = poolManager.modifyPosition(input.poolKey, params, bytes(""));

        // amount of tokens to pay/take
        BalanceDelta settleDelta = input.reserveDelta + delta;

        // mint/burn pool tokens
        _updatePoolTokens(input.poolKey.currency0, input.poolKey.currency1, poolTokenDelta);

        // settle currency payments to zero out delta with PoolManager
        _settleCurrencies(input.user, input.poolKey.currency0, input.poolKey.currency1, settleDelta);

        (returnData.amount0, returnData.amount1) = (abs(delta.amount0()), abs(delta.amount1()));
    }

    struct HookCallbackInputData {
        PoolKey poolKey;
        IBunniToken bunniToken;
        BunniTokenState state;
        LiquidityDelta[] liquidityDeltas;
    }

    /// @dev Adds liquidity using a pool's reserves. Expected to be called by the pool's hook.
    function _hookModifyLiquidityLockCallback(HookCallbackInputData memory data) internal {
        (uint256 initialReserve0, uint256 initialReserve1) = (data.state.reserve0, data.state.reserve1);

        IPoolManager.ModifyPositionParams memory params;

        // modify the liquidity of all specified ticks
        {
            uint256 numTicks = data.liquidityDeltas.length;
            for (uint256 i; i < numTicks;) {
                params.tickLower = data.liquidityDeltas[i].tickLower;
                params.tickUpper = data.liquidityDeltas[i].tickLower + data.poolKey.tickSpacing;
                params.liquidityDelta = data.liquidityDeltas[i].delta;

                BalanceDelta balanceDelta = poolManager.modifyPosition(data.poolKey, params, bytes(""));

                // update pool reserves
                // this prevents malicious hooks from adding liquidity using other pools' reserves
                (int128 amount0, int128 amount1) = (balanceDelta.amount0(), balanceDelta.amount1());
                if (amount0 > 0) {
                    data.state.reserve0 -= uint128(amount0);
                } else if (amount0 < 0) {
                    data.state.reserve0 += uint128(-amount0);
                }
                if (amount1 > 0) {
                    data.state.reserve1 -= uint128(amount1);
                } else if (amount1 < 0) {
                    data.state.reserve1 += uint128(-amount1);
                }

                unchecked {
                    ++i;
                }
            }
        }

        // store updated pool reserves
        _bunniTokenState[data.bunniToken].reserve0 = data.state.reserve0;
        _bunniTokenState[data.bunniToken].reserve1 = data.state.reserve1;

        _updatePoolToken(data.poolKey.currency0, data.state.reserve0.toInt256() - initialReserve0.toInt256());
        _updatePoolToken(data.poolKey.currency1, data.state.reserve1.toInt256() - initialReserve1.toInt256());
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function _pay(Currency token, address payer, address recipient, uint256 value) internal {
        if (token.isNative()) {
            recipient.safeTransferETH(value);
        } else {
            IERC20(Currency.unwrap(token)).safeTransferFrom(payer, recipient, value);
        }
    }

    function _getStateOfBunniToken(IBunniToken bunniToken) internal view returns (BunniTokenState memory state) {
        state = _bunniTokenState[bunniToken];
        if (address(state.liquidityDensityFunction) == address(0)) revert BunniHub__BunniTokenNotInitialized();
    }

    function _updatePoolTokens(Currency currency0, Currency currency1, BalanceDelta delta) internal {
        _updatePoolToken(currency0, delta.amount0());
        _updatePoolToken(currency1, delta.amount1());
    }

    function _updatePoolToken(Currency currency, int256 amount) internal {
        if (amount > 0) {
            poolManager.mint(currency, address(this), uint256(amount));
        } else if (amount < 0) {
            poolManager.safeTransferFrom(
                address(this), address(poolManager), currency.toId(), uint256(-amount), bytes("")
            );
        }
    }

    function _settleCurrency(address user, Currency currency, int256 amount) internal {
        if (amount > 0) {
            _pay(currency, user, address(poolManager), uint256(amount));
            poolManager.settle(currency);
        } else if (amount < 0) {
            poolManager.take(currency, user, uint256(-amount));
        }
    }

    function _settleCurrencies(address user, Currency currency0, Currency currency1, BalanceDelta delta) internal {
        _settleCurrency(user, currency0, delta.amount0());
        _settleCurrency(user, currency1, delta.amount1());
    }
}
