// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Payroll {
    struct Employee {
        address employee;
        uint salary;
    }
    
    Employee[] public employees;
    address public Admin;

    modifier onlyAdmin {
        require(msg.sender == Admin, "only Admin!");
        _;
    }

    event employeeRegisterSuccess(address indexed admin, address indexed employee, uint salary);
    event salaryPayed(address indexed admin, address indexed employee, uint salary);
    event employeeFired(address indexed admin, address employee);

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

    function paySalaries() external payable onlyAdmin {
        uint companyBalance = 0;

        for(uint i = 0; i < employees.length; i++) {
            companyBalance += employees[i].salary;
        }

        for(uint i = 0; i < employees.length; i++) {
            require(companyBalance >= employees[i].salary, "Not enough balance to pay salary!");

            (bool success,) = employees[i].employee.call{value: employees[i].salary}("");
            require(success, "Payment failed!");
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

}
