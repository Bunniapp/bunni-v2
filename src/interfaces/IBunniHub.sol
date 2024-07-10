// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";

import {WETH} from "solady/tokens/WETH.sol";
import {ERC4626} from "solady/tokens/ERC4626.sol";

import "../base/SharedStructs.sol";
import {IERC20} from "./IERC20.sol";
import {IOwnable} from "./IOwnable.sol";
import {IBunniHook} from "./IBunniHook.sol";
import {IBunniToken} from "./IBunniToken.sol";
import {PoolState} from "../types/PoolState.sol";
import {IPermit2Enabled} from "./IPermit2Enabled.sol";
import {ILiquidityDensityFunction} from "./ILiquidityDensityFunction.sol";

/// @title BunniHub
/// @author zefram.eth
/// @notice The main contract LPs interact with. Each BunniKey corresponds to a BunniToken,
/// which is the ERC20 LP token for the Uniswap V3 position specified by the BunniKey.
/// Use deposit()/withdraw() to mint/burn LP tokens, and use compound() to compound the swap fees
/// back into the LP position.
interface IBunniHub is IUnlockCallback, IPermit2Enabled, IOwnable {
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
    /// @notice Emitted when a withdrawal is queued
    /// @param sender The msg.sender address
    /// @param poolId The Uniswap V4 pool's ID
    /// @param shares The amount of share tokens queued for withdrawal
    event QueueWithdraw(address indexed sender, PoolId indexed poolId, uint256 shares);
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
    /// @notice Emitted when a new IBunniToken is created
    /// @param bunniToken The BunniToken associated with the call
    /// @param poolId The Uniswap V4 pool's ID
    event NewBunni(IBunniToken indexed bunniToken, PoolId indexed poolId);
    /// @notice Emitted when a new referrer is set
    /// @param referrer The referrer ID
    /// @param referrerAddress The referrer address
    event SetReferrerAddress(uint24 indexed referrer, address indexed referrerAddress);

    /// @param poolKey The PoolKey of the Uniswap V4 pool
    /// @param recipient The recipient of the minted share tokens
    /// @param refundRecipient The recipient of the refunded ETH
    /// @param amount0Desired The desired amount of token0 to be spent,
    /// @param amount1Desired The desired amount of token1 to be spent,
    /// @param amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
    /// @param amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
    /// @param vaultFee0 When we deposit token0 into vault0, the deposit amount is multiplied by WAD / (WAD - vaultFee0),
    /// @param vaultFee1 When we deposit token1 into vault1, the deposit amount is multiplied by WAD / (WAD - vaultFee1),
    /// @param deadline The time by which the transaction must be included to effect the change
    /// @param referrer The referrer of the liquidity provider. Used for fee sharing.
    struct DepositParams {
        PoolKey poolKey;
        address recipient;
        address refundRecipient;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 vaultFee0;
        uint256 vaultFee1;
        uint256 deadline;
        uint24 referrer;
    }

    /// @notice Increases the amount of liquidity in a position, with tokens paid by the `msg.sender`
    /// @dev Must be called after the corresponding BunniToken has been deployed via deployBunniToken()
    /// @param params The input parameters
    /// poolKey The PoolKey of the Uniswap V4 pool
    /// recipient The recipient of the minted share tokens
    /// refundRecipient The recipient of the refunded ETH
    /// amount0Desired The desired amount of token0 to be spent,
    /// amount1Desired The desired amount of token1 to be spent,
    /// amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
    /// amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
    /// vaultFee0 When we deposit token0 into vault0, the deposit amount is multiplied by WAD / (WAD - vaultFee0),
    /// vaultFee1 When we deposit token1 into vault1, the deposit amount is multiplied by WAD / (WAD - vaultFee1),
    /// deadline The time by which the transaction must be included to effect the change
    /// @return shares The new share tokens minted to the sender
    /// @return amount0 The amount of token0 to acheive resulting liquidity
    /// @return amount1 The amount of token1 to acheive resulting liquidity
    function deposit(DepositParams calldata params)
        external
        payable
        returns (uint256 shares, uint256 amount0, uint256 amount1);

