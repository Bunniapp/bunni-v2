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
import {LibString} from "solady/utils/LibString.sol";

import "../src/lib/Math.sol";
import "../src/ldf/ShiftMode.sol";
import "../src/types/LDFType.sol";
import "../src/base/Constants.sol";
import {BunniHub} from "../src/BunniHub.sol";
import {BunniZone} from "../src/BunniZone.sol";
import {BunniHook} from "../src/BunniHook.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {BunniToken} from "../src/BunniToken.sol";
import {IHooklet} from "../src/interfaces/IHooklet.sol";
import {FloodDeployer} from "./utils/FloodDeployer.sol";
import {IBunniHub} from "../src/interfaces/IBunniHub.sol";
import {IBunniHook} from "../src/interfaces/IBunniHook.sol";
import {Permit2Deployer} from "./utils/Permit2Deployer.sol";
import {IBunniToken} from "../src/interfaces/IBunniToken.sol";
import {GeometricDistribution} from "../src/ldf/GeometricDistribution.sol";
import {ILiquidityDensityFunction} from "../src/interfaces/ILiquidityDensityFunction.sol";

contract BunniTokenTest is Test, Permit2Deployer, FloodDeployer, IUnlockCallback {
    using LibString for *;
    using CurrencyLibrary for Currency;

    uint48 internal constant K = 7200;
    uint32 internal constant ALPHA = 0.7e8;
    uint24 internal constant FEE_MIN = 0.0001e6;
    uint24 internal constant FEE_MAX = 0.1e6;
    uint24 internal constant FEE_QUADRATIC_MULTIPLIER = 0.5e6;
    uint24 internal constant FEE_TWAP_SECONDS_AGO = 30 minutes;
    uint16 internal constant SURGE_HALFLIFE = 1 minutes;
    uint16 internal constant SURGE_AUTOSTART_TIME = 2 minutes;
    uint16 internal constant VAULT_SURGE_THRESHOLD_0 = 1e4; // 0.01% change in share price
    uint16 internal constant VAULT_SURGE_THRESHOLD_1 = 1e3; // 0.1% change in share price
    uint32 internal constant HOOK_FEE_MODIFIER = 0.1e6;
    uint32 internal constant REFERRAL_REWARD_MODIFIER = 0.1e6;
    uint16 internal constant REBALANCE_THRESHOLD = 100; // 1 / 100 = 1%
    uint16 internal constant REBALANCE_MAX_SLIPPAGE = 1; // 5%
    uint16 internal constant REBALANCE_TWAP_SECONDS_AGO = 1 hours;
    uint16 internal constant REBALANCE_ORDER_TTL = 10 minutes;
    uint32 internal constant ORACLE_MIN_INTERVAL = 1 hours;
    uint24 internal constant POOL_MAX_AMAMM_FEE = 0.05e6; // 5%
    uint48 internal constant MIN_RENT_MULTIPLIER = 1e10;
    uint256 internal constant HOOK_FLAGS = Hooks.AFTER_INITIALIZE_FLAG + Hooks.BEFORE_ADD_LIQUIDITY_FLAG
        + Hooks.BEFORE_SWAP_FLAG + Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG;
    uint256 internal constant MAX_REL_ERROR = 1e4;
    address internal constant HOOK_FEE_RECIPIENT = address(0xfee);

    IBunniHub internal hub;
    BunniHook internal bunniHook;
    IPoolManager internal poolManager;
    WETH internal weth;
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
        _deployPermit2(vm);
        poolManager = new PoolManager(address(this));
        floodPlain = _deployFlood(address(PERMIT2));

        // initialize bunni hub
        hub = new BunniHub(poolManager, weth, PERMIT2, new BunniToken(), address(this));

        // deploy zone
        zone = new BunniZone(address(this));

        // initialize bunni hook
        bytes32 hookSalt;
        unchecked {
            bytes memory hookCreationCode = abi.encodePacked(
                type(BunniHook).creationCode,
                abi.encode(
                    poolManager,
                    hub,
                    floodPlain,
                    weth,
                    zone,
                    address(this),
                    HOOK_FEE_RECIPIENT,
                    HOOK_FEE_MODIFIER,
                    REFERRAL_REWARD_MODIFIER,
                    K
                )
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
            poolManager,
            hub,
            floodPlain,
            weth,
            zone,
            address(this),
            HOOK_FEE_RECIPIENT,
            HOOK_FEE_MODIFIER,
            REFERRAL_REWARD_MODIFIER,
            K
        );
        vm.label(address(bunniHook), "BunniHook");

        // deploy currencies
        currency0 = CurrencyLibrary.ADDRESS_ZERO;
        token1 = new ERC20Mock();
        currency1 = Currency.wrap(address(token1));

        // deploy LDF
        ldf = new GeometricDistribution(address(hub), address(bunniHook), address(this));

        // deploy BunniToken
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-30), int16(6), ALPHA));
        bytes memory hookParams = abi.encodePacked(
            FEE_MIN,
            FEE_MAX,
            FEE_QUADRATIC_MULTIPLIER,
            FEE_TWAP_SECONDS_AGO,
            POOL_MAX_AMAMM_FEE,
            SURGE_HALFLIFE,
            SURGE_AUTOSTART_TIME,
            VAULT_SURGE_THRESHOLD_0,
            VAULT_SURGE_THRESHOLD_1,
            REBALANCE_THRESHOLD,
            REBALANCE_MAX_SLIPPAGE,
            REBALANCE_TWAP_SECONDS_AGO,
            REBALANCE_ORDER_TTL,
            true, // amAmmEnabled
            ORACLE_MIN_INTERVAL,
            MIN_RENT_MULTIPLIER
        );
        (bunniToken, key) = hub.deployBunniToken(
            IBunniHub.DeployBunniTokenParams({
                currency0: currency0,
                currency1: currency1,
                tickSpacing: 10,
                twapSecondsAgo: 7 days,
                liquidityDensityFunction: ldf,
                hooklet: IHooklet(address(0)),
                ldfType: LDFType.DYNAMIC_AND_STATEFUL,
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
                metadataURI: "",
                salt: bytes32(0)
            })
        );

        poolManager.setOperator(address(bunniToken), true);
    }

    function test_distribute_singleDistro_singleReferrer(bool isToken0, uint256 amount) public {
        address referrer = makeAddr("referrer");
        amount = bound(amount, 1e5, 1e36);

        // mint bunni token using referrer
        uint256 shares = _makeDeposit(key, 1 ether, 1 ether, address(this), referrer);
        assertEq(bunniToken.scoreOf(referrer), shares, "score incorrect");

        // distribute `amount` tokens to referrers
        Currency token = isToken0 ? currency0 : currency1;
        poolManager.unlock(abi.encode(token, amount));
        bunniToken.distributeReferralRewards(isToken0, amount);

        // check claimable amounts
        (uint256 claimableAmount0, uint256 claimableAmount1) = bunniToken.getClaimableReferralRewards(referrer);
        if (isToken0) {
            if (dist(claimableAmount0, amount) > 1) {
                assertApproxEqRel(claimableAmount0, amount, 1e13, "claimableAmount0 incorrect");
            }
            assertEq(claimableAmount1, 0, "claimableAmount1 incorrect");
        } else {
            assertEq(claimableAmount0, 0, "claimableAmount0 incorrect");
            if (dist(claimableAmount1, amount) > 1) {
                assertApproxEqRel(claimableAmount1, amount, 1e13, "claimableAmount1 incorrect");
            }
        }

        // claim rewards
        (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrer);
        assertEq(claimedAmount0, claimableAmount0, "claimedAmount0 incorrect");
        assertEq(claimedAmount1, claimableAmount1, "claimedAmount1 incorrect");
        assertEq(token.balanceOf(referrer), isToken0 ? claimableAmount0 : claimableAmount1, "balance incorrect");
    }

    function test_distribute_doubleDistro_singleReferrer(
        bool isToken0,
        uint256 amountFirst,
        uint256 amountSecond,
        address referrer
    ) public {
        vm.assume(referrer != address(0));
        amountFirst = bound(amountFirst, 1e5, 1e36);
        amountSecond = bound(amountSecond, 1e5, 1e36);

        // mint bunni token using referrer
        uint256 shares = _makeDeposit(key, 1 ether, 1 ether, address(this), referrer);
        assertEq(bunniToken.scoreOf(referrer), shares, "score incorrect");

        // distribute `amountFirst` tokens and then `amountSecond` tokens to referrers
        Currency token = isToken0 ? currency0 : currency1;
        uint256 amountTotal = amountFirst + amountSecond;
        poolManager.unlock(abi.encode(token, amountTotal));
        bunniToken.distributeReferralRewards(isToken0, amountFirst);
        bunniToken.distributeReferralRewards(isToken0, amountSecond);

        // check claimable amounts
        (uint256 claimableAmount0, uint256 claimableAmount1) = bunniToken.getClaimableReferralRewards(referrer);
        if (isToken0) {
            if (dist(claimableAmount0, amountTotal) > 1) {
                assertApproxEqRel(claimableAmount0, amountTotal, 1e13, "claimableAmount0 incorrect");
            }
            assertEq(claimableAmount1, 0, "claimableAmount1 incorrect");
        } else {
            assertEq(claimableAmount0, 0, "claimableAmount0 incorrect");
            if (dist(claimableAmount1, amountTotal) > 1) {
                assertApproxEqRel(claimableAmount1, amountTotal, 1e13, "claimableAmount1 incorrect");
            }
        }

        // claim rewards
        (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrer);
        assertEq(claimedAmount0, claimableAmount0, "claimedAmount0 incorrect");
        assertEq(claimedAmount1, claimableAmount1, "claimedAmount1 incorrect");
        assertEq(token.balanceOf(referrer), isToken0 ? claimableAmount0 : claimableAmount1, "balance incorrect");
    }

    function test_distribute_singleDistro_multipleReferrers(bool isToken0, uint256 amount) public {
        amount = bound(amount, 1e5, 1e36);
        uint256 numReferrers = 100;

        address[] memory referrerAddresses = new address[](numReferrers);
        for (uint256 i; i < numReferrers; i++) {
            // register referrer
            referrerAddresses[i] = makeAddr(string.concat("referrer-", uint256(i + 1).toString()));

            // mint bunni token using referrer
            uint256 shares = _makeDeposit(
                key, uint256(i + 1) * 1 ether, uint256(i + 1) * 1 ether, referrerAddresses[i], referrerAddresses[i]
            );
            assertEq(bunniToken.scoreOf(referrerAddresses[i]), shares, "score incorrect");
        }

        // distribute `amount` tokens to referrers
        Currency token = isToken0 ? currency0 : currency1;
        poolManager.unlock(abi.encode(token, amount));
        bunniToken.distributeReferralRewards(isToken0, amount);

        uint256 totalScore = bunniToken.totalSupply();
        for (uint256 i; i < numReferrers; i++) {
            // check claimable amounts
            uint256 referrerScore = bunniToken.scoreOf(referrerAddresses[i]);
            (uint256 claimableAmount0, uint256 claimableAmount1) =
                bunniToken.getClaimableReferralRewards(referrerAddresses[i]);
            (uint256 expectedClaimableAmount0, uint256 expectedClaimableAmount1) = isToken0
                ? (amount * referrerScore / totalScore, uint256(0))
                : (uint256(0), amount * referrerScore / totalScore);
            if (dist(claimableAmount0, expectedClaimableAmount0) > 1) {
                assertApproxEqRel(
                    claimableAmount0, expectedClaimableAmount0, MAX_REL_ERROR, "claimableAmount0 incorrect"
                );
            }
            if (dist(claimableAmount1, expectedClaimableAmount1) > 1) {
                assertApproxEqRel(
                    claimableAmount1, expectedClaimableAmount1, MAX_REL_ERROR, "claimableAmount1 incorrect"
                );
            }

            // claim rewards
            uint256 beforeBalance = token.balanceOf(referrerAddresses[i]);
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrerAddresses[i]);
            assertEq(claimedAmount0, claimableAmount0, "claimedAmount0 incorrect");
            assertEq(claimedAmount1, claimableAmount1, "claimedAmount1 incorrect");
            assertEq(
                token.balanceOf(referrerAddresses[i]) - beforeBalance,
                isToken0 ? claimableAmount0 : claimableAmount1,
                "balance incorrect"
            );
        }
    }

    function test_distribute_doubleDistro_multipleReferrers(bool isToken0, uint256 amountFirst, uint256 amountSecond)
        public
    {
        amountFirst = bound(amountFirst, 1e5, 1e36);
        amountSecond = bound(amountSecond, 1e5, 1e36);
        uint256 numReferrers = 100;

        address[] memory referrerAddresses = new address[](numReferrers);
        for (uint256 i; i < numReferrers; i++) {
            // register referrer
            referrerAddresses[i] = makeAddr(string.concat("referrer-", uint256(i + 1).toString()));

            // mint bunni token using referrer
            uint256 shares = _makeDeposit(
                key, uint256(i + 1) * 1 ether, uint256(i + 1) * 1 ether, referrerAddresses[i], referrerAddresses[i]
            );
            assertEq(bunniToken.scoreOf(referrerAddresses[i]), shares, "score incorrect");
        }

        // distribute `amountFirst` tokens and then `amountSecond` tokens to referrers
        Currency token = isToken0 ? currency0 : currency1;
        uint256 amountTotal = amountFirst + amountSecond;
        poolManager.unlock(abi.encode(token, amountTotal));
        bunniToken.distributeReferralRewards(isToken0, amountFirst);
        bunniToken.distributeReferralRewards(isToken0, amountSecond);

        uint256 totalScore = bunniToken.totalSupply();
        for (uint256 i; i < numReferrers; i++) {
            // check claimable amounts
            uint256 referrerScore = bunniToken.scoreOf(referrerAddresses[i]);
            (uint256 claimableAmount0, uint256 claimableAmount1) =
                bunniToken.getClaimableReferralRewards(referrerAddresses[i]);
            (uint256 expectedClaimableAmount0, uint256 expectedClaimableAmount1) = isToken0
                ? (amountTotal * referrerScore / totalScore, uint256(0))
                : (uint256(0), amountTotal * referrerScore / totalScore);
            if (dist(claimableAmount0, expectedClaimableAmount0) > 1) {
                assertApproxEqRel(
                    claimableAmount0, expectedClaimableAmount0, MAX_REL_ERROR, "claimableAmount0 incorrect"
                );
            }
            if (dist(claimableAmount1, expectedClaimableAmount1) > 1) {
                assertApproxEqRel(
                    claimableAmount1, expectedClaimableAmount1, MAX_REL_ERROR, "claimableAmount1 incorrect"
                );
            }

            // claim rewards
            uint256 beforeBalance = token.balanceOf(referrerAddresses[i]);
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrerAddresses[i]);
            assertEq(claimedAmount0, claimableAmount0, "claimedAmount0 incorrect");
            assertEq(claimedAmount1, claimableAmount1, "claimedAmount1 incorrect");
            assertEq(
                token.balanceOf(referrerAddresses[i]) - beforeBalance,
                isToken0 ? claimableAmount0 : claimableAmount1,
                "balance incorrect"
            );
        }
    }

    function test_distribute_singleDistro_bothTokens_multipleReferrers(uint256 amount0, uint256 amount1) public {
        amount0 = bound(amount0, 1e5, 1e36);
        amount1 = bound(amount1, 1e5, 1e36);
        uint256 numReferrers = 100;

        address[] memory referrerAddresses = new address[](numReferrers);
        for (uint256 i; i < numReferrers; i++) {
            // register referrer
            referrerAddresses[i] = makeAddr(string.concat("referrer-", uint256(i + 1).toString()));

            // mint bunni token using referrer
            uint256 shares = _makeDeposit(
                key, uint256(i + 1) * 1 ether, uint256(i + 1) * 1 ether, referrerAddresses[i], referrerAddresses[i]
            );
            assertEq(bunniToken.scoreOf(referrerAddresses[i]), shares, "score incorrect");
        }

        // distribute `amount0` currency0 and `amount1` currency1 to referrers
        poolManager.unlock(abi.encode(currency0, amount0));
        bunniToken.distributeReferralRewards(true, amount0);
        poolManager.unlock(abi.encode(currency1, amount1));
        bunniToken.distributeReferralRewards(false, amount1);

        uint256 totalScore = bunniToken.totalSupply();
        for (uint256 i; i < numReferrers; i++) {
            // check claimable amounts
            uint256 referrerScore = bunniToken.scoreOf(referrerAddresses[i]);
            (uint256 claimableAmount0, uint256 claimableAmount1) =
                bunniToken.getClaimableReferralRewards(referrerAddresses[i]);
            (uint256 expectedClaimableAmount0, uint256 expectedClaimableAmount1) =
                (amount0 * referrerScore / totalScore, amount1 * referrerScore / totalScore);
            if (dist(claimableAmount0, expectedClaimableAmount0) > 1) {
                assertApproxEqRel(
                    claimableAmount0, expectedClaimableAmount0, MAX_REL_ERROR, "claimableAmount0 incorrect"
                );
            }
            if (dist(claimableAmount1, expectedClaimableAmount1) > 1) {
                assertApproxEqRel(
                    claimableAmount1, expectedClaimableAmount1, MAX_REL_ERROR, "claimableAmount1 incorrect"
                );
            }

            // claim rewards
            uint256 beforeBalance0 = currency0.balanceOf(referrerAddresses[i]);
            uint256 beforeBalance1 = currency1.balanceOf(referrerAddresses[i]);
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrerAddresses[i]);
            assertEq(claimedAmount0, claimableAmount0, "claimedAmount0 incorrect");
            assertEq(claimedAmount1, claimableAmount1, "claimedAmount1 incorrect");
            assertEq(currency0.balanceOf(referrerAddresses[i]) - beforeBalance0, claimableAmount0, "balance0 incorrect");
            assertEq(currency1.balanceOf(referrerAddresses[i]) - beforeBalance1, claimableAmount1, "balance1 incorrect");
        }
    }

    function test_distribute_singleDistro_twoReferrersWithTransfer(bool isToken0, uint256 amount) public {
        amount = bound(amount, 1e5, 1e36);

        // register referrer
        address referrer1Address = makeAddr("referrer1");
        address referrer2Address = makeAddr("referrer2");

        // mint bunni token using referrers
        uint256 shares1 = _makeDeposit(key, 1 ether, 1 ether, referrer1Address, referrer1Address);
        assertEq(bunniToken.scoreOf(referrer1Address), shares1, "score incorrect");

        uint256 shares2 = _makeDeposit(key, 1 ether, 1 ether, referrer2Address, referrer2Address);
        assertEq(bunniToken.scoreOf(referrer2Address), shares2, "score incorrect");

        // distribute `amount` tokens to referrers
        Currency token = isToken0 ? currency0 : currency1;
        poolManager.unlock(abi.encode(token, amount));
        bunniToken.distributeReferralRewards(isToken0, amount);

        // make transfer from referrer1 to referrer2
        vm.startPrank(referrer1Address);
        bunniToken.transfer(referrer2Address, bunniToken.balanceOf(referrer1Address) / 2);
        vm.stopPrank();

        // check claimable amounts
        // transfer shouldn't have affected claimable amounts
        // since it was after the distribution
        uint256 bunniTotalSupply = bunniToken.totalSupply();
        {
            (uint256 claimableAmount0, uint256 claimableAmount1) =
                bunniToken.getClaimableReferralRewards(referrer1Address);
            if (isToken0) {
                if (dist(claimableAmount0, amount * shares1 / bunniTotalSupply) > 1) {
                    assertApproxEqRel(
                        claimableAmount0,
                        amount * shares1 / bunniTotalSupply,
                        MAX_REL_ERROR,
                        "claimableAmount0 incorrect"
                    );
                }
                assertEq(claimableAmount1, 0, "claimableAmount1 incorrect");
            } else {
                assertEq(claimableAmount0, 0, "claimableAmount0 incorrect");
                if (dist(claimableAmount1, amount * shares1 / bunniTotalSupply) > 1) {
                    assertApproxEqRel(
                        claimableAmount1,
                        amount * shares1 / bunniTotalSupply,
                        MAX_REL_ERROR,
                        "claimableAmount1 incorrect"
                    );
                }
            }

            // claim rewards
            uint256 beforeBalance = token.balanceOf(referrer1Address);
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrer1Address);
            assertEq(claimedAmount0, claimableAmount0, "claimedAmount0 incorrect");
            assertEq(claimedAmount1, claimableAmount1, "claimedAmount1 incorrect");
            assertEq(
                token.balanceOf(referrer1Address) - beforeBalance,
                isToken0 ? claimableAmount0 : claimableAmount1,
                "balance incorrect"
            );
        }

        {
            (uint256 claimableAmount0, uint256 claimableAmount1) =
                bunniToken.getClaimableReferralRewards(referrer2Address);
            if (isToken0) {
                if (dist(claimableAmount0, amount * shares2 / bunniTotalSupply) > 1) {
                    assertApproxEqRel(
                        claimableAmount0,
                        amount * shares2 / bunniTotalSupply,
                        MAX_REL_ERROR,
                        "claimableAmount0 incorrect"
                    );
                }
                assertEq(claimableAmount1, 0, "claimableAmount1 incorrect");
            } else {
                assertEq(claimableAmount0, 0, "claimableAmount0 incorrect");
                if (dist(claimableAmount1, amount * shares2 / bunniTotalSupply) > 1) {
                    assertApproxEqRel(
                        claimableAmount1,
                        amount * shares2 / bunniTotalSupply,
                        MAX_REL_ERROR,
                        "claimableAmount1 incorrect"
                    );
                }
            }

            // claim rewards
            uint256 beforeBalance = token.balanceOf(referrer2Address);
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrer2Address);
            assertEq(claimedAmount0, claimableAmount0, "claimedAmount0 incorrect");
            assertEq(claimedAmount1, claimableAmount1, "claimedAmount1 incorrect");
            assertEq(
                token.balanceOf(referrer2Address) - beforeBalance,
                isToken0 ? claimableAmount0 : claimableAmount1,
                "balance incorrect"
            );
        }
    }

    function test_distribute_transferAndDistro(
        bool isToken0,
        uint256 amountFirst,
        uint256 amountSecond,
        uint256 amountThird
    ) public {
        amountFirst = bound(amountFirst, 1e5, 1e36);
        amountSecond = bound(amountSecond, 1e5, 1e36);
        amountThird = bound(amountThird, 1e5, 1e36);

        // register referrers
        address referrer1Address = makeAddr("referrer1");
        address referrer2Address = makeAddr("referrer2");

        // mint bunni token to referrer 1
        uint256 shares1 = _makeDeposit(key, 1 ether, 1 ether, referrer1Address, referrer1Address);
        assertEq(bunniToken.scoreOf(referrer1Address), shares1, "score incorrect");

        // mint bunni token to referrer 2
        uint256 shares2 = _makeDeposit(key, 2 ether, 2 ether, referrer2Address, referrer2Address);
        assertEq(bunniToken.scoreOf(referrer2Address), shares2, "score incorrect");

        // distribute `amountFirst` tokens
        Currency token = isToken0 ? currency0 : currency1;
        uint256 amountTotal = amountFirst + amountSecond + amountThird;
        poolManager.unlock(abi.encode(token, amountTotal));
        bunniToken.distributeReferralRewards(isToken0, amountFirst);

        // transfer referrer 2 balance to referrer 1
        // so that referrer 1 has `shares1 + shares2` tokens
        // and referrer 2 has 0 tokens
        vm.prank(referrer2Address);
        bunniToken.transfer(referrer1Address, shares2);

        // distribute `amountSecond` tokens
        bunniToken.distributeReferralRewards(isToken0, amountSecond);

        // transfer referrer 1 balance to referrer 2
        vm.prank(referrer1Address);
        bunniToken.transfer(referrer2Address, shares1 + shares2);

        // distribute `amountThird` tokens
        bunniToken.distributeReferralRewards(isToken0, amountThird);

        // check claimable amounts
        uint256 bunniTotalSupply = bunniToken.totalSupply();
        {
            (uint256 claimableAmount0, uint256 claimableAmount1) =
                bunniToken.getClaimableReferralRewards(referrer1Address);
            uint256 expectedClaimableAmount =
                amountFirst * shares1 / bunniTotalSupply + amountSecond * (shares1 + shares2) / bunniTotalSupply;
            if (isToken0) {
                if (dist(claimableAmount0, expectedClaimableAmount) > 1) {
                    assertApproxEqRel(
                        claimableAmount0, expectedClaimableAmount, MAX_REL_ERROR, "referrer1 claimableAmount0 incorrect"
                    );
                }
                assertEq(claimableAmount1, 0, "referrer1 claimableAmount1 incorrect");
            } else {
                assertEq(claimableAmount0, 0, "referrer1 claimableAmount0 incorrect");
                if (dist(claimableAmount1, expectedClaimableAmount) > 1) {
                    assertApproxEqRel(
                        claimableAmount1, expectedClaimableAmount, MAX_REL_ERROR, "referrer1 claimableAmount1 incorrect"
                    );
                }
            }

            // claim rewards
            uint256 beforeBalance = token.balanceOf(referrer1Address);
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrer1Address);
            assertEq(claimedAmount0, claimableAmount0, "referrer1 claimedAmount0 incorrect");
            assertEq(claimedAmount1, claimableAmount1, "referrer1 claimedAmount1 incorrect");
            assertEq(
                token.balanceOf(referrer1Address) - beforeBalance,
                isToken0 ? claimableAmount0 : claimableAmount1,
                "balance incorrect"
            );
        }

        {
            (uint256 claimableAmount0, uint256 claimableAmount1) =
                bunniToken.getClaimableReferralRewards(referrer2Address);
            uint256 expectedClaimableAmount =
                amountFirst * shares2 / bunniTotalSupply + amountThird * (shares1 + shares2) / bunniTotalSupply;
            if (isToken0) {
                if (dist(claimableAmount0, expectedClaimableAmount) > 1) {
                    assertApproxEqRel(
                        claimableAmount0, expectedClaimableAmount, MAX_REL_ERROR, "referrer2 claimableAmount0 incorrect"
                    );
                }
                assertEq(claimableAmount1, 0, "referrer2 claimableAmount1 incorrect");
            } else {
                assertEq(claimableAmount0, 0, "referrer2 claimableAmount0 incorrect");
                if (dist(claimableAmount1, expectedClaimableAmount) > 1) {
                    assertApproxEqRel(
                        claimableAmount1, expectedClaimableAmount, MAX_REL_ERROR, "referrer2 claimableAmount1 incorrect"
                    );
                }
            }

            // claim rewards
            uint256 beforeBalance = token.balanceOf(referrer2Address);
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrer2Address);
            assertEq(claimedAmount0, claimableAmount0, "referrer2 claimedAmount0 incorrect");
            assertEq(claimedAmount1, claimableAmount1, "referrer2 claimedAmount1 incorrect");
            assertEq(
                token.balanceOf(referrer2Address) - beforeBalance,
                isToken0 ? claimableAmount0 : claimableAmount1,
                "balance incorrect"
            );
        }
    }

    function test_claim_mint_doubleCount() public {
        bool isToken0 = true;
        uint256 amountToDistribute = 1 ether;
        // register depositors and referrers
        address depositor1 = makeAddr("depositor1");
        address referrer1 = makeAddr("referrer1");
        address depositor2 = makeAddr("depositor2");
        address referrer2 = makeAddr("referrer2");
        //
        // 1. `Depositor1` deposits 1 ether. referrer1 gets score
        console.log("Depositor1 deposits token using referrer1");
        _makeDeposit(key, 1 ether, 1 ether, depositor1, referrer1);
        console.log("ScoreOf referrer1", bunniToken.scoreOf(referrer1));
        //
        // 2. `Depositor2` deposits 1 ether. referrer2 gets score.
        console.log("Depositor2 deposits token using referrer2");
        _makeDeposit(key, 1 ether, 1 ether, depositor2, referrer2);
        console.log("ScoreOf referrer2", bunniToken.scoreOf(referrer2));
        //
        // 3. Distribute rewards to the `BunniToken`
        console.log("\nOwner distributes 1 ether rewards...");
        Currency token = isToken0 ? currency0 : currency1;
        poolManager.unlock(abi.encode(token, amountToDistribute));
        bunniToken.distributeReferralRewards(isToken0, amountToDistribute);
        //
        (uint256 referrer1Reward0, uint256 referrer1Reward1) = bunniToken.claimReferralRewards(referrer1);
        (uint256 referrer2Reward0, uint256 referrer2Reward1) = bunniToken.getClaimableReferralRewards(referrer2);
        console.log("ScoreOf referrer1", bunniToken.scoreOf(referrer1));
        console.log("ScoreOf referrer2", bunniToken.scoreOf(referrer2));
        console.log("Rewards claimed by referrer1", referrer1Reward0, referrer1Reward1);
        console.log("Rewards claimable by referrer2", referrer2Reward0, referrer2Reward1);
        //
        // 4. Malicious `Depositor1` deposits 0.1 ether again but he changes the referrer1 to referrer2
        console.log("\nMalicious Depositor1 deposits more token using referrer2 (referrer is modified)");
        _makeDeposit(key, 0.1 ether, 0.1 ether, depositor1, referrer2);
        (referrer1Reward0, referrer1Reward1) = bunniToken.getClaimableReferralRewards(referrer1);
        (uint256 referrer2Reward0After, uint256 referrer2Reward1After) =
            bunniToken.getClaimableReferralRewards(referrer2);
        console.log("ScoreOf referrer1", bunniToken.scoreOf(referrer1));
        console.log("ScoreOf referrer2", bunniToken.scoreOf(referrer2));
        console.log("Rewards claimable by referrer1", referrer1Reward0, referrer1Reward1);
        console.log("Rewards claimable by referrer2", referrer2Reward0After, referrer2Reward1After);

        // referrer2 reward should not change
        assertEq(referrer2Reward0, referrer2Reward0After, "referrer2 reward0 incorrect");
        assertEq(referrer2Reward1, referrer2Reward1After, "referrer2 reward1 incorrect");
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
        if (token.isAddressZero()) {
            poolManager.settle{value: amount}();
        } else {
            token.transfer(address(poolManager), amount);
            poolManager.settle();
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
        address referrer
    ) internal returns (uint256 shares) {
        // mint tokens
        uint256 value;
        if (key_.currency0.isAddressZero()) {
            value = depositAmount0;
        } else if (key_.currency1.isAddressZero()) {
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
            vaultFee0: 0,
            vaultFee1: 0,
            referrer: referrer
        });
        vm.startPrank(depositor);
        token1.approve(address(PERMIT2), type(uint256).max);
        PERMIT2.approve(address(token1), address(hub), type(uint160).max, type(uint48).max);
        (shares,,) = hub.deposit{value: value}(depositParams);
        vm.stopPrank();
    }

    function _mint(Currency currency, address to, uint256 amount) internal {
        if (currency.isAddressZero()) {
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
