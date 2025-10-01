// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StealthTWAPResponse {
    event TWAPTriggered(address indexed token, uint256 twapValue, address triggeredBy);

    function handleTWAPEvent(address token, uint256 twapValue) external {
        emit TWAPTriggered(token, twapValue, msg.sender);
    }
}
