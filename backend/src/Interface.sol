// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IDeScholarResearch {
    struct Research {
        string title;
        uint256 tokenId;
        uint256 timestamp;
        bool peerReviewed;
        address researcher;
        bool isDeleted;
        bool exists;
    }

    struct Review {
        address reviewer;
        uint256 score;
        string comment;
        uint256 timestamp;
    }

    function publishResearch(
        string memory title,
        string memory tokenURI
    ) external returns (uint256);
    function getResearcherPublications(
        address researcher
    ) external view returns (uint256);
    function researchExists(uint256 tokenId) external view returns (bool);
    function getResearch(
        uint256 tokenId
    ) external view returns (Research memory);
    function getResearchReviews(
        uint256 tokenId
    ) external view returns (Review[] memory);
}

interface IDeScholarCourse {
    struct Course {
        uint256 courseId;
        address instructor;
        string title;
        string description;
        uint256 price;
        string URI;
        uint256 purchaseCount;
        bool exists;
    }

    function createCourse(
        string memory title,
        string memory description,
        uint256 price,
        string memory URI
    ) external returns (uint256);
    function purchaseCourse(uint256 courseId) external;
    function getCourse(
        uint256 courseId
    )
        external
        view
        returns (
            uint256,
            address,
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        );
    function getAllCourses() external view returns (Course[] memory);
}

interface IDeScholarProposal {
    struct ProposalView {
        uint256 id;
        address researcher;
        string title;
        string description;
        uint256 fundingGoal;
        uint256 currentFunding;
        uint256 deadline;
        bool active;
    }

    function createProposal(
        string memory title,
        string memory description,
        uint256 fundingGoal,
        uint256 durationDays
    ) external returns (uint256);
    function fundProposal(uint256 proposalId) external payable;
    function getAllProposals() external view returns (ProposalView[] memory);
}
