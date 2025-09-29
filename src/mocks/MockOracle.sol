// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
  MockOracle: returns a configurable price scaled by 1e18 (tokenOut per tokenIn).
  getPrice(tokenIn, tokenOut, windowSecs) ignores windowSecs for simplicity.
*/
contract MockOracle {
    uint256 public priceScaled = 1e18;

    function setPrice(uint256 scaled) external {
        priceScaled = scaled;
    }

    function getPrice(address /*tokenIn*/, address /*tokenOut*/, uint32 /*window*/) external view returns (uint256) {
        require(priceScaled > 0, "price not set");
        return priceScaled;
    }
}
