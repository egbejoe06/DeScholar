// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {QuestionAndAnswer} from "../src/QuestionContract.sol";

contract DeployScript is Script {
    function run() external returns (QuestionAndAnswer) {
        // Begin recording transactions for deployment
        vm.startBroadcast();

        // Deploy the contract
        QuestionAndAnswer questionAndanswer = new QuestionAndAnswer();

        // Stop recording transactions
        vm.stopBroadcast();

        // Return the deployed token contract instance
        return questionAndanswer;
    }
}
