// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Account {
    mapping(address => uint) public balances;

    event deposited(address indexed user, uint amount);
    event withdrawn(address indexed user, uint amount);

    function isOwner(address x) public view returns(bool) {
        return balances[x] > 0;
    }

    function deposit(uint amount) external payable {
        require(amount > 0, "Must send ether");
        balances[msg.sender] += amount;
        emit deposited(msg.sender, amount);
    }

    function withdraw(uint amount) external payable {
        require(isOwner(msg.sender), "Not the owner!");
        require(balances[msg.sender] >= amount, "Insufficient balance!");

        balances[msg.sender] -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
        
        emit withdrawn(msg.sender, amount);
    }

    function Bal(address x) public view returns(uint) {
        return balances[x];
    }
}
