// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowTesting is Test {
    Escrow public escrow;
    address deployer = address(0x1);
    address services = address(0x2);
    address arbiter = address(0x3);

    function setUp() public {
        vm.deal(deployer, 10 ether); 
        vm.deal(services, 0 ether); 
        vm.deal(arbiter, 0 ether); 

        escrow = new Escrow(services, arbiter);
    }

    function testDeposit() public {
        vm.prank(deployer);
        vm.deal(deployer, 10 ether); 
        escrow.deposit{value: 5 ether}();

        assertEq(address(escrow).balance, 5 ether, "Balance should be 5 ether");
    }

    function testReleaseFunds() public {
        vm.prank(deployer);
        escrow.deposit{value: 5 ether}();

        uint beforeBalance = services.balance;

        vm.prank(arbiter);
        escrow.approvePayment();

        assertEq(address(escrow).balance, 0, "Balance should be 0 after release");
        assertEq(services.balance, beforeBalance + 5 ether, "Services should receive funds");
    }

    function testRefund() public {
        vm.prank(deployer);
        escrow.deposit{value: 5 ether}();

        uint beforeBalance = deployer.balance;

        vm.prank(arbiter);
        escrow.refund();

        assertEq(address(escrow).balance, 0, "Balance should be 0 after refund");
        assertEq(deployer.balance, beforeBalance + 5 ether, "Deployer should get refunded");
    }

    function testOnlyArbiterCanReleaseFunds() public {
        vm.prank(deployer);
        escrow.deposit{value: 5 ether}();

        vm.prank(deployer);
        vm.expectRevert("You are not the arbiter!");
        escrow.approvePayment();
    }

    function testOnlyArbiterCanRefund() public {
        vm.prank(deployer);
        escrow.deposit{value: 5 ether}();

        vm.prank(deployer);
        vm.expectRevert("You are not the arbiter!");
        escrow.refund();
    }

    function testCannotDepositFromNonDeployer() public {
        vm.prank(arbiter);
        vm.expectRevert("You are not the deployer!");
        escrow.deposit{value: 5 ether}();
    }

    function testCannotDepositZeroEther() public {
        vm.prank(deployer);
        vm.expectRevert("You are not the deployer!");
        escrow.deposit{value: 0}();
    }

    function testCannotReleaseFundsIfBalanceIsZero() public {
        vm.prank(arbiter);
        vm.expectRevert("Deployer hasn't send ether!");
        escrow.approvePayment();
    }

    function testCannotRefundIfBalanceIsZero() public {
        vm.prank(arbiter);
        vm.expectRevert("Deployer hasn't send ether!");
        escrow.refund();
    }
}
