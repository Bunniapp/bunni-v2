// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

interface ILiquidityDensityFunction {
    function liquidityDensity(int24 tick, int24 currentTick, int24 twapTick) external view returns (uint256 density);

    function cumulativeAmount0Density(int24 tick, int24 currentTick, int24 twapTick)
        external
        view
        returns (uint256 cumulativeDensity);

    function cumulativeAmount1Density(int24 tick, int24 currentTick, int24 twapTick)
        external
        view
        returns (uint256 cumulativeDensity);
}
