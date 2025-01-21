// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Account {
    address public User;

    constructor(address deployer) {
        User = deployer;
    }

    mapping(address => uint) identify;

    receive() external payable {
        identify[msg.sender] += msg.value;
    }

    function Transfer(uint amount) external {
        require(identify[msg.sender] >= amount);
        identify[msg.sender] -= amount;

        (bool success,) = address(this).call{value: amount} ("");
        require(success);
    }   

    function withdraw() external {
        
    }

}