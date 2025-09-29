// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/StealthTWAPTrap.sol";
import "../src/KeeperRegistry.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockRouter.sol";
import "../src/mocks/MockOracle.sol";

contract DeployTrap is Script {
    function run() external {
        // Load deployer private key
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy mocks (for testing purposes on Hoodi testnet)
        MockERC20 tokenA = new MockERC20("TokenA", "TKA", 18);
        MockERC20 tokenB = new MockERC20("TokenB", "TKB", 18);
        MockRouter router = new MockRouter();
        MockOracle oracle = new MockOracle();

        // Deploy registry
        KeeperRegistry registry = new KeeperRegistry();

        // Deploy the trap
        StealthTWAPTrap trap = new StealthTWAPTrap(
            address(tokenA),
            address(tokenB),
            address(router),
            address(oracle),
            address(registry),
            1e18,      // amountIn = 1 TKA
            5          // twapInterval = 5 blocks
        );

        // Register the trap in registry
        registry.registerTrap(address(trap));

        vm.stopBroadcast();
    }
}
