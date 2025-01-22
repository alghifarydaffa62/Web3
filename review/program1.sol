// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Account {
    mapping(address => uint) public balances;

    function isOwner() external {

    }

    event deposited(address indexed user, uint amount);
    event withdrawn(address indexed user, uint amount);

    function deposit(uint amount) external payable {
        require(amount > 0, "0 ether means no ether mate");
        balances[msg.sender] += amount;
        emit deposited(msg.sender, amount);
    }

    function withdraw(uint amount) external payable {
        require(balances[msg.sender] >= amount, "insufficient balance");
        balances[msg.sender] -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success);
    }

    function Bal(address user) external view returns(uint){
        return balances[user];
    }
}