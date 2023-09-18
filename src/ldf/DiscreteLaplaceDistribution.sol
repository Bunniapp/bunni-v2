// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.19;

import "../lib/Math.sol";
import {ILiquidityDensityFunction} from "../interfaces/ILiquidityDensityFunction.sol";

contract DiscreteLaplaceDistribution is ILiquidityDensityFunction {
    function query(int24 currentTick, int24 twapTick, int24 tickSpacing, bytes11 decodedLDFParams)
        external
        view
        override
        returns (uint256 liquidityDensity_, uint256 cumulativeAmount0Density, uint256 cumulativeAmount1Density)
    {}

    function liquidityDensity(int24 roundedTick, int24 currentTick, int24 twapTick, bytes11 decodedLDFParams)
        external
        view
        override
        returns (uint256)
    {}
}
