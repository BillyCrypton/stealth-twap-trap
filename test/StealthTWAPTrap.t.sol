// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/StealthTWAPResponse.sol";

contract StealthTWAPResponseTest is Test {
    StealthTWAPResponse response;
    address alice = address(0xA11CE);
    address trap = address(0xBEEF);

    function setUp() public {
        response = new StealthTWAPResponse();
        // by default owner is address(this) in tests; make trap authorized via owner
        response.addAuthorized(trap);
    }

    function testAuthorizedEmitsEvent() public {
        vm.prank(trap);
        // Expect emitted event
        vm.expectEmit(true, false, false, true);
        emit StealthTWAPResponse.TWAPTriggered(address(0x123), 2000, trap, block.timestamp);

        vm.prank(trap);
        response.handleTWAPEvent(address(0x123), 2000);
    }

    function testUnauthorizedReverts() public {
        vm.expectRevert("Not authorized");
        response.handleTWAPEvent(address(0x123), 1000);
    }
}

}
