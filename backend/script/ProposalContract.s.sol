// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DeScholarProposal} from "../src/ProposalContract.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        DeScholarProposal deScholarProposal = new DeScholarProposal();

        console.log(
            "DeScholarProposal deployed at:",
            address(deScholarProposal)
        );

        vm.stopBroadcast();
    }
}
