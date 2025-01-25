// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SecureWallet {
    struct User {
        uint balances;
        bool isOwner;
    }

    mapping(address => User) public Owner;

    constructor() {
        Owner[msg.sender].isOwner = true;
    }

    event deposited(address indexed user, uint amount);
    event withdrawn(address indexed user, uint amount);
    event transfered(address indexed sender, address indexed recipient, uint amount);

    function depositEther(uint amount) external payable {
        require(Owner[msg.sender].isOwner, "Not the owner!");
        require(amount > 0, "Must more than 0");
        Owner[msg.sender].balances += amount;
        emit deposited(msg.sender, amount);
    }

    function withdrawEther(uint amount) external payable {
        require(Owner[msg.sender].isOwner, "Not the owner!");
        require(Owner[msg.sender].balances >= amount, "Insufficient balances!");
        
        Owner[msg.sender].balances -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
        emit withdrawn(msg.sender, amount);
    }

    function Transfer(address recipient, uint amount) external payable {
        require(Owner[msg.sender].isOwner, "Not the owner!");
        require(Owner[msg.sender].balances >= amount, "Insufficient balances!");
        require(Owner[recipient].isOwner, "Not the owner!");
        
        Owner[msg.sender].balances -= amount;
        Owner[recipient].balances += amount;

        emit transfered(msg.sender, recipient, amount);
    }

}
