// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Escrow {
    address public deployer;
    address public services;
    address public arbiter;
    uint public balance;

    constructor(address _services, address _arbiter) {
        deployer = msg.sender;
        services = _services;
        arbiter = _arbiter;
    }

    modifier onlyArbiter {
        require(msg.sender == arbiter, "You are not the arbiter!");
        _;
    }
    
    event depositSuccess(address indexed deployer, uint amount);
    event servicesPayed(address indexed arbiter, address indexed service, uint amount);
    event refundSuccess(address indexed arbiter, address indexed deployer, uint amount);

    function deposit() external payable {
        require(msg.sender == deployer, "You are not the deployer!");
        require(msg.value > 0, "Must send ether!");
        balance += msg.value;

        emit depositSuccess(msg.sender, msg.value);
    }

    function approvePayment() external payable onlyArbiter {
        require(balance > 0, "Deployer hasn't send ether!");

        uint amount = balance;
        (bool success,) = services.call{value: amount}("");
        require(success, "Failed!");
        balance = 0;

        emit servicesPayed(msg.sender, services, amount);
    }

    function refund() external payable onlyArbiter {
        require(balance > 0, "Deployer hasn't send ether!");

        uint amount = balance;
        (bool success,) = deployer.call{value: amount}("");
        require(success, "refund failed!");
        balance = 0;

        emit refundSuccess(msg.sender, deployer, amount);
    }
    
}
