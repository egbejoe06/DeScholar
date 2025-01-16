// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DeScholarToken} from "../src/DeScholarToken.sol";

contract DeployScript is Script {
    function run() external returns (DeScholarToken) {
        // Begin recording transactions for deployment
        vm.startBroadcast();

        // Deploy the contract
        DeScholarToken deScholarToken = new DeScholarToken();

        // Stop recording transactions
        vm.stopBroadcast();

        // Return the deployed token contract instance
        return deScholarToken;
    }
}
