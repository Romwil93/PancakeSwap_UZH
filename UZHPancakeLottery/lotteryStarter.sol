// Author: Roman Willi
// The purpose of this contract was to get an idea about how a general lottery works in solidity

pragma solidity >=0.8.0 <0.9.0;

// Defines and initializes contract state variables 
contract Lottery {
    address public owner;            // Declares owner state variable of type address
    address payable[] private players; // Declares players state variable of type address payable array
    uint public pot;                 // Declares pot state variable of type uint
    uint public numPlayers;          // Declares numPlayers state variable of type uint

    // Constructor function to set owner state variable to the sender of the contract's deployment message
    constructor() public {
        owner = msg.sender;
    }

    // Function to allow users to enter the lottery
    function enter() public payable {
        require(msg.value > 0.01 ether, "Your ticket must be at least 0.01 ether"); // Checks if the value sent with the transaction is greater than 0.01 ether
        players.push(payable(msg.sender)); // Adds the sender's address to the players array
        numPlayers++; // Increments the numPlayers state variable
        pot += msg.value; // Adds the value sent with the transaction to the pot state variable
    }

    // Function to generate a random index within the bounds of the players array
    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players))) % players.length; // Generates a random index by hashing the difficulty, timestamp, and players array
    }

    // Function to pick a winner of the lottery
    function pickWinner() public {
        require(msg.sender == owner, "Only the owner can pick a winner"); // Checks if the sender of the function call is the owner
        require(numPlayers > 0, "There must be at least one player to pick a winner"); // Checks if there are any players in the lottery
        uint index = random(); // Generates a random index within the bounds of the players array
        address payable winner = players[index]; // Sets the winner to the address at the index generated
        uint winAmount = pot; // Sets the winAmount to the current value of the pot
        players = new address payable[](0); // Empty the players array
        pot = 0; // Reset the pot to 0
        numPlayers = 0; // Reset the numPlayers to 0
        winner.transfer(winAmount); // Transfers the winAmount to the winner's address
    }

}