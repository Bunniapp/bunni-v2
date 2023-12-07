// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.19;

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import "@uniswap/v4-core/src/types/BalanceDelta.sol";
import "@uniswap/v4-core/src/libraries/SqrtPriceMath.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {FeeLibrary} from "@uniswap/v4-core/src/libraries/FeeLibrary.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {FixedPoint96} from "@uniswap/v4-core/src/libraries/FixedPoint96.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {ILockCallback} from "@uniswap/v4-core/src/interfaces/callback/ILockCallback.sol";

import {CREATE3} from "solady/src/utils/CREATE3.sol";
import {SSTORE2} from "solady/src/utils/SSTORE2.sol";
import {SafeCastLib} from "solady/src/utils/SafeCastLib.sol";

import {WETH} from "solmate/tokens/WETH.sol";
import {ERC1155TokenReceiver} from "solmate/tokens/ERC1155.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

import "./lib/Math.sol";
import "./lib/Structs.sol";
import "./lib/VaultMath.sol";
import {BunniToken} from "./BunniToken.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {Multicallable} from "./lib/Multicallable.sol";
import {IBunniHook} from "./interfaces/IBunniHook.sol";
import {Permit2Enabled} from "./lib/Permit2Enabled.sol";
import {IBunniToken} from "./interfaces/IBunniToken.sol";
import {SafeTransferLib} from "./lib/SafeTransferLib.sol";
import {ReentrancyGuard} from "./lib/ReentrancyGuard.sol";
import {LiquidityAmounts} from "./lib/LiquidityAmounts.sol";
import {IBunniHub, ILiquidityDensityFunction} from "./interfaces/IBunniHub.sol";

