# Stealth TWAP Trap on Drosera (Hoodi Testnet)

This repository contains smart contracts, scripts, and configuration for deploying a **Stealth Time-Weighted Average Price (TWAP) Trap** on the **Drosera network**, powered by **Hoodi Ethereum testnet**.  

The setup includes:
- `StealthTWAPTrap.sol` → Core trap contract
- `StealthTWAPResponse.sol` → Response handler contract (emits events when trap triggers)
- Deployment + testing scripts
- TOML configs for Drosera trap execution

---

## 📂 Project Structure

├── foundry.toml
├── drosera.toml
├── remappings.txt
├── src
│ ├── StealthTWAPTrap.sol
│ └── StealthTWAPResponse.sol
├── script
│ └── DeployTrap.s.sol
└── test
└── StealthTWAPTrap.t.sol

---

## 📊 Architecture Flow

```mermaid
flowchart LR
    A[StealthTWAPTrap] -- Detects TWAP condition --> B[Drosera Network]
    B -- Routes execution --> C[StealthTWAPResponse]
    C -- Emits event --> D[(On-chain Logs)]

    subgraph User
      E[Whitelisted Operator<br>0xfb3d951fa8496c6933ea0275695bca906c58527e]
    end

    E -- Deploys & Configures --> A
    E -- Reads events --> D
Workflow Example

Block Sampling

Trap collects price data over sample_window_blocks (e.g., 20 blocks).

TWAP Calculation

Trap computes the time-weighted average price.

Threshold Check

If the TWAP exceeds the set threshold, the trap conditions are met.

Drosera Trigger

Drosera operator detects the breach and calls the trap’s configured respond function.

Response Execution

Drosera routes the call to StealthTWAPResponse.handleTWAPEvent(address,uint256).

Event Emission

The response contract emits TWAPTriggered(token, twapValue, triggeredBy).

Off-chain Monitoring

Whitelisted operator (your address) listens to the emitted event logs.

This proves trap execution and can trigger further automation.
