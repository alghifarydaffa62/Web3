// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
 * @title CrowdFunding smart contract
 * @notice A decentralized crowdfunding contract where users 
    can create fundraising campaign and receive donations 
 */ 
contract CrowdFunding {
    // -------------------------
    // Stucts and Storage
    // -------------------------

    /**
     * @dev Represents a crowdfunding campaign
     */
    struct Campaign {
        address owner;
        uint ID;
        uint targetAmount;
        uint deadline;
        uint totalAmount;
        bool isComplete;
        mapping(address => uint) donates; // Mapping the donor to amount
    }

    mapping(uint => Campaign) private campaigns; // Mapping the campaign
    mapping(uint => address[]) private donors; // Mappinf the amount of donors
    uint public campaignCount; // Variable to track amount of campaign

    // ---------------------------
    // Events
    // ---------------------------

    /// @notice Emitted when a campaign successfully created
    event CampaignCreated(address indexed owner, uint target, uint deadline, uint ID);

    /// @notice Emitted when a donation successfully send to the campaign
    event DonateSuccess(address indexed donor, uint amount, uint campaignId);

    /// @notice Emitted when the campaign owner successfully withdraw the funds
    event Withdrawn(address indexed owner, uint amount, uint campaignId);

    // --------------------------
    // External Functions
    // --------------------------

    /**
     * @notice Allows anyone to create a new crowdfunding campaign
     * @param _targetAmount Set the target amount of the donation
     * @param _durationInSeconds Duration from now until deadline in seconds
     */
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

    /**
     * @notice Allows anyone to donate a specified campaign
     * @param _id Specified campaign id
     * @dev Successfully donate using this function will emit the DonateSuccess event
     * @dev The donor must specified a valid campaign id, or the donate will revert
     * @dev The donor can donate only to an active campaign, and the value greater than zero
     */
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

    /**
     * @notice Allows the campaign owner to withdraw all the collected funds
     * @param _id Specified campaign id
     * @dev The campaign owner must specified the valid and right 
        campaign id, or the withdraw will be reverted
     * @dev The campaign owner only can withdraw when the 
        campaign is complete and hasn't been withdrawn
     * @dev Successfully withdraw the collected funds will emit the withdrawn event
     */
    function withdraw(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.owner == msg.sender, "Not campaign owner");
        require(block.timestamp > campaign.deadline, "Campaign still active");
        require(!campaign.isComplete, "Already withdrawn");

        campaign.isComplete = true;
        uint amount = campaign.totalAmount;
        campaign.totalAmount = 0;

        (bool success, ) = payable(campaign.owner).call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawn(campaign.owner, amount, _id);
    }

    /**
     * @notice Allows donor to get information about the specified campaign
     * @param _id Specified campaign id
     * @return owner Owner of the campaign
     * @return targetAmount Target amount of the funding
     * @return deadline Timestamp of camapaign deadline
     * @return totalAmount Total collected so far
     * @return isComplete Campaign status
     */
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

    /**
     * @notice Returns list of all donors address
     * @param _id Campaign id
     */
    function getDonors(uint _id) external view returns (address[] memory) {
        return donors[_id];
    }
}