// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Bill} from "../src/Bill.sol";

contract AccountTest is Test {
    Bill public bill;
    
    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        bill = new Bill();
    }

    function testDeposit() public {
        vm.deal(user1, 1 ether);
        vm.startPrank(user1);

        bill.deposit{value: 1 ether}(1 ether);
        assertEq(bill.Bal(user1), 1 ether, "Deposit failed");

        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.deal(user1, 1 ether);
        vm.startPrank(user1);

        bill.deposit{value: 1 ether}(1 ether);
        bill.withdraw(0.5 ether);
        assertEq(bill.Bal(user1), 0.5 ether, "Withdraw Failed!");

        vm.stopPrank();
    }

    function testIsOwner() public {
        vm.deal(user1, 1 ether);
        vm.startPrank(user1);

        bill.deposit{value: 1 ether}(1 ether);
        assertTrue(bill.isOwner(user1), "Not the owner!");

        vm.stopPrank();
    }

    function testWithdrawNotOwner() public {
        vm.startPrank(user2);

        vm.expectRevert("You Are not the owner");   
        bill.withdraw(0.1 ether);

        vm.stopPrank();
    }

    function testInsufficientBal() public {
        vm.deal(user1, 1 ether);
        vm.startPrank(user1);

        bill.deposit{value: 0.5 ether}(0.5 ether);
        vm.expectRevert("Insufficient Balance!");
        bill.withdraw(1 ether);

        vm.stopPrank(); 
    }
}
