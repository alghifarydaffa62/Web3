// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFunding {
    struct Campaign {
        address owner;
        uint ID;
        uint targetAmount;
        uint deadline;
        uint totalAmount;
        bool isComplete;
        mapping(address => uint) donates;
    }

    mapping(uint => Campaign) private campaigns;
    mapping(uint => address[]) private donors;
    uint public campaignCount;

    event CampaignCreated(address indexed owner, uint target, uint deadline, uint ID);
    event DonateSuccess(address indexed donor, uint amount, uint campaignId);
    event Withdrawn(address indexed owner, uint amount, uint campaignId);
    event Refunded(address indexed donor, uint amount, uint campaignId);

    function createCampaign(uint _targetAmount, uint _durationInSeconds) external {
        uint id = campaignCount++;
        Campaign storage campaign = campaigns[id];

        campaign.owner = msg.sender;
        campaign.ID = id;
        campaign.targetAmount = _targetAmount;
        campaign.deadline = block.timestamp + _durationInSeconds;
        campaign.totalAmount = 0;
        campaign.isComplete = false;

        emit CampaignCreated(msg.sender, _targetAmount, campaign.deadline, id);
    }

    function donate(uint _id) external payable {
        Campaign storage campaign = campaigns[_id];
        require(campaign.owner != address(0), "Campaign does not exist");
        require(!campaign.isComplete, "Campaign already complete");
        require(block.timestamp <= campaign.deadline, "Campaign expired");
        require(msg.value > 0, "Must send ETH");

        if (campaign.donates[msg.sender] == 0) {
            donors[_id].push(msg.sender);
        }

        campaign.totalAmount += msg.value;
        campaign.donates[msg.sender] += msg.value;

        emit DonateSuccess(msg.sender, msg.value, _id);
    }

    function withdraw(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.owner == msg.sender, "Not campaign owner");
        require(block.timestamp > campaign.deadline, "Campaign still active");
        require(!campaign.isComplete, "Already withdrawn");
        require(campaign.totalAmount >= campaign.targetAmount, "Target not reached");

        campaign.isComplete = true;
        uint amount = campaign.totalAmount;
        campaign.totalAmount = 0;

        (bool success, ) = payable(campaign.owner).call{value: amount}("");
        require(success, "Transfer failed");
    }

    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.owner != address(0), "Campaign does not exist");
        require(block.timestamp > campaign.deadline, "Campaign still active");
        require(campaign.totalAmount < campaign.targetAmount, "Target reached");
        require(!campaign.isComplete, "Already completed");

        uint donated = campaign.donates[msg.sender];
        require(donated > 0, "No donations to refund");

        campaign.donates[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: donated}("");
        require(success, "Refund failed");

        emit Refunded(msg.sender, donated, _id);
    }

    function getDonation(uint _id, address _donor) external view returns (uint) {
        return campaigns[_id].donates[_donor];
    }

    function getCampaign(uint _id)
        external
        view
        returns (
            address owner,
            uint targetAmount,
            uint deadline,
            uint totalAmount,
            bool isComplete
        )
    {
        Campaign storage c = campaigns[_id];
        return (c.owner, c.targetAmount, c.deadline, c.totalAmount, c.isComplete);
    }

    function getDonors(uint _id) external view returns (address[] memory) {
        return donors[_id];
    }
}

