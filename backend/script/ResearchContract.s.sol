// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DeScholarResearch} from "../src/ResearchContract.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        address dstToken = 0x7c6c7918494C29AcD2764b9CCC153eEBed7FE415; // Replace with actual ERC20 token address
        DeScholarResearch researchContract = new DeScholarResearch(dstToken);

        console.log(
            "DeScholarResearch deployed at:",
            address(researchContract)
        );

        vm.stopBroadcast();
    }
}
