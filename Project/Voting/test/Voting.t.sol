// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Voting} from "../src/Voting.sol";

contract VotingTesting is Test {
    Voting public voting;

    address admin = address(1);

    address voter1 = address(2);
    address voter2 = address(3);
    address voter3 = address(4);
    address voter4 = address(5);
    address voter5 = address(6);
    address voter6 = address(7);
    address voter7 = address(8);

    address candidate1 = address(9);
    address candidate2 = address(10);
    address candidate3 = address(11);

    function setUp() public {
        vm.prank(admin);
        voting = new Voting();
    }

    function testRegisterVoter() public {
        vm.startPrank(admin);
        voting.registerVoter(voter1);
        voting.registerVoter(voter2);
        voting.registerVoter(voter3);
        voting.registerVoter(voter4);
        voting.registerVoter(voter5);
        voting.registerVoter(voter6);
        voting.registerVoter(voter7);
    }
}
