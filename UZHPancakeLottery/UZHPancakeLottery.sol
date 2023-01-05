// Author: Roman Willi
// UZHPancakeLottery is a contract that allows users to buy tickets and compete in a lottery. 
// The contract was created independently from scratch according to the instructions of Pancakeswap
pragma solidity >=0.8.0 <0.9.0;

contract UZHPancakeLottery {
    // address of the owner of the contract
    address public owner;
    // array containing the winning numbers
    uint[] private winningNumber;
    // mapping containing each player's ticket numbers
    mapping (address => uint[]) private playersTickets; 
    // ticket ticketprice in ether
    uint private ticketprice = 5 ether;
    // total amount of ether spent on tickets
    uint private TotalLotteryPot;
    // total number of tickets bought
    uint public NrticketsBought = 0; 
    // array containing the addresses of the players
    address [] public playersAddresses;
    // bool indicating whether the lottery has started
    bool public lotteryStarted = false;

    
    // constructor setting the owner of the contract to be the sender
    constructor() public {
        owner = msg.sender;
    }


    // modifier that only allows the owner to execute the function
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }


    // function to change the ticket ticketprice
    function changeTicketPrice(uint _price) public onlyOwner {
        // requirement that the lottery has not started
        require(lotteryStarted == false, "A lottery is running");
        ticketprice = _price * 1 ether;
    }

    // view function to get the ticket ticketprice 
    function getTicketPrice() public view returns (uint) {
        // requirement that the lottery has started
        require(lotteryStarted == true, "No lottery is running");
        return ticketprice / 1 ether;
    }

    // view function to get the total amount of ether spent on tickets
    function getTotalLotteryPot() public view returns (uint) {
        // requirement that the lottery has started
        require(lotteryStarted == true, "No lottery is running");
        return TotalLotteryPot / 1 ether;
    }

    // function to set the winning numbers randomly
    function BeginLottery() public onlyOwner {
        // requirement that the lottery has not started
        require(lotteryStarted == false, "A lottery is running");
        lotteryStarted = true;
        winningNumber = new uint[](6);
        uint counter = 0;
        // loop that assigns a random number to each index of the array
        for (uint i = 0; i < 6; i++) {
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, i))) % 10;
            if (randomNumber != 0) {
                winningNumber[counter] = randomNumber; 
                counter++;
            }
        }
    }

    //Just for testing purposes to set a specific winning number.
    function setWinningNumber(uint[] memory _winningNumber) public onlyOwner {
        require(_winningNumber.length == 6);
        for(uint i = 0; i < _winningNumber.length; i++) {
            require(_winningNumber[i] <= 9);
        }
        winningNumber = _winningNumber;
    }

    // view function to get the winning numbers
    //  just for testing purposes public
    function getWinningNumber() public view onlyOwner returns (uint[] memory) {
        // requirement that the lottery has started
        require(lotteryStarted == true, "No lottery is running");
        return winningNumber;
    }

    // function to buy a ticket
    function buyTicket(uint[] memory ticketNumbers) public payable {
        // requirement that the lottery has started
        require(lotteryStarted == true, "No lottery is running");
        // requirement that the amount sent is equal to the ticketprice of the ticket
        require(msg.value == ticketprice, "Wrong amount");
        // requirement that the ticket contains 6 numbers
        require(ticketNumbers.length == 6, "Wrong number of numbers");
        // loop to check that all the numbers are between 0 and 10
        for (uint i = 0; i < ticketNumbers.length; i++) {
            require(ticketNumbers[i] < 10 && ticketNumbers[i] >= 0, "Wrong number");
        }
        // requirement that the player has not already bought a ticket
        require(playersTickets[msg.sender].length == 0, "You have already bought a ticket");
        // assigning the ticket numbers to the player's address
        playersTickets[msg.sender] = ticketNumbers;
        // adding the player's address to the playersAddresses array
        playersAddresses.push(msg.sender);
        // adding the amount sent to the TotalLotteryPot
        TotalLotteryPot += msg.value;
        // incrementing the NrticketsBought
        NrticketsBought += 1;
    }

    // view function to get the ticket numbers of a player
    function getMyTicketNumbers() public view returns (uint[] memory) {
        return playersTickets[msg.sender];
    }

    // function to calculate the winner
    function EndLottery() public onlyOwner{
        // requirement that the lottery has started
        require(lotteryStarted == true, "No lottery is running");
        // requirement that at least one ticket has been bought
        require(NrticketsBought > 0, "No ticket was bou");
        // variable indicating the number of matching numbers
        uint firstMatchedNumbers = 0;
        // variable indicating the percentage of the TotalLotteryPot that the winner will get
        uint percentage = 0;
        // variable indicating the reward of a player
        uint reward = 0;
        // variable indicating the total reward
        uint totalreward = 0;
        // address of a player
        address payable playeraddress;

        // loop to check the ticket of each player
        for (uint i = 0; i < playersAddresses.length; i++) {   
            // loop to check each number in the winningNumber array
            for (uint j = 0; j < winningNumber.length; j++) {
                // checking if the ticket number at index j is equal to the winningNumber at index j
                if (playersTickets[playersAddresses[i]][j] == winningNumber[j]) {
                    firstMatchedNumbers++;
                } else {
                    break;
                }
            }

            // deleting the ticket numbers of the player
            delete playersTickets[playersAddresses[i]];

            // assigning a percentage depending on the number of matching numbers
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

            // calculating the reward
            reward = (TotalLotteryPot * percentage) / 100;
            // adding the reward to the total reward
            totalreward += reward;
            // setting the player's address to a payable address
            playeraddress = payable(playersAddresses[i]);
            // transferring the reward to the player
            playeraddress.transfer(reward);
            // resetting the variables
            firstMatchedNumbers = 0;
            percentage = 0;
            reward = 0;
        }

        // resetting all the variables
        NrticketsBought = 0;
        TotalLotteryPot -= totalreward;
        playersAddresses = new address[](0);
        playeraddress = payable(address(0));
        lotteryStarted = false;
    }

    // function to pull out the TotalLotteryPot, only for testing
    function Pull() public onlyOwner {
        // requirement that the lottery has not started
        require(lotteryStarted == false, "A lottery is running");
        // converting the owner address to a payable address
        address payable ownerpayable = payable(owner);
        // requirement that the TotalLotteryPot is greater than 0
        require(TotalLotteryPot > 0, "No Ether to pull out");
        // transferring the TotalLotteryPot to the owner
        ownerpayable.transfer(TotalLotteryPot);
        // resetting the TotalLotteryPot to 0
        TotalLotteryPot = 0;
    }

}