// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
    function swap(uint _amount1, uint _amount2) public{

        require(msg.sender == owner1 || msg.sender == owner2, "not authorized");
        require(token1.allowance(owner1, address(this)) >= _amount1, 
        "Token 1 allowance too low");
        require(token2.allowance(owner2, address(this)) >= _amount2, 
        "Token 2 allowance too low");

        // transfer tokens 
        // token1, owner1, amount1 - > owner2
        _safeTransferFrom(token1, owner1, owner2, _amount1);
        // token2, owner2, amount2 - > owner
        _safeTransferFrom(token2, owner2, owner1, _amount2);
    }

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


// Person 1: 
// 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// Token 1: 0xd9145CCE52D386f254917e481eB44e9943F39138 
// 10000000000000000000


// Person 2: 
// 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// Token 2: 0x652c9ACcC53e765e1d96e2455E618dAaB79bA595
// 20000000000000000000

//TokenSwap 
// 0xB302F922B24420f3A3048ddDC4E2761CE37Ea098


