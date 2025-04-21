# 🔐 Secure Wallet Smart Contract

A simple yet secure Ethereum smart contract wallet that allows registered users (owners) to deposit, withdraw, and transfer Ether with complete control over their funds.

This contract is designed for **learning, prototyping, and testing**, and can be extended to integrate with front-end dApps or mobile wallets.

---

## 📌 Features

- ✅ Owner registration system
- 💰 Secure deposit and withdrawal system
- 🔁 Internal transfer between owners
- 🧾 Event logging for all key actions
- 🔒 Access control via `onlyOwner` modifier

---

## 🛠 Built With

- **Solidity** `^0.8.20`
- **Foundry** for testing, building, and local development
  - `forge`, `anvil`, and `cast` used throughout

---

## 🧠 Smart Contract Overview

### Structure

```solidity
struct User {
    uint balances;
    bool isOwner;
}
```

### Key Features
```solidity
registerOwner()
```
* Register sender as an owner
```solidity
depositEther()
```
* Deposit ETH to your wallet balance
```solidity
withdawEther(uint amount)
```
* Withdraw ETH from your wallet
```solidity
Transfer(address recipient, uint amount)
```
* Send ETH balance to another owner
