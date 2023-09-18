// SPDX-License-Identifier: AGPL-3.0

pragma solidity >=0.6.0;
pragma abicoder v2;

interface ILiquidityDensityFunction {
    function query(int24 currentTick, int24 twapTick, int24 tickSpacing, bytes11 decodedLDFParams)
        external
        view
        returns (uint256 liquidityDensity, uint256 cumulativeAmount0Density, uint256 cumulativeAmount1Density);

    function liquidityDensity(int24 roundedTick, int24 currentTick, int24 twapTick, bytes11 decodedLDFParams)
        external
        view
        returns (uint256);
}
