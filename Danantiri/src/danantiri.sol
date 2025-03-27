// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Danantiri {
    enum ProgramStatus {
        INACTIVE, REGISTERED, ALLOCATED
    }

    struct Program {
        uint256 id;
        string name;
        string desc;
        uint256 targetFund;
        uint256 allocated;
        address pic;
        ProgramStatus status;
    }

    address public owner;
    Program[] public programs;
    uint256 public totalFund;
    uint256 public totalAllocated;
}
