// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Payroll {
    struct Employee {
        address employee;
        uint salary;
    }
    
    Employee[] public employees;
    address public Admin;
    uint companyBalance;

    constructor() {
        Admin = msg.sender;
    }

    modifier onlyAdmin {
        require(msg.sender == Admin, "only Admin!");
        _;
    }

    event depositSuccess(address indexed admin, uint amount);
    event employeeRegisterSuccess(address indexed admin, address indexed employee, uint salary);
    event salaryPayed(address indexed admin, address indexed employee, uint salary);
    event employeeFired(address indexed admin, address employee);

    function deposit() external payable onlyAdmin {
        require(msg.value > 0, "Must send ether!");
        companyBalance += msg.value;

        emit depositSuccess(msg.sender, msg.value);
    }

    function addEmployee(address _employee, uint _salary) external onlyAdmin {
        require(!findEmployee(_employee), "Employee already registered!");
        require(_salary > 0, "Salary can't be zero!");
        
        employees.push(Employee(_employee, _salary));
        emit employeeRegisterSuccess(msg.sender, _employee, _salary);
    }

    function findEmployee(address _employee) internal view returns(bool) {
        for(uint i = 0; i < employees.length; i++) {
            if(employees[i].employee == _employee) {
                return true;
            }
        }
        return false;
    }

    function paySalaries() external onlyAdmin {
        uint totalSalaries = 0;

        for(uint i = 0; i < employees.length; i++) {
            totalSalaries += employees[i].salary;
        }

        require(companyBalance >= totalSalaries, "Not enough balance to pay salary!");

        for(uint i = 0; i < employees.length; i++) {
            (bool success,) = employees[i].employee.call{value: employees[i].salary}("");
            require(success, "Payment failed!");
            companyBalance -= employees[i].salary;
            emit salaryPayed(msg.sender, employees[i].employee, employees[i].salary);
        }
    }

    function removeEmployee(address _employee) external onlyAdmin {
        for(uint i = 0; i < employees.length; i++) {
            if(employees[i].employee == _employee) {
                employees[i] = employees[employees.length - 1];
                employees.pop();
                emit employeeFired(msg.sender, _employee);
                return;
            }
        }
    }

    // FUNCTION HELPER TESTING
    function getEmployee(uint index) public view returns (address, uint) {
        require(index < employees.length, "Index out of bounds");
        return (employees[index].employee, employees[index].salary);
    }

    function getTotalSalaries() public view returns (uint) {
        uint total = 0;
        for (uint i = 0; i < employees.length; i++) {
            total += employees[i].salary;
        }
        return total;
    }

    function getEmployeeCount() public view returns (uint) {
        return employees.length;
    }
}
