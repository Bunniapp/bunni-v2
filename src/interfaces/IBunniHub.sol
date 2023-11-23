// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {ILockCallback} from "@uniswap/v4-core/src/interfaces/callback/ILockCallback.sol";

import {ERC4626} from "solmate/mixins/ERC4626.sol";

import "../lib/Structs.sol";
import {IERC20} from "./IERC20.sol";
import {IBunniHook} from "./IBunniHook.sol";
import {IBunniToken} from "./IBunniToken.sol";
import {IMulticallable} from "./IMulticallable.sol";
import {ILiquidityDensityFunction} from "./ILiquidityDensityFunction.sol";

/// @title BunniHub
/// @author zefram.eth
/// @notice The main contract LPs interact with. Each BunniKey corresponds to a BunniToken,
/// which is the ERC20 LP token for the Uniswap V3 position specified by the BunniKey.
/// Use deposit()/withdraw() to mint/burn LP tokens, and use compound() to compound the swap fees
/// back into the LP position.
interface IBunniHub is IMulticallable, ILockCallback {
    /// @notice Emitted when liquidity is increased via deposit
    /// @param sender The msg.sender address
    /// @param recipient The address of the account that received the share tokens
    /// @param poolId The Uniswap V4 pool's ID
    /// @param amount0 The amount of token0 that was paid for the increase in liquidity
    /// @param amount1 The amount of token1 that was paid for the increase in liquidity
    /// @param shares The amount of share tokens minted to the recipient
    event Deposit(
        address indexed sender,
        address indexed recipient,
        PoolId indexed poolId,
        uint256 amount0,
        uint256 amount1,
        uint256 shares
    );
    /// @notice Emitted when liquidity is decreased via withdrawal
    /// @param sender The msg.sender address
    /// @param recipient The address of the account that received the collected tokens
    /// @param poolId The Uniswap V4 pool's ID
    /// @param amount0 The amount of token0 that was accounted for the decrease in liquidity
    /// @param amount1 The amount of token1 that was accounted for the decrease in liquidity
    /// @param shares The amount of share tokens burnt from the sender
    event Withdraw(
        address indexed sender,
        address indexed recipient,
        PoolId indexed poolId,
        uint256 amount0,
        uint256 amount1,
        uint256 shares
    );
    /// @notice Emitted when fees are compounded back into liquidity
    /// @param poolId The Uniswap V4 pool's ID
    /// @param feeDelta The amount of token0 and token1 added to the reserves
    event Compound(PoolId indexed poolId, BalanceDelta feeDelta);
    /// @notice Emitted when a new IBunniToken is created
    /// @param bunniToken The BunniToken associated with the call
    /// @param poolId The Uniswap V4 pool's ID
    event NewBunni(IBunniToken indexed bunniToken, PoolId indexed poolId);

    /// @param poolKey The PoolKey of the Uniswap V4 pool
    /// @param amount0Desired The desired amount of token0 to be spent,
    /// @param amount1Desired The desired amount of token1 to be spent,
    /// @param amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
    /// @param amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
    /// @param deadline The time by which the transaction must be included to effect the change
    /// @param recipient The recipient of the minted share tokens
    struct DepositParams {
        PoolKey poolKey;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
        address recipient;
    }

    /// @notice Increases the amount of liquidity in a position, with tokens paid by the `msg.sender`
    /// @dev Must be called after the corresponding BunniToken has been deployed via deployBunniToken()
    /// @param params The input parameters
    /// bunniToken The BunniToken associated with the call
    /// amount0Desired The desired amount of token0 to be spent,
    /// amount1Desired The desired amount of token1 to be spent,
    /// amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
    /// amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
    /// deadline The time by which the transaction must be included to effect the change
    /// @return shares The new share tokens minted to the sender
    /// @return addedLiquidity The new liquidity amount as a result of the increase
    /// @return amount0 The amount of token0 to acheive resulting liquidity
    /// @return amount1 The amount of token1 to acheive resulting liquidity
    function deposit(DepositParams calldata params)
        external
        payable
        returns (uint256 shares, uint128 addedLiquidity, uint256 amount0, uint256 amount1);

