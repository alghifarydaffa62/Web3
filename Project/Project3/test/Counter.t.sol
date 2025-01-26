// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Charity} from "../src/Charity.sol";

contract CharityTest is Test {
    Charity private charity;

    address private owner = address(this);
    address private donor = address(0x123);
    address private recipient = address(0x456);

    function setUp() public {
        charity = new Charity();
    }

    function testTheOwner() public view {
        assertEq(charity.getOwner(), owner, "Owner should be the deployer");
    }

    function testDonate() public {
        vm.deal(donor, 1 ether);
        vm.prank(donor);
        charity.donate{value: 0.5 ether}();

        assertEq(address(charity).balance, 0.5 ether);
        assertEq(charity.TotalCharity(), 0.5 ether);
    }

    function testDonateWhenClosed() public {
        charity.closeCharity();

        vm.deal(donor, 1 ether);
        vm.prank(donor);
        vm.expectRevert("Charity donations are closed!");
        charity.donate{value: 0.5 ether}();
    }

    function testClosedCharityPermission() public {
        address nonOwner = address(0x789);

        vm.prank(nonOwner);
        vm.expectRevert("You are not the owner!");
        charity.closeCharity();
    }

    function testSendCharity() public {
        vm.deal(donor, 1 ether);
        vm.prank(donor);
        charity.donate{value: 1 ether}(); 

        charity.closeCharity();

        uint recipientInitialBalance = recipient.balance;

        vm.prank(owner); 
        charity.SendCharity(recipient);

        assertEq(address(charity).balance, 0, "Charity contract balance should be 0");
        assertEq(charity.TotalCharity(), 0, "TotalCharity should reset to 0");
        assertEq(
            recipient.balance,
            recipientInitialBalance + 1 ether,
            "Recipient should receive the full charity amount"
        );
    }

    function testSendCharityWhenActive() public {
        vm.expectRevert("Charity is still active!");
        charity.SendCharity(recipient);
    }
}
