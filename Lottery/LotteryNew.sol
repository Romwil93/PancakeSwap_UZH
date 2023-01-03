pragma solidity >=0.8.0 <0.9.0;


contract Lottery {
    address public owner;
    uint[] private winningNumber;
    mapping (address => uint[]) private players; 
    uint private price = 5 ether;
    uint private totalLotteryPrice;
    
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
    require(players[msg.sender].length == 0, "You have already bought a ticket");
    players[msg.sender] = ticketNumbers;
    totalLotteryPrice += msg.value;

}

    function getMyTicketNumbers() public view returns (uint[] memory) {
    return players[msg.sender];
}
 }