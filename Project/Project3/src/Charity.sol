// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Charity {
    address private owner;
    uint public TotalCharity;
    bool isActive;

    constructor() {
        owner = msg.sender;
        isActive = true;
    }

    modifier onlyOwner { 
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    event donateSuccess(address indexed donator, uint amount);
    event CharitySended(address indexed owner, address indexed recipient, uint amount);
    event CharityClosed(address indexed owner);

    function donate() external payable {
        require(msg.value > 0, "Must send ether!");
        require(isActive, "Charity donations are closed!");

        TotalCharity += msg.value;

        emit donateSuccess(msg.sender, msg.value);
    }

    function SendCharity(address recipient) external payable onlyOwner {
        require(!isActive, "Charity is still active!");
        require(recipient != address(0), "Invalid recipient address!");

        uint amount = TotalCharity;
        (bool success, ) = recipient.call{value: amount}("");
        require(success);
        TotalCharity = 0;

        emit CharitySended(msg.sender, recipient, amount);
    }

    function closeCharity() external onlyOwner {
        isActive = false;
        emit CharityClosed(msg.sender);
    }

    function getStatus() external view returns(bool) {
        return isActive;
    }

    function getOwner() external view returns(address) {
        return owner;
    }
}
