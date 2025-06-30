// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Escrow smart contract
 * @author [M Daffa Al Ghifary a.k.a dfpro]
 * @notice A smart contract for securing payments 
    between a service provider and a deployer with an arbiter as the third party
 * @dev The arbiter has the authority to either release the funds to the service provide
    or refund to the deployer
 */
contract Escrow {
    /// @notice Address of the person deploying the contract (payer)
    address public deployer;

    /// @notice Address of the service provider
    address public services;

    /// @notice Address of the third party (decision maker)
    address public arbiter;

    /// @notice Balance held in the escrow
    uint public balance;

    /**
     * @notice Constructor sets up the contract participants
     * @param _services Address of the service provider
     * @param _arbiter Address of the third party (decision maker)
     */
    constructor(address _services, address _arbiter) {
        deployer = msg.sender;
        services = _services;
        arbiter = _arbiter;
    }

    // ------------------------
    // Modifier
    // ------------------------
    
    /// @dev Restricts the access to only the arbiter
    modifier onlyArbiter {
        require(msg.sender == arbiter, "You are not the arbiter!");
        _;
    }
    
    // ------------------------
    // Events
    // ------------------------

    /// @notice Emitted when the deployer successfully deposit ether to the escrow
    event depositSuccess(address indexed deployer, uint amount);

    /// @notice Emitted when the arbiter approves the payment to the service provider
    event servicesPayed(address indexed arbiter, address indexed service, uint amount);

    /// @notice Emitted when the arbiter refunds to the deployer
    event refundSuccess(address indexed arbiter, address indexed deployer, uint amount);

    // --------------------------
    // External Functions
    // --------------------------

    /**
     * @notice Allows the deployer to deposit ether to the escrow.
     * @dev Only the deployer can deposit ether, and the value must be more than zero.
     * @dev Successfully deposit ether will emit the depositSuccess event.
     */
    function deposit() external payable {
        require(msg.sender == deployer, "You are not the deployer!");
        require(msg.value > 0, "Must send ether!");
        balance += msg.value;

        emit depositSuccess(msg.sender, msg.value);
    }

    /**
     * @notice Allows the arbiter to approve and send all the escrow balance to the service provider.
     * @dev Only the arbiter can call this function, and the deployer must have deposited ether.
     * @dev Successfully send the funds to the service provider will emit the servicesPayed event.
     */
    function approvePayment() external payable onlyArbiter {
        require(balance > 0, "Deployer hasn't send ether!");

        uint amount = balance;
        (bool success,) = services.call{value: amount}("");
        require(success, "Failed!");
        balance = 0;

        emit servicesPayed(msg.sender, services, amount);
    }

    /**
     * @notice Allows the arbiter to refunds all the balance to the deployer of the contract.
     * @dev Only arbiter can call this function and the deployer must have deposited ether.
     * @dev Successfully refund to the deployer will emit the refundSuccess event. 
     */
    function refund() external payable onlyArbiter {
        require(balance > 0, "Deployer hasn't send ether!");

        uint amount = balance;
        (bool success,) = deployer.call{value: amount}("");
        require(success, "refund failed!");
        balance = 0;

        emit refundSuccess(msg.sender, deployer, amount);
    }
    
}
