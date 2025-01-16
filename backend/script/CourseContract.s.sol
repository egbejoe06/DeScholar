// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {DeScholarCourse} from "../src/CourseContract.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        address dstToken = 0x7c6c7918494C29AcD2764b9CCC153eEBed7FE415; // Replace with actual ERC20 token address
        address researchContract = 0x6f95Ab3F65e49422B9794f4A75E547cD05e0fe34; // Replace with deployed DeScholarResearch address

        DeScholarCourse courseContract = new DeScholarCourse(
            dstToken,
            researchContract
        );

        console.log("DeScholarCourse deployed at:", address(courseContract));

        vm.stopBroadcast();
    }
}
