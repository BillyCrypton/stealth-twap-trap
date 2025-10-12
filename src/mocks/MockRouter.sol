// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title MockRouter
/// @notice Minimal mock of a DEX router for testing
contract MockRouter {
    using SafeERC20 for IERC20;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    /// @notice Simulates a swap; returns a 1:1 exchange
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 /* amountOutMin */,
        address[] calldata path,
        address to,
        uint256 /* deadline */
    ) external returns (uint256[] memory amounts) {
        require(path.length >= 2, "Invalid path");

        IERC20(path[0]).safeTransferFrom(msg.sender, address(this), amountIn);

        uint256 amountOut = amountIn;
        IERC20(path[path.length - 1]).safeTransfer(to, amountOut);

        // ✅ allocate array of length 2
        amounts = new uint256 ;
        amounts[0] = amountIn;
        amounts[1] = amountOut;
    }

    /// @notice Simulates getAmountsOut; returns 1:1 mapping
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external pure returns (uint256[] memory amounts) {
        require(path.length >= 2, "Invalid path");

        // ✅ allocate array of length 2
        amounts = new uint256 ;
        amounts[0] = amountIn;
        amounts[1] = amountIn;
    }

    /// @notice Simulates addLiquidity; mirrors back inputs
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

        amountA = amountADesired;
        amountB = amountBDesired;
        liquidity = (amountADesired + amountBDesired) / 2;

        IERC20(tokenA).safeTransfer(to, amountA / 100);
        IERC20(tokenB).safeTransfer(to, amountB / 100);
    }

    /// @notice Simulates removeLiquidity; returns half–half split
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256,
        uint256,
        address to,
        uint256
    ) external returns (uint256 amountA, uint256 amountB) {
        amountA = liquidity / 2;
        amountB = liquidity / 2;

        IERC20(tokenA).safeTransfer(to, amountA);
        IERC20(tokenB).safeTransfer(to, amountB);
    }
}
