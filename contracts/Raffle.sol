//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error Raffle__SendMoreToEnter();
error Raffle__RaffleNotOpen();
error Raffle__UpkeepNotTrue();

contract Raffle{
    
    enum RaffleState{
        Open,
        Calculating
    }

    RaffleState public s_raffleState;
    uint256 public immutable i_entranceFee;
    uint256 public immutable i_interval;    
    //an array of all players
    address payable[] s_players;
    uint256 public s_lastTimestamp;

    event RaffleEnter(address indexed player);

    constructor(uint256 entranceFee, uint256 interval){
        i_entranceFee = entranceFee;
        i_interval = interval;
    }
    function enterRaffle() external payable{
        //ensure payment to enter raffle is equal to raffle amount
        if(msg.value < i_entranceFee){
            revert Raffle__SendMoreToEnter();
        }
        //if raffle isnt open revert 
        if(s_raffleState != RaffleState.Open){
            revert Raffle__RaffleNotOpen();
        }
        //for all players that entered the raffle
        s_players.push(payable(msg.sender));     

        emit RaffleEnter(msg.sender);   
    }

    //a function that checks whether its time for finding winners
    function checkUpkeep(bytes memory /*checkData */) 
        public view returns(
            bool upkeepNeeded,
            bytes memory /* performData */
        )
        {
            bool isOpen = RaffleState.Open == s_raffleState;
            bool timePassed = (block.timestamp - s_lastTimestamp) > i_interval;
            bool hasBalance = address(this).balance > 0;
            bool hasPlayers = s_players.length > 0 ;

            upkeepNeeded = (timePassed && isOpen && hasBalance && hasPlayers);
            return(upkeepNeeded, "0x0");
        }

    // a function that performs the process of finding winners
    function performUpkeep(bytes calldata /* performData */ ) external {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if(!upkeepNeeded){
            revert Raffle__UpkeepNotTrue();
        }
        s_raffleState = RaffleState.Calculating;
    }
    
}