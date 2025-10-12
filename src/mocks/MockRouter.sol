// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title MockRouter
/// @notice Minimal mock of a DEX router for testing
contract MockRouter {
    using SafeERC20 for IERC20;

    constructor() {}

    /// @notice Simulates swapExactTokensForTokens (mock 1:1)
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256, // amountOutMin (ignored in mock)
        address[] calldata path,
        address to,
        uint256 // deadline (ignored)
    ) external returns (uint256[] memory amounts) {
        require(path.length >= 2, "Invalid path");

        // take tokens from caller
        IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountIn);

        // mock a 1:1 swap
        uint256 amountOut = amountIn;
        IERC20(path[path.length - 1]).safeTransfer(to, amountOut);

        // CORRECT memory array allocation: new uint256
        amounts = new uint256;
        amounts[0] = amountIn;
        amounts[1] = amountOut;
    }

    /// @notice Simulates getAmountsOut (mock 1:1)
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external pure returns (uint256[] memory amounts) {
        require(path.length >= 2, "Invalid path");

        amounts = new uint256;
        amounts[0] = amountIn;
        amounts[1] = amountIn;
    }
}
