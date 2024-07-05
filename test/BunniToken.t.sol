// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.4;

import "forge-std/Test.sol";

import {IFloodPlain} from "flood-contracts/src/interfaces/IFloodPlain.sol";

import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import "@uniswap/v4-core/src/types/Currency.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {PoolManager} from "@uniswap/v4-core/src/PoolManager.sol";
import {IPoolManager, PoolKey} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";

import {WETH} from "solady/tokens/WETH.sol";
import {ERC4626} from "solady/tokens/ERC4626.sol";

import "../src/lib/Math.sol";
import "../src/ldf/ShiftMode.sol";
import "../src/base/Constants.sol";
import {BunniHub} from "../src/BunniHub.sol";
import {BunniZone} from "../src/BunniZone.sol";
import {BunniHook} from "../src/BunniHook.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {BunniToken} from "../src/BunniToken.sol";
import {FloodDeployer} from "./utils/FloodDeployer.sol";
import {IBunniHub} from "../src/interfaces/IBunniHub.sol";
import {IBunniHook} from "../src/interfaces/IBunniHook.sol";
import {Permit2Deployer} from "./utils/Permit2Deployer.sol";
import {IBunniToken} from "../src/interfaces/IBunniToken.sol";
import {GeometricDistribution} from "../src/ldf/GeometricDistribution.sol";
import {ILiquidityDensityFunction} from "../src/interfaces/ILiquidityDensityFunction.sol";

