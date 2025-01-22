// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DeScholarICO} from "../src/DeScholarICO.sol";

contract DeployScript is Script {
    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Replace with actual ERC20 token address
        address dstToken = 0x7c6c7918494C29AcD2764b9CCC153eEBed7FE415;
        uint256 tokensAvailableForSale = 10000000;

        // Deploy the DeScholarICO contract
        DeScholarICO deScholarICO = new DeScholarICO(dstToken, tokensAvailableForSale);

        // Log the deployed contract address
        console.log("DeScholarICO deployed at:", address(deScholarICO));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}