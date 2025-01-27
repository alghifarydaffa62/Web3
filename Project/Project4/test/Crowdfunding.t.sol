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

        crowdfunding.createCampaign(targetAmount, deadline);

        uint campaignId = getMockedCampaignId();

        (address campaignOwner, uint ID, uint target, uint deadlineTime, uint totalAmount, bool isComplete) = crowdfunding.campaigns(campaignId);
        assertEq(campaignOwner, owner, "Owner mismatch");
        assertEq(ID, campaignId, "ID mismatch");
        assertEq(target, targetAmount, "Target amount mismatch");
        assertApproxEqAbs(deadlineTime, block.timestamp + deadline, 1, "Deadline mismatch");
        assertEq(totalAmount, 0, "Initial total amount mismatch");
        assertFalse(isComplete, "Campaign should not be complete");
    }

    function testDonateAndValidateTotal() public {
        uint targetAmount = 10 ether;
        uint deadline = 1 days;

        crowdfunding.createCampaign(targetAmount, deadline);
        uint campaignId = getMockedCampaignId();

        vm.prank(donor1);
        vm.deal(donor1, 5 ether);
        crowdfunding.donate{value: 5 ether}(campaignId);

        vm.prank(donor2);
        vm.deal(donor2, 3 ether);
        crowdfunding.donate{value: 3 ether}(campaignId);

        (, , , , uint totalAmount, ) = crowdfunding.campaigns(campaignId);
        assertEq(totalAmount, 8 ether, "Total amount mismatch");
    }

    function testWithdraw() public {
        uint targetAmount = 10 ether;
        uint deadline = 1 days;

        crowdfunding.createCampaign(targetAmount, deadline);
        uint campaignId = getMockedCampaignId();

        vm.prank(donor1);
        vm.deal(donor1, 10 ether);
        crowdfunding.donate{value: 10 ether}(campaignId);

        vm.warp(block.timestamp + 2 days);

        uint initialBalance = address(owner).balance;
        crowdfunding.withdraw(campaignId);
        uint finalBalance = address(owner).balance;

        assertEq(finalBalance, initialBalance - 10 ether, "Owner withdrawal mismatch");

        (, , , , uint totalAmount, bool isComplete) = crowdfunding.campaigns(campaignId);
        assertEq(totalAmount, 0, "Campaign total amount should be zero after withdrawal");
        assertTrue(isComplete, "Campaign should be marked as complete");
    }

    function testRefund() public {
        uint targetAmount = 10 ether;
        uint deadline = 1 days;

        crowdfunding.createCampaign(targetAmount, deadline);
        uint campaignId = getMockedCampaignId();

        vm.prank(donor1);
        vm.deal(donor1, 5 ether);
        crowdfunding.donate{value: 5 ether}(campaignId);

        vm.warp(block.timestamp + 2 days);

        uint initialBalance = donor1.balance;
        vm.prank(donor1);
        crowdfunding.refund(campaignId);
        uint finalBalance = donor1.balance;

        assertEq(finalBalance, initialBalance + 5 ether, "Refund amount mismatch");
    }

    function getMockedCampaignId() internal view returns (uint) {
        uint hash = uint(keccak256(abi.encodePacked(owner, block.timestamp, uint256(1))));
        return hash % 100000000;
    }

    
}
