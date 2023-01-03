pragma solidity ^0.6.12;

pragma experimental ABIEncoderV2;

contract PancakeLottery {
    address public owner; 
    uint256 public ticketPrice; 
    mapping (address => uint256[][]) public tickets; 
    uint256[] public winningNumbers; 
    mapping (uint256 => uint256[]) public prizePools;
    uint256 public totalPrizePool; 
    uint256 public burnPool; 
    uint256 public burnAmount; 
    
    constructor() public {
        owner = msg.sender; 
        ticketPrice = 5 * 1000000000000000000; 
        burnPool = 20 * 1000000000000000000; 
    }
    
    // Buy a ticket
    // This function allows a user to purchase a ticket with the ticket price declared in the constructor
    // The ticket is then stored in the tickets mapping
    function buyTicket(uint256[] memory ticket) public payable {
        require(msg.value == ticketPrice, "You need to pay the correct ticket price");
        require(ticket.length == 6, "Ticket must have 6 digits"); 
        //require(tickets[msg.sender].length == 0, "You can only buy one ticket"); 
        tickets[msg.sender].push(ticket); 
    }

    //returns the amount of tickets the user bought
    function getTicketsBoughtCount() public view returns(uint count){
    return tickets[msg.sender].length;
}


    // View tickets
    // This function allows a user to view all the tickets they have purchased
    function viewTickets(uint256 ticketnr) public view returns(uint256[] memory) {
        return tickets[msg.sender][ticketnr];
    }

    
    // Start a new round
    // This function allows the owner to start a new round of the lottery
    // The total prize pool and burn amount is reset to 0
    function startRound() public {
        require(msg.sender == owner, "Only the owner can start a round"); 
        totalPrizePool = 0; 
        burnAmount = 0; 
        for (uint256 i = 0; i < 6; i++) {
            uint256[] memory pool = new uint256[](2); 
            pool[0] = 0; 
            pool[1] = 0; 
            prizePools[i] = pool; 
        }
    }


    
    // Set the winning numbers
    // This function allows the owner to set the winning numbers for the lottery
    // 6 numbers must be provided
    function setWinningNumbers(uint256[] memory numbers) public {
        require(msg.sender == owner, "Only the owner can set the winning numbers"); 
        require(numbers.length == 6, "Must provide 6 numbers"); 
        winningNumbers = numbers; 
    }
    

    //This function is used to generate 6 random numbers and store them in the winningNumbers array. The random numbers 
    //are generated using the block timestamp and a loop index. 
    function setWinningNumbers() public {
        require(msg.sender == owner, "Only the owner can set the winning numbers"); 
        for (uint i = 0; i < 6; i++) {
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, i))) % 10;
            winningNumbers.push(randomNumber); 
        }
    }


    //This function returns the winning numbers stored in the contract as an array.
    function getWinningNumbers() public view returns (uint256[6] memory) {
        uint256[6] memory winningNumbersCopy;
        for (uint i = 0; i < 6; i++) {
            winningNumbersCopy[i] = winningNumbers[i];
        }
        return winningNumbersCopy;
    }

  


    // Calculate the prizes
    // This function allows the owner to calculate the prizes for the current round
    // It goes through the tickets and checks each one to determine if it is a winning ticket
    // The associated prize is then added to the prize pool for that prize tier
    function calculatePrizes() public {
        totalPrizePool = 0;
        burnAmount = 0;
        require(msg.sender == owner, "Only the owner can calculate prizes"); 
        for (uint256 i = 0; i < tickets[msg.sender].length; i++) {
            uint256[] memory ticket = tickets[msg.sender][i]; 
            uint256 counter = 0; 
            for (uint256 j = 0; j < 6; j++) {
                if (ticket[j] == winningNumbers[j]) {
                    counter++; 
                }
            }
            if (counter == 1) {
                prizePools[0][0] = 0;
                prizePools[0][0] += 2 * 1000000000000000000 ; 
            } else if (counter == 2) {
                prizePools[1][0] = 0;
                prizePools[1][0] += 3 * 1000000000000000000; 
            } else if (counter == 3) {
                prizePools[2][0] = 0;
                prizePools[2][0] += 5 * 1000000000000000000; 
            } else if (counter == 4) {
                prizePools[3][0] = 0; 
                prizePools[3][0] += 10 * 1000000000000000000; 
            } else if (counter == 5) {
                prizePools[4][0] = 0;
                prizePools[4][0] += 20 * 1000000000000000000; 
            } else if (counter == 6) {
                prizePools[5][0] = 0;
                prizePools[5][0] += 40 * 1000000000000000000; 
            }
        }

        for (uint256 i = 0; i < 6; i++) {
            totalPrizePool += prizePools[i][0]; 
            burnAmount += prizePools[i][1]; 
        }
    }
    
    // Claim prizes
    // This function allows a user to claim their prize if they have a winning ticket
    // The amount they are entitled to is transferred to their wallet
    function claimPrizes(uint256 ticketnumber) public {
        require(tickets[msg.sender].length > 0, "You don't have any tickets at all"); 
        require(tickets[msg.sender][ticketnumber].length > 0, "No ticket with that number"); 
        uint256 counter = 0; 
        for (uint256 j = 0; j < 6; j++) {
            if (tickets[msg.sender][ticketnumber][j] == winningNumbers[j]) {
                counter++; 
            }
        }
        if (counter == 1) {
            prizePools[0][1] += 2 * 1000000000000000000; 
        } else if (counter == 2) {
            prizePools[1][1] += 3 * 1000000000000000000; 
        } else if (counter == 3) {
            prizePools[2][1] += 5  * 1000000000000000000; 
        } else if (counter == 4) {
            prizePools[3][1] += 10 * 1000000000000000000; 
        } else if (counter == 5) {
            prizePools[4][1] += 20 * 1000000000000000000; 
        } else if (counter == 6) {
            prizePools[5][1] += 40 * 1000000000000000000; 
        }
        uint256 prize = prizePools[counter-1][1]; 
        msg.sender.transfer(prize); 
        delete tickets[msg.sender][ticketnumber];
    }
    
    // End the round and distribute the prize pool
    // This function allows the owner to end the round and distribute the prize pool
    // The prize pool is split between the winners and the burn pool
    function endRound() public {
        require(msg.sender == owner, "Only the owner can end the round"); 
        uint256 total = totalPrizePool + burnAmount; 
        for (uint256 i = 0; i < 6; i++) {
            uint256 amount = prizePools[i][1] * (totalPrizePool / total); 
            prizePools[i][1] = 0; 
            prizePools[i][0] += amount; 
        }
        burnAmount = burnPool * (totalPrizePool / total); 
    }
    
    // Distribute prizes
    // This function allows the owner to distribute prizes to the winners of the lottery
    // The burn amount is reset to 0
    function distributePrizes() public {
        require(msg.sender == owner, "Only the owner can distribute prizes"); 
        for (uint256 i = 0; i < 6; i++) {
            uint256 total = prizePools[i][0] + prizePools[i][1]; 
            msg.sender.transfer(total); 
        }
        burnAmount = 0; 
    }
}