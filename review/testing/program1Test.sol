// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/program1.sol";

contract AccountTest is Test {
    Account public account;

    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() public {
        account = new Account();
    }

    function testDeposit() public {
        vm.deal(user1, 2 ether);
        vm.startPrank(user1);


        account.deposit{value: 1 ether}(1 ether);
        assertEq(account.Bal(user1), 1 ether, "Deposit failed");

        vm.stopPrank();
    }

    function testWithdraw() public {
        vm.deal(user1, 2 ether);
        vm.startPrank(user1);

        account.deposit{value: 1 ether}(1 ether);
        account.withdraw(0.5 ether);
        assertEq(account.Bal(user1), 0.5 ether, "Withdraw Failed!");

        vm.stopPrank();
    }

    function testIsOwner() public {
        vm.deal(user1, 1 ether);
        vm.startPrank(user1);

        account.deposit{value: 1 ether}(1 ether);
        assertTrue(account.isOwner(user1), "Not the owner!");

        vm.stopPrank();
    }

    function testWithdrawNotOwner() public {
        vm.startPrank(user2);

        vm.expectRevert("You Are not the owner");   
        account.withdraw(0.1 ether);

        vm.stopPrank();
    }

    function testInsufficientBal() public {
        vm.deal(user1, 1 ether);
        vm.startPrank(user1);

        account.deposit{value: 0.5 ether}(0.5 ether);
        vm.expectRevert("Insufficient Balance!");
        account.withdraw(1 ether);

        vm.stopPrank(); 
    }


}