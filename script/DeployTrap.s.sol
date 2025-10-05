/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/StealthTWAPTrap.sol";
import "../src/StealthTWAPResponse.sol";

contract DeployTrap is Script {
    // Example constructor args (change to your trap constructor)
    address constant TOKEN = 0x0000000000000000000000000000000000000001;
    address constant VAULT = 0x0000000000000000000000000000000000000002;
    uint256 constant WINDOW = 20;
    uint256 constant THRESHOLD = 1000;

    function run() external {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        // Deploy trap (adjust args to your actual contract)
        StealthTWAPTrap trap = new StealthTWAPTrap(TOKEN, VAULT, WINDOW, THRESHOLD);

        // Deploy response
        StealthTWAPResponse response = new StealthTWAPResponse();

        // Authorize the trap in the response contract
        response.addAuthorized(address(trap));

        vm.stopBroadcast();

        console2.log("StealthTWAPTrap deployed at:", address(trap));
        console2.log("StealthTWAPResponse deployed at:", address(response));
    }
}

