## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

### COVERAGE:

| File         | % Lines        | % Statements   | % Branches     | % Funcs      |
|--------------|----------------|----------------|----------------|--------------|
| src/Vote.sol | 90.00% (27/30) | 91.18% (31/34) | 58.33% (14/24) | 75.00% (6/8) |
| Total        | 90.00% (27/30) | 91.18% (31/34) | 58.33% (14/24) | 75.00% (6/8) |

```shell
$ forge --help
$ anvil --help
$ cast --help
```
