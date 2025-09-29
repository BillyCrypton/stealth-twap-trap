// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
  StealthTWAPTrap.sol
  - Commit-reveal deposit flow.
  - Orders executed only by registered keepers (KeeperRegistry).
  - Price check via a pluggable Price Oracle (simple interface).
  - Uses OpenZeppelin v5 imports (utils/ReentrancyGuard, token utils).
*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IKeeperRegistry {
    function isKeeper(address who) external view returns (bool);
}

interface IPriceOracle {
    // return price scaled by 1e18 (tokenOut per tokenIn)
    function getPrice(address tokenIn, address tokenOut, uint32 windowSeconds) external view returns (uint256);
}

contract StealthTWAPTrap is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IRouter public immutable router;
    IKeeperRegistry public immutable registry;
    IPriceOracle public priceOracle;

    uint256 public orderCounter;

    struct Deposit {
        address user;
        address tokenIn;
        uint256 amountIn;
        bool used;
    }

    struct Order {
        address user;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
        uint256 targetPrice;      // tokenOut per tokenIn scaled by 1e18
        uint32 twapWindowSec;     // TWAP window to fetch from oracle
        uint64 expiry;
        uint256 keeperReward;     // paid in tokenOut
        bool executed;
    }

    // commitment => deposit
    mapping(bytes32 => Deposit) public deposits;
    // orderId => order
    mapping(uint256 => Order) public orders;

    event Deposited(bytes32 indexed commitment, address indexed user, address tokenIn, uint256 amountIn);
    event Revealed(uint256 indexed orderId, bytes32 indexed commitment, address indexed user);
    event Executed(uint256 indexed orderId, address indexed keeper, uint256 amountOut);

    constructor(address _router, address _registry, address _priceOracle) {
        require(_router != address(0) && _registry != address(0), "zero address");
        router = IRouter(_router);
        registry = IKeeperRegistry(_registry);
        priceOracle = IPriceOracle(_priceOracle);
    }

    // owner helper: change oracle (useful on testnet)
    function setPriceOracle(address _oracle) external onlyOwner {
        priceOracle = IPriceOracle(_oracle);
    }

    /**
     * @notice Deposit token with commitment (commitment is off-chain keccak256 preimage)
     * @param commitment bytes32 commitment hash
     * @param tokenIn token to deposit
     * @param amountIn amount to deposit
     */
    function depositWithCommitment(bytes32 commitment, address tokenIn, uint256 amountIn) external nonReentrant {
        require(amountIn > 0, "zero amount");
        require(deposits[commitment].user == address(0), "commit exists");
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        deposits[commitment] = Deposit({user: msg.sender, tokenIn: tokenIn, amountIn: amountIn, used: false});
        emit Deposited(commitment, msg.sender, tokenIn, amountIn);
    }

    /**
     * @notice Reveal preimage and create an order (consumes the deposit)
     * preimage must be: keccak256(abi.encodePacked(user, salt, tokenIn, tokenOut, amountIn, minAmountOut, targetPrice, twapWindowSec, expiry))
     */
    function revealAndCreateOrder(
        bytes32 salt,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 targetPrice,
        uint32 twapWindowSec,
        uint64 expiry,
        uint256 keeperReward
    ) external nonReentrant returns (uint256 orderId) {
        bytes32 commitment = keccak256(abi.encodePacked(msg.sender, salt, tokenIn, tokenOut, amountIn, minAmountOut, targetPrice, twapWindowSec, expiry));
        Deposit storage dep = deposits[commitment];
        require(dep.user == msg.sender, "no deposit");
        require(!dep.used, "already used");
        require(dep.amountIn == amountIn, "amount mismatch");

        dep.used = true;

        orderId = ++orderCounter;
        orders[orderId] = Order({
            user: msg.sender,
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            amountIn: amountIn,
            minAmountOut: minAmountOut,
            targetPrice: targetPrice,
            twapWindowSec: twapWindowSec,
            expiry: expiry,
            keeperReward: keeperReward,
            executed: false
        });

        emit Revealed(orderId, commitment, msg.sender);
    }

    /**
     * @notice Keeper executes the order when price condition met
     * Only a registered keeper (registry.isKeeper) can call.
     */
    function executeOrder(uint256 orderId, address[] calldata path, uint256 deadline) external nonReentrant {
        require(registry.isKeeper(msg.sender), "not keeper");
        Order storage ord = orders[orderId];
        require(!ord.executed, "already done");
        require(block.timestamp <= ord.expiry, "expired");
        require(path.length >= 2, "bad path");
        require(path[0] == ord.tokenIn && path[path.length - 1] == ord.tokenOut, "path mismatch");

        // price check via oracle (scaled 1e18)
        uint256 price = priceOracle.getPrice(ord.tokenIn, ord.tokenOut, ord.twapWindowSec);
        require(price >= ord.targetPrice, "price not reached");

        // Approve router using the contract-held tokens (deposit was transferred earlier)
        IERC20(ord.tokenIn).safeApprove(address(router), ord.amountIn);

        uint[] memory amounts = router.swapExactTokensForTokens(ord.amountIn, ord.minAmountOut, path, address(this), deadline);

        ord.executed = true;

        uint256 finalOut = amounts[amounts.length - 1];

        // pay keeper reward in tokenOut (if set)
        if (ord.keeperReward > 0) {
            require(finalOut >= ord.keeperReward, "insufficient output for reward");
            IERC20(ord.tokenOut).safeTransfer(msg.sender, ord.keeperReward);
            finalOut -= ord.keeperReward;
        }

        // send remaining tokens to user
        IERC20(ord.tokenOut).safeTransfer(ord.user, finalOut);

        emit Executed(orderId, msg.sender, amounts[amounts.length - 1]);
    }

    /**
     * @notice Refund deposit before reveal
     */
    function refundDeposit(bytes32 commitment) external nonReentrant {
        Deposit storage dep = deposits[commitment];
        require(dep.user == msg.sender, "not owner");
        require(!dep.used, "used");
        dep.used = true;
        IERC20(dep.tokenIn).safeTransfer(msg.sender, dep.amountIn);
    }
}
