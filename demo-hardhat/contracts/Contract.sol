// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Contract {
    uint public x;

    function changes(uint _x) external {
        x = _x;
    }

    
}
