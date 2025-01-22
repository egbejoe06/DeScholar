// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {ResearchGroups} from "../src/ResearchGroupContract.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        ResearchGroups researchGroups = new ResearchGroups();

        console.log("ResearchGroups deployed at:", address(researchGroups));

        vm.stopBroadcast();
    }
}