    /// @param poolKey The PoolKey of the Uniswap V4 pool
    /// @param shares The amount of share tokens to burn
    struct QueueWithdrawParams {
        PoolKey poolKey;
        uint200 shares;
    }

    /// @notice Queues a withdrawal of liquidity. Need to use this before calling withdraw() if am-AMM is enabled
    /// and a manager exists for the pool. A queued withdrawal is unlocked after WITHDRAW_DELAY (1 minutes) has passed,
    /// and before WITHDRAW_GRACE_PERIOD (15 minutes) has passed after it's been unlocked. This ensures the am-AMM manager
    /// has an opportunity to execute any arbitrage trades before a withdrawal is processed.
    /// @param params The input parameters
    /// poolKey The PoolKey of the Uniswap V4 pool
    /// shares The amount of share tokens to burn
    function queueWithdraw(QueueWithdrawParams calldata params) external;

    /// @param poolKey The PoolKey of the Uniswap V4 pool
    /// @param recipient The recipient of the withdrawn tokens
    /// @param shares The amount of share tokens to burn
    /// @param amount0Min The minimum amount of token0 that should be accounted for the burned liquidity
    /// @param amount1Min The minimum amount of token1 that should be accounted for the burned liquidity
    /// @param deadline The time by which the transaction must be included to effect the change
    /// @param useQueuedWithdrawal If true, queued withdrawal share tokens will be used
    struct WithdrawParams {
        PoolKey poolKey;
        address recipient;
        uint256 shares;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
        bool useQueuedWithdrawal;
    }

    /// @notice Decreases the amount of liquidity in the position and sends the tokens to the sender.
    /// If withdrawing ETH, need to follow up with unwrapWETH9() and sweepToken()
    /// @dev Must be called after the corresponding BunniToken has been deployed via deployBunniToken()
    /// @param params The input parameters
    /// poolKey The Uniswap v4 pool's key
    /// recipient The recipient of the withdrawn tokens
    /// shares The amount of share tokens to burn,
    /// amount0Min The minimum amount of token0 that should be accounted for the burned liquidity,
    /// amount1Min The minimum amount of token1 that should be accounted for the burned liquidity,
    /// deadline The time by which the transaction must be included to effect the change
    /// @return amount0 The amount of token0 withdrawn to the recipient
    /// @return amount1 The amount of token1 withdrawn to the recipient
    function withdraw(WithdrawParams calldata params) external returns (uint256 amount0, uint256 amount1);

    /// @param currency0 The token0 of the Uniswap V4 pool
    /// @param currency1 The token1 of the Uniswap V4 pool
    /// @param tickSpacing The tick spacing of the Uniswap V4 pool
    /// @param twapSecondsAgo The TWAP time period to use for the liquidity density function
    /// @param liquidityDensityFunction The liquidity density function to use
    /// @param ldfParams The parameters for the liquidity density function
    /// @param hooks The hooks to use for the Uniswap V4 pool
    /// @param hookParams The parameters for the hooks
    /// @param vault0 The vault for token0. If address(0), then a vault is not used.
    /// @param vault1 The vault for token1. If address(0), then a vault is not used.
    /// @param minRawTokenRatio0 The minimum (rawBalance / balance) ratio for token0
    /// @param targetRawTokenRatio0 The target (rawBalance / balance) ratio for token0
    /// @param maxRawTokenRatio0 The maximum (rawBalance / balance) ratio for token0
    /// @param minRawTokenRatio1 The minimum (rawBalance / balance) ratio for token1
    /// @param targetRawTokenRatio1 The target (rawBalance / balance) ratio for token1
    /// @param maxRawTokenRatio1 The maximum (rawBalance / balance) ratio for token1
    /// @param sqrtPriceX96 The initial sqrt price of the Uniswap V4 pool
    /// @param name The name of the BunniToken
    /// @param symbol The symbol of the BunniToken
    /// @param owner The owner of the BunniToken. Only has the power to set the metadata URI.
    /// @param metadataURI The initial metadata URI of the BunniToken, containing info like description, image, etc.
    struct DeployBunniTokenParams {
        Currency currency0;
        Currency currency1;
        int24 tickSpacing;
        uint24 twapSecondsAgo;
        ILiquidityDensityFunction liquidityDensityFunction;
        bool statefulLdf;
        bytes32 ldfParams;
        IBunniHook hooks;
        bytes hookParams;
        ERC4626 vault0;
        ERC4626 vault1;
        uint24 minRawTokenRatio0;
        uint24 targetRawTokenRatio0;
        uint24 maxRawTokenRatio0;
        uint24 minRawTokenRatio1;
        uint24 targetRawTokenRatio1;
        uint24 maxRawTokenRatio1;
        uint160 sqrtPriceX96;
        bytes32 name;
        bytes32 symbol;
        address owner;
        string metadataURI;
    }

