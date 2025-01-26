// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFunding {
    struct Campaign {
        uint targetAmount;
        uint deadline;
        uint totalAmount;
        bool isComplete;
        bool isOwner;
    }

    mapping(address => Campaign) public campaigns;

    function registerOwner() external {
        campaigns[msg.sender].isOwner = true;
    }

    function createCampaign(uint _targetAmount, uint _deadline) external {
        require(campaigns[msg.sender].isOwner, "You need to register first!");
        campaigns[msg.sender] = Campaign({
            targetAmount: _targetAmount,
            deadline: block.timestamp + _deadline,
            totalAmount: 0,
            isComplete: false,
            isOwner: true
        });
    }

    function donate() external payable {
        require(msg.value > 0, "Need to send ether!");
        campaigns[msg.sender].totalAmount += msg.value;
    }
}
