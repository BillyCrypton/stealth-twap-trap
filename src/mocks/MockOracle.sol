// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MockOracle {
    uint256 public price = 1e18;

    function setPrice(uint256 p) external {
        price = p;
    }

    function getPrice(address, address) external view returns (uint256) {
        return price;
    }
}
