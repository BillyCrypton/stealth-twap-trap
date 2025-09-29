// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Simple Keeper Registry
/// @notice Keepers must stake tokens to be eligible
contract KeeperRegistry {
    IERC20 public stakeToken;
    uint256 public minStake;
    mapping(address => uint256) public stakes;

    constructor(address _token, uint256 _minStake) {
        stakeToken = IERC20(_token);
        minStake = _minStake;
    }

    function register(uint256 amount) external {
        require(amount >= minStake, "Below min stake");
        stakeToken.transferFrom(msg.sender, address(this), amount);
        stakes[msg.sender] += amount;
    }

    function isKeeper(address k) external view returns (bool) {
        return stakes[k] >= minStake;
    }
}
