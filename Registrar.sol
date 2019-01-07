pragma solidity ^0.4.17;

contract Registrar {
    event RegistrarContractEvents(address indexed sender, address indexed participantAddress,
        address affectedContractAddress, string indexed actionType);
    struct Participant {
        address ethAddress;
        bool isLearningProvider;
        address indexContract;
        uint8 status; // 0 = rejected 1 = approved 2 = pending 3 = unregistered
    }

    struct SchoolsUsersRegistry {
        bool isApproved;
        bytes accessToken;
        mapping(bytes => address) schoolId2BOLLAddress;
    }
    
    address owner;
    mapping(address => Participant) private registeredParticipants;
    mapping(address => SchoolsUsersRegistry) private schoolsUsersRegistry;
    
    constructor() public {
        owner = msg.sender;
    emit RegistrarContractEvents(msg.sender, msg.sender, address(this), "RC");
    }

    function findUserAddress(bytes userId, address schoolBOLLAddress, bytes accessToken) public view returns(address) {
        if(isApprovedInstitute(accessToken)){
            if(schoolsUsersRegistry[schoolBOLLAddress].isApproved) {
                //emit RegistrarContractEvents(msg.sender, schoolBOLLAddress, address(this), "findUserAddress");
                return schoolsUsersRegistry[schoolBOLLAddress].schoolId2BOLLAddress[userId];
            }
            return 0;
        }
    }

    function findUserAddress(bytes userId, bytes accessToken) public view returns(address) {
        return findUserAddress(userId, msg.sender, accessToken);
    }

function getIndexContract(address participantAddress) public constant returns (address) {
    //emit RegistrarContractEvents(msg.sender, participantAddress, address(this), "getIndexContract");
        return registeredParticipants[participantAddress].indexContract;
    }
    
    function getStatus(address participantAddress) public constant returns (uint8) {
        //emit RegistrarContractEvents(msg.sender, participantAddress, address(this), "getStatus");
        return registeredParticipants[participantAddress].status;
    }
    
    function checkIsLearningProvider(address participantAddress) public constant returns (bool) {
        //emit RegistrarContractEvents(msg.sender, participantAddress, address(this), "checkIsLearningProvider");
        return registeredParticipants[participantAddress].isLearningProvider;
    }

    // ToDo who can deregister a user?
    function unregistered(address participantAddress, bytes accessToken) public payable returns (bool) {
        if (isApprovedInstitute(accessToken) && registeredParticipants[participantAddress].status ==1) {
            registeredParticipants[participantAddress].status = 3;
            emit RegistrarContractEvents(msg.sender, participantAddress, address(this), "unregistered");
            return true;
        }else {
            return false;
        }
    }
    // must be sent by the school ToDo change to allow schools to register other schools via consensus
    function approveInstitute(address schoolAddress, bool approved, bytes accessToken) public payable {
        if(msg.sender == owner) {
        schoolsUsersRegistry[schoolAddress] = SchoolsUsersRegistry(approved, accessToken);
            emit RegistrarContractEvents(msg.sender, schoolAddress, address(this), "approveInstitute");
        }
    }
    //
    function register(address participantAddress, bool isLearningProvider, address indexContract, bytes accessToken) public payable returns (bool) {
        if(isApprovedInstitute(accessToken)){
            Participant memory participant = registeredParticipants[participantAddress];
            // Needs rewrite because only the creator can register learners
           if ((msg.sender == participantAddress && isLearningProvider) ||
            (msg.sender != participantAddress && !isLearningProvider) ) {
               if (participant.ethAddress == 0) {
                    participant.ethAddress = participantAddress;
                    participant.isLearningProvider = isLearningProvider;
                    participant.indexContract = indexContract;
                    participant.status = 2;
                } else {
                    //already registered;
                    participant.isLearningProvider = isLearningProvider;
                    participant.status = msg.sender==owner?1:2;
                    participant.indexContract = indexContract;
                }
                registeredParticipants[participantAddress] = participant;
               emit RegistrarContractEvents(msg.sender, participantAddress, address(this), "register");
                return true;
           }
        }
       return false;
    }
    // must be sent/signed by school
    function pairUserIdWithBOLLAddress(bytes userId, address bollAddress, bytes accessToken) public payable {
        if(isApprovedInstitute(accessToken)) {
            schoolsUsersRegistry[msg.sender].schoolId2BOLLAddress[userId] = bollAddress;
            emit RegistrarContractEvents(msg.sender, bollAddress, address(this), "pairUserIdWithBOLLAddress");
        }

    }

    function assignIndexContract(address participantAddress, address indexContract, bytes accessToken) public payable returns (bool) {
        if (isApprovedInstitute(accessToken)) {
            registeredParticipants[participantAddress].indexContract = indexContract;
            emit RegistrarContractEvents(msg.sender, participantAddress, address(this), "assignIndexContract");
            return true;
        }else {
            return false;
        }
    }

    function isApprovedInstitute(bytes accessToken) public view returns(bool) {
        //emit RegistrarContractEvents(msg.sender, msg.sender, address(this), "isApprovedInstitute");
        return schoolsUsersRegistry[msg.sender].isApproved &&
          keccak256(schoolsUsersRegistry[msg.sender].accessToken) == keccak256(accessToken);
    }

    function isApprovedInstitute(bytes accessToken, address providerAddress) public view returns(bool) {
        //emit RegistrarContractEvents(msg.sender, providerAddress, address(this), "isApprovedInstitute");
        return schoolsUsersRegistry[providerAddress].isApproved &&
        keccak256(schoolsUsersRegistry[providerAddress].accessToken) == keccak256(accessToken);
    }
}