    /// @notice Deploys the BunniToken contract for a Bunni position. This token
    /// represents a user's share in the Uniswap V4 LP position.
    /// @param params The input parameters
    /// currency0 The token0 of the Uniswap V4 pool
    /// currency1 The token1 of the Uniswap V4 pool
    /// tickSpacing The tick spacing of the Uniswap V4 pool
    /// twapSecondsAgo The TWAP time period to use for the liquidity density function
    /// liquidityDensityFunction The liquidity density function to use
    /// ldfParams The parameters for the liquidity density function
    /// hooks The hooks to use for the Uniswap V4 pool
    /// hookParams The parameters for the hooks
    /// vault0 The vault for token0. If address(0), then a vault is not used.
    /// vault1 The vault for token1. If address(0), then a vault is not used.
    /// sqrtPriceX96 The initial sqrt price of the Uniswap V4 pool
    /// @return token The deployed BunniToken
    /// @return key The PoolKey of the Uniswap V4 pool
    function deployBunniToken(DeployBunniTokenParams calldata params)
        external
        returns (IBunniToken token, PoolKey memory key);

    /// @notice Called by the hook to execute a generalized swap from one token to the other. Also used during rebalancing.
    /// @dev If the raw balance is insufficient, vault reserves will be automatically used.
    /// Will update vault reserves if the raw/reserve ratio is outside of the bounds.
    /// @param key The PoolKey of the Uniswap V4 pool
    /// @param zeroForOne True if the swap is for token0->token1, false if token1->token0
    /// @param inputAmount The amount of the input token to pull from the hook
    /// @param outputAmount The amount of the output token to push to the hook
    function hookHandleSwap(PoolKey calldata key, bool zeroForOne, uint256 inputAmount, uint256 outputAmount)
        external;

    /// @notice Sets the address that corresponds to a referrer ID. Only callable by the owner or the current referrer address.
    /// @param referrer The referrer ID
    /// @param referrerAddress The address of the referrer
    function setReferrerAddress(uint24 referrer, address referrerAddress) external;

    /// @notice The state of a Bunni pool.
    function poolState(PoolId poolId) external view returns (PoolState memory);

    /// @notice The PoolState struct of a given pool with only the immutable params filled out.
    function poolParams(PoolId poolId) external view returns (PoolState memory);

    /// @notice The BunniToken of a given pool. address(0) if the pool is not a Bunni pool.
    function bunniTokenOfPool(PoolId poolId) external view returns (IBunniToken);

    /// @notice The params of the given Bunni pool's hook. bytes("") if the pool is not a Bunni pool.
    function hookParams(PoolId poolId) external view returns (bytes memory);

    /// @notice The nonce of the given Bunni subspace.
    function nonce(bytes32 bunniSubspace) external view returns (uint24);

    /// @notice The PoolId of a given BunniToken.
    function poolIdOfBunniToken(IBunniToken bunniToken) external view returns (PoolId);

    /// @notice The token balances of a Bunni pool. Reserves in vaults are converted to raw token balances via ERC4626.previewRedeem().
    function poolBalances(PoolId poolId) external view returns (uint256 balance0, uint256 balance1);

    /// @notice The address that corresponds to a given referrer ID.
    function getReferrerAddress(uint24 referrer) external view returns (address);
}
