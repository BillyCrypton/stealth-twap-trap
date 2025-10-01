// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/StealthTWAPTrap.sol";
import "../src/StealthTWAPResponse.sol";

contract DeployTrap is Script {
    // Replace with real testnet params for your trap
    address constant TOKEN = 0x0000000000000000000000000000000000000001;
    address constant VAULT = 0x0000000000000000000000000000000000000002;
    uint256 constant WINDOW = 20;
    uint256 constant THRESHOLD = 1000;

    function run() external {
        vm.startBroadcast();

        StealthTWAPTrap trap = new StealthTWAPTrap(TOKEN, VAULT, WINDOW, THRESHOLD);
        StealthTWAPResponse response = new StealthTWAPResponse();

        vm.stopBroadcast();

        console2.log("StealthTWAPTrap deployed at:", address(trap));
        console2.log("StealthTWAPResponse deployed at:", address(response));
    }
}
