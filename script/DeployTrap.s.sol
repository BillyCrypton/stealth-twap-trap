// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/StealthToken.sol";
import "../src/StealthVault.sol";
import "../src/StealthTWAP.sol";

contract DeployTrap is Script {
    // Deployment parameters (you can change these before running)
    uint256 constant INITIAL_SUPPLY = 1_000_000 * 1e18;  // 1M tokens
    uint256 constant TWAP_INTERVAL = 3600;               // 1 hour interval

    function run() external {
        // Load deployer private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Step 1: Deploy Token
        StealthToken token = new StealthToken(INITIAL_SUPPLY);
        console.log("StealthToken deployed at:", address(token));

        // Step 2: Deploy Vault
        StealthVault vault = new StealthVault(msg.sender); 
        console.log("StealthVault deployed at:", address(vault));

        // Step 3: Deploy TWAP executor (uses token)
        StealthTWAP twap = new StealthTWAP(address(token), TWAP_INTERVAL);
        console.log("StealthTWAP deployed at:", address(twap));

        // Step 4: (Optional) Transfer some tokens to Vault and TWAP for testing
        token.mint(address(vault), 10_000 * 1e18);
        token.mint(address(twap), 5_000 * 1e18);

        console.log("Initial funding done");

        vm.stopBroadcast();
    }
}
