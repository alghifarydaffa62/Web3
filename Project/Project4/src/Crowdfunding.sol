// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFunding {
    struct Campaign {
        address owner;
        uint targetAmount;
        uint deadline;
        uint totalAmount;
        bool isComplete;
    }

    mapping(uint => Campaign) public campaigns;
    uint campaignID;

    event CampaignCreated(address indexed owner, uint target, uint deadline);
    event donateSuccess(address indexed donor, uint amount);

    function createCampaign(uint _targetAmount, uint _deadline) external {
        campaignID++;
        campaigns[campaignID] = Campaign({
            owner: msg.sender,
            targetAmount: _targetAmount,
            totalAmount: 0,
            deadline: block.timestamp + _deadline,
            isComplete: false
        });

        emit CampaignCreated(msg.sender, _targetAmount, _deadline);
    }

    function donate(uint Id) external payable {
        Campaign storage campaign = campaigns[Id];
        require(!campaign.isComplete, "Campaign already closed!");
        require(block.timestamp <= campaign.deadline, "Campaign already expired!");
        require(msg.value > 0, "must send ether!");

        campaign.totalAmount += msg.value;
        emit donateSuccess(msg.sender, msg.value);
    }

    function withdraw(uint Id) external payable {
        Campaign storage campaign = campaigns[Id];
        require(campaign.totalAmount == campaign.targetAmount);
        require(block.timestamp > campaign.deadline, "Campaign is still active!");
        require(!campaign.isComplete);
    }
}