contract BunniTokenTest is Test, Permit2Deployer, FloodDeployer, IUnlockCallback {
    using CurrencyLibrary for Currency;

    uint32 internal constant ALPHA = 0.7e8;
    uint24 internal constant FEE_MIN = 0.0001e6;
    uint24 internal constant FEE_MAX = 0.1e6;
    uint24 internal constant FEE_QUADRATIC_MULTIPLIER = 0.5e6;
    uint24 internal constant FEE_TWAP_SECONDS_AGO = 30 minutes;
    uint24 internal constant SURGE_FEE = 0.1e6;
    uint16 internal constant SURGE_HALFLIFE = 1 minutes;
    uint16 internal constant SURGE_AUTOSTART_TIME = 2 minutes;
    uint16 internal constant VAULT_SURGE_THRESHOLD_0 = 1e4; // 0.01% change in share price
    uint16 internal constant VAULT_SURGE_THRESHOLD_1 = 1e3; // 0.1% change in share price
    uint88 internal constant HOOK_SWAP_FEE = 0.1e18;
    uint32 internal constant ORACLE_MIN_INTERVAL = 1 hours;
    uint256 internal constant HOOK_FLAGS = Hooks.AFTER_INITIALIZE_FLAG + Hooks.BEFORE_ADD_LIQUIDITY_FLAG
        + Hooks.BEFORE_SWAP_FLAG + Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG;
    uint256 internal constant MAX_REL_ERROR = 1e4;

    IBunniHub internal hub;
    BunniHook internal bunniHook = BunniHook(payable(address(uint160(HOOK_FLAGS))));
    IPoolManager internal poolManager;
    WETH internal weth;
    IPermit2 internal permit2;
    IFloodPlain internal floodPlain;
    BunniZone internal zone;
    IBunniToken internal bunniToken;
    Currency internal currency0;
    Currency internal currency1;
    ERC20Mock internal token1;
    ILiquidityDensityFunction internal ldf;
    PoolKey internal key;

    function setUp() public {
        vm.warp(1e9); // init block timestamp to reasonable value

        weth = new WETH();
        permit2 = _deployPermit2();
        poolManager = new PoolManager(1e7);
        floodPlain = _deployFlood(address(permit2));

        // initialize bunni hub
        hub = new BunniHub(poolManager, weth, permit2, new BunniToken(), address(this));

        // deploy zone
        zone = new BunniZone(address(this));

        // initialize bunni hook
        bytes32 hookSalt;
        unchecked {
            bytes memory hookCreationCode = abi.encodePacked(
                type(BunniHook).creationCode,
                abi.encode(poolManager, hub, floodPlain, weth, zone, address(this), HOOK_SWAP_FEE, ORACLE_MIN_INTERVAL)
            );
            for (uint256 offset; offset < 100000; offset++) {
                hookSalt = bytes32(offset);
                address hookDeployed = computeAddress(address(this), hookSalt, hookCreationCode);
                if (uint160(bytes20(hookDeployed)) & Hooks.ALL_HOOK_MASK == HOOK_FLAGS && hookDeployed.code.length == 0)
                {
                    break;
                }
            }
        }
        bunniHook = new BunniHook{salt: hookSalt}(
            poolManager, hub, floodPlain, weth, zone, address(this), HOOK_SWAP_FEE, ORACLE_MIN_INTERVAL
        );
        vm.label(address(bunniHook), "BunniHook");

        // deploy currencies
        currency0 = CurrencyLibrary.NATIVE;
        token1 = new ERC20Mock();
        currency1 = Currency.wrap(address(token1));

        // deploy LDF
        ldf = new GeometricDistribution();

        // deploy BunniToken
        bytes32 ldfParams = bytes32(abi.encodePacked(int24(-3), int16(6), ALPHA, ShiftMode.BOTH));
        bytes32 hookParams = bytes32(
            abi.encodePacked(
                FEE_MIN,
                FEE_MAX,
                FEE_QUADRATIC_MULTIPLIER,
                FEE_TWAP_SECONDS_AGO,
                SURGE_FEE,
                SURGE_HALFLIFE,
                SURGE_AUTOSTART_TIME,
                VAULT_SURGE_THRESHOLD_0,
                VAULT_SURGE_THRESHOLD_1
            )
        );
        (bunniToken, key) = hub.deployBunniToken(
            IBunniHub.DeployBunniTokenParams({
                currency0: currency0,
                currency1: currency1,
                tickSpacing: 10,
                twapSecondsAgo: 7 days,
                liquidityDensityFunction: ldf,
                statefulLdf: true,
                ldfParams: ldfParams,
                hooks: bunniHook,
                hookParams: hookParams,
                vault0: ERC4626(address(0)),
                vault1: ERC4626(address(0)),
                minRawTokenRatio0: 0.08e6,
                targetRawTokenRatio0: 0.1e6,
                maxRawTokenRatio0: 0.12e6,
                minRawTokenRatio1: 0.08e6,
                targetRawTokenRatio1: 0.1e6,
                maxRawTokenRatio1: 0.12e6,
                sqrtPriceX96: uint160(Q96),
                name: "BunniToken",
                symbol: "BUNNI",
                owner: address(this),
                metadataURI: ""
            })
        );

        // approve tokens
        token1.approve(address(permit2), type(uint256).max);
        poolManager.setOperator(address(bunniToken), true);

        // permit2 approve tokens to hub
        permit2.approve(address(token1), address(hub), type(uint160).max, type(uint48).max);
    }

    function test_distribute_singleDistro_singleReferrer(bool isToken0, uint256 amount, uint16 referrer) public {
        vm.assume(referrer != 0);
        amount = bound(amount, 1e5, 1e36);

        // register referrer
        address referrerAddress = makeAddr("referrer");
        hub.setReferrerAddress(referrer, referrerAddress);

        // mint bunni token using referrer
        uint256 shares = _makeDeposit(key, 1 ether, 1 ether, address(this), referrer);
        assertEq(bunniToken.scoreOf(referrer), shares, "score incorrect");

        // distribute `amount` tokens to referrers
        if (isToken0) {
            poolManager.unlock(abi.encode(currency0, amount));
            bunniToken.distributeReferralRewards(isToken0, amount);
        } else {
            poolManager.unlock(abi.encode(currency1, amount));
            bunniToken.distributeReferralRewards(isToken0, amount);
        }

        // check claimable amounts
        (uint256 claimableAmount0, uint256 claimableAmount1) = bunniToken.getClaimableReferralRewards(referrer);
        if (isToken0) {
            if (dist(claimableAmount0, amount) > 1) {
                assertApproxEqRel(claimableAmount0, amount, MAX_REL_ERROR, "claimableAmount0 incorrect");
            }
            assertEq(claimableAmount1, 0, "claimableAmount1 incorrect");
        } else {
            assertEq(claimableAmount0, 0, "claimableAmount0 incorrect");
            if (dist(claimableAmount1, amount) > 1) {
                assertApproxEqRel(claimableAmount1, amount, MAX_REL_ERROR, "claimableAmount1 incorrect");
            }
        }

        // claim rewards
        (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrer);
        if (isToken0) {
            assertEq(claimedAmount0, claimableAmount0, "claimedAmount0 incorrect");
            assertEq(claimedAmount1, 0, "claimedAmount1 incorrect");
            assertEq(currency0.balanceOf(referrerAddress), claimableAmount0, "balance incorrect");
        } else {
            assertEq(claimedAmount0, 0, "claimedAmount0 incorrect");
            assertEq(claimedAmount1, claimableAmount1, "claimedAmount1 incorrect");
            assertEq(currency1.balanceOf(referrerAddress), claimableAmount1, "balance incorrect");
        }
    }

    /// @inheritdoc IUnlockCallback
    /// @dev Mint claim tokens of a currency
    function unlockCallback(bytes calldata data) external override returns (bytes memory) {
        // decode input
        (Currency token, uint256 amount) = abi.decode(data, (Currency, uint256));

        // mint tokens
        _mint(token, address(this), amount);

        // mint claim tokens
        poolManager.mint(address(this), token.toId(), amount);
        poolManager.sync(token);
        if (token.isNative()) {
            poolManager.settle{value: amount}(token);
        } else {
            token.transfer(address(poolManager), amount);
            poolManager.settle(token);
        }

        // fallback
        return bytes("");
    }

    receive() external payable {}

    /// @notice Precompute a contract address deployed via CREATE2
    /// @param deployer The address that will deploy the hook. In `forge test`, this will be the test contract `address(this)` or the pranking address
    ///                 In `forge script`, this should be `0x4e59b44847b379578588920cA78FbF26c0B4956C` (CREATE2 Deployer Proxy)
    /// @param salt The salt used to deploy the hook
    /// @param creationCode The creation code of a hook contract
    function computeAddress(address deployer, bytes32 salt, bytes memory creationCode)
        public
        pure
        returns (address hookAddress)
    {
        return address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xFF), deployer, salt, keccak256(creationCode)))))
        );
    }

    function _makeDeposit(
        PoolKey memory key_,
        uint256 depositAmount0,
        uint256 depositAmount1,
        address depositor,
        uint16 referrer
    ) internal returns (uint256 shares) {
        // mint tokens
        uint256 value;
        if (key_.currency0.isNative()) {
            value = depositAmount0;
        } else if (key_.currency1.isNative()) {
            value = depositAmount1;
        }
        _mint(key_.currency0, depositor, depositAmount0);
        _mint(key_.currency1, depositor, depositAmount1);

        // deposit tokens
        IBunniHub.DepositParams memory depositParams = IBunniHub.DepositParams({
            poolKey: key_,
            amount0Desired: depositAmount0,
            amount1Desired: depositAmount1,
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp,
            recipient: depositor,
            refundRecipient: depositor,
            tax0: 0,
            tax1: 0,
            vaultFee0: 0,
            vaultFee1: 0,
            referrer: referrer
        });
        vm.startPrank(depositor);
        (shares,,) = hub.deposit{value: value}(depositParams);
        vm.stopPrank();
    }

    function _mint(Currency currency, address to, uint256 amount) internal {
        if (currency.isNative()) {
            vm.deal(to, to.balance + amount);
        } else if (Currency.unwrap(currency) == address(weth)) {
            vm.deal(address(this), address(this).balance + amount);
            weth.deposit{value: amount}();
            weth.transfer(to, amount);
        } else {
            ERC20Mock(Currency.unwrap(currency)).mint(to, amount);
        }
    }
}
