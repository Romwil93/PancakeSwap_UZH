// SPDX-License-Identifier: MIT
// References: https://www.youtube.com/watch?v=jP1A1odqXFM 

pragma solidity ^0.8.0; 

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Token Smart Contract
contract TokenSwap {
    IERC20 public token1;
    address public owner1;
    IERC20 public token2; 
    address public owner2; 

    constructor (
        address _token1,
        address _owner1,
        address _token2,
        address _owner2
    ) public {
        token1 = IERC20(_token1);
        owner1 = _owner1; 
        token2 = IERC20(_token2);
        owner2 = _owner2; 
    }
    // Swap function: takes amounts of tokens you want to swap as an input 
    function swap(uint _amount1, uint _amount2) public{

        // not logged in / no authentication = not authorized 
        require(msg.sender == owner1 || msg.sender == owner2, "not authorized");
        //  check if user 1 is allowed to swap token 1 with amount 1 
        require(token1.allowance(owner1, address(this)) >= _amount1, 
        "Token 1 allowance too low");
        
        //  check if user 2 is allowed to swap token 2 with amount 2
        require(token2.allowance(owner2, address(this)) >= _amount2, 
        "Token 2 allowance too low");

        // transfer tokens from user 1 to user 2 
        // token1, owner1, amount1 - > owner2
        _safeTransferFrom(token1, owner1, owner2, _amount1);
        // token2, owner2, amount2 - > owner
        _safeTransferFrom(token2, owner2, owner1, _amount2);
    }
    // function to transfer tokens 
    function _safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }
}


