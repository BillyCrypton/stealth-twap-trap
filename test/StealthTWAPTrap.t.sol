// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/StealthTWAPTrap.sol";
import "../src/KeeperRegistry.sol";
import "../src/mocks/MockERC20.sol";
import "../src/mocks/MockRouter.sol";
import "../src/mocks/MockOracle.sol";

contract StealthTWAPTrapTest is Test {
    MockERC20 tokenA;
    MockERC20 tokenB;
    MockRouter router;
    MockOracle oracle;
    KeeperRegistry registry;
    StealthTWAPTrap trap;

    address user = address(0x123);

    function setUp() public {
        tokenA = new MockERC20("TokenA", "TKA", 18);
        tokenB = new MockERC20("TokenB", "TKB", 18);
        router = new MockRouter();
        oracle = new MockOracle();
        registry = new KeeperRegistry();

        trap = new StealthTWAPTrap(
            address(tokenA),
            address(tokenB),
            address(router),
            address(oracle),
            address(registry),
            1e18,  // swap 1 TKA
            5      // 5 blocks TWAP
        );

        registry.registerTrap(address(trap));

        // Fund user with TKA
        tokenA.mint(user, 10e18);
        vm.startPrank(user);
        tokenA.approve(address(trap), 10e18);
        vm.stopPrank();
    }

    function testExecuteTrap() public {
        // User triggers the trap
        vm.startPrank(user);
        trap.execute();
        vm.stopPrank();

        // Check balances
        uint256 balanceTokenA = tokenA.balanceOf(user);
        uint256 balanceTokenB = tokenB.balanceOf(user);

        assertLt(balanceTokenA, 10e18); // should spend some TKA
        assertGt(balanceTokenB, 0);     // should receive some TKB
    }

    function testOnlyRegisteredTrap() public {
        vm.expectRevert("not registered trap");
        registry.deregisterTrap(address(0xdead));
    }
}

