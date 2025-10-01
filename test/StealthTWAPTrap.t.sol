// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/StealthTWAPTrap.sol";
import "../src/StealthTWAPResponse.sol";

contract StealthTWAPTrapTest is Test {
    StealthTWAPTrap trap;
    StealthTWAPResponse response;

    address constant TOKEN = address(0x123);
    address constant VAULT = address(0x456);

    function setUp() public {
        trap = new StealthTWAPTrap(TOKEN, VAULT, 20, 1000);
        response = new StealthTWAPResponse();
    }

    function testHandleTWAPEvent() public {
        vm.expectEmit(true, false, false, true);
        emit StealthTWAPResponse.TWAPTriggered(TOKEN, 1200, address(this));

        response.handleTWAPEvent(TOKEN, 1200);
    }

    function testTrapLogicCallsResponse() public {
        vm.expectEmit(true, false, false, true);
        emit StealthTWAPResponse.TWAPTriggered(TOKEN, 1500, address(this));

        response.handleTWAPEvent(TOKEN, 1500);
    }
}
