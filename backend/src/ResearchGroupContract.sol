// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ResearchGroups {
    struct Message {
        address sender;
        string content;
        uint256 timestamp;
        uint256 upvotes;
        bool deleted; // Flag for deleted messages
    }

    struct ResearchGroup {
        string name;
        string description;
        uint256 memberCount;
        bool isActive;
        address creator;
    }

    struct UserProfile {
        uint256 reputation;
        uint256 messageCount;
    }

    enum Role {
        Member,
        Moderator,
        Admin
    }
    enum PredefinedTopic {
        MEDICAL,
        QUANTUM_PHYSICS,
        ARTIFICIAL_INTELLIGENCE,
        BLOCKCHAIN,
        RENEWABLE_ENERGY,
        BIOTECHNOLOGY,
        SPACE_EXPLORATION,
        NEUROSCIENCE
    }

    mapping(PredefinedTopic => ResearchGroup) public predefinedGroups;
    mapping(uint256 => ResearchGroup) public customGroups;
    mapping(uint256 => Message[]) public groupMessages;
    mapping(uint256 => address[]) public groupMembers;
    mapping(address => mapping(uint256 => bool)) public userMemberships;
    mapping(address => UserProfile) public userProfiles; // Mini profile
    mapping(address => Role) public roles;
    mapping(address => mapping(uint256 => bool)) public joined; // Tracking if the user has already joined

    uint256 public customGroupCount;

    event GroupCreated(uint256 indexed groupId, string name, address creator);
    event GroupStatusUpdated(uint256 indexed groupId, bool isActive);
    event GroupJoined(uint256 indexed groupId, address indexed user);
    event GroupLeft(uint256 indexed groupId, address indexed user);
    event MessageSent(
        uint256 indexed groupId,
        address indexed sender,
        string content
    );
    event MessageUpvoted(
        uint256 indexed groupId,
        uint256 messageIndex,
        address indexed voter
    );
    event MessageDeleted(uint256 indexed groupId, uint256 messageIndex);
    event UserPromoted(address indexed user, Role newRole);

    modifier onlyAdmin() {
        require(
            roles[msg.sender] == Role.Admin,
            "Only admins can perform this action"
        );
        _;
    }

    modifier onlyModerator(uint256 groupId) {
        require(
            roles[msg.sender] == Role.Admin ||
                userMemberships[msg.sender][groupId],
            "Only moderators or admins can perform this action"
        );
        _;
    }

    constructor() {
        roles[msg.sender] = Role.Admin; // Deployer becomes admin
        initializePredefinedGroups();
    }

    // Initialize predefined groups
    function initializePredefinedGroups() private {
        predefinedGroups[PredefinedTopic.MEDICAL] = ResearchGroup({
            name: "Medical Research",
            description: "Discussion of medical breakthroughs and research",
            memberCount: 0,
            isActive: true,
            creator: address(0)
        });
        predefinedGroups[PredefinedTopic.QUANTUM_PHYSICS] = ResearchGroup({
            name: "Quantum Physics",
            description: "Quantum mechanics and theoretical physics discussions",
            memberCount: 0,
            isActive: true,
            creator: address(0)
        });
        predefinedGroups[
            PredefinedTopic.ARTIFICIAL_INTELLIGENCE
        ] = ResearchGroup({
            name: "Artificial Intelligence",
            description: "AI research and development discussions",
            memberCount: 0,
            isActive: true,
            creator: address(0)
        });
        predefinedGroups[PredefinedTopic.BLOCKCHAIN] = ResearchGroup({
            name: "Blockchain Technology",
            description: "Blockchain research and development",
            memberCount: 0,
            isActive: true,
            creator: address(0)
        });
        predefinedGroups[PredefinedTopic.RENEWABLE_ENERGY] = ResearchGroup({
            name: "Renewable Energy",
            description: "Sustainable energy research",
            memberCount: 0,
            isActive: true,
            creator: address(0)
        });
        predefinedGroups[PredefinedTopic.BIOTECHNOLOGY] = ResearchGroup({
            name: "Biotechnology",
            description: "Biotech research and innovations",
            memberCount: 0,
            isActive: true,
            creator: address(0)
        });
        predefinedGroups[PredefinedTopic.SPACE_EXPLORATION] = ResearchGroup({
            name: "Space Exploration",
            description: "Space research and astronomy",
            memberCount: 0,
            isActive: true,
            creator: address(0)
        });
        predefinedGroups[PredefinedTopic.NEUROSCIENCE] = ResearchGroup({
            name: "Neuroscience",
            description: "Brain research and cognitive science",
            memberCount: 0,
            isActive: true,
            creator: address(0)
        });
    }

    // Join a predefined group
    function joinPredefinedGroup(PredefinedTopic topic) external {
        require(predefinedGroups[topic].isActive, "Group is not active");
        require(
            !userMemberships[msg.sender][uint256(topic)],
            "Already a member"
        );
        require(
            !joined[msg.sender][uint256(topic)],
            "Already joined this group"
        );

        userMemberships[msg.sender][uint256(topic)] = true;
        predefinedGroups[topic].memberCount++;
        groupMembers[uint256(topic)].push(msg.sender);
        joined[msg.sender][uint256(topic)] = true; // Mark as joined

        emit GroupJoined(uint256(topic), msg.sender);
    }

    // Create a new custom group
    function createCustomGroup(
        string calldata name,
        string calldata description
    ) external {
        require(
            userProfiles[msg.sender].reputation >= 100,
            "Insufficient reputation to create a group"
        );

        customGroupCount++;
        uint256 groupId = uint256(PredefinedTopic.NEUROSCIENCE) +
            customGroupCount;

        customGroups[groupId] = ResearchGroup({
            name: name,
            description: description,
            memberCount: 0,
            isActive: false,
            creator: msg.sender
        });

        emit GroupCreated(groupId, name, msg.sender);
    }

    // Activate or deactivate a custom group
    function updateCustomGroupStatus(
        uint256 groupId,
        bool isActive
    ) external onlyAdmin {
        require(
            customGroups[groupId].creator != address(0),
            "Group does not exist"
        );
        customGroups[groupId].isActive = isActive;
        emit GroupStatusUpdated(groupId, isActive);
    }

    // Join a custom group
    function joinCustomGroup(uint256 groupId) external {
        require(customGroups[groupId].isActive, "Group is not active");
        require(!userMemberships[msg.sender][groupId], "Already a member");
        require(!joined[msg.sender][groupId], "Already joined this group");

        userMemberships[msg.sender][groupId] = true;
        customGroups[groupId].memberCount++;
        groupMembers[groupId].push(msg.sender);
        joined[msg.sender][groupId] = true; // Mark as joined

        emit GroupJoined(groupId, msg.sender);
    }

    // Send a message to a group (predefined or custom)
    function sendMessage(uint256 groupId, string calldata content) external {
        require(bytes(content).length > 0, "Message cannot be empty");
        require(bytes(content).length <= 1000, "Message too long");

        if (groupId <= uint256(PredefinedTopic.NEUROSCIENCE)) {
            require(
                predefinedGroups[PredefinedTopic(groupId)].isActive,
                "Predefined group not active"
            );
            require(
                userMemberships[msg.sender][groupId],
                "Not a member of this predefined group"
            );
        } else {
            require(customGroups[groupId].isActive, "Custom group not active");
            require(
                userMemberships[msg.sender][groupId],
                "Not a member of this custom group"
            );
        }

        groupMessages[groupId].push(
            Message({
                sender: msg.sender,
                content: content,
                timestamp: block.timestamp,
                upvotes: 0,
                deleted: false
            })
        );

        userProfiles[msg.sender].messageCount++; // Track sent messages
        userProfiles[msg.sender].reputation += 1; // Reward activity

        emit MessageSent(groupId, msg.sender, content);
    }

    // Upvote a message
    function upvoteMessage(uint256 groupId, uint256 messageIndex) external {
        Message storage message = groupMessages[groupId][messageIndex];
        require(message.sender != msg.sender, "Cannot upvote your own message");

        message.upvotes++;
        userProfiles[msg.sender].reputation += 5;
        emit MessageUpvoted(groupId, messageIndex, msg.sender);
    }

    // Delete a message
    function deleteMessage(uint256 groupId, uint256 messageIndex) external {
        Message storage message = groupMessages[groupId][messageIndex];
        require(
            message.sender == msg.sender,
            "Only the sender can delete their message"
        );
        require(!message.deleted, "Message already deleted");

        message.deleted = true;
        userProfiles[msg.sender].messageCount--; // Decrease message count
        emit MessageDeleted(groupId, messageIndex);
    }

    // View user's mini profile
    function getUserProfile(
        address user
    ) external view returns (UserProfile memory) {
        return userProfiles[user];
    }
}
