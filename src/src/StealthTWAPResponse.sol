// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title StealthTWAPResponse
/// @notice Minimal secure response for StealthTWAPTrap. Emits an event when called by an authorized caller.
/// Owner can add/remove authorized callers (e.g., the deployed trap or the Drosera relay).
contract StealthTWAPResponse is Ownable {
    /// @notice Emitted when TWAP response executes
    event TWAPTriggered(address indexed token, uint256 twapValue, address indexed triggeredBy, uint256 timestamp);

    /// @notice Optional: emitted when an action is performed by the response contract
    event ResponseActionExecuted(address indexed target, bytes data);

    mapping(address => bool) public authorized;

    modifier onlyAuthorized() {
        require(authorized[msg.sender] || owner() == msg.sender, "Not authorized");
        _;
    }

    constructor() {
        // owner is deployer by default (Ownable)
    }

    /// @notice Called by the trap (via Drosera) to notify a TWAP breach
    /// Matches drosera.toml signature: handleTWAPEvent(address,uint256)
    function handleTWAPEvent(address token, uint256 twapValue) external onlyAuthorized {
        emit TWAPTriggered(token, twapValue, msg.sender, block.timestamp);
    }

    /// --------------------
    /// Administration
    /// --------------------

    /// @notice Add an authorized caller (trap address or Drosera relay)
    function addAuthorized(address who) external onlyOwner {
        require(who != address(0), "zero addr");
        authorized[who] = true;
    }

    /// @notice Remove an authorized caller
    function removeAuthorized(address who) external onlyOwner {
        authorized[who] = false;
    }

    /// --------------------
    /// Optional advanced actions (owner only)
    /// --------------------

    /// @notice Execute an arbitrary call from this contract (owner only).
    /// Use for advanced responses only (e.g., forwarding to an automation contract).
    function executeAction(address target, bytes calldata data) external onlyOwner returns (bytes memory) {
        require(target != address(0), "zero target");
        (bool ok, bytes memory ret) = target.call(data);
        require(ok, "call failed");
        emit ResponseActionExecuted(target, data);
        return ret;
    }
}
