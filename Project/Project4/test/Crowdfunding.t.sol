// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CrowdFunding} from "../src/Crowdfunding.sol";

contract CrowdFundingTest is Test {
    CrowdFunding private crowdfunding;
    address owner;
    address donor1;
    address donor2;

    function setUp() public {
        crowdfunding = new CrowdFunding();
        owner = address(this);
        donor1 = vm.addr(1);
        donor2 = vm.addr(2);
    }

    function testCreateCampaign() public {
        uint targetAmount = 10 ether;
        uint deadline = 1 days;

        vm.prank(owner);
        crowdfunding.createCampaign(targetAmount, deadline);

        // uint count = crowdfunding.campaignCount();
        // assertEq(count, 1);

        (address campaignOwner, uint target, 
            uint timedeadline, uint totalAmount, bool isComplete) = crowdfunding.getCampaignDetails(1);
        assertEq(campaignOwner, owner);
        assertEq(target, targetAmount);
        assertEq(timedeadline, block.timestamp + deadline);
        assertEq(totalAmount, 0);
        assertEq(isComplete, false);
    }

    function testDonateCampaign() public {
        uint targetAmount = 10 ether;
        uint deadline = 1 days;

        vm.prank(owner);
        crowdfunding.createCampaign(targetAmount, deadline);

        vm.prank(donor1);
        vm.deal(donor1, 5 ether);
        crowdfunding.donate{value: 2 ether}(1);

        (,, uint totalAmount,) = crowdfunding.getCampaignDetails(1);
        assertEq(totalAmount, 2 ether);

        uint donorBalance = crowdfunding.getDonorBalance(1, donor1);
        assertEq(donorBalance, 2 ether);
    }
}
