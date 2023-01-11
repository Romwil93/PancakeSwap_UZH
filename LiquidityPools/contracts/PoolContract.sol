pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/utils/math/Math.sol";

/* LiquidityPool contract can be found below LiquidityToken contract on which it is based */

contract LiquidityToken is IERC20 {
    using SafeMath for uint;

    string private constant _name = "UZH Liquidty Pool";
    string private constant _symbol = "UZH-LP";
    uint8 private constant decimals = 18;
    uint override public totalSupply;
    mapping(address => uint) override public balanceOf;
    mapping(address => mapping(address => uint)) override public allowance;


    constructor() {}


    // Internal functions
    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }
    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }
    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }
    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    // External functions
    function transfer(address to, uint value) override external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(address from, address to, uint value) override external returns (bool) 
    {
        if (allowance[from][msg.sender] != type(uint).max) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        }
        _transfer(from, to, value);
        return true;
    }
    function approve(address spender, uint value) override external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
}


contract LiquidityPool is LiquidityToken {
    using SafeMath for uint;
    address public admin;

    address public immutable factory;
    address public router;
    address public immutable token0;
    address public immutable token1;

    uint private _reserve0;
    uint private _reserve1;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Exchange(address indexed sender, uint amount0In, uint amount1In, uint amount0Out, uint amount1Out, address indexed to);
    

    constructor(address _admin, address _factory, address _router, address _token0, address _token1) {
        admin = _admin;
        factory = _factory;
        router = _router;
        token0 = _token0;
        token1 = _token1;
    }

    // Mint liquidity for tokens
    function mint(address to) external returns (uint liquidity) {
        // Only specified router contract can mint liquidity
        require(msg.sender == router, "POOL: Access denied");
        // Get recieved amounts from difference between reserves and balances
        (uint balance0, uint balance1) = getBalances();
        (uint reserve0, uint reserve1) = getReserves();
        uint amount0 = balance0.sub(reserve0);
        uint amount1 = balance1.sub(reserve1);
        // Determin corresponding liquidity to be payed out
        if (totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1));
        } else {
            liquidity = Math.min(amount0.mul(totalSupply) / reserve0, amount1.mul(totalSupply) / reserve1);
        }
        require(liquidity > 0, "POOL: Insufficient liquidity minted");
        // Mint liquidity tokens
        _mint(to, liquidity);
        // Update reserves and emit 'Mint' event  
        _update(balance0, balance1);
        emit Mint(msg.sender, amount0, amount1);
    }

    // Burn liquidity for tokens 
    function burn(address to) external returns (uint amount0, uint amount1) {
        // Only specified router contract can burn liquidity
        require(msg.sender == router, "POOL: Access denied");
        // Get recieved liquidity 
        (uint balance0, uint balance1) = getBalances();
        (uint reserve0, uint reserve1) = getReserves();
        uint liquidity = balanceOf[address(this)];
        // determine corresponding amounts to be payed out
        amount0 = liquidity.mul(balance0) / totalSupply;
        amount1 = liquidity.mul(balance1) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "POOL: Insufficient liquidity burned");
        // Burn liquidity tokens and transfer amounts
        _burn(address(this), liquidity);
        IERC20(token0).transfer(to, amount0);
        IERC20(token1).transfer(to, amount1);
        // Update reserves and emit 'Burn' event
        (balance0, balance1) = getBalances();
        _update(balance0, balance1);
        emit Burn(msg.sender, amount0, amount1, to);
    }  

    // Exchange tokens using liquidity
    function exchange(address tokenIn, address tokenOut, uint amountIn, uint amountOut, address to) external {
        // Only specified router contract can burn liquidity
        require(msg.sender == router, "POOL: Access denied");
        // Check output amount
        (uint reserve0, uint reserve1) = getReserves();
        (uint amount0Out, uint amount1Out) = token0 == tokenOut ? (amountOut, uint(0)) : (uint(0), amountOut);
        require(amount0Out > 0 || amount1Out > 0, "ERROR: Insufficent output amount");
        // Check input amount
        (uint balance0, uint balance1) = getBalances();
        uint amount0In = balance0 > reserve0.sub(amount0Out) ? balance0.sub(reserve0.sub(amount0Out)) : 0;
        uint amount1In = balance1 > reserve1.sub(amount1Out) ? balance1.sub(reserve1.sub(amount1Out)) : 0;
        require(amount0In > 0 || amount1In > 0, "ERROR: insufficient input amount");
        // Send output token
        if (amount0Out > 0) IERC20(token0).transfer(to, amount0Out);
        if (amount1Out > 0) IERC20(token1).transfer(to, amount1Out);
        // update reserves and emit 'Exchange' event
        _update(balance0, balance1);
        emit Exchange(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // Helper functions
    function getReserves() public view returns (uint reserve0, uint reserve1) {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function getBalances() public view returns (uint balance0, uint balance1) {
        balance0 = IERC20(token0).balanceOf(address(this));
        balance1 = IERC20(token1).balanceOf(address(this));
    }

    function _update(uint balance0, uint balance1) private {
        require(balance0 <= type(uint).max && balance1 <= type(uint).max, "POOL: Overflow");
        _reserve0 = balance0;
        _reserve1 = balance1;
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