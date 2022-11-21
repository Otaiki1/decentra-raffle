//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

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

    //using the imported interface to create a type
    VRFCoordinatorV2Interface public immutable i_vrfCoordinator;
    //chainlink variables
    bytes32 public i_gasLane;
    uint64 public i_subscriptionId;
    uint32 public i_callbackGasLimit;

    uint16 public constant REQUEST_CONFIRMATIONS = 3;
    uint32 public constant NUM_WORDS = 1;

    event RaffleEnter(address indexed player);
    event RequestedRaffleWinner(uint256 indexed requestId);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinatorV2,
        bytes32 gasLane, //keyhash 
        uint64 subscriptionId,
        uint32 callbackGasLimit
        ){
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId ;
        i_callbackGasLimit = callbackGasLimit;
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
        //getting the random number
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId, 
            REQUEST_CONFIRMATIONS, 
            i_callbackGasLimit, 
            NUM_WORDS);
        emit RequestedRaffleWinner(requestId);
    }
    
   
    
}