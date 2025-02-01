// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Payroll} from "../src/Payroll.sol";

contract PayrollTest is Test {
    Payroll public payroll;

    address Admin = address(1);
    address employee1 = address(2);
    address employee2 = address(3);
    
    function setUp() public {
        vm.prank(Admin);
        payroll = new Payroll();
    }

    function testDeposit() public {
        vm.deal(Admin, 20 ether);
        vm.prank(Admin);
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
        vm.prank(Admin);
        vm.expectRevert("Must send ether!");
        payroll.deposit{value: 0 ether}();
    }

    function testAddEmployee() public {
        vm.prank(Admin);
        payroll.addEmployee(employee1, 6 ether);
        
        (address emp, uint salary) = payroll.getEmployee(0);
        assertEq(emp, employee1, "Employee address mismatch!");
        assertEq(salary, 6 ether, "Employee salary mismatch!");
    }

    function testAddEmployeeNotAdmin() public {
        vm.prank(employee1);
        vm.expectRevert("only Admin!");
        payroll.addEmployee(employee2, 8 ether);
    }

    function testAddEmployeeZeroSalary() public {
        vm.prank(Admin);
        vm.expectRevert("Salary can't be zero!");
        payroll.addEmployee(employee1, 0);
    }

    function testAddEmployeeAlreadyRegistered() public {
        vm.prank(Admin);
        payroll.addEmployee(employee1, 6 ether);

        vm.prank(Admin);
        vm.expectRevert("Employee already registered!");
        payroll.addEmployee(employee1, 6 ether);
    }

    function testPaySalary() public {
        vm.deal(Admin, 20 ether);
        vm.prank(Admin);
        payroll.deposit{value: 18 ether}();
        assertEq(address(payroll).balance, 18 ether, "imbalance!");

        vm.prank(Admin);
        payroll.addEmployee(employee1, 6 ether);

        vm.prank(Admin);
        payroll.addEmployee(employee2, 8 ether);

        vm.prank(Admin);
        payroll.paySalaries();
        assertEq(address(payroll).balance, 4 ether, "Imbalance!");
    }

    function testPaySalaryImbalance() public {
        vm.deal(Admin, 10 ether);
        vm.prank(Admin);
        payroll.deposit{value: 10 ether}();
        assertEq(address(payroll).balance, 10 ether, "imbalance!");

        vm.prank(Admin);
        payroll.addEmployee(employee1, 6 ether);

        vm.prank(Admin);
        payroll.addEmployee(employee2, 8 ether);

        vm.prank(Admin);
        vm.expectRevert("Not enough balance to pay salary!");
        payroll.paySalaries();
    }

    function testPaySalaryNotAdmin() public {
        vm.deal(Admin, 10 ether);
        vm.prank(Admin);
        payroll.deposit{value: 10 ether}();
        assertEq(address(payroll).balance, 10 ether, "imbalance!");

        vm.prank(employee1);
        vm.expectRevert("only Admin!");
        payroll.paySalaries();
    }

    function testRemoveEmployee() public {
        vm.prank(Admin);
        payroll.addEmployee(employee1, 6 ether);

        vm.prank(Admin);
        payroll.addEmployee(employee2, 6 ether);
        assertEq(payroll.getEmployeeCount(), 2, "Employee count mismatch before removal");

        vm.prank(Admin);
        payroll.removeEmployee(employee1);
        assertEq(payroll.getEmployeeCount(), 1, "Employee count mismatch after removal");
    }

    function testRemoveEmployeeNotAdmin() public {
        vm.prank(Admin);
        payroll.addEmployee(employee1, 6 ether);

        vm.prank(Admin);
        payroll.addEmployee(employee2, 6 ether);
        assertEq(payroll.getEmployeeCount(), 2, "Employee count mismatch before removal");

        vm.prank(employee1);
        vm.expectRevert("only Admin!");
        payroll.removeEmployee(employee1);
    }
}
