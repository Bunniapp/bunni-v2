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
    uint32 internal constant HOOK_FEE_MODIFIER = 0.1e6;
    uint32 internal constant REFERRAL_REWARD_MODIFIER = 0.1e6;
    uint16 internal constant REBALANCE_THRESHOLD = 100; // 1 / 100 = 1%
    uint16 internal constant REBALANCE_MAX_SLIPPAGE = 1; // 5%
    uint16 internal constant REBALANCE_TWAP_SECONDS_AGO = 1 hours;
    uint16 internal constant REBALANCE_ORDER_TTL = 10 minutes;
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
                abi.encode(
                    poolManager, hub, floodPlain, weth, zone, address(this), HOOK_FEE_MODIFIER, REFERRAL_REWARD_MODIFIER
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
            poolManager, hub, floodPlain, weth, zone, address(this), HOOK_FEE_MODIFIER, REFERRAL_REWARD_MODIFIER
        );
        vm.label(address(bunniHook), "BunniHook");

        // deploy currencies
        currency0 = CurrencyLibrary.NATIVE;
        token1 = new ERC20Mock();
        currency1 = Currency.wrap(address(token1));

        // deploy LDF
        ldf = new GeometricDistribution();

        // deploy BunniToken
        bytes32 ldfParams = bytes32(abi.encodePacked(ShiftMode.BOTH, int24(-30), int16(6), ALPHA));
        bytes memory hookParams = abi.encodePacked(
            FEE_MIN,
            FEE_MAX,
            FEE_QUADRATIC_MULTIPLIER,
            FEE_TWAP_SECONDS_AGO,
            SURGE_FEE,
            SURGE_HALFLIFE,
            SURGE_AUTOSTART_TIME,
            VAULT_SURGE_THRESHOLD_0,
            VAULT_SURGE_THRESHOLD_1,
            REBALANCE_THRESHOLD,
            REBALANCE_MAX_SLIPPAGE,
            REBALANCE_TWAP_SECONDS_AGO,
            REBALANCE_ORDER_TTL,
            true, // amAmmEnabled
            ORACLE_MIN_INTERVAL
        );
        (bunniToken, key) = hub.deployBunniToken(
            IBunniHub.DeployBunniTokenParams({
                currency0: currency0,
                currency1: currency1,
                tickSpacing: 10,
                twapSecondsAgo: 7 days,
                liquidityDensityFunction: ldf,
                hooklet: IHooklet(address(0)),
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
                metadataURI: "",
                salt: bytes32(0)
            })
        );

        poolManager.setOperator(address(bunniToken), true);
    }

    function test_distribute_singleDistro_singleReferrer(bool isToken0, uint256 amount, uint24 referrer) public {
        amount = bound(amount, 1e5, 1e36);
        referrer = uint24(bound(referrer, 1, MAX_REFERRER));

        // register referrer
        address referrerAddress = makeAddr("referrer");
        hub.setReferrerAddress(referrer, referrerAddress);

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
        assertEq(claimedAmount0, claimableAmount0, "claimedAmount0 incorrect");
        assertEq(claimedAmount1, claimableAmount1, "claimedAmount1 incorrect");
        assertEq(token.balanceOf(referrerAddress), isToken0 ? claimableAmount0 : claimableAmount1, "balance incorrect");
    }

    function test_distribute_doubleDistro_singleReferrer(
        bool isToken0,
        uint256 amountFirst,
        uint256 amountSecond,
        uint24 referrer
    ) public {
        amountFirst = bound(amountFirst, 1e5, 1e36);
        amountSecond = bound(amountSecond, 1e5, 1e36);
        referrer = uint24(bound(referrer, 1, MAX_REFERRER));

        // register referrer
        address referrerAddress = makeAddr("referrer");
        hub.setReferrerAddress(referrer, referrerAddress);

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
                assertApproxEqRel(claimableAmount0, amountTotal, MAX_REL_ERROR, "claimableAmount0 incorrect");
            }
            assertEq(claimableAmount1, 0, "claimableAmount1 incorrect");
        } else {
            assertEq(claimableAmount0, 0, "claimableAmount0 incorrect");
            if (dist(claimableAmount1, amountTotal) > 1) {
                assertApproxEqRel(claimableAmount1, amountTotal, MAX_REL_ERROR, "claimableAmount1 incorrect");
            }
        }

        // claim rewards
        (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrer);
        assertEq(claimedAmount0, claimableAmount0, "claimedAmount0 incorrect");
        assertEq(claimedAmount1, claimableAmount1, "claimedAmount1 incorrect");
        assertEq(token.balanceOf(referrerAddress), isToken0 ? claimableAmount0 : claimableAmount1, "balance incorrect");
    }

    function test_distribute_singleDistro_multipleReferrers(bool isToken0, uint256 amount) public {
        amount = bound(amount, 1e5, 1e36);
        uint256 numReferrers = 100;

        address[] memory referrerAddresses = new address[](numReferrers);
        for (uint256 i; i < numReferrers; i++) {
            // register referrer
            uint24 referrer = uint24(i + 1);
            referrerAddresses[i] = makeAddr(string.concat("referrer-", uint256(referrer).toString()));
            hub.setReferrerAddress(referrer, referrerAddresses[i]);

            // mint bunni token using referrer
            uint256 shares = _makeDeposit(
                key, uint256(referrer) * 1 ether, uint256(referrer) * 1 ether, referrerAddresses[i], referrer
            );
            assertEq(bunniToken.scoreOf(referrer), shares, "score incorrect");
        }

        // distribute `amount` tokens to referrers
        Currency token = isToken0 ? currency0 : currency1;
        poolManager.unlock(abi.encode(token, amount));
        bunniToken.distributeReferralRewards(isToken0, amount);

        uint256 totalScore = bunniToken.totalSupply();
        for (uint256 i; i < numReferrers; i++) {
            uint24 referrer = uint24(i + 1);

            // check claimable amounts
            uint256 referrerScore = bunniToken.scoreOf(referrer);
            (uint256 claimableAmount0, uint256 claimableAmount1) = bunniToken.getClaimableReferralRewards(referrer);
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
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrer);
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
            uint24 referrer = uint24(i + 1);
            referrerAddresses[i] = makeAddr(string.concat("referrer-", uint256(referrer).toString()));
            hub.setReferrerAddress(referrer, referrerAddresses[i]);

            // mint bunni token using referrer
            uint256 shares = _makeDeposit(
                key, uint256(referrer) * 1 ether, uint256(referrer) * 1 ether, referrerAddresses[i], referrer
            );
            assertEq(bunniToken.scoreOf(referrer), shares, "score incorrect");
        }

        // distribute `amountFirst` tokens and then `amountSecond` tokens to referrers
        Currency token = isToken0 ? currency0 : currency1;
        uint256 amountTotal = amountFirst + amountSecond;
        poolManager.unlock(abi.encode(token, amountTotal));
        bunniToken.distributeReferralRewards(isToken0, amountFirst);
        bunniToken.distributeReferralRewards(isToken0, amountSecond);

        uint256 totalScore = bunniToken.totalSupply();
        for (uint256 i; i < numReferrers; i++) {
            uint24 referrer = uint24(i + 1);

            // check claimable amounts
            uint256 referrerScore = bunniToken.scoreOf(referrer);
            (uint256 claimableAmount0, uint256 claimableAmount1) = bunniToken.getClaimableReferralRewards(referrer);
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
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrer);
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
            uint24 referrer = uint24(i + 1);
            referrerAddresses[i] = makeAddr(string.concat("referrer-", uint256(referrer).toString()));
            hub.setReferrerAddress(referrer, referrerAddresses[i]);

            // mint bunni token using referrer
            uint256 shares = _makeDeposit(
                key, uint256(referrer) * 1 ether, uint256(referrer) * 1 ether, referrerAddresses[i], referrer
            );
            assertEq(bunniToken.scoreOf(referrer), shares, "score incorrect");
        }

        // distribute `amount0` currency0 and `amount1` currency1 to referrers
        poolManager.unlock(abi.encode(currency0, amount0));
        bunniToken.distributeReferralRewards(true, amount0);
        poolManager.unlock(abi.encode(currency1, amount1));
        bunniToken.distributeReferralRewards(false, amount1);

        uint256 totalScore = bunniToken.totalSupply();
        for (uint256 i; i < numReferrers; i++) {
            uint24 referrer = uint24(i + 1);

            // check claimable amounts
            uint256 referrerScore = bunniToken.scoreOf(referrer);
            (uint256 claimableAmount0, uint256 claimableAmount1) = bunniToken.getClaimableReferralRewards(referrer);
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
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(referrer);
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
        hub.setReferrerAddress(1, referrer1Address);
        address referrer2Address = makeAddr("referrer2");
        hub.setReferrerAddress(2, referrer2Address);

        // mint bunni token using referrers
        uint256 shares1 = _makeDeposit(key, 1 ether, 1 ether, referrer1Address, 1);
        assertEq(bunniToken.scoreOf(1), shares1, "score incorrect");

        uint256 shares2 = _makeDeposit(key, 1 ether, 1 ether, referrer2Address, 2);
        assertEq(bunniToken.scoreOf(2), shares2, "score incorrect");

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
            (uint256 claimableAmount0, uint256 claimableAmount1) = bunniToken.getClaimableReferralRewards(1);
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
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(1);
            assertEq(claimedAmount0, claimableAmount0, "claimedAmount0 incorrect");
            assertEq(claimedAmount1, claimableAmount1, "claimedAmount1 incorrect");
            assertEq(
                token.balanceOf(referrer1Address) - beforeBalance,
                isToken0 ? claimableAmount0 : claimableAmount1,
                "balance incorrect"
            );
        }

        {
            (uint256 claimableAmount0, uint256 claimableAmount1) = bunniToken.getClaimableReferralRewards(2);
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
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(2);
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
        hub.setReferrerAddress(1, referrer1Address);
        address referrer2Address = makeAddr("referrer2");
        hub.setReferrerAddress(2, referrer2Address);

        // mint bunni token to referrer 1
        uint256 shares1 = _makeDeposit(key, 1 ether, 1 ether, referrer1Address, 1);
        assertEq(bunniToken.scoreOf(1), shares1, "score incorrect");

        // mint bunni token to referrer 2
        uint256 shares2 = _makeDeposit(key, 2 ether, 2 ether, referrer2Address, 2);
        assertEq(bunniToken.scoreOf(2), shares2, "score incorrect");

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
            (uint256 claimableAmount0, uint256 claimableAmount1) = bunniToken.getClaimableReferralRewards(1);
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
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(1);
            assertEq(claimedAmount0, claimableAmount0, "referrer1 claimedAmount0 incorrect");
            assertEq(claimedAmount1, claimableAmount1, "referrer1 claimedAmount1 incorrect");
            assertEq(
                token.balanceOf(referrer1Address) - beforeBalance,
                isToken0 ? claimableAmount0 : claimableAmount1,
                "balance incorrect"
            );
        }

        {
            (uint256 claimableAmount0, uint256 claimableAmount1) = bunniToken.getClaimableReferralRewards(2);
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
            (uint256 claimedAmount0, uint256 claimedAmount1) = bunniToken.claimReferralRewards(2);
            assertEq(claimedAmount0, claimableAmount0, "referrer2 claimedAmount0 incorrect");
            assertEq(claimedAmount1, claimableAmount1, "referrer2 claimedAmount1 incorrect");
            assertEq(
                token.balanceOf(referrer2Address) - beforeBalance,
                isToken0 ? claimableAmount0 : claimableAmount1,
                "balance incorrect"
            );
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
        uint24 referrer
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
            vaultFee0: 0,
            vaultFee1: 0,
            referrer: referrer
        });
        vm.startPrank(depositor);
        token1.approve(address(permit2), type(uint256).max);
        permit2.approve(address(token1), address(hub), type(uint160).max, type(uint48).max);
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
