pragma solidity >=0.8.0 <0.9.0;


contract Lottery {
    address public owner;
    uint[] private winningNumber;
    mapping (address => uint[]) private playersTickets; 
    uint private price = 5 ether;
    uint private totalLotteryPrice;
    uint public ticketsBought = 0; 
    address [] public playersAddresses;
    address payable playeraddress;
    bool public lotteryStarted = false;

    
    constructor() public {
        owner = msg.sender;
    }


   modifier onlyOwner {
    require(msg.sender == owner, "Only the owner can perform this action");
    _;
}


    function changeTicketPrice(uint _price) public onlyOwner {
    price = _price * 1 ether;
}

    function getTicketPrice() public view returns (uint) {
    return price / 1 ether;
    }

    function getTotalLotteryPrice() public view returns (uint) {
    return totalLotteryPrice / 1 ether;
    }

    function setWinningNumbers() public onlyOwner {
    lotteryStarted = true;
    winningNumber = new uint[](6);
    uint counter = 0;
    for (uint i = 0; i < 6; i++) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, i))) % 10;
        if (randomNumber != 0) {
            winningNumber[counter] = randomNumber; 
            counter++;
        }
    }
}

    function getWinningNumber() public view onlyOwner returns (uint[] memory) {
        return winningNumber;
}



    function buyTicket(uint[] memory ticketNumbers) public payable {
    require(msg.value == price, "Wrong amount");
    require(ticketNumbers.length == 6, "Wrong number of numbers");
    for (uint i = 0; i < ticketNumbers.length; i++) {
        require(ticketNumbers[i] < 10 && ticketNumbers[i] >= 0, "Wrong number");
    }
    require(playersTickets[msg.sender].length == 0, "You have already bought a ticket");
    playersTickets[msg.sender] = ticketNumbers;
    // Use the push() function provided by the Solidity library
    playersAddresses.push(msg.sender);
    totalLotteryPrice += msg.value;
    ticketsBought += 1;
    }


    function getMyTicketNumbers() public view returns (uint[] memory) {
    return playersTickets[msg.sender];
}

function calculateWinner() public onlyOwner{
    require(lotteryStarted == true, "No lottery is running");
    require(ticketsBought > 0, "No ticket was bou");
    uint firstMatchedNumbers = 0;
    uint percentage = 0;
    uint winnings = 0;
    uint totalwinnings = 0;

    for (uint i = 0; i < playersAddresses.length; i++) {   
        for (uint j = 0; j < winningNumber.length; j++) {
            if (playersTickets[playersAddresses[i]][j] == winningNumber[j]) {
                firstMatchedNumbers++;
            } else {
                break;
            }
        }


        delete playersTickets[playersAddresses[i]];

        if (firstMatchedNumbers == 1) {
            percentage = 2;
        } else if (firstMatchedNumbers == 2) {
            percentage = 3;
        } else if (firstMatchedNumbers == 3) {
            percentage = 5;
        } else if (firstMatchedNumbers == 4) {
            percentage = 10;
        } else if (firstMatchedNumbers == 5) {
            percentage = 20;
        } else if (firstMatchedNumbers == 6) {
            percentage = 40;
        }

        winnings = (totalLotteryPrice * percentage) / 100;
        totalwinnings += winnings;
        playeraddress = payable(playersAddresses[i]);
        playeraddress.transfer(winnings);
        firstMatchedNumbers = 0;
        percentage = 0;
        winnings = 0;
    }


    ticketsBought = 0;
    totalLotteryPrice -= totalwinnings;
    playersAddresses = new address[](0);
    playeraddress = payable(address(0));
    lotteryStarted = false;



}

}


