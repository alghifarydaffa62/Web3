// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";

contract CrowdFundingTest is Test {
    CrowdFunding public crowdfunding;
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

        uint campaignId = 0;

        (
            address campaignOwner,
            uint target,
            uint deadlineTime,
            uint totalAmount,
            bool isComplete
        ) = crowdfunding.getCampaign(campaignId);

        assertEq(campaignOwner, owner, "Owner mismatch");
        assertEq(target, targetAmount, "Target amount mismatch");
        assertApproxEqAbs(deadlineTime, block.timestamp + deadline, 1, "Deadline mismatch");
        assertEq(totalAmount, 0, "Initial total amount mismatch");
        assertFalse(isComplete, "Campaign should not be complete");
    }

    function testDonateAndValidateTotal() public {
        uint targetAmount = 10 ether;
        uint deadline = 1 days;

        crowdfunding.createCampaign(targetAmount, deadline);
        uint campaignId = 0;

        vm.deal(donor1, 5 ether);
        vm.startPrank(donor1);
        crowdfunding.donate{value: 5 ether}(campaignId);
        vm.stopPrank();

        vm.deal(donor2, 3 ether);
        vm.startPrank(donor2);
        crowdfunding.donate{value: 3 ether}(campaignId);
        vm.stopPrank();

        (, , , uint totalAmount, ) = crowdfunding.getCampaign(campaignId);
        assertEq(totalAmount, 8 ether, "Total amount mismatch");

        uint donation1 = crowdfunding.getDonation(campaignId, donor1);
        uint donation2 = crowdfunding.getDonation(campaignId, donor2);

        assertEq(donation1, 5 ether, "Donor1 donation mismatch");
        assertEq(donation2, 3 ether, "Donor2 donation mismatch");
    }

    function testWithdraw() public {
        uint targetAmount = 10 ether;
        uint deadline = 1 days;

        crowdfunding.createCampaign(targetAmount, deadline);
        uint campaignId = 0;

        vm.deal(donor1, 10 ether);
        vm.prank(donor1);
        crowdfunding.donate{value: 10 ether}(campaignId);

        vm.warp(block.timestamp + 2 days);

        uint initialBalance = address(owner).balance;

        crowdfunding.withdraw(campaignId);

        uint finalBalance = address(owner).balance;
        assertEq(finalBalance, initialBalance + 10 ether, "Owner withdrawal mismatch");

        (, , , uint totalAmount, bool isComplete) = crowdfunding.getCampaign(campaignId);
        assertEq(totalAmount, 0, "Total should be 0 after withdraw");
        assertTrue(isComplete, "Should be marked complete");
    }
}