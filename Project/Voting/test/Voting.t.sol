// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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
        vm.stopPrank();

        (address voterAddr, , , bool isRegistered) = voting.voters(voter1);
        assertEq(voterAddr, voter1, "voter address not equal");
        assertTrue(isRegistered, "isRegistered not equal");
    }

    function testRegisterCandidate() public {
        vm.startPrank(admin);
        voting.registerCandidate(candidate1);
        voting.registerCandidate(candidate2);
        voting.registerCandidate(candidate3);
        vm.stopPrank();

        (address candidateAddr, , , bool isCandidate) = voting.candidates(candidate1);
        assertEq(candidateAddr, candidate1, "Candidate address not equal");
        assertTrue(isCandidate, "isCandidate not equal");
    }

    function testVoting() public {
        vm.startPrank(admin);
        voting.registerVoter(voter1);
        voting.registerVoter(voter2);
        voting.registerVoter(voter3);
        voting.registerVoter(voter4);
        voting.registerVoter(voter5);
        voting.registerCandidate(candidate1);
        voting.registerCandidate(candidate2);
        vm.stopPrank();

        vm.prank(admin);
        voting.startVoting();

        vm.prank(voter1);
        voting.castVote(0);

        vm.prank(voter2);
        voting.castVote(0);

        vm.prank(voter3);
        voting.castVote(0);

        vm.prank(voter4);
        voting.castVote(1);

        vm.prank(voter5);
        voting.castVote(1);

        (, , uint total, ) = voting.candidates(candidate1);
        assertEq(total, 3, "total voting imbalance!");
    }

    function testShowProgress() public {
        vm.startPrank(admin);
        voting.registerVoter(voter1);
        voting.registerVoter(voter2);
        voting.registerVoter(voter3);
        voting.registerCandidate(candidate1);
        voting.registerCandidate(candidate2);
        vm.stopPrank();

        vm.prank(admin);
        voting.startVoting();

        vm.prank(voter1);
        voting.castVote(0);
        vm.prank(voter2);
        voting.castVote(0);
        vm.prank(voter3);
        voting.castVote(1);

        (uint[] memory candidateIds, uint[] memory total) = voting.showProgress();
        assertEq(candidateIds[0], 0, "candidate1 should have id 0");
        assertEq(candidateIds[1], 1, "candidate2 should have id 1");
        assertEq(total[0], 2, "candidate1 should have 2 totalvotes");
        assertEq(total[1], 1, "candidate1 should have 1 totalvotes");
    }

    function testShowResult() public {
        vm.startPrank(admin);
        voting.registerVoter(voter1);
        voting.registerVoter(voter2);
        voting.registerCandidate(candidate1);
        voting.registerCandidate(candidate2);
        vm.stopPrank();

        vm.prank(admin);
        voting.startVoting();

        vm.prank(voter1);
        voting.castVote(0);

        vm.prank(voter2);
        voting.castVote(0);

        vm.prank(admin);
        voting.closeVoting();

        (uint[] memory candidateIds, address[] memory candidateAddr, uint[] memory votes) = voting.showResult();
        assertEq(candidateIds[0], 0, "candidate1 should have id 0");
        assertEq(candidateIds[1], 1, "candidate2 should have id 1");
        assertEq(candidateAddr[0], candidate1, "Candidate1 address not equal");
        assertEq(candidateAddr[1], candidate2, "Candidate2 address not equal");
        assertEq(votes[0], 2, "Candidate1 harus memiliki 2 suara!");
        assertEq(votes[1], 0, "Candidate2 harus memiliki 0 suara!");
    }
}
