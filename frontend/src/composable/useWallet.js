import { ref } from "vue";
import { ethers } from "ethers";
// import { CONTRACT_ADDRESS, CONTRACT_ABI } from "../constant/tokenContract";
import {
  Research_CONTRACT_ADDRESS,
  Research_CONTRACT_ABI,
} from "../constants/ResearchContract";
import {
  Question_CONTRACT_ADDRESS,
  Question_CONTRACT_ABI,
} from "../constants/QuestionContract";
import {
  Proposal_CONTRACT_ADDRESS,
  Proposal_CONTRACT_ABI,
} from "../constants/ProposalContract";
import {
  ICO_CONTRACT_ADDRESS,
  ICO_CONTRACT_ABI,
} from "../constants/ICOContract";

let provider = null;
let signer = null;
let ResearchContractInstance = null;
let QuestionContractInstance = null;
let ProposalContractInstance = null;
let ICOContractInstance = null;

// Vue reactive state
const connected = ref(false);
const userAccount = ref("");
const isAuthenticated = ref(false);

export const useWallet = () => {
  const connectWallet = async () => {
    // Check if MetaMask is installed
    if (typeof window.ethereum !== "undefined") {
      try {
        await window.ethereum.request({ method: "eth_requestAccounts" });
        provider = new ethers.providers.Web3Provider(window.ethereum);
        signer = provider.getSigner();
        userAccount.value = await signer.getAddress();
        connected.value = true;

        ResearchContractInstance = new ethers.Contract(
          Research_CONTRACT_ADDRESS,
          Research_CONTRACT_ABI,
          signer
        );
        QuestionContractInstance = new ethers.Contract(
          Question_CONTRACT_ADDRESS,
          Question_CONTRACT_ABI,
          signer
        );
        ProposalContractInstance = new ethers.Contract(
          Proposal_CONTRACT_ADDRESS,
          Proposal_CONTRACT_ABI,
          signer
        );
        ICOContractInstance = new ethers.Contract(
          ICO_CONTRACT_ADDRESS,
          ICO_CONTRACT_ABI,
          signer
        );

        window.ethereum.on("accountsChanged", handleAccountsChanged);
        return (
          ResearchContractInstance,
          QuestionContractInstance,
          ProposalContractInstance,
          ICOContractInstance
        );
      } catch (error) {
        connected.value = false;
        console.error("Error connecting wallet:", error);
        throw error;
      }
    } else {
      // Handle mobile deep linking with return URL
      const currentUrl = encodeURIComponent(window.location.href);

      // Universal Link format
      let metamaskAppDeepLink;
      if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
        // iOS needs a different format
        metamaskAppDeepLink = `metamask://dapp/${window.location.host}?redirect=${currentUrl}`;
      } else {
        // Android format
        metamaskAppDeepLink = `https://metamask.app.link/dapp/${window.location.host}?redirect=${currentUrl}`;
      }

      // For debugging
      console.log("Redirecting to:", metamaskAppDeepLink);

      if (
        /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
          navigator.userAgent
        )
      ) {
        window.location.href = metamaskAppDeepLink;
      } else {
        throw new Error("Please install MetaMask!");
      }
    }
  };

  const handleAccountsChanged = async (accounts) => {
    if (accounts.length === 0) {
      connected.value = false;
      userAccount.value = "";
    } else {
      userAccount.value = accounts[0];
      connected.value = true;
    }
  };

  if (window.ethereum) {
    window.ethereum
      .request({ method: "eth_accounts" })
      .then(async (accounts) => {
        if (accounts.length > 0) {
          await connectWallet();
        }
      });
  }

  const getResearchContract = () => ResearchContractInstance;
  const getQuestionContract = () => QuestionContractInstance;
  const getProposalContract = () => ProposalContractInstance;
  const getICOContract = () => ICOContractInstance;

  const signInWithEthereum = async () => {
    if (!connected.value) {
      throw new Error("Wallet not connected");
    }

    const domain = window.location.host;
    const nonce = Math.floor(Math.random() * 1000000).toString();
    const currentTime = new Date().toISOString();

    const message = `${domain} wants you to sign in with your Ethereum account:
${userAccount.value}

I accept the Terms of Service: https://${domain}/tos

URI: https://${domain}
Version: 1
Chain ID: 11155111
Nonce: ${nonce}
Issued At: ${currentTime}`;

    try {
      const signature = await signer.signMessage(message);
      isAuthenticated.value = true;
      return signature;
    } catch (error) {
      console.error("Error signing message:", error);
      throw error;
    }
  };

  return {
    connected,
    userAccount,
    connectWallet,
    isAuthenticated,
    signInWithEthereum,
    getResearchContract,
    getProposalContract,
    getQuestionContract,
    getICOContract,
  };
};
