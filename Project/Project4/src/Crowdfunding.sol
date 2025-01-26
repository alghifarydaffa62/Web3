// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFunding {
    struct Campaign {
        address owner;
        uint targetAmount;
        uint deadline;
        uint totalAmount;
        bool isComplete;
        mapping(address => uint) donates;
    }

    mapping(uint => Campaign) public campaigns;
    uint campaignID;

    event CampaignCreated(address indexed owner, uint target, uint deadline);
    event donateSuccess(address indexed donor, uint amount);
    event withdrawn(address indexed owner, uint amount);
    event refunded(address indexed donor, uint amount);

    function createCampaign(uint _targetAmount, uint _deadline) external {
        campaignID++;
        Campaign storage campaign = campaigns[campaignID];
        campaign.owner = msg.sender;
        campaign.targetAmount = _targetAmount;
        campaign.deadline = block.timestamp + _deadline;
        campaign.totalAmount = 0;
        campaign.isComplete = false;

        emit CampaignCreated(msg.sender, _targetAmount, _deadline);
    }

    function donate(uint Id) external payable {
        Campaign storage campaign = campaigns[Id];
        require(!campaign.isComplete, "Campaign already closed!");
        require(block.timestamp <= campaign.deadline, "Campaign already expired!");
        require(msg.value > 0, "must send ether!");

        campaign.totalAmount += msg.value;
        campaign.donates[msg.sender] += msg.value;
        emit donateSuccess(msg.sender, msg.value);
    }

    function withdraw(uint Id) external payable {
        Campaign storage campaign = campaigns[Id];
        require(msg.sender == campaign.owner, "You are not the owner");
        require(campaign.totalAmount >= campaign.targetAmount, "Target has not been achieved");
        require(block.timestamp > campaign.deadline, "Campaign is still active!");
        require(!campaign.isComplete, "Funds already withdrawn!");

        campaign.isComplete = true;
        uint total = campaign.totalAmount;
    
        (bool success,) = msg.sender.call{value: total}("");
        require(success);
        campaign.totalAmount = 0;

        emit withdrawn(msg.sender, campaign.targetAmount);
    }

    function refund(uint Id) external payable {
        Campaign storage campaign = campaigns[Id];
        require(campaign.totalAmount < campaign.targetAmount, "Target is achieved! no refunds!");
        require(block.timestamp > campaign.deadline, "Campaign is still active!, no refunds!");
        require(!campaign.isComplete, "funds is withdrawn, no refunds!");

        uint donateAmount = campaign.donates[msg.sender];
        require(donateAmount > 0, "No donations, no refunds!");

        (bool success,) = msg.sender.call{value: donateAmount}("");
        require(success);
        campaign.donates[msg.sender] = 0;

        emit refunded(msg.sender, campaign.donates[msg.sender]);
    }
}
