// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "./Interface.sol"; // Contains all interfaces

contract DeScholarProposal is ReentrancyGuard, IDeScholarProposal {
    address public owner;
    uint256 private proposalCount;

    struct Proposal {
        address researcher;
        string title;
        string description;
        uint256 fundingGoal;
        uint256 currentFunding;
        uint256 deadline;
        bool active;
        mapping(address => uint256) contributions;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256[] public activeProposalIds;

    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed researcher,
        uint256 fundingGoal
    );
    event ProposalFunded(
        uint256 indexed proposalId,
        address indexed funder,
        uint256 amount
    );
    event ProposalFundingCompleted(
        uint256 indexed proposalId,
        address indexed researcher,
        uint256 totalFunded
    );

    constructor() {
        owner = msg.sender;
    }

    function createProposal(
        string memory title,
        string memory description,
        uint256 fundingGoal,
        uint256 durationDays
    ) public returns (uint256) {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(description).length > 0, "Description cannot be empty");
        require(fundingGoal > 0, "Funding goal must be positive");
        require(durationDays > 0, "Duration must be positive");

        proposalCount++;
        Proposal storage proposal = proposals[proposalCount];
        proposal.researcher = msg.sender;
        proposal.title = title;
        proposal.description = description;
        proposal.fundingGoal = fundingGoal;
        proposal.deadline = block.timestamp + (durationDays * 1 days);
        proposal.active = true;

        activeProposalIds.push(proposalCount); // Track active proposals

        emit ProposalCreated(proposalCount, msg.sender, fundingGoal);
        return proposalCount;
    }

    function getAllProposals() public view returns (ProposalView[] memory) {
        uint256 count = activeProposalIds.length;
        uint256 activeCount = 0;

        // First pass: count active proposals
        for (uint256 i = 0; i < count; i++) {
            if (proposals[activeProposalIds[i]].active) {
                activeCount++;
            }
        }

        // Second pass: collect active proposals
        ProposalView[] memory activeProposals = new ProposalView[](activeCount);
        uint256 index = 0;
        for (uint256 i = 0; i < count; i++) {
            uint256 proposalId = activeProposalIds[i];
            Proposal storage proposal = proposals[proposalId];

            if (proposal.active) {
                activeProposals[index] = ProposalView({
                    id: proposalId,
                    researcher: proposal.researcher,
                    title: proposal.title,
                    description: proposal.description,
                    fundingGoal: proposal.fundingGoal,
                    currentFunding: proposal.currentFunding,
                    deadline: proposal.deadline,
                    active: proposal.active
                });
                index++;
            }
        }

        return activeProposals;
    }

    function fundProposal(uint256 proposalId) public payable nonReentrant {
        require(
            proposalId > 0 && proposalId <= proposalCount,
            "Invalid proposal ID"
        );
        Proposal storage proposal = proposals[proposalId];
        require(proposal.active, "Proposal not active");
        require(block.timestamp < proposal.deadline, "Deadline passed");
        require(msg.value > 0, "Must send funds");

        proposal.contributions[msg.sender] += msg.value;
        proposal.currentFunding += msg.value;

        emit ProposalFunded(proposalId, msg.sender, msg.value);

        if (proposal.currentFunding >= proposal.fundingGoal) {
            proposal.active = false;
            _removeInactiveProposal(proposalId);

            // Safe ETH transfer
            (bool success, ) = payable(proposal.researcher).call{
                value: proposal.currentFunding
            }("");
            require(success, "Transfer failed");

            emit ProposalFundingCompleted(
                proposalId,
                proposal.researcher,
                proposal.currentFunding
            );
        }
    }
    function withdrawFunds(uint256 proposalId) public nonReentrant {
        require(
            proposalId > 0 && proposalId <= proposalCount,
            "Invalid proposal ID"
        );
        Proposal storage proposal = proposals[proposalId];
        require(
            block.timestamp >= proposal.deadline,
            "Funding period not over"
        );
        require(proposal.active, "Proposal already closed");

        uint256 contributedAmount = proposal.contributions[msg.sender];
        require(contributedAmount > 0, "No funds to withdraw");

        proposal.contributions[msg.sender] = 0; // Prevent reentrancy
        (bool success, ) = payable(msg.sender).call{value: contributedAmount}(
            ""
        );
        require(success, "Withdrawal failed");
    }

    function getProposalFunding(
        uint256 proposalId
    ) public view returns (uint256) {
        require(
            proposalId > 0 && proposalId <= proposalCount,
            "Invalid proposal ID"
        );
        return proposals[proposalId].currentFunding;
    }

    function _removeInactiveProposal(uint256 proposalId) internal {
        uint256 length = activeProposalIds.length;
        for (uint256 i = 0; i < length; i++) {
            if (activeProposalIds[i] == proposalId) {
                activeProposalIds[i] = activeProposalIds[length - 1]; // Swap with last element
                activeProposalIds.pop(); // Remove last element
                break;
            }
        }
    }
}
