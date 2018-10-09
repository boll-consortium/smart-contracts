pragma solidity ^0.4.17;

contract Registrar {

    struct Participant {
        address ethAddress;
        bytes otherId;
        bool isLearningProvider;
        address indexContract;
        uint8 status; // 0 = rejected 1 = approved 2 = pending 3 = unregistered
    }
    
    address owner;
    mapping(address => Participant) public registeredParticipants;
    
    function Registrar() {
        owner = msg.sender;
    }

    function getOtherId(address participantAddress) public constant returns(bytes) {
        return registeredParticipants[participantAddress].otherId; 
    }
    
    function getIndexContract(address participantAddress) public constant returns (address) {
        return registeredParticipants[participantAddress].indexContract;
    }
    
    function getStatus(address participantAddress) public constant returns (uint8) {
        return registeredParticipants[participantAddress].status;
    }
    
    function checkIsLearningProvider(address participantAddress) public constant returns (bool) {
        return registeredParticipants[participantAddress].isLearningProvider;
    }
    
    function unregistered(address participantAddress) public payable returns (bool) {
        if (msg.sender==owner) {
            registeredParticipants[participantAddress].status = 3;
            return true;
        }else {
            return false;
        }
    }
    
    function register(address participantAddress, bytes otherId, bool isLearningProvider, address indexContract) public payable returns (bool) {
        Participant memory participant = registeredParticipants[participantAddress];
        // Needs rewrite because only the creator can register learners
       if (msg.sender == owner ) {
           if (participant.ethAddress == 0) {
                participant.ethAddress = participantAddress;
                participant.otherId = otherId;
                participant.isLearningProvider = isLearningProvider;
                participant.indexContract = indexContract;
                participant.status = 2;
            } else {
                //already registered;
                participant.otherId = otherId;
                participant.isLearningProvider = isLearningProvider;
                participant.status = msg.sender==owner?1:2;
                participant.indexContract = indexContract;
            }
            registeredParticipants[participantAddress] = participant;
            return true;
       }
       return false;
    }
    
    function assignIndexContract(address participantAddress, address indexContract) public payable returns (bool) {
        if (msg.sender == owner) {
            registeredParticipants[participantAddress].indexContract = indexContract;
            return true;
        }else {
            return false;
        }
    }
}
