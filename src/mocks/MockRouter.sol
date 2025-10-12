// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MockRouter
 * @notice Simple mock DEX router for local testing of StealthTWAPTrap.
 *         It pretends to perform swaps and returns predictable values.
 */
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MockRouter {
    using SafeERC20 for IERC20;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /// @notice mock function similar to Uniswap's swapExactTokensForTokens
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 /*deadline*/
    ) external returns (uint256[] memory amounts) {
        require(path.length >= 2, "Invalid path");

        // Transfer input tokens from msg.sender
        IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountIn);

        // For simplicity, this mock just returns a 1:1 swap ratio
        uint256 amountOut = amountIn;

        // Mint/mock-transfer the output token to receiver
        IERC20(path[path.length - 1]).safeTransfer(to, amountOut);

        // Prepare output array
        amounts = new uint256 ;
        amounts[0] = amountIn;
        amounts[1] = amountOut;
    }

    /// @notice mock function similar to Uniswap's getAmountsOut
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external pure returns (uint256[] memory amounts) {
        require(path.length >= 2, "Invalid path");
        amounts = new uint256 ;
        amounts[0] = amountIn;
        // Mock a simple 1:1 price ratio
        amounts[1] = amountIn;
    }

    /// @notice mock function similar to addLiquidity
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256,
        uint256,
        address to,
        uint256
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), amountADesired);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountBDesired);

        // Just mirror back the values
        amountA = amountADesired;
        amountB = amountBDesired;
        liquidity = (amountADesired + amountBDesired) / 2;

        IERC20(tokenA).safeTransfer(to, amountA / 100); // tiny "reward"
        IERC20(tokenB).safeTransfer(to, amountB / 100);
    }

    /// @notice mock removeLiquidity
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256,
        uint256,
        address to,
        uint256
    ) external returns (uint256 amountA, uint256 amountB) {
        // Return some arbitrary values for testing
        amountA = liquidity / 2;
        amountB = liquidity / 2;

        IERC20(tokenA).safeTransfer(to, amountA);
        IERC20(tokenB).safeTransfer(to, amountB);
    }
}
