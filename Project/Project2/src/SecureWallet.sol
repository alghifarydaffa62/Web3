// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SecureWallet {
    struct User {
        uint balances;
        bool isOwner;
    }

    mapping(address => User) public Owner;

    modifier onlyOwner {
         require(Owner[msg.sender].isOwner, "Not an owner!");
         _;
    }

    event registered(address indexed user);
    event deposited(address indexed user, uint amount);
    event withdrawn(address indexed user, uint amount);
    event transfered(address indexed sender, address indexed recipient, uint amount);

    function registerOwner() external {
        require(!Owner[msg.sender].isOwner, "Already registered");
        Owner[msg.sender].isOwner = true;
        emit registered(msg.sender);
    }

    function depositEther() external payable onlyOwner {
        require(msg.value > 0, "Must send ether!");
        Owner[msg.sender].balances += msg.value;
        emit deposited(msg.sender, msg.value);
    }

    function withdrawEther(uint amount) external payable onlyOwner {
        require(Owner[msg.sender].balances >= amount, "Insufficient balances!");

        Owner[msg.sender].balances -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Withdraw failed!");

        emit withdrawn(msg.sender, amount);
    }

    function Transfer(address recipient, uint amount) external payable onlyOwner {
        require(Owner[recipient].isOwner, "Recipient is not an owner!");
        require(Owner[msg.sender].balances >= amount, "Insufficient balances!");
        
        Owner[msg.sender].balances -= amount;
        Owner[recipient].balances += amount;

        emit transfered(msg.sender, recipient, amount);
    }

}
