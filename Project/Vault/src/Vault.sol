// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Vault {
    struct User {
        uint256 id;
        address owner;
        uint256 balance;
    }

    mapping(address => User) public users;
    uint256 public userCount;

    modifier onlyOwner() {
        require(users[msg.sender].owner != address(0), "You are not registered!");
        _;
    }
    
    event registered(address indexed user);
    
    function register() external {
        require(users[msg.sender].owner == address(0), "Already registered!");

        userCount++;
        users[msg.sender] = User({
            id: userCount,
            owner: msg.sender,
            balance: 0
        });

        emit registered(msg.sender);
    }

    function deposit() external payable onlyOwner() {
        require(msg.value > 0, "Must send ether!");
        users[msg.sender].balance += msg.value;

    }
}
