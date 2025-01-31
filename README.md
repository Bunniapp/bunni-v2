# Bunni v2

Bunni v2 is a next-gen decentralized exchange with **shapeshifting liquidity**, the next breakthrough in AMM design after Uniswap v3's concentrated liquidity.

To learn more, see:

- [Bunni v2 whitepaper](https://github.com/Bunniapp/whitepaper/blob/main/bunni-v2.pdf)
- [Documentation](https://docs.bunni.xyz/)

## Installation

To install with [Foundry](https://github.com/gakonst/foundry):

```
forge install timeless-fi/bunni-v2
```

## Local development

This project uses [Foundry](https://github.com/gakonst/foundry) as the development framework.

Note: This project only compiles using Solidity `0.8.25` (and not `0.8.26`), but Uniswap's v4-core repo only compiles using Solidity 0.8.26. To develop locally, change the Solidity version of `lib/v4-core/src/PoolManager.sol` to `0.8.25`.

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

- `BunniHub`
- `BunniZone`
- `BunniHook`
- `BunniQuoter`

#### Dryrun

```
FOUNDRY_PROFILE=gas forge script script/DeployLibraries.s.sol -f [network]
FOUNDRY_PROFILE=gas forge script script/DeployLDFs.s.sol -f [network]
forge script script/DeployCore.s.sol -f [network] --libraries src/lib/BunniSwapMath.sol:BunniSwapMath:[swapMathLibAddress] --libraries src/lib/RebalanceLogic.sol:RebalanceLogic:[rebalanceLibAddress]
forge script script/DeployBunniQuoter.s.sol -f [network]
```

### Live

```
FOUNDRY_PROFILE=gas forge script script/DeployLibraries.s.sol -f [network] --verify --broadcast --slow
FOUNDRY_PROFILE=gas forge script script/DeployLDFs.s.sol -f [network] --verify --broadcast --slow
forge script script/DeployCore.s.sol -f [network] --verify --broadcast --slow --libraries src/lib/BunniSwapMath.sol:BunniSwapMath:[swapMathLibAddress] --libraries src/lib/RebalanceLogic.sol:RebalanceLogic:[rebalanceLibAddress]
forge script script/DeployBunniQuoter.s.sol -f [network] --verify --broadcast --slow
```
