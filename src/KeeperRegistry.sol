// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract KeeperRegistry is Ownable {
    constructor() Ownable(msg.sender) {}

    // Example keeper mapping
    mapping(address => bool) public keepers;

    function registerKeeper(address keeper) external onlyOwner {
        keepers[keeper] = true;
    }

    function removeKeeper(address keeper) external onlyOwner {
        keepers[keeper] = false;
    }
}
