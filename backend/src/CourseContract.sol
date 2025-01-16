// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Interface.sol"; // Contains all interfaces

contract DeScholarCourse is ReentrancyGuard, IDeScholarCourse {
    using SafeERC20 for IERC20;

    IERC20 public dstToken;
    IDeScholarResearch public researchContract;
    address public owner;
    uint256 private courseCount;

    mapping(uint256 => Course) public courses;
    mapping(address => mapping(uint256 => bool)) public coursePurchases;

    event CourseCreated(
        uint256 indexed courseId,
        address indexed instructor,
        string title,
        uint256 price
    );
    event CoursePurchased(
        uint256 indexed courseId,
        address indexed buyer,
        uint256 price
    );
    event CourseDeleted(uint256 indexed courseId, address indexed instructor);

    modifier onlyEligibleInstructor() {
        require(
            researchContract.getResearcherPublications(msg.sender) >= 3,
            "Must have at least 3 published researches"
        );
        _;
    }

    constructor(address _dstToken, address _researchContract) {
        require(
            _dstToken != address(0) && _researchContract != address(0),
            "Invalid addresses"
        );
        dstToken = IERC20(_dstToken);
        researchContract = IDeScholarResearch(_researchContract);
        owner = msg.sender;
    }

    function createCourse(
        string memory title,
        string memory description,
        uint256 price,
        string memory URI
    ) public onlyEligibleInstructor returns (uint256) {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(description).length > 0, "Description cannot be empty");
        require(price > 0, "Price must be greater than 0");
        require(bytes(URI).length > 0, "URI cannot be empty");

        courseCount++;
        courses[courseCount] = Course({
            courseId: courseCount,
            instructor: msg.sender,
            title: title,
            description: description,
            price: price,
            URI: URI,
            purchaseCount: 0,
            exists: true
        });

        emit CourseCreated(courseCount, msg.sender, title, price);
        return courseCount;
    }

    function purchaseCourse(uint256 courseId) public nonReentrant {
        require(courses[courseId].exists, "Course does not exist");
        require(
            !coursePurchases[msg.sender][courseId],
            "Already purchased this course"
        );

        uint256 price = courses[courseId].price;
        require(
            dstToken.balanceOf(msg.sender) >= price,
            "Insufficient DST balance"
        );

        // Transfer DST tokens from buyer to instructor
        dstToken.safeTransferFrom(
            msg.sender,
            courses[courseId].instructor,
            price
        );

        // Mark course as purchased
        coursePurchases[msg.sender][courseId] = true;
        courses[courseId].purchaseCount++;

        emit CoursePurchased(courseId, msg.sender, price);
    }

    function getCourse(
        uint256 courseId
    )
        public
        view
        returns (
            uint256,
            address,
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        Course memory course = courses[courseId];
        require(course.exists, "Course does not exist");

        return (
            course.courseId,
            course.instructor,
            course.title,
            course.description,
            course.price,
            course.purchaseCount,
            course.exists
        );
    }

    function getCourseContent(
        uint256 courseId
    ) public view returns (string memory) {
        require(courses[courseId].exists, "Course does not exist");
        require(
            coursePurchases[msg.sender][courseId],
            "You have not purchased this course"
        );

        return (courses[courseId].URI);
    }

    function getInstructorCourses(
        address instructor
    ) public view returns (uint256[] memory) {
        uint256[] memory instructorCourses = new uint256[](courseCount);
        uint256 index = 0;

        for (uint256 i = 1; i <= courseCount; i++) {
            if (courses[i].instructor == instructor) {
                instructorCourses[index] = i;
                index++;
            }
        }

        assembly {
            mstore(instructorCourses, index)
        }
        return instructorCourses;
    }

    function hasPurchasedCourse(
        address user,
        uint256 courseId
    ) public view returns (bool) {
        return coursePurchases[user][courseId];
    }

    function getTotalCourses() public view returns (uint256) {
        return courseCount;
    }
    // Declare a state variable to track the number of active courses
    uint public activeCourseCount;

    // Example function to get all courses
    function getAllCourses() public view returns (Course[] memory) {
        uint256 actualCount = 0;
        for (uint256 i = 1; i <= courseCount; i++) {
            if (courses[i].exists) {
                actualCount++;
            }
        }

        Course[] memory allCourses = new Course[](actualCount);
        uint256 index = 0;

        for (uint256 i = 1; i <= courseCount; i++) {
            if (courses[i].exists) {
                allCourses[index] = courses[i];
                index++;
            }
        }
        return allCourses;
    }

    function deleteCourse(uint256 courseId) public {
        require(courses[courseId].exists, "Course does not exist");
        require(
            courses[courseId].instructor == msg.sender || msg.sender == owner,
            "Only instructor or owner can delete course"
        );
        require(
            courses[courseId].purchaseCount == 0,
            "Cannot delete course with purchases"
        );

        // Delete course reviews and stats
        delete courseStats[courseId];
        delete courseReviews[courseId];

        // Mark course as deleted while preserving some historical data
        courses[courseId].exists = false;

        // Emit deletion event
        emit CourseDeleted(courseId, msg.sender);
    }

    // Add these struct and mappings at the contract level
    struct CourseReview {
        address reviewer;
        uint256 rating; // 1-5 stars
        string comment;
        uint256 timestamp;
        bool verified; // indicates if reviewer actually purchased the course
    }

    struct CourseStats {
        uint256 totalRatings;
        uint256 sumRatings;
        mapping(uint256 => uint256) ratingDistribution; // maps rating (1-5) to count
    }

    // Add these mappings to the contract
    mapping(uint256 => CourseReview[]) private courseReviews;
    mapping(uint256 => CourseStats) private courseStats;

    // Add these events
    event CourseReviewSubmitted(
        uint256 indexed courseId,
        address indexed reviewer,
        uint256 rating
    );
    event CourseReviewDeleted(
        uint256 indexed courseId,
        address indexed reviewer
    );

    // Add these functions to the DeScholar contract
    function submitCourseReview(
        uint256 courseId,
        uint256 rating,
        string memory comment
    ) public {
        require(courses[courseId].exists, "Course does not exist");
        require(rating >= 1 && rating <= 5, "Rating must be between 1 and 5");
        require(
            bytes(comment).length > 0 && bytes(comment).length <= 1000,
            "Invalid comment length"
        );
        require(
            !hasReviewedCourse(courseId, msg.sender),
            "Already reviewed this course"
        );

        bool isVerifiedPurchaser = coursePurchases[msg.sender][courseId];
        require(isVerifiedPurchaser, "Must purchase course to review");

        CourseReview memory review = CourseReview({
            reviewer: msg.sender,
            rating: rating,
            comment: comment,
            timestamp: block.timestamp,
            verified: isVerifiedPurchaser
        });

        // Add review
        courseReviews[courseId].push(review);

        // Update course stats
        CourseStats storage stats = courseStats[courseId];
        stats.totalRatings++;
        stats.sumRatings += rating;
        stats.ratingDistribution[rating]++;

        emit CourseReviewSubmitted(courseId, msg.sender, rating);
    }

    function getCourseReviews(
        uint256 courseId
    ) public view returns (CourseReview[] memory) {
        require(courses[courseId].exists, "Course does not exist");
        return courseReviews[courseId];
    }

    function getCourseRatingStats(
        uint256 courseId
    )
        public
        view
        returns (
            uint256 averageRating,
            uint256 totalReviews,
            uint256[5] memory ratingCounts
        )
    {
        require(courses[courseId].exists, "Course does not exist");

        CourseStats storage stats = courseStats[courseId];

        if (stats.totalRatings == 0) {
            return (0, 0, [uint256(0), 0, 0, 0, 0]);
        }

        // Calculate average with 2 decimal precision (multiply by 100)
        averageRating = (stats.sumRatings * 100) / stats.totalRatings;

        // Get rating distribution
        for (uint256 i = 1; i <= 5; i++) {
            ratingCounts[i - 1] = stats.ratingDistribution[i];
        }

        return (averageRating, stats.totalRatings, ratingCounts);
    }

    function hasReviewedCourse(
        uint256 courseId,
        address reviewer
    ) public view returns (bool) {
        CourseReview[] memory reviews = courseReviews[courseId];
        for (uint256 i = 0; i < reviews.length; i++) {
            if (reviews[i].reviewer == reviewer) {
                return true;
            }
        }
        return false;
    }

    function getRecentReviews(
        uint256 courseId,
        uint256 limit
    ) public view returns (CourseReview[] memory) {
        require(courses[courseId].exists, "Course does not exist");
        require(limit > 0, "Limit must be greater than 0");

        CourseReview[] memory allReviews = courseReviews[courseId];
        uint256 resultCount = limit > allReviews.length
            ? allReviews.length
            : limit;

        CourseReview[] memory recentReviews = new CourseReview[](resultCount);

        // Copy most recent reviews (from end of array)
        for (uint256 i = 0; i < resultCount; i++) {
            recentReviews[i] = allReviews[allReviews.length - resultCount + i];
        }

        return recentReviews;
    }
    function canDeleteCourse(
        uint256 courseId
    ) public view returns (bool, string memory) {
        if (!courses[courseId].exists) {
            return (false, "Course does not exist");
        }

        if (courses[courseId].instructor != msg.sender && msg.sender != owner) {
            return (false, "Not authorized to delete course");
        }

        if (courses[courseId].purchaseCount > 0) {
            return (false, "Course has active purchases");
        }

        return (true, "Course can be deleted");
    }
}
