// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MockERC20.sol";

/*
  Simple Mock Router:
  - swapExactTokensForTokens: expects the caller (contract) to have approved router.
  - For simplicity we treat swaps as 1:1 (amountOut = amountIn).
  - This design expects the trap contract to call router.swapExactTokensForTokens
    after approving router (so router.transferFrom(msg.sender, address(this), amountIn) pulls tokens from trap).
*/

contract MockRouter {
    function getAmountsOut(uint amountIn, address[] calldata /*path*/) external pure returns (uint[] memory amounts) {
        amounts = new uint;
        amounts[0] = amountIn;
        amounts[1] = amountIn;
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint /* amountOutMin */,
        address[] calldata path,
        address to,
        uint /* deadline */
    ) external returns (uint[] memory amounts) {
        // pull tokenIn from caller (the trap contract)
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);

        // If tokenOut is the same token as tokenIn, just transfer back
        if (path[0] == path[path.length - 1]) {
            IERC20(path[0]).transfer(to, amountIn);
        } else {
            // If tokenOut is MockERC20, mint to recipient (works with our MockERC20)
            try MockERC20(path[path.length - 1]).mint(to, amountIn) {
                // minted successfully
            } catch {
                // Fallback: if tokenOut cannot be minted, attempt to transfer tokenIn
                IERC20(path[0]).transfer(to, amountIn);
            }
        }

        amounts = new uint;
        amounts[0] = amountIn;
        amounts[1] = amountIn;
    }
}
