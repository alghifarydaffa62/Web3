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

    function testAlreadyRegistered() external {
        vm.prank(owner2);   
        wallet.registerOwner();

        vm.prank(owner2);
        vm.expectRevert("Already Registered!");
        wallet.registerOwner();
    }

    function testDepositEther() external {
        vm.prank(owner2);
        wallet.registerOwner();

        vm.deal(owner2, 1 ether);
        vm.prank(owner2);
        wallet.depositEther{value: 1 ether}();

        (uint balances, ) = wallet.Owner(owner2);
        assertEq(balances, 1 ether);
    }

    function testDepositIfNotRegistered() external {
        vm.prank(owner2);
        vm.deal(owner2, 1 ether);
        vm.expectRevert("Your are not an owner!");
        wallet.depositEther{value: 1 ether}();
    }

    function testWithdraw() external {
        vm.prank(owner2);
        wallet.registerOwner();

        vm.deal(owner2, 1 ether);
        vm.prank(owner2);
        wallet.depositEther{value: 1 ether}();

    }
}
