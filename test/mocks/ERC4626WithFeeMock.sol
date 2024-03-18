// SPDX-License-Identifier: AGPL-3.0

pragma solidity ^0.8.15;

import {ERC20} from "solady/tokens/ERC20.sol";
import {ERC4626} from "solady/tokens/ERC4626.sol";
import {FixedPointMathLib} from "solady/utils/FixedPointMathLib.sol";

import {IERC20} from "../../src/interfaces/IERC20.sol";

contract ERC4626WithFeeMock is ERC4626 {
    using FixedPointMathLib for uint256;

    uint256 public constant FEE_DENOMINATOR = 10_000;
    uint256 public constant withdrawalPenalty = 300;

    address internal immutable _asset;

    constructor(IERC20 asset_) {
        _asset = address(asset_);
    }

    function asset() public view override returns (address) {
        return _asset;
    }

    function name() public pure override returns (string memory) {
        return "MockERC4626";
    }

    function symbol() public pure override returns (string memory) {
        return "MOCK-ERC4626";
    }

    function previewWithdraw(uint256 assets) public view override returns (uint256 shares) {
        shares = super.previewWithdraw(assets);

        // Save 1 SLOAD
        uint256 _totalSupply = totalSupply();

        // Factor in additional shares to fulfill withdrawal if user is not the last to withdraw
        return (_totalSupply == 0 || _totalSupply - shares == 0)
            ? shares
            : shares.mulDivUp(FEE_DENOMINATOR, FEE_DENOMINATOR - withdrawalPenalty);
    }

    function previewRedeem(uint256 shares) public view override returns (uint256 assets) {
        assets = super.previewRedeem(shares);

        uint256 _totalSupply = totalSupply();

        // Calculate a penalty - zero if user is the last to withdraw
        uint256 penalty =
            (_totalSupply == 0 || _totalSupply - shares == 0) ? 0 : assets.mulDiv(withdrawalPenalty, FEE_DENOMINATOR);

        // Redeemable amount is the post-penalty amount
        return assets - penalty;
    }
}
