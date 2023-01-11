pragma solidity ^0.8.0;

import "./PoolContract.sol";

contract PoolFactory {
    address public admin;
    address public router;

    mapping(address => mapping(address => address)) public getPool;
    address[] public allPools;

    event PoolCreated(address indexed token0, address indexed token1, address pool, uint);


    constructor(address _admin) {
        admin = _admin;
    }

    // Information functions
    function countPools() external view returns (uint) {
        return allPools.length;
    }

    // Function to deploy a new liquidity pool
    function createPool(address tokenA, address tokenB) external returns (address pool) {
        // Only specified router contract can add new pools
        require(msg.sender == router, "FACTORY: Access denied");
        // Token addresses checks
        require(tokenA != tokenB, "FACTORY: Identical addresses");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "FACTORY: Zero address");
        require(getPool[token0][token1] == address(0), "FACTORY: Pool exists");
        // Create new pool
        LiquidityPool newPool = new LiquidityPool(admin, address(this), msg.sender, token0, token1);
        pool = address(newPool);
        // Record token mapping (bi-directional) and pool address
        getPool[token0][token1] = pool;
        getPool[token1][token0] = pool;
        allPools.push(pool);
        // Emit 'PoolCreated' event
        emit PoolCreated(token0, token1, pool, allPools.length);
    }

    // Admin functions
    function setRouter(address _router) external {
        // Only admin can change router
        require(msg.sender == admin, "FACTORY: Access denied");
        router = _router;
    }

    function setAdmin(address _admin) external {
        // Only admin can change admin
        require(msg.sender == admin, "FACTORY: Access denied");
        admin = _admin;
    }
}