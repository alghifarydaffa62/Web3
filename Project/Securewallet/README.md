# 🔐 Secure Wallet Smart Contract

A simple yet secure Ethereum smart contract wallet that allows registered users (owners) to deposit, withdraw, and transfer Ether with complete control over their funds.

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
* Register sender as an owner
```solidity
registerOwner()
```
* Deposit ETH to your wallet balance
```solidity
depositEther()
```
* Withdraw ETH from your wallet
```solidity
withdawEther(uint amount)
```
* Send ETH balance to another owner
```solidity
Transfer(address recipient, uint amount)
```
# 🧪 Getting Started (Local Development with Foundry)
1. Install Foundry: Follow the instructions on the Foundry Book.
2. Clone the Repository (if applicable):
3. Compile the Contract:
4. Start a Local Development Network: This will start a local Ethereum network.
5. Deploy the Contract (using forge create in a separate terminal): Replace [your-private-key] with the private key of an account on your local network.
6. Interact with the Contract (using cast in a separate terminal): You can use cast to call the contract's functions. For example, to register an owner: To deposit Ether: Replace [contract-address] with the address of your deployed contract and adjust the value and function arguments as needed.
