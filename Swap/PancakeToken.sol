// SPDX-License-Identifier: MIT
// References: https://www.youtube.com/watch?v=jP1A1odqXFM 

pragma solidity ^0.8.0; 

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// contract to make a new token. Here we call our contract pancake token. but can be used for different tokens. 

// takes a string with a name and a string for a symbol as input 

contract PancakeToken is ERC20 {
    constructor (string memory name, string memory symbol)
        ERC20(name, symbol)
        public 
    {
        _mint(msg.sender, 100 * 10 ** uint(decimals()));

    }
}
