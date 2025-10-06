// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/StealthTWAPTrap.sol";
import "../src/StealthTWAPResponse.sol";

/// @title Deploy Script for Stealth TWAP Trap
/// @notice Deploys both the trap and its response contract on the Hoodi Testnet
contract DeployTrap is Script {
    // Declare contract instances
    StealthTWAPTrap public trap;
    StealthTWAPResponse public response;

    function run() external {
        // Load deployer private key from environment variable
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Begin broadcast
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the response contract first
        response = new StealthTWAPResponse();

        // Deploy the main Stealth TWAP trap contract
        trap = new StealthTWAPTrap(
            address(response) // Pass response contract address to the trap if needed
        );

        // Stop broadcast
        vm.stopBroadcast();

        // Log deployed addresses
        console.log("StealthTWAPResponse deployed at:", address(response));
        console.log("StealthTWAPTrap deployed at:", address(trap));
    }
}
