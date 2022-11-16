//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error Raffle__SendMoreToEnter();
error Raffle__RaffleNotOpen();

contract Raffle{
    
    enum RaffleState{
        Open,
        Calculating
    }

    RaffleState public s_raffleState;
    uint256 public immutable i_entranceFee;
    //an array of all players
    address payable[] s_players;

    event RaffleEnter(address indexed player);

    constructor(uint256 entranceFee){
        i_entranceFee = entranceFee;
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
}