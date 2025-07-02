# Escrow Smart Contract

A secure and transparent escrow smart contract built on Ethereum that facilitates safe transactions between service providers and clients with third-party arbitration.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Contract Architecture](#contract-architecture)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Functions](#functions)
- [Events](#events)
- [Security Considerations](#security-considerations)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

## 🔍 Overview

This Escrow smart contract provides a secure payment mechanism for service transactions where:
- A **Deployer** (client) deposits funds
- A **Service Provider** delivers services
- An **Arbiter** (trusted third party) makes the final decision to either release funds to the service provider or refund to the client

The contract eliminates the need for traditional escrow services and provides transparency through blockchain technology.

## ✨ Features

- **Secure Fund Holding**: Funds are locked in the smart contract until resolution
- **Third-Party Arbitration**: Neutral arbiter makes final decisions
- **Transparent Operations**: All transactions are recorded on the blockchain
- **Event Logging**: Comprehensive event emission for tracking
- **Access Control**: Role-based permissions for different participants
- **Gas Efficient**: Optimized for minimal gas consumption

## 🏗️ Contract Architecture

### Participants

1. **Deployer**: The party that deploys the contract and deposits funds
2. **Service Provider**: The party that will receive payment upon successful completion
3. **Arbiter**: The neutral third party who decides the outcome

### State Variables

- `deployer`: Address of the contract deployer (payer)
- `services`: Address of the service provider
- `arbiter`: Address of the arbiter
- `balance`: Current balance held in escrow

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://getfoundry.sh/) toolkit
- Git
- MetaMask or similar Web3 wallet

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd escrow-smart-contract

# Install Foundry dependencies
forge install

# Initialize Foundry project (if not already done)
forge init --force
```

### Environment Setup

Create a `.env` file in the root directory:

```env
PRIVATE_KEY=your_private_key_here
RPC_URL=your_rpc_url_here
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## 📖 Usage

### 1. Contract Deployment

Deploy the contract with the service provider and arbiter addresses:

```bash
# Deploy using Forge
forge create --rpc-url $RPC_URL --private-key $PRIVATE_KEY src/Escrow.sol:Escrow --constructor-args <SERVICE_PROVIDER_ADDRESS> <ARBITER_ADDRESS>

# Or using deployment script
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### 2. Interact with Contract

Use cast for contract interactions:

```bash
# Deposit funds (replace with actual contract address)
cast send <CONTRACT_ADDRESS> "deposit()" --value 1ether --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Approve payment (as arbiter)
cast send <CONTRACT_ADDRESS> "approvePayment()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Refund (as arbiter)
cast send <CONTRACT_ADDRESS> "refund()" --rpc-url $RPC_URL --private-key $PRIVATE_KEY
```

### 3. Query Contract State

```bash
# Check balance
cast call <CONTRACT_ADDRESS> "balance()" --rpc-url $RPC_URL

# Check deployer address
cast call <CONTRACT_ADDRESS> "deployer()" --rpc-url $RPC_URL

# Check service provider address
cast call <CONTRACT_ADDRESS> "services()" --rpc-url $RPC_URL
```

## 🔧 Functions

### Public Functions

#### `deposit()`
- **Caller**: Deployer only
- **Purpose**: Deposit Ether into the escrow
- **Requirements**: Must send Ether (value > 0)
- **Emits**: `depositSuccess`

#### `approvePayment()`
- **Caller**: Arbiter only
- **Purpose**: Release all funds to the service provider
- **Requirements**: Balance must be > 0
- **Emits**: `servicesPayed`

#### `refund()`
- **Caller**: Arbiter only
- **Purpose**: Refund all funds to the deployer
- **Requirements**: Balance must be > 0
- **Emits**: `refundSuccess`

### View Functions

- `deployer()`: Returns the deployer's address
- `services()`: Returns the service provider's address
- `arbiter()`: Returns the arbiter's address
- `balance()`: Returns the current escrow balance

## 📡 Events

```solidity
event depositSuccess(address indexed deployer, uint amount);
event servicesPayed(address indexed arbiter, address indexed service, uint amount);
event refundSuccess(address indexed arbiter, address indexed deployer, uint amount);
```

## 🧪 Testing

Run the comprehensive test suite using Forge:

```bash
# Run all tests
forge test

# Run tests with detailed output
forge test -vvv

# Run specific test contract
forge test --match-contract EscrowTesting

# Run specific test function
forge test --match-test testDeposit
```

### Test Structure

The test suite (`test/Escrow.t.sol`) includes comprehensive testing with:

```solidity
contract EscrowTesting is Test {
    // Test setup with proper address allocation
    // Complete functional and security testing
}
```

### Detailed Test Coverage

**✅ Core Functionality Tests:**
- `testDeposit()` - Validates successful Ether deposits
- `testReleaseFunds()` - Confirms fund release to service provider
- `testRefund()` - Verifies refund mechanism to deployer

**✅ Access Control Tests:**
- `testOnlyArbiterCanReleaseFunds()` - Ensures only arbiter can approve payments
- `testOnlyArbiterCanRefund()` - Confirms only arbiter can issue refunds
- `testCannotDepositFromNonDeployer()` - Blocks unauthorized deposits

**✅ Input Validation Tests:**
- `testCannotDepositZeroEther()` - Prevents zero-value deposits
- `testCannotReleaseFundsIfBalanceIsZero()` - Blocks payment when no funds
- `testCannotRefundIfBalanceIsZero()` - Prevents refund when no funds

**✅ State Management:**
- Balance tracking accuracy
- Contract state changes
- Ether transfer verification
- Address balance assertions

### Test Features

- **Comprehensive Setup**: Proper address allocation with `vm.deal()`
- **Role-Based Testing**: Separate test addresses for deployer, services, and arbiter
- **Revert Testing**: Extensive use of `vm.expectRevert()` for error conditions
- **State Verification**: Balance checks before and after operations
- **Edge Case Coverage**: Zero amounts, unauthorized access, empty balances

## 🚢 Deployment

### Local Network

```bash
# Start local Anvil node
anvil

# Deploy to local network
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast
```

### Testnet Deployment

```bash
# Deploy to Sepolia testnet
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

# Or using forge create
forge create --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY src/Escrow.sol:Escrow --constructor-args <SERVICE_PROVIDER> <ARBITER> --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Mainnet Deployment

```bash
# Deploy to Ethereum mainnet
forge script script/Deploy.s.sol --rpc-url $MAINNET_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY

# Double-check deployment
cast code <DEPLOYED_CONTRACT_ADDRESS> --rpc-url $MAINNET_RPC_URL
```

### Deployment Script Example

Create `script/Deploy.s.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Escrow.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address serviceProvider = vm.envAddress("SERVICE_PROVIDER");
        address arbiter = vm.envAddress("ARBITER");
        
        vm.startBroadcast(deployerPrivateKey);
        
        Escrow escrow = new Escrow(serviceProvider, arbiter);
        
        vm.stopBroadcast();
        
        console.log("Escrow deployed to:", address(escrow));
    }
}
```

## 🛠️ Development Tools

### Foundry Commands

```bash
# Compile contracts
forge build

# Format code
forge fmt

# Update dependencies
forge update

# Generate documentation
forge doc

# Analyze contract sizes
forge build --sizes

# Static analysis
slither src/Escrow.sol
```

### Development Guidelines

- Follow Solidity style guide
- Add comprehensive tests for new features
- Update documentation for any changes
- Use conventional commit messages

## 👨‍💻 Author

**M Daffa Al Ghifary (alghifarydaffa62)**

## ⚠️ Disclaimer

This smart contract is provided as-is. Users should conduct their own security audits before using in production. The authors are not responsible for any loss of funds or damages resulting from the use of this contract.

---

*Built with ❤️ for the Ethereum community*