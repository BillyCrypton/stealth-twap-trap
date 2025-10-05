# Stealth TWAP Trap on Drosera (Hoodi Testnet)

A next-generation Drosera trap engineered to monitor **time-weighted average price (TWAP)** anomalies on-chain and respond instantly to deviations beyond a safe threshold. This system empowers DeFi users with automated detection, real-time event emission, and secure private execution using the Hoodi Ethereum testnet.

---

## Overview

In decentralized finance, sudden TWAP deviations can expose protocols to manipulation, arbitrage exploits, and liquidation cascades. A malicious whale or flash loan attack can distort prices temporarily, allowing unfair trading opportunities and threatening liquidity pools.  

The **Stealth TWAP Trap** is designed as a protective layer to detect and respond to such threats with speed, precision, and minimal resource consumption.  

What makes this trap exceptional:
- **Lightweight monitoring**: Uses efficient block sampling instead of heavy oracles.  
- **Real-time TWAP computation**: Detects deviations immediately as blocks finalize.  
- **Customizable thresholds**: Set sensitivity (e.g., 5%, 10%) to tune detection.  
- **Secure responses**: Routes execution through a dedicated response contract.  
- **Private execution**: Whitelisting ensures only your authorized operator address can manage or respond.  

---

## What it Detects

- **TWAP Breaches**: Flags deviations beyond the defined threshold.  
- **Price Manipulation**: Identifies abnormal swings that might indicate flash loan attacks.  
- **Stalled Prices**: Detects when TWAP stops updating, often a sign of faulty feeds.  
- **Edge Cases**: Handles malformed or unexpected block data gracefully to avoid false positives.  

---

## How it Works

1. **Data Collection**  
   - The trap samples price feeds or internal signals across a block window.  

2. **TWAP Computation**  
   - Computes the average price across the sampling window, smoothing volatility.  

3. **Threshold Check**  
   - Compares computed TWAP with the last stable TWAP.  
   - If deviation exceeds threshold (e.g., 10%), a response is prepared.  

4. **Secure Response Trigger**  
   - Encodes the response and calls the `StealthTWAPResponse` contract.  
   - Security is enforced with `onlyAuthorizedTrap` modifier and private whitelist.  

5. **Event Emission**  
   - The response contract emits `TWAPTriggered(token, twapValue, triggeredBy)` for monitoring and automation.  

6. **Monitoring**  
   - Off-chain bots or dashboards listen for emitted events and trigger protocol-level defenses (pauses, alerts, etc.).  

---

## Prerequisites

- [Foundry](https://getfoundry.sh/) for compilation and deployment.  
- Drosera CLI for trap registration.  
- Ethereum wallet with funds on Hoodi testnet (**chain ID 560048**).  

---

## Deployment Steps

1. **Set Up Terminal**:  
   ```bash
   mkdir ~/twap_trap && cd ~/twap_trap
