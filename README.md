# Bunni v2

**Important:** Bunni v2 has been exploited (see post mortem [here](https://blog.bunni.xyz/posts/exploit-post-mortem/)), and this repo does not have the relevant issues addressed. Please do not use this code in production as is.

Bunni v2 is a next-gen decentralized exchange with **shapeshifting liquidity**, the next breakthrough in AMM design after Uniswap v3's concentrated liquidity.

To learn more, see:

- [Bunni v2 whitepaper](https://github.com/Bunniapp/whitepaper/blob/main/bunni-v2.pdf)
- [Documentation](https://docs.bunni.xyz/)

This repo is licensed under the MIT License, though some files are licensed under AGPL-3.0. See the SPDX license identifier in each file for details.

## Installation

To install with [Foundry](https://github.com/gakonst/foundry):

```
forge install bunniapp/bunni-v2
```

## Local development

This project uses [Foundry](https://github.com/gakonst/foundry) as the development framework.

Note: Uniswap's v4-core repo only compiles using Solidity 0.8.26. To develop locally, change the Solidity version of `lib/v4-core/src/PoolManager.sol` to `^0.8.25`.

### Dependencies

```
forge install
```

### Compilation

```
forge build
```

### Testing

```
forge test
```

### Medusa fuzzing

Bunni uses [Medusa](https://github.com/crytic/medusa) and [fuzz-utils](https://github.com/crytic/fuzz-utils) for fuzzing.

Before fuzzing, `BunniSwapMath` should be temporarily modified to use `internal` instead of `external` and to use `memory` instead of `calldata` for the `computeSwap` function. This is because Medusa doesn't support external libraries.

To start fuzzing, run:

```
medusa fuzz
```

To generate Foundry tests from the failed fuzzing runs, run:

```
fuzz-utils generate ./fuzz/FuzzEntry.sol -c FuzzEntry -cd medusa
```

To use Foundry to run the failed fuzzing runs, run:

```
forge test --mc FuzzEntry_Medusa_Test
```

### Contract deployment

Please create a `.env` file before deployment. An example can be found in `.env.example`.

The Create3 salts for the following contracts are required in the `.env` file:

- `BunniSwapMath`
- `RebalanceLogic`
- `BunniHub`
- `BunniHook`
- `BunniZone`
- `BunniQuoter`
- `GeometricDistribution`
- `DoubleGeometricDistribution`
- `CarpetedGeometricDistribution`
- `CarpetedDoubleGeometricDistribution`
- `UniformDistribution`
- `BuyTheDipGeometricDistribution`
- `BunniHubLogic`
- `BunniHookLogic`

#### Dryrun

```bash
FOUNDRY_PROFILE=gas forge script script/DeployLibraries.s.sol -f [network]
FOUNDRY_PROFILE=hub_logic forge script script/DeployHubLogic.s.sol -f [network]
FOUNDRY_PROFILE=hook_logic forge script script/DeployHookLogic.s.sol -f [network] --libraries src/lib/BunniSwapMath.sol:BunniSwapMath:[swapMathLibAddress] --libraries src/lib/RebalanceLogic.sol:RebalanceLogic:[rebalanceLibAddress]
FOUNDRY_PROFILE=hub forge script script/DeployHub.s.sol -f [network] --libraries src/lib/BunniHubLogic.sol:BunniHubLogic:[hubLogicLibAddress]
FOUNDRY_PROFILE=gas forge script script/DeployLDFs.s.sol -f [network]
FOUNDRY_PROFILE=gas forge script script/DeployZone.s.sol -f [network]
FOUNDRY_PROFILE=quoter forge script script/DeployBunniQuoter.s.sol -f [network] --libraries src/lib/BunniSwapMath.sol:BunniSwapMath:[swapMathLibAddress] --libraries src/lib/RebalanceLogic.sol:RebalanceLogic:[rebalanceLibAddress] --libraries src/lib/BunniHookLogic.sol:BunniHookLogic:[hookLogicLibAddress]
FOUNDRY_PROFILE=hook forge script script/DeployHook.s.sol -f [network] --libraries src/lib/BunniHookLogic.sol:BunniHookLogic:[hookLogicLibAddress] --libraries src/lib/BunniSwapMath.sol:BunniSwapMath:[swapMathLibAddress] --libraries src/lib/RebalanceLogic.sol:RebalanceLogic:[rebalanceLibAddress]
```

### Live

```bash
FOUNDRY_PROFILE=gas forge script script/DeployLibraries.s.sol -f [network] --verify --broadcast --slow --account [keystoreAccount]
FOUNDRY_PROFILE=hub_logic forge script script/DeployHubLogic.s.sol -f [network] --verify --broadcast --slow --account [keystoreAccount]
FOUNDRY_PROFILE=hook_logic forge script script/DeployHookLogic.s.sol -f [network] --verify --broadcast --slow --account [keystoreAccount] --libraries src/lib/BunniSwapMath.sol:BunniSwapMath:[swapMathLibAddress] --libraries src/lib/RebalanceLogic.sol:RebalanceLogic:[rebalanceLibAddress]
FOUNDRY_PROFILE=hub forge script script/DeployHub.s.sol -f [network] --verify --broadcast --slow --account [keystoreAccount] --libraries src/lib/BunniHubLogic.sol:BunniHubLogic:[hubLogicLibAddress]
FOUNDRY_PROFILE=gas forge script script/DeployLDFs.s.sol -f [network] --verify --broadcast --slow --account [keystoreAccount]
FOUNDRY_PROFILE=gas forge script script/DeployZone.s.sol -f [network] --verify --broadcast --slow --account [keystoreAccount]
FOUNDRY_PROFILE=quoter forge script script/DeployBunniQuoter.s.sol -f [network] --verify --broadcast --slow --account [keystoreAccount] --libraries src/lib/BunniSwapMath.sol:BunniSwapMath:[swapMathLibAddress] --libraries src/lib/RebalanceLogic.sol:RebalanceLogic:[rebalanceLibAddress] --libraries src/lib/BunniHookLogic.sol:BunniHookLogic:[hookLogicLibAddress]
FOUNDRY_PROFILE=hook forge script script/DeployHook.s.sol -f [network] --verify --broadcast --slow --account [keystoreAccount] --libraries src/lib/BunniHookLogic.sol:BunniHookLogic:[hookLogicLibAddress] --libraries src/lib/BunniSwapMath.sol:BunniSwapMath:[swapMathLibAddress] --libraries src/lib/RebalanceLogic.sol:RebalanceLogic:[rebalanceLibAddress]
```
