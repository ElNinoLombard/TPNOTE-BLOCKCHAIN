// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/Vote.sol";

contract SimpleVotingSystemTest is Test {
    SimpleVotingSystem votingSystem;
    address admin = address(0x1);
    address nonAdmin = address(0x2);

    function setUp() public {
        votingSystem = new SimpleVotingSystem();
        votingSystem.grantRole(votingSystem.DEFAULT_ADMIN_ROLE(), admin);
        votingSystem.grantRole(votingSystem.ADMIN_ROLE(), admin);
    }

    function testAddCandidate() public {
        vm.prank(admin);
        votingSystem.setWorkflowStatus(
            SimpleVotingSystem.WorkflowStatus.REGISTER_CANDIDATES
        );
        votingSystem.addCandidate("Candidate 1");
        SimpleVotingSystem.Candidate memory candidate = votingSystem
            .getCandidate(1);
        assertEq(candidate.name, "Candidate 1");
        assertEq(candidate.voteCount, 0);
    }

    function testCannotAddCandidateInWrongWorkflow() public {
        vm.prank(admin);
        votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
        vm.prank(admin);
        try votingSystem.addCandidate("Candidate 1") {
            fail();
        } catch Error(string memory reason) {
            assertEq(reason, "Cannot add candidates at this stage");
        }
    }

    function testNonAdminCannotAddCandidate() public {
        vm.prank(nonAdmin);
        try votingSystem.addCandidate("Candidate 1") {
            fail();
        } catch Error(string memory reason) {
            assertEq(reason, "Only admins can add candidates");
        }
    }

    function testChangeWorkflowStatus() public {
        vm.prank(admin);
        votingSystem.setWorkflowStatus(
            SimpleVotingSystem.WorkflowStatus.REGISTER_CANDIDATES
        );
        assertEq(
            uint(votingSystem.workflowStatus()),
            uint(SimpleVotingSystem.WorkflowStatus.REGISTER_CANDIDATES)
        );

        vm.prank(admin);
        votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
        assertEq(
            uint(votingSystem.workflowStatus()),
            uint(SimpleVotingSystem.WorkflowStatus.VOTE)
        );
    }

    function testNonAdminCannotChangeWorkflowStatus() public {
        vm.prank(nonAdmin);
        try
            votingSystem.setWorkflowStatus(
                SimpleVotingSystem.WorkflowStatus.VOTE
            )
        {
            fail();
        } catch Error(string memory reason) {
            assertEq(reason, "Only admins can change workflow status");
        }
    }

    function testVote() public {
        vm.prank(admin);
        votingSystem.setWorkflowStatus(
            SimpleVotingSystem.WorkflowStatus.REGISTER_CANDIDATES
        );
        votingSystem.addCandidate("Candidate 1");
        vm.prank(admin);
        votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
        skip(1 hours);
        votingSystem.vote(1);
        SimpleVotingSystem.Candidate memory candidate = votingSystem
            .getCandidate(1);
        assertEq(candidate.voteCount, 1);
    }

    function testCannotVoteBeforeAllowedTime() public {
        vm.prank(admin);
        votingSystem.setWorkflowStatus(
            SimpleVotingSystem.WorkflowStatus.REGISTER_CANDIDATES
        );
        votingSystem.addCandidate("Candidate 1");
        vm.prank(admin);
        votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
        vm.prank(nonAdmin);
        try votingSystem.vote(1) {
            fail();
        } catch Error(string memory reason) {
            assertEq(reason, "Voting is not open yet");
        }
    }

    function testCannotVoteInvalidCandidateId() public {
        vm.prank(admin);
        votingSystem.setWorkflowStatus(
            SimpleVotingSystem.WorkflowStatus.REGISTER_CANDIDATES
        );
        votingSystem.addCandidate("Candidate 1");
        vm.prank(admin);
        votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
        skip(1 hours);
        vm.prank(nonAdmin);
        try votingSystem.vote(999) {
            fail();
        } catch Error(string memory reason) {
            assertEq(reason, "Invalid candidate ID");
        }
    }

    function testDesignateWinner() public {
        vm.prank(admin);
        votingSystem.setWorkflowStatus(
            SimpleVotingSystem.WorkflowStatus.REGISTER_CANDIDATES
        );
        votingSystem.addCandidate("Candidate 1");
        votingSystem.addCandidate("Candidate 2");

        vm.prank(admin);
        votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
        skip(1 hours);

        address voter1 = address(0x3);
        address voter2 = address(0x4);
        address voter3 = address(0x5);

        vm.prank(voter1);
        votingSystem.vote(1);

        vm.prank(voter2);
        votingSystem.vote(1);

        vm.prank(voter3);
        votingSystem.vote(2);

        vm.prank(admin);
        votingSystem.setWorkflowStatus(
            SimpleVotingSystem.WorkflowStatus.COMPLETED
        );
        SimpleVotingSystem.Candidate memory winner = votingSystem
            .designateWinner();
        assertEq(winner.name, "Candidate 1");
        assertEq(winner.voteCount, 2);
    }

    function testFounderCanSendFundsToCandidates() public {
        address founder = address(0x6);
        vm.prank(admin);
        votingSystem.grantRole(votingSystem.FOUNDER_ROLE(), founder);

        uint256 initialBalance = address(votingSystem).balance;
        uint256 amountToSend = 1 ether;

        (bool success, ) = address(votingSystem).call{value: amountToSend}("");
        assertTrue(success, "Fund transfer failed");

        uint256 finalBalance = address(votingSystem).balance;

        assertEq(
            finalBalance,
            initialBalance + amountToSend,
            "Contract balance did not increase by the expected amount"
        );
    }
}
