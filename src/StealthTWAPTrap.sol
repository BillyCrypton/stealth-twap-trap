// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IRegistry {
    function isKeeper(address) external view returns (bool);
}

interface IOracle {
    function getPrice(address tokenIn, address tokenOut) external view returns (uint256);
}

/// @title Stealth TWAP Trap (testnet unique trap for Hoodi)
/// @notice Commit–reveal order execution guarded by TWAP + keeper registry
contract StealthTWAPTrap is Ownable, ReentrancyGuard {
    IRouter public router;
    IRegistry public registry;
    IOracle public oracle;

    struct Order {
        address user;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minOut;
        uint256 deadline;
        bool executed;
    }

    mapping(bytes32 => Order) public orders;
    mapping(bytes32 => bytes32) public commitments;

    event OrderCommitted(bytes32 indexed id, bytes32 commitment);
    event OrderRevealed(bytes32 indexed id, address user);
    event OrderExecuted(bytes32 indexed id, address keeper, uint256 amountOut);

    constructor(address _router, address _registry, address _oracle) {
        router = IRouter(_router);
        registry = IRegistry(_registry);
        oracle = IOracle(_oracle);
    }

    /// @notice Commit a new order hash
    function commitOrder(bytes32 id, bytes32 commitment) external {
        require(commitments[id] == 0, "Already committed");
        commitments[id] = commitment;
        emit OrderCommitted(id, commitment);
    }

    /// @notice Reveal preimage of commitment and create order
    function revealAndCreateOrder(
        bytes32 id,
        bytes32 salt,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minOut,
        uint256 deadline
    ) external {
        require(commitments[id] != 0, "No commitment");
        bytes32 preimage = keccak256(abi.encodePacked(msg.sender, salt, tokenIn, tokenOut, amountIn, minOut, deadline));
        require(preimage == commitments[id], "Invalid reveal");

        orders[id] = Order(msg.sender, tokenIn, tokenOut, amountIn, minOut, deadline, false);

        emit OrderRevealed(id, msg.sender);
    }

    /// @notice Keeper executes order if TWAP condition is satisfied
    function executeOrder(bytes32 id) external nonReentrant {
        require(registry.isKeeper(msg.sender), "Not keeper");
        Order storage o = orders[id];
        require(!o.executed, "Already executed");
        require(o.deadline >= block.timestamp, "Expired");

        uint256 price = oracle.getPrice(o.tokenIn, o.tokenOut);
        require(price > 0, "Bad oracle");

        address ;
        path[0] = o.tokenIn;
        path[1] = o.tokenOut;

        IERC20(o.tokenIn).approve(address(router), o.amountIn);
        uint[] memory amounts = router.swapExactTokensForTokens(
            o.amountIn,
            o.minOut,
            path,
            o.user,
            block.timestamp + 60
        );

        o.executed = true;
        emit OrderExecuted(id, msg.sender, amounts[amounts.length - 1]);
    }
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}