/// @title BunniHub
/// @author zefram.eth
/// @notice The main contract LPs interact with. Each BunniKey corresponds to a BunniToken,
/// which is the ERC20 LP token for the Uniswap V4 position specified by the BunniKey.
/// Use deposit()/withdraw() to mint/burn LP tokens, and use compound() to compound the swap fees
/// back into the LP position.
contract BunniHub is IBunniHub, Multicallable, ERC1155TokenReceiver, Permit2Enabled {
    using SSTORE2 for bytes;
    using SSTORE2 for address;
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
    error BunniHub__HookCannotBeZero();
    error BunniHub__ZeroSharesMinted();
    error BunniHub__InvalidLDFParams();
    error BunniHub__InvalidHookParams();
    error BunniHub__VaultAssetMismatch();
    error BunniHub__BunniTokenNotInitialized();

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
        PoolId poolId = params.poolKey.toId();
        PoolState memory state = _getPoolState(poolId);

        (uint160 sqrtPriceX96, int24 currentTick,,) = poolManager.getSlot0(poolId);
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, params.poolKey.tickSpacing);

        uint128 currentLiquidity = poolManager.getLiquidity(poolId);
        DepositLogicReturnData memory depositReturnData = _depositLogic(
            DepositLogicInputData({
                state: state,
                params: params,
                poolId: poolId,
                currentTick: currentTick,
                currentLiquidity: currentLiquidity,
                sqrtPriceX96: sqrtPriceX96,
                roundedTick: roundedTick,
                nextRoundedTick: nextRoundedTick
            })
        );
        addedLiquidity = depositReturnData.addedLiquidity;
        uint256 depositAmount0 = depositReturnData.depositAmount0;
        uint256 depositAmount1 = depositReturnData.depositAmount1;
        amount0 = depositReturnData.amount0;
        amount1 = depositReturnData.amount1;
        shares = depositReturnData.shares;

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // add liquidity and reserves
        BalanceDelta reserveDeltaInUnderlying =
            toBalanceDelta(depositAmount0.toInt256().toInt128(), depositAmount1.toInt256().toInt128());
        ModifyLiquidityInputData memory inputData = ModifyLiquidityInputData({
            poolKey: params.poolKey,
            tickLower: roundedTick,
            tickUpper: nextRoundedTick,
            liquidityDelta: uint256(addedLiquidity).toInt256(),
            user: msg.sender,
            reserveDeltaInUnderlying: reserveDeltaInUnderlying,
            currentLiquidity: currentLiquidity,
            vault0: state.vault0,
            vault1: state.vault1
        });
        ModifyLiquidityReturnData memory returnData = abi.decode(
            poolManager.lock(address(this), abi.encode(LockCallbackType.MODIFY_LIQUIDITY, abi.encode(inputData))),
            (ModifyLiquidityReturnData)
        );
        if (amount0 < params.amount0Min || amount1 < params.amount1Min) {
            revert BunniHub__SlippageTooHigh();
        }

        // update reserves
        // reserves represent the amount of tokens not in the current tick
        _poolState[poolId].reserve0 = (state.reserve0.toInt256() + returnData.reserveChange0).toUint256();
        _poolState[poolId].reserve1 = (state.reserve1.toInt256() + returnData.reserveChange1).toUint256();

        // refund excess ETH
        if (params.refundETH && address(this).balance != 0) {
            payable(msg.sender).transfer(address(this).balance);
        }

        // emit event
        emit Deposit(msg.sender, params.recipient, poolId, amount0, amount1, shares);
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
        /// -----------------------------------------------------------------------
        /// Validation
        /// -----------------------------------------------------------------------

        if (params.shares == 0) revert BunniHub__ZeroInput();

        PoolId poolId = params.poolKey.toId();
        PoolState memory state = _getPoolState(poolId);

        uint256 currentTotalSupply = state.bunniToken.totalSupply();
        (, int24 currentTick,,) = poolManager.getSlot0(poolId);
        uint128 existingLiquidity = poolManager.getLiquidity(poolId);

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // burn shares
        state.bunniToken.burn(msg.sender, params.shares);
        // at this point of execution we know params.shares <= currentTotalSupply
        // since otherwise the burn() call would've reverted

        // burn liquidity from pool
        // type cast is safe because we know removedLiquidity <= existingLiquidity
        removedLiquidity = uint128(existingLiquidity.mulDivDown(params.shares, currentTotalSupply));

        uint256 removedReserve0InUnderlying =
            getReservesInUnderlying(state.reserve0.mulDivDown(params.shares, currentTotalSupply), state.vault0);
        uint256 removedReserve1InUnderlying =
            getReservesInUnderlying(state.reserve1.mulDivDown(params.shares, currentTotalSupply), state.vault1);
        if (state.poolCredit0Set) {
            removedReserve0InUnderlying += poolCredit0[poolId].mulDivDown(params.shares, currentTotalSupply);
        }
        if (state.poolCredit1Set) {
            removedReserve1InUnderlying += poolCredit1[poolId].mulDivDown(params.shares, currentTotalSupply);
        }

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // burn liquidity and withdraw reserves
        (int24 roundedTick, int24 nextRoundedTick) = roundTick(currentTick, params.poolKey.tickSpacing);
        BalanceDelta reserveDeltaInUnderlying = toBalanceDelta(
            -removedReserve0InUnderlying.toInt256().toInt128(), -removedReserve1InUnderlying.toInt256().toInt128()
        );
        ModifyLiquidityInputData memory inputData = ModifyLiquidityInputData({
            poolKey: params.poolKey,
            tickLower: roundedTick,
            tickUpper: nextRoundedTick,
            liquidityDelta: -uint256(removedLiquidity).toInt256(),
            user: msg.sender,
            reserveDeltaInUnderlying: reserveDeltaInUnderlying,
            currentLiquidity: existingLiquidity,
            vault0: state.vault0,
            vault1: state.vault1
        });

        ModifyLiquidityReturnData memory returnData = abi.decode(
            poolManager.lock(address(this), abi.encode(LockCallbackType.MODIFY_LIQUIDITY, abi.encode(inputData))),
            (ModifyLiquidityReturnData)
        );
        (amount0, amount1) =
            (returnData.amount0 + removedReserve0InUnderlying, returnData.amount1 + removedReserve1InUnderlying);
        if (amount0 < params.amount0Min || amount1 < params.amount1Min) {
            revert BunniHub__SlippageTooHigh();
        }

        // update reserves
        // reserves represent the amount of tokens not in the current tick
        _poolState[poolId].reserve0 = (state.reserve0.toInt256() + returnData.reserveChange0).toUint256();
        _poolState[poolId].reserve1 = (state.reserve1.toInt256() + returnData.reserveChange1).toUint256();

        emit Withdraw(msg.sender, params.recipient, poolId, amount0, amount1, params.shares);
    }

    /// @inheritdoc IBunniHub
    function deployBunniToken(DeployBunniTokenParams calldata params)
        external
        override
        nonReentrant
        returns (IBunniToken token, PoolKey memory key)
    {
        /// -----------------------------------------------------------------------
        /// Verification
        /// -----------------------------------------------------------------------

        // each Uniswap v4 pool corresponds to a single BunniToken
        // since Univ4 pool key is deterministic based on poolKey, we use dynamic fee so that the lower 20 bits of `poolKey.fee` is used
        // as nonce to differentiate the BunniTokens
        // each "subspace" has its own nonce that's incremented whenever a BunniToken is deployed with the same tokens & tick spacing & hooks
        // nonce can be at most 2^20 - 1 = 1048575 after which the deployment will fail
        bytes32 bunniSubspace =
            keccak256(abi.encode(params.currency0, params.currency1, params.tickSpacing, params.hooks));
        uint24 nonce_ = nonce[bunniSubspace];
        if (nonce_ + 1 > MAX_NONCE) revert BunniHub__MaxNonceReached();

        // ensure LDF params are valid
        if (address(params.liquidityDensityFunction) == address(0)) revert BunniHub__LDFCannotBeZero();
        if (!params.liquidityDensityFunction.isValidParams(params.tickSpacing, params.twapSecondsAgo, params.ldfParams))
        {
            revert BunniHub__InvalidLDFParams();
        }

        // ensure hook params are valid
        if (address(params.hooks) == address(0)) revert BunniHub__HookCannotBeZero();
        if (!params.hooks.isValidParams(params.hookParams)) revert BunniHub__InvalidHookParams();

        // validate vaults
        _validateVault(params.vault0, params.currency0);
        _validateVault(params.vault1, params.currency1);

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // deploy BunniToken
        token = IBunniToken(
            CREATE3.deploy(
                keccak256(abi.encode(bunniSubspace, nonce_)),
                abi.encodePacked(type(BunniToken).creationCode, abi.encode(this, params.currency0, params.currency1)),
                0
            )
        );

        key = PoolKey({
            currency0: params.currency0,
            currency1: params.currency1,
            fee: uint24(0xC00000) + nonce_, // top nibble is 1100 to enable dynamic fee & hook swap fee, bottom 20 bits are the nonce
            tickSpacing: params.tickSpacing,
            hooks: params.hooks
        });
        PoolId poolId = key.toId();
        poolIdOfBunniToken[token] = poolId;

        // increment nonce
        nonce[bunniSubspace] = nonce_ + 1;

        // set immutable params
        _poolState[poolId].immutableParamsPointer = abi.encodePacked(
            params.liquidityDensityFunction,
            token,
            params.twapSecondsAgo,
            params.ldfParams,
            params.hookParams,
            params.vault0,
            params.vault1
        ).write();

        /// -----------------------------------------------------------------------
        /// External calls
        /// -----------------------------------------------------------------------

        // initialize Uniswap v4 pool
        poolManager.lock(
            address(this), abi.encode(LockCallbackType.INITIALIZE_POOL, abi.encode(key, params.sqrtPriceX96))
        );

        // initialize cardinality target
        if (params.cardinalityNext != 0) {
            params.hooks.increaseCardinalityNext(key, params.cardinalityNext);
        }

        emit NewBunni(token, poolId);
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
            (PoolKey memory key, uint160 sqrtPriceX96) = abi.decode(callbackData, (PoolKey, uint160));
            _initializePoolLockCallback(key, sqrtPriceX96);
        }
        // fallback
        return bytes("");
    }

    /// -----------------------------------------------------------
    /// Internal functions
    /// -----------------------------------------------------------

    struct DepositLogicInputData {
        PoolState state;
        DepositParams params;
        PoolId poolId;
        int24 currentTick;
        uint128 currentLiquidity;
        uint160 sqrtPriceX96;
        int24 roundedTick;
        int24 nextRoundedTick;
    }

    struct DepositLogicReturnData {
        uint128 addedLiquidity;
        uint256 depositAmount0;
        uint256 depositAmount1;
        uint256 amount0;
        uint256 amount1;
        uint256 shares;
    }

    /// @dev Separated to avoid stack too deep error
    function _depositLogic(DepositLogicInputData memory inputData)
        internal
        returns (DepositLogicReturnData memory returnData)
    {
        (uint160 roundedTickSqrtRatio, uint160 nextRoundedTickSqrtRatio) =
            (TickMath.getSqrtRatioAtTick(inputData.roundedTick), TickMath.getSqrtRatioAtTick(inputData.nextRoundedTick));

        // query existing assets
        // assets = urrent tick tokens + reserve tokens + pool credits
        (uint256 existingAmount0, uint256 existingAmount1) = LiquidityAmounts.getAmountsForLiquidity(
            inputData.sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, inputData.currentLiquidity, false
        );
        (uint256 assets0, uint256 assets1) = (
            existingAmount0 + getReservesInUnderlying(inputData.state.reserve0, inputData.state.vault0),
            existingAmount1 + getReservesInUnderlying(inputData.state.reserve1, inputData.state.vault1)
        );
        if (inputData.state.poolCredit0Set) {
            assets0 += poolCredit0[inputData.poolId];
        }
        if (inputData.state.poolCredit1Set) {
            assets1 += poolCredit1[inputData.poolId];
        }

        // update TWAP oracle and optionally observe
        int24 arithmeticMeanTick;
        bool requiresLDF = assets0 == 0 && assets1 == 0;
        {
            uint24 twapSecondsAgo = inputData.state.twapSecondsAgo;
            // we only need to observe the TWAP if currentTotalSupply is zero
            assembly ("memory-safe") {
                twapSecondsAgo := mul(twapSecondsAgo, requiresLDF)
            }
            arithmeticMeanTick = IBunniHook(address(inputData.params.poolKey.hooks)).updateOracleAndObserve(
                inputData.poolId, inputData.currentTick, twapSecondsAgo
            );
        }

        if (requiresLDF) {
            // use LDF to initialize token proportions

            // compute density
            bool useTwap = inputData.state.twapSecondsAgo != 0;
            (
                uint256 liquidityDensityOfRoundedTickX96,
                uint256 density0RightOfRoundedTickX96,
                uint256 density1LeftOfRoundedTickX96
            ) = inputData.state.liquidityDensityFunction.query(
                inputData.params.poolKey,
                inputData.roundedTick,
                arithmeticMeanTick,
                inputData.currentTick,
                inputData.params.poolKey.tickSpacing,
                useTwap,
                inputData.state.ldfParams
            );
            (uint256 density0OfRoundedTickX96, uint256 density1OfRoundedTickX96) = LiquidityAmounts
                .getAmountsForLiquidity(
                inputData.sqrtPriceX96,
                roundedTickSqrtRatio,
                nextRoundedTickSqrtRatio,
                uint128(liquidityDensityOfRoundedTickX96),
                false
            );

            // compute how much liquidity we'd get from the desired token amounts
            uint256 totalLiquidity = min(
                inputData.params.amount0Desired.mulDivDown(
                    Q96, density0RightOfRoundedTickX96 + density0OfRoundedTickX96
                ),
                inputData.params.amount1Desired.mulDivDown(Q96, density1LeftOfRoundedTickX96 + density1OfRoundedTickX96)
            );
            // totalLiquidity could exceed uint128 so .toUint128() is used
            returnData.addedLiquidity = ((totalLiquidity * liquidityDensityOfRoundedTickX96) >> 96).toUint128();

            // compute token amounts
            (uint256 addedLiquidityAmount0, uint256 addedLiquidityAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                inputData.sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, returnData.addedLiquidity, true
            );
            (returnData.depositAmount0, returnData.depositAmount1) = (
                totalLiquidity.mulDivUp(density0RightOfRoundedTickX96, Q96),
                totalLiquidity.mulDivUp(density1LeftOfRoundedTickX96, Q96)
            );
            (returnData.amount0, returnData.amount1) =
                (addedLiquidityAmount0 + returnData.depositAmount0, addedLiquidityAmount1 + returnData.depositAmount1);

            // sanity check against desired amounts
            // the amounts can exceed the desired amounts due to math errors
            if (
                (returnData.amount0 > inputData.params.amount0Desired)
                    || (returnData.amount1 > inputData.params.amount1Desired)
            ) {
                // scale down amounts and take minimum
                if (returnData.amount0 == 0) {
                    (returnData.amount1, returnData.addedLiquidity) = (
                        inputData.params.amount1Desired,
                        uint128(
                            returnData.addedLiquidity.mulDivDown(inputData.params.amount1Desired, returnData.amount1)
                            )
                    );
                } else if (returnData.amount1 == 0) {
                    (returnData.amount0, returnData.addedLiquidity) = (
                        inputData.params.amount0Desired,
                        uint128(
                            returnData.addedLiquidity.mulDivDown(inputData.params.amount0Desired, returnData.amount0)
                            )
                    );
                } else {
                    // both are non-zero
                    (returnData.amount0, returnData.amount1, returnData.addedLiquidity) = (
                        min(
                            inputData.params.amount0Desired,
                            returnData.amount0.mulDivDown(inputData.params.amount1Desired, returnData.amount1)
                            ),
                        min(
                            inputData.params.amount1Desired,
                            returnData.amount1.mulDivDown(inputData.params.amount0Desired, returnData.amount0)
                            ),
                        uint128(
                            min(
                                returnData.addedLiquidity.mulDivDown(
                                    inputData.params.amount0Desired, returnData.amount0
                                ),
                                returnData.addedLiquidity.mulDivDown(
                                    inputData.params.amount1Desired, returnData.amount1
                                )
                            )
                            )
                    );
                }

                // update token amounts
                (addedLiquidityAmount0, addedLiquidityAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                    inputData.sqrtPriceX96,
                    roundedTickSqrtRatio,
                    nextRoundedTickSqrtRatio,
                    returnData.addedLiquidity,
                    true
                );
                (returnData.depositAmount0, returnData.depositAmount1) =
                    (returnData.amount0 - addedLiquidityAmount0, returnData.amount1 - addedLiquidityAmount1);
            }
        } else {
            // already initialized liquidity shape
            // simply add tokens at the current ratio
            // need to update: addedLiquidity, depositAmount0, depositAmount1, amount0, amount1

            // compute amount0 and amount1 such that the ratio is the same as the current ratio
            returnData.amount0 = assets1 == 0
                ? inputData.params.amount0Desired
                : min(inputData.params.amount0Desired, inputData.params.amount1Desired.mulDivDown(assets0, assets1));
            returnData.amount1 = assets0 == 0
                ? inputData.params.amount1Desired
                : min(inputData.params.amount1Desired, inputData.params.amount0Desired.mulDivDown(assets1, assets0));

            // compute added liquidity using current liquidity
            returnData.addedLiquidity = inputData.currentLiquidity.mulDivDown(
                returnData.amount0 + returnData.amount1, assets0 + assets1
            ).toUint128();

            // remaining tokens will be deposited into the reserves
            (uint256 addedLiquidityAmount0, uint256 addedLiquidityAmount1) = LiquidityAmounts.getAmountsForLiquidity(
                inputData.sqrtPriceX96, roundedTickSqrtRatio, nextRoundedTickSqrtRatio, returnData.addedLiquidity, true
            );
            returnData.depositAmount0 = returnData.amount0 - addedLiquidityAmount0;
            returnData.depositAmount1 = returnData.amount1 - addedLiquidityAmount1;
        }

        /// -----------------------------------------------------------------------
        /// State updates
        /// -----------------------------------------------------------------------

        // mint shares
        returnData.shares = _mintShares(
            inputData.state.bunniToken,
            inputData.params.recipient,
            returnData.amount0,
            assets0,
            returnData.amount1,
            assets1
        );
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
            // given that the position may become single-sided, we need to handle the case where one of the existingAmount values is zero
            shares = min(
                existingAmount0 == 0 ? type(uint256).max : existingShareSupply.mulDivDown(addedAmount0, existingAmount0),
                existingAmount1 == 0 ? type(uint256).max : existingShareSupply.mulDivDown(addedAmount1, existingAmount1)
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
        BalanceDelta reserveDeltaInUnderlying;
        uint128 currentLiquidity;
        address user;
        ERC4626 vault0;
        ERC4626 vault1;
    }

    struct ModifyLiquidityReturnData {
        uint256 amount0;
        uint256 amount1;
        int256 reserveChange0;
        int256 reserveChange1;
    }

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
            BalanceDelta feeDelta = BalanceDelta.wrap(0) - poolManager.modifyPosition(input.poolKey, params, bytes(""));

            if (BalanceDelta.unwrap(feeDelta) != 0) {
                // add fees to the amount of pool tokens to mint/burn
                poolTokenDelta = poolTokenDelta + feeDelta;

                // emit event
                emit Compound(input.poolKey.toId(), feeDelta);
            }
        }

        // update liquidity
        params.liquidityDelta = input.liquidityDelta;
        BalanceDelta delta = poolManager.modifyPosition(input.poolKey, params, bytes(""));

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

    struct HookCallbackInputData {
        PoolKey poolKey;
        ERC4626 vault0;
        ERC4626 vault1;
        bool poolCredit0Set;
        bool poolCredit1Set;
        LiquidityDelta[] liquidityDeltas;
    }

    struct HookCallbackReturnData {
        int256 reserveChange0;
        int256 reserveChange1;
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
            params.tickLower = data.liquidityDeltas[i].tickLower;
            params.tickUpper = data.liquidityDeltas[i].tickLower + data.poolKey.tickSpacing;
            params.liquidityDelta = data.liquidityDeltas[i].delta;

            BalanceDelta balanceDelta = poolManager.modifyPosition(data.poolKey, params, bytes(""));

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

    function _initializePoolLockCallback(PoolKey memory key, uint160 sqrtPriceX96) internal {
        poolManager.initialize(key, sqrtPriceX96, bytes(""));
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
                uint256 poolManagerBalance = currency.balanceOf(address(poolManager));
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
        if (amount > 0) {
            IERC20 token;
            uint256 absAmount = uint256(amount);
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
                uint256 absAmount = uint256(-amount);
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

    function _validateVault(ERC4626 vault, Currency currency) internal view {
        // if vault is set, make sure the vault asset matches the currency
        // if the currency is ETH, the vault asset must be WETH
        if (address(vault) != address(0)) {
            bool isNative = currency.isNative();
            address vaultAsset = address(vault.asset());
            if ((isNative && vaultAsset != address(weth)) || (!isNative && vaultAsset != Currency.unwrap(currency))) {
                revert BunniHub__VaultAssetMismatch();
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

        assembly ("memory-safe") {
            liquidityDensityFunction := shr(96, mload(add(immutableParams, 32)))
            bunniToken := shr(96, mload(add(immutableParams, 52)))
            twapSecondsAgo := shr(232, mload(add(immutableParams, 72)))
            ldfParams := mload(add(immutableParams, 75))
            hookParams := mload(add(immutableParams, 107))
            vault0 := shr(96, mload(add(immutableParams, 139)))
            vault1 := shr(96, mload(add(immutableParams, 159)))
        }

        state = PoolState({
            liquidityDensityFunction: liquidityDensityFunction,
            bunniToken: bunniToken,
            twapSecondsAgo: twapSecondsAgo,
            ldfParams: ldfParams,
            hookParams: hookParams,
            vault0: vault0,
            vault1: vault1,
            poolCredit0Set: rawState.poolCredit0Set,
            poolCredit1Set: rawState.poolCredit1Set,
            reserve0: rawState.reserve0,
            reserve1: rawState.reserve1
        });
    }
}
