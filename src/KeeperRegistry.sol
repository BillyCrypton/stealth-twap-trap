// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
  KeeperRegistry.sol
  - Simple staking-based registry of keepers.
  - Keepers must stake an ERC20 token to register.
  - Minimal and intentionally simple for testnet use.
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KeeperRegistry is Ownable {
    IERC20 public immutable stakeToken;
    uint256 public immutable minStake;

    mapping(address => uint256) public stakes;
    mapping(address => bool) public active;

    event Registered(address indexed keeper, uint256 stake);
    event Unregistered(address indexed keeper, uint256 stake);
    event Slashed(address indexed keeper, uint256 amount, address indexed to);

    constructor(address _stakeToken, uint256 _minStake) {
        require(_stakeToken != address(0), "zero token");
        stakeToken = IERC20(_stakeToken);
        minStake = _minStake;
    }

    function register(uint256 amount) external {
        require(amount >= minStake, "stake too small");
        stakeToken.transferFrom(msg.sender, address(this), amount);
        stakes[msg.sender] += amount;
        if (!active[msg.sender] && stakes[msg.sender] >= minStake) {
            active[msg.sender] = true;
            emit Registered(msg.sender, stakes[msg.sender]);
        }
    }

    function unregister() external {
        require(active[msg.sender], "not active");
        uint256 s = stakes[msg.sender];
        stakes[msg.sender] = 0;
        active[msg.sender] = false;
        stakeToken.transfer(msg.sender, s);
        emit Unregistered(msg.sender, s);
    }

    function slash(address keeper, uint256 amount, address to) external onlyOwner {
        require(active[keeper], "not active");
        require(amount <= stakes[keeper], "exceeds stake");
        stakes[keeper] -= amount;
        stakeToken.transfer(to, amount);
        emit Slashed(keeper, amount, to);
        if (stakes[keeper] < minStake) {
            active[keeper] = false;
            emit Unregistered(keeper, stakes[keeper]);
        }
    }

    function isKeeper(address who) external view returns (bool) {
        return active[who] && stakes[who] >= minStake;
    }
}
