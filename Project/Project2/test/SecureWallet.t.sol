// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {SecureWallet} from "../src/SecureWallet.sol";

contract SecureWallterTest is Test {
    SecureWallet private wallet;

    address private owner = address(1);
    address private owner2 = address(2);
    address private owner3 = address(3);

    function setUp() public {
        wallet = new SecureWallet();
    }

    function testRegisterOwner() public {
        vm.prank(owner2);
        wallet.registerOwner();

        (uint balances, bool isOwner) = wallet.Owner(owner2);
        assertTrue(isOwner);
        assertEq(balances, 0);
    }

    function testAlreadyRegistered() public {
        vm.prank(owner2);   
        wallet.registerOwner();

        vm.prank(owner2);
        vm.expectRevert("Already registered!");
        wallet.registerOwner();
    }

    function testDepositEther() public {
        vm.prank(owner2);
        wallet.registerOwner();

        vm.deal(owner2, 1 ether);
        vm.prank(owner2);
        wallet.depositEther{value: 1 ether}();

        (uint balances, ) = wallet.Owner(owner2);
        assertEq(balances, 1 ether);
    }

    function testDepositIfNotRegistered() public {
        vm.deal(owner2, 1 ether);
        vm.prank(owner2);
        vm.expectRevert("You are not an owner!");
        wallet.depositEther{value: 1 ether}();
    }

    function testWithdraw() public {
        vm.prank(owner2);
        wallet.registerOwner();

        vm.deal(owner2, 1 ether);
        vm.prank(owner2);
        wallet.depositEther{value: 1 ether}();

        vm.prank(owner2);
        wallet.withdrawEther(0.5 ether);

        (uint balances, ) = wallet.Owner(owner2);
        assertEq(balances, 0.5 ether);
    }

    function testWithdrawIfNotRegistered() public {
        vm.deal(owner2, 1 ether);
        vm.prank(owner2);
        vm.expectRevert("You are not an owner!");
        wallet.withdrawEther(0.5 ether);
    }

    function testWithdrawInsufficientBal() public {
        vm.prank(owner2);
        wallet.registerOwner();

        vm.deal(owner2, 1 ether);
        vm.prank(owner2);
        wallet.depositEther{value: 1 ether}();

        vm.prank(owner2);
        vm.expectRevert("Insufficient balances!");
        wallet.withdrawEther(2 ether);
    }

    function testTransfer() public {
        vm.prank(owner2);
        wallet.registerOwner();

        vm.prank(owner3);
        wallet.registerOwner();

        vm.deal(owner2, 2 ether);
        vm.prank(owner2);
        wallet.depositEther{value: 2 ether}();
        
        vm.prank(owner2);
        wallet.Transfer(owner3, 1 ether);

        (uint balanceSender, ) = wallet.Owner(owner2);
        (uint balanceRecipient, ) = wallet.Owner(owner3);

        assertEq(balanceSender, 1 ether);
        assertEq(balanceRecipient, 1 ether);
    }

    function testTransferToNotOwner() public {
        vm.prank(owner2);
        wallet.registerOwner();

        vm.deal(owner2, 1 ether);
        vm.prank(owner2);
        wallet.depositEther{value: 1 ether}();

        vm.prank(owner2);
        vm.expectRevert("Recipient is not an owner!");
        wallet.Transfer(owner3, 0.5 ether);
    }

    function testTransferInsufficientBalance() public {
        vm.prank(owner2);
        wallet.registerOwner();

        vm.prank(owner3);
        wallet.registerOwner();

        vm.deal(owner2, 1 ether);
        vm.prank(owner2);
        wallet.depositEther{value: 1 ether}();

        vm.prank(owner2);
        vm.expectRevert("Insufficient balances!");
        wallet.Transfer(owner3, 2 ether);
    }
}
