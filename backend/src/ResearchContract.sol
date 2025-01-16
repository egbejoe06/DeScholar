// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Interface.sol";

contract DeScholarResearch is
    ERC721URIStorage,
    ReentrancyGuard,
    IDeScholarResearch
{
    using SafeERC20 for IERC20;

    IERC20 public dstToken;
    uint256 public _tokenIds;
    address public owner;
    uint256[] public researchIds;

    // Constants
    uint256 public constant REVIEW_REWARD = 10 * 10 ** 18;
    uint256 public constant MIN_REVIEW_SCORE = 1;
    uint256 public constant MAX_REVIEW_SCORE = 5;

    mapping(uint256 => Research) public researches;
    mapping(uint256 => Review[]) public researchReviews;
    mapping(address => uint256) public reviewerScores;
    mapping(address => uint256) public researcherPublications;

    event ResearchPublished(
        uint256 indexed tokenId,
        address indexed researcher,
        string title
    );
    event ResearchDeleted(uint256 indexed tokenId, address indexed researcher);
    event ReviewSubmitted(
        uint256 indexed tokenId,
        address indexed reviewer,
        uint256 score
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _dstToken) ERC721("DeScholar Research", "DSR") {
        require(_dstToken != address(0), "Invalid token address");
        dstToken = IERC20(_dstToken);
        owner = msg.sender;
    }

    function publishResearch(
        string memory title,
        string memory tokenURI
    ) public override returns (uint256) {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(tokenURI).length > 0, "TokenURI cannot be empty");

        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        researches[newTokenId] = Research({
            title: title,
            tokenId: newTokenId,
            timestamp: block.timestamp,
            peerReviewed: false,
            researcher: msg.sender,
            isDeleted: false,
            exists: true
        });

        researcherPublications[msg.sender]++;
        researchIds.push(newTokenId); // Track published research
        emit ResearchPublished(newTokenId, msg.sender, title);
        return newTokenId;
    }

    error ResearchDoesNotExist(uint256 tokenId);
    error ResearchAlreadyExists(uint256 tokenId);

    function researchExists(uint256 tokenId) public view returns (bool) {
        return researches[tokenId].exists && !researches[tokenId].isDeleted;
    }

    function deleteResearch(uint256 tokenId) public {
        if (!researchExists(tokenId)) revert ResearchDoesNotExist(tokenId);
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(!researches[tokenId].isDeleted, "Already deleted");

        researches[tokenId].isDeleted = true;
        _burn(tokenId);

        emit ResearchDeleted(tokenId, msg.sender);
    }

    function submitReview(
        uint256 tokenId,
        uint256 score,
        string memory comment
    ) public nonReentrant {
        if (!researchExists(tokenId)) revert ResearchDoesNotExist(tokenId);
        require(
            score >= MIN_REVIEW_SCORE && score <= MAX_REVIEW_SCORE,
            "Invalid score"
        );
        require(!isReviewer(tokenId, msg.sender), "Already reviewed");
        require(!researches[tokenId].isDeleted, "Research deleted");
        require(
            msg.sender != researches[tokenId].researcher,
            "Cannot review own research"
        );
        require(bytes(comment).length > 0, "Comment cannot be empty");

        researchReviews[tokenId].push(
            Review({
                reviewer: msg.sender,
                score: score,
                comment: comment,
                timestamp: block.timestamp
            })
        );

        // Update reviewer score and transfer reward
        reviewerScores[msg.sender]++;
        require(
            dstToken.balanceOf(address(this)) >= REVIEW_REWARD,
            "Insufficient reward tokens"
        );
        dstToken.safeTransfer(msg.sender, REVIEW_REWARD);

        emit ReviewSubmitted(tokenId, msg.sender, score);
    }

    function isReviewer(
        uint256 tokenId,
        address reviewer
    ) public view returns (bool) {
        Review[] memory reviews = researchReviews[tokenId];
        for (uint i = 0; i < reviews.length; i++) {
            if (reviews[i].reviewer == reviewer) return true;
        }
        return false;
    }

    function getResearcherPublications(
        address researcher
    ) external view override returns (uint256) {
        return researcherPublications[researcher];
    }

    function getResearch(
        uint256 tokenId
    ) public view returns (Research memory) {
        if (!researchExists(tokenId)) revert ResearchDoesNotExist(tokenId);
        return researches[tokenId];
    }

    function getResearchReviews(
        uint256 tokenId
    ) public view returns (Review[] memory) {
        if (!researchExists(tokenId)) revert ResearchDoesNotExist(tokenId);
        return researchReviews[tokenId];
    }

    function getAllAvailableResearch() public view returns (uint256[] memory) {
        uint256 count = 0;

        // Count non-deleted research items
        for (uint256 i = 0; i < researchIds.length; i++) {
            if (!researches[researchIds[i]].isDeleted) {
                count++;
            }
        }

        // Create an array to store available research
        uint256[] memory availableResearch = new uint256[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < researchIds.length; i++) {
            if (!researches[researchIds[i]].isDeleted) {
                availableResearch[index] = researchIds[i];
                index++;
            }
        }

        return availableResearch;
    }
}
