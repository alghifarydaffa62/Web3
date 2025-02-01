// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Payroll} from "../src/Payroll.sol";

contract PayrollTest is Test {
    Payroll public payroll;

    address admin = address(0x123);
    address employee1 = address(0x456);
    address employee2 = address(0x789);

    function setUp() public {
        payroll = new Payroll();
    }

    function testDeposit() public {
        vm.deal(admin, 20 ether);
        vm.prank(admin);
        payroll.deposit{value: 18 ether}();

        assertEq(address(payroll).balance, 18 ether, "imbalance!");
    }

    function testDepositNotAdmin() public {
        vm.deal(employee1, 10 ether);
        vm.prank(employee1);
        vm.expectRevert("only Admin!");
        payroll.deposit{value: 8 ether}();
    }

    function testDepositZeroEther() public {
        vm.prank(admin);
        vm.expectRevert("Must send ether!");
        payroll.deposit{value: 0 ether}();
    }

    function testAddEmployee() public {
        vm.prank(admin);
        payroll.addEmployee(employee1, 6 ether);
    }

    function testAddEmployeeNotAdmin() public {
        vm.prank(employee1);
        vm.expectRevert("only Admin!");
        payroll.addEmployee(employee2, 8 ether);
    }

    function testAddEmployeeZeroSalary() public {
        vm.prank(admin);
        vm.expectRevert("Salary can't be zero!");
        payroll.addEmployee(employee1, 0 ether);
    }

    function testAddEmployeeAlreadyRegistered() public {
        vm.prank(admin);
        payroll.addEmployee(employee1, 6 ether);

        vm.prank(admin);
        vm.expectRevert("Employee already registered!");
        payroll.addEmployee(employee1, 6 ether);
    }

    function testPaySalary() public {
        vm.deal(admin, 20 ether);
        vm.prank(admin);
        payroll.deposit{value: 18 ether}();
        assertEq(address(payroll).balance, 18 ether, "imbalance!");

        vm.prank(admin);
        payroll.addEmployee(employee1, 6 ether);

        vm.prank(admin);
        payroll.addEmployee(employee2, 8 ether);
        // assertEq(payroll.totalSalaries, 14 ether, "imbalance!"); masih bingung

        vm.prank(admin);
        payroll.paySalaries();
    }

    function testPaySalaryImbalance() public {
        vm.deal(admin, 10 ether);
        vm.prank(admin);
        payroll.deposit{value: 10 ether};
        assertEq(address(payroll).balance, 10 ether, "imbalance!");

        vm.prank(admin);
        payroll.addEmployee(employee1, 6 ether);

        vm.prank(admin);
        payroll.addEmployee(employee2, 8 ether);

        vm.prank(admin);
        vm.expectRevert("Not enough balance to pay salary!");
        payroll.paySalaries();
    }

    function testPaySalaryNotAdmin() public {
        vm.deal(admin, 10 ether);
        vm.prank(admin);
        payroll.deposit{value: 10 ether};
        assertEq(address(payroll).balance, 10 ether, "imbalance!");

        vm.prank(employee1);
        vm.expectRevert("only Admin!");
        payroll.paySalaries();
    }

    function testRemoveEmployee() public {
        vm.prank(admin);
        payroll.addEmployee(employee1, 6 ether);

        vm.prank(admin);
        payroll.addEmployee(employee2, 6 ether);

        vm.prank(admin);
        payroll.removeEmployee(employee1);
    }

    function testRemoveEmployeeNotAdmin() public {
        vm.prank(admin);
        payroll.addEmployee(employee1, 6 ether);

        vm.prank(admin);
        payroll.addEmployee(employee2, 6 ether);

        vm.prank(employee1);
        vm.expectRevert("only Admin!");
        payroll.removeEmployee(employee1);
    }
}
