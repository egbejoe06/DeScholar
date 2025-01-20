export const Question_CONTRACT_ADDRESS =
  "0xe077b1Fe1416821f0eB0d2Cb68A20517231a7757";
export const Question_CONTRACT_ABI = [
  {
    type: "function",
    name: "askQuestion",
    inputs: [{ name: "content", type: "string", internalType: "string" }],
    outputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "getAllQuestions",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "tuple[]",
        internalType: "struct QuestionAndAnswer.Question[]",
        components: [
          { name: "questionId", type: "uint256", internalType: "uint256" },
          { name: "content", type: "string", internalType: "string" },
          { name: "asker", type: "address", internalType: "address" },
          { name: "timestamp", type: "uint256", internalType: "uint256" },
          { name: "isResolved", type: "bool", internalType: "bool" },
          { name: "exists", type: "bool", internalType: "bool" },
        ],
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getAnswers",
    inputs: [{ name: "questionId", type: "uint256", internalType: "uint256" }],
    outputs: [
      {
        name: "",
        type: "tuple[]",
        internalType: "struct QuestionAndAnswer.Answer[]",
        components: [
          { name: "answerId", type: "uint256", internalType: "uint256" },
          { name: "questionId", type: "uint256", internalType: "uint256" },
          { name: "content", type: "string", internalType: "string" },
          { name: "responder", type: "address", internalType: "address" },
          { name: "timestamp", type: "uint256", internalType: "uint256" },
          { name: "exists", type: "bool", internalType: "bool" },
        ],
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "questionAnswers",
    inputs: [
      { name: "", type: "uint256", internalType: "uint256" },
      { name: "", type: "uint256", internalType: "uint256" },
    ],
    outputs: [
      { name: "answerId", type: "uint256", internalType: "uint256" },
      { name: "questionId", type: "uint256", internalType: "uint256" },
      { name: "content", type: "string", internalType: "string" },
      { name: "responder", type: "address", internalType: "address" },
      { name: "timestamp", type: "uint256", internalType: "uint256" },
      { name: "exists", type: "bool", internalType: "bool" },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "questions",
    inputs: [{ name: "", type: "uint256", internalType: "uint256" }],
    outputs: [
      { name: "questionId", type: "uint256", internalType: "uint256" },
      { name: "content", type: "string", internalType: "string" },
      { name: "asker", type: "address", internalType: "address" },
      { name: "timestamp", type: "uint256", internalType: "uint256" },
      { name: "isResolved", type: "bool", internalType: "bool" },
      { name: "exists", type: "bool", internalType: "bool" },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "resolveQuestion",
    inputs: [{ name: "questionId", type: "uint256", internalType: "uint256" }],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "submitAnswer",
    inputs: [
      { name: "questionId", type: "uint256", internalType: "uint256" },
      { name: "content", type: "string", internalType: "string" },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
];