    /// @param poolKey The PoolKey of the Uniswap V4 pool
    /// @param recipient The user if not withdrawing ETH, address(0) if withdrawing ETH
    /// @param shares The amount of ERC20 tokens (this) to burn,
    /// @param amount0Min The minimum amount of token0 that should be accounted for the burned liquidity,
    /// @param amount1Min The minimum amount of token1 that should be accounted for the burned liquidity,
    /// @param deadline The time by which the transaction must be included to effect the change
    struct WithdrawParams {
        PoolKey poolKey;
        address recipient;
        uint256 shares;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// @notice Decreases the amount of liquidity in the position and sends the tokens to the sender.
    /// If withdrawing ETH, need to follow up with unwrapWETH9() and sweepToken()
    /// @dev Must be called after the corresponding BunniToken has been deployed via deployBunniToken()
    /// @param params The input parameters
    /// key The Bunni position's key
    /// recipient The user if not withdrawing ETH, address(0) if withdrawing ETH
    /// shares The amount of share tokens to burn,
    /// amount0Min The minimum amount of token0 that should be accounted for the burned liquidity,
    /// amount1Min The minimum amount of token1 that should be accounted for the burned liquidity,
    /// deadline The time by which the transaction must be included to effect the change
    /// @return removedLiquidity The amount of liquidity decrease
    /// @return amount0 The amount of token0 withdrawn to the recipient
    /// @return amount1 The amount of token1 withdrawn to the recipient
    function withdraw(WithdrawParams calldata params)
        external
        returns (uint128 removedLiquidity, uint256 amount0, uint256 amount1);

    struct DeployBunniTokenParams {
        Currency currency0;
        Currency currency1;
        int24 tickSpacing;
        uint24 twapSecondsAgo;
        ILiquidityDensityFunction liquidityDensityFunction;
        bytes32 ldfParams;
        IBunniHook hooks;
        bytes32 hookParams;
        ERC4626 vault0;
        ERC4626 vault1;
        uint160 sqrtPriceX96;
    }

    /// @notice Deploys the BunniToken contract for a Bunni position. This token
    /// represents a user's share in the Uniswap V4 LP position.
    /// @return token The deployed BunniToken
    function deployBunniToken(DeployBunniTokenParams calldata params)
        external
        returns (IBunniToken token, PoolKey memory key);

    function hookModifyLiquidity(PoolKey calldata poolKey, LiquidityDelta[] calldata liquidityDeltas) external;

    function poolManager() external view returns (IPoolManager);
    function poolState(PoolId poolId) external view returns (PoolState memory);
    function nonce(bytes32 bunniSubspace) external view returns (uint24);
    function poolIdOfBunniToken(IBunniToken bunniToken) external view returns (PoolId);

    /// @notice The amount of extra PoolManager claim tokens a pool has. The claim tokens come from
    /// the edge case where 1) a vault is used 2) a swap occurs that crosses a rounded tick boundary
    /// 3) PoolManager doesn't have enough balance for paying out the tokens of the withdrawn liquidity
    /// before the swapper settles the swap so that the tokens can be deposited into the vault as reserve.
    /// In this case, we mint PoolManager claim tokens to the pool's reserves so that later the tokens can be deposited
    /// into the vault.
    function poolCredit0(PoolId poolId) external view returns (uint256);

    /// @notice The amount of extra PoolManager claim tokens a pool has. The claim tokens come from
    /// the edge case where 1) a vault is used 2) a swap occurs that crosses a rounded tick boundary
    /// 3) PoolManager doesn't have enough balance for paying out the tokens of the withdrawn liquidity
    /// before the swapper settles the swap so that the tokens can be deposited into the vault as reserve.
    /// In this case, we mint PoolManager claim tokens to the pool's reserves so that later the tokens can be deposited
    /// into the vault.
    function poolCredit1(PoolId poolId) external view returns (uint256);
}
