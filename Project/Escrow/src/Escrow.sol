// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Escrow {
    address public deployer;
    address public services;
    address public arbiter;
    uint money;

    constructor(address _services, address _arbiter) {
        deployer = msg.sender;
        services = _services;
        arbiter = _arbiter;
    }
    
    event transferSuccess(address indexed deployer, uint amount);

    function Transfer() external payable {
        require(msg.sender == deployer, "You are not the deployer!");
        require(msg.value > 0, "Must send ether!");
        money += msg.value;
        emit transferSuccess(msg.sender, msg.value);
    }

    
}
