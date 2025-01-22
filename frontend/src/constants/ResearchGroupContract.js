export const ResearchGroup_CONTRACT_ADDRESS =
  "0xde9E56302384E97BCD52a98728A8E0c344b68520";
export const ResearchGroup_CONTRACT_ABI = [
  { type: "constructor", inputs: [], stateMutability: "nonpayable" },
  {
    type: "function",
    name: "createCustomGroup",
    inputs: [
      { name: "name", type: "string", internalType: "string" },
      { name: "description", type: "string", internalType: "string" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "customGroupCount",
    inputs: [],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "customGroups",
    inputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    outputs: [
      { name: "name", type: "string", internalType: "string" },
      { name: "description", type: "string", internalType: "string" },
      { name: "memberCount", type: "uint256", internalType: "uint256" },
      { name: "isActive", type: "bool", internalType: "bool" },
      { name: "creator", type: "address", internalType: "address" },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "deleteMessage",
    inputs: [
      { name: "groupId", type: "uint256", internalType: "uint256" },
      { name: "messageIndex", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "getUserProfile",
    inputs: [{ name: "user", type: "address", internalType: "address" }],
    outputs: [
      {
        name: "",
        type: "tuple",
        internalType: "struct ResearchGroups.UserProfile",
        components: [
          { name: "reputation", type: "uint256", internalType: "uint256" },
          { name: "messageCount", type: "uint256", internalType: "uint256" },
        ],
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "groupMembers",
    inputs: [
      { name: "", type: "uint256", internalType: "uint256" },
      { name: "", type: "uint256", internalType: "uint256" },
    ],
    outputs: [{ name: "", type: "address", internalType: "address" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "groupMessages",
    inputs: [
      { name: "", type: "uint256", internalType: "uint256" },
      { name: "", type: "uint256", internalType: "uint256" },
    ],
    outputs: [
      { name: "sender", type: "address", internalType: "address" },
      { name: "content", type: "string", internalType: "string" },
      { name: "timestamp", type: "uint256", internalType: "uint256" },
      { name: "upvotes", type: "uint256", internalType: "uint256" },
      { name: "deleted", type: "bool", internalType: "bool" },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "joinCustomGroup",
    inputs: [{ name: "groupId", type: "uint256", internalType: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "joinPredefinedGroup",
    inputs: [
      {
        name: "topic",
        type: "uint8",
        internalType: "enum ResearchGroups.PredefinedTopic",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "joined",
    inputs: [
      { name: "", type: "address", internalType: "address" },
      { name: "", type: "uint256", internalType: "uint256" },
    ],
    outputs: [{ name: "", type: "bool", internalType: "bool" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "predefinedGroups",
    inputs: [
      {
        name: "",
        type: "uint8",
        internalType: "enum ResearchGroups.PredefinedTopic",
      },
    ],
    outputs: [
      { name: "name", type: "string", internalType: "string" },
      { name: "description", type: "string", internalType: "string" },
      { name: "memberCount", type: "uint256", internalType: "uint256" },
      { name: "isActive", type: "bool", internalType: "bool" },
      { name: "creator", type: "address", internalType: "address" },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "roles",
    inputs: [{ name: "", type: "address", internalType: "address" }],
    outputs: [
      { name: "", type: "uint8", internalType: "enum ResearchGroups.Role" },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "sendMessage",
    inputs: [
      { name: "groupId", type: "uint256", internalType: "uint256" },
      { name: "content", type: "string", internalType: "string" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "updateCustomGroupStatus",
    inputs: [
      { name: "groupId", type: "uint256", internalType: "uint256" },
      { name: "isActive", type: "bool", internalType: "bool" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "upvoteMessage",
    inputs: [
      { name: "groupId", type: "uint256", internalType: "uint256" },
      { name: "messageIndex", type: "uint256", internalType: "uint256" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "userMemberships",
    inputs: [
      { name: "", type: "address", internalType: "address" },
      { name: "", type: "uint256", internalType: "uint256" },
    ],
    outputs: [{ name: "", type: "bool", internalType: "bool" }],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "userProfiles",
    inputs: [{ name: "", type: "address", internalType: "address" }],
    outputs: [
      { name: "reputation", type: "uint256", internalType: "uint256" },
      { name: "messageCount", type: "uint256", internalType: "uint256" },
    ],
    stateMutability: "view",
  },
  {
    type: "event",
    name: "GroupCreated",
    inputs: [
      {
        name: "groupId",
        type: "uint256",
        indexed: true,
        internalType: "uint256",
      },
      { name: "name", type: "string", indexed: false, internalType: "string" },
      {
        name: "creator",
        type: "address",
        indexed: false,
        internalType: "address",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "GroupJoined",
    inputs: [
      {
        name: "groupId",
        type: "uint256",
        indexed: true,
        internalType: "uint256",
      },
      { name: "user", type: "address", indexed: true, internalType: "address" },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "GroupLeft",
    inputs: [
      {
        name: "groupId",
        type: "uint256",
        indexed: true,
        internalType: "uint256",
      },
      { name: "user", type: "address", indexed: true, internalType: "address" },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "GroupStatusUpdated",
    inputs: [
      {
        name: "groupId",
        type: "uint256",
        indexed: true,
        internalType: "uint256",
      },
      { name: "isActive", type: "bool", indexed: false, internalType: "bool" },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "MessageDeleted",
    inputs: [
      {
        name: "groupId",
        type: "uint256",
        indexed: true,
        internalType: "uint256",
      },
      {
        name: "messageIndex",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "MessageSent",
    inputs: [
      {
        name: "groupId",
        type: "uint256",
        indexed: true,
        internalType: "uint256",
      },
      {
        name: "sender",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "content",
        type: "string",
        indexed: false,
        internalType: "string",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "MessageUpvoted",
    inputs: [
      {
        name: "groupId",
        type: "uint256",
        indexed: true,
        internalType: "uint256",
      },
      {
        name: "messageIndex",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
      {
        name: "voter",
        type: "address",
        indexed: true,
        internalType: "address",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "UserPromoted",
    inputs: [
      { name: "user", type: "address", indexed: true, internalType: "address" },
      {
        name: "newRole",
        type: "uint8",
        indexed: false,
        internalType: "enum ResearchGroups.Role",
      },
    ],
    anonymous: false,
  },
];
