pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

import "./FactoryContract.sol";
import "./PoolContract.sol";

contract Router {
    using SafeMath for uint;
    address public admin;

    address public factory;


    constructor(address _admin) {
        admin = _admin;
    }

    /* CORE FUNCTIONS */
    // Add liquidity to corresponding pool or create new one
    function addLiquidity(address tokenA, address tokenB, uint amountADesired, uint amountBDesired) external {
        require(factory != address(0), "ROUTER: No factory set");
        // Check if pool exists and get address
        address pool = PoolFactory(factory).getPool(tokenA, tokenB);
        if (pool == address(0)) {
            pool = PoolFactory(factory).createPool(tokenA, tokenB);
        }
        // Determin optimal token amounts based on reserves
        (uint amountA, uint amountB) = (0, 0);
        (uint reserveA, uint reserveB) = getReserves(pool, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            (uint amountBOptimal, ) = getQuote(tokenA, tokenB, amountADesired);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= 0, "ROUTER: Insufficent amount of token B");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                (uint amountAOptimal, ) = getQuote(tokenB, tokenA, amountBDesired);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= 0, "ROUTER: Insufficent amount of token A");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
        // Send tokens and request liquidity (amounts need to be approved by token owner first)
        bool sentA = IERC20(tokenA).transferFrom(msg.sender, pool, amountA);
        require(sentA, "ROUTER: Transaction failed");
        bool sentB = IERC20(tokenB).transferFrom(msg.sender, pool, amountB);
        require(sentB, "ROUTER: Transaction failed");
        uint liquidity = LiquidityPool(pool).mint(msg.sender);
    }

    // Withdraw liquidity from corresponding pool
    function withdrawLiquidity(address tokenA, address tokenB, uint liquidity) external {
        require(factory != address(0), "ROUTER: No factory set");
        // Get pool address
        address pool = PoolFactory(factory).getPool(tokenA, tokenB);
        // Send liquidity to pool and request tokens (amount needs to be approved by liquidity owner first)
        bool sent = LiquidityPool(pool).transferFrom(msg.sender, pool, liquidity);
        require(sent, "ROUTER: Transaction failed");
        (uint amount0, uint amount1) = LiquidityPool(pool).burn(msg.sender);
    }

    // Exchange tokens using liquidity in corresponding pool    
    function exchangeTokens(address tokenIn, address tokenOut, uint amountIn, uint amountOutMin) external {
        require(factory != address(0), "ROUTER: No factory set");
        // get quote
        (uint amountOut, address pool) = getQuote(tokenIn, tokenOut, amountIn);
        require(amountOut >= amountOutMin, "ROUTER: Insufficent liquidity");
        // Send token to pool and initiate exchange
        bool sent = IERC20(tokenIn).transferFrom(msg.sender, pool, amountIn);
        require(sent, "ROUTER: Transaction failed");
        LiquidityPool(pool).exchange(tokenIn, tokenOut, amountIn, amountOut, msg.sender);
    }

    /* ADDITIONAL FUNCTIONS */   
    function getQuote(address tokenIn, address tokenOut, uint amountIn) public view returns (uint amountOut, address pool) {
        // Check if corresponding liquidity pool is available
        pool = PoolFactory(factory).getPool(tokenIn, tokenOut);
        require(pool != address(0), "ROUTER: No liquidity pool available");
        // Get reserves and check inputs
        (uint reserveIn, uint reserveOut) = getReserves(pool, tokenIn, tokenOut);
        require(reserveIn > 0 && reserveOut > 0, "ROUTER: Insufficent liquidity");
        require(amountIn > 0, "ROUTER: Insufficent input amount");
        // calculate relative price based on available liquidity
        amountOut = amountIn.mul(reserveOut) / reserveIn;
    }

    // Helper funtions
    function getReserves(address pool, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (uint reserve0, uint reserve1) = LiquidityPool(pool).getReserves();
        (address token0, ) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }


    // Admin functions
    function setFactory(address _factory) external {
        // Only admin can change router
        require(msg.sender == admin, "FACTORY: Access denied");
        factory = _factory;
    }

    function setAdmin(address _admin) external {
        // Only admin can change admin
        require(msg.sender == admin, "FACTORY: Access denied");
        admin = _admin;
    }
}