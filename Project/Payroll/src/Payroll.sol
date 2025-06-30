// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
 * @title Payroll smart contract
 * @author [M Daffa Al Ghifary a.k.a dfpro]
 * @notice A Payroll smart contract to manage employees, pay salaries and remove employees
 * @dev Only the admin (contract deployer) can manage payroll operations
 */
contract Payroll {
    
    // ----------------------------
    // Structs and Variables
    // -----------------------------

    /**
     * @dev Represents an employee with address and salary
     */
    struct Employee {
        address employee;
        uint salary;
    }
    
    /// @notice List of registered employees
    Employee[] public employees;

    /// @notice Admin address
    address public Admin;

    /// @notice Balance of the payroll contract
    uint companyBalance;

    /// @dev Set the contract deployer as the admin
    constructor() {
        Admin = msg.sender;
    }

    // -----------------------
    // Modifier
    // -----------------------
    
    /// @dev Restricts access to only the admin to call certain functions
    modifier onlyAdmin {
        require(msg.sender == Admin, "only Admin!");
        _;
    }

    // ------------------------
    // Events
    // ------------------------

    /// @notice Emitted when admin successfully deposit ether to contract
    event depositSuccess(address indexed admin, uint amount);

    /// @notice Emitted when admin successfully registers an employee
    event employeeRegisterSuccess(address indexed admin, address indexed employee, uint salary);

    /// @notice Emitted when admin successfully pay the employee salary
    event salaryPayed(address indexed admin, address indexed employee, uint salary);

    /// @notice Emitted when admin successfully remove an employee
    event employeeFired(address indexed admin, address employee);

    // -----------------------
    // Core Functions
    // -----------------------

    /**
     * @notice Allows the admin to deposit ether to contract balance
     * @dev Deposit require value more than zero
     * @dev Successfully deposit ether using this funtion will emit the despositSuccess event
     */
    function deposit() external payable onlyAdmin {
        require(msg.value > 0, "Must send ether!");
        companyBalance += msg.value;

        emit depositSuccess(msg.sender, msg.value);
    }

    /**
     * @notice Allows the admin to add new employee and their the salary
     * @param _employee The address of the new employee
     * @param _salary The amount of salary
     * @dev Only unregistered employee can be added using this 
        function and the salary must be greater than zero
     * @dev Successfully added new employee using this function
         will emit the EmployeeRegisterSuccess event
     */
    function addEmployee(address _employee, uint _salary) external onlyAdmin {
        require(!findEmployee(_employee), "Employee already registered!");
        require(_salary > 0, "Salary can't be zero!");
        
        employees.push(Employee(_employee, _salary));
        emit employeeRegisterSuccess(msg.sender, _employee, _salary);
    }

    /**
     * @notice Pays salary to all registered employees
     * @dev Only admin can call this functing, and the contract's 
        balance should be greater than or equal to total of employee salary
     * @dev Souccessfully payed salary will emit the salaryPayed event
     */
    function paySalaries() external onlyAdmin {
        uint totalSalaries = getTotalSalaries();
        require(companyBalance >= totalSalaries, "Not enough balance to pay salary!");

        for(uint i = 0; i < employees.length; i++) {
            (bool success,) = employees[i].employee.call{value: employees[i].salary}("");
            require(success, "Payment failed!");
            companyBalance -= employees[i].salary;

            emit salaryPayed(msg.sender, employees[i].employee, employees[i].salary);
        }
    }

    /**
     * @notice Removes an employee from the payroll
     * @dev Only the admin can call this function
     */
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

    // -----------------------
    // INTERNAL HELPER
    // -----------------------
    
    /**
     * @notice Checks if an employee is already registered
     * @param _employee Address of the employee
     * @return true if employee already registered, false otherwise
     */
    function findEmployee(address _employee) internal view returns(bool) {
        for(uint i = 0; i < employees.length; i++) {
            if(employees[i].employee == _employee) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Returns employee details at a specificied index
     * @param index Index in the employees array
     * @return Address of the employee and the salary
     */
    function getEmployee(uint index) public view returns (address, uint) {
        require(index < employees.length, "Index out of bounds");
        return (employees[index].employee, employees[index].salary);
    }

    /**
     * @notice Returns total amount of salaries
     */
    function getTotalSalaries() public view returns (uint) {
        uint total = 0;
        for (uint i = 0; i < employees.length; i++) {
            total += employees[i].salary;
        }
        return total;
    }

    /**
     * @notice Returns a number of registered employees
     */
    function getEmployeeCount() public view returns (uint) {
        return employees.length;
    }
}
