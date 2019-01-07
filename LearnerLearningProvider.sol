pragma solidity ^0.4.17;
import './Registrar.sol';

contract LearnerLearningProvider {
    event LearnerLearningProviderContractEvents(address indexed sender, address indexed participantAddress,
        address affectedContractAddress, string indexed actionType);
    struct LearningRecord {
        string queryResultHash;
        string queryHash;
        address writer;
    }
    
    struct Permissions {
        bool canRead;
        bool canWrite;
        bool canGrant;
        bool isPendingRequest;
    }
    
    address owner;
    mapping(address => Permissions) permissions;
    mapping(address => Permissions) permissionsRequests;
    address[] pendingRequests;
    LearningRecord[] learningRecords;
    mapping(string => bool) duplicateLearningLogTracker;
    bytes recordType;
    address provider;

    function getOwner() public view returns (address) {
        return owner;
    }

    function getRecordType() public view returns (bytes) {
        return recordType;
    }

    function isDuplicate(string queryString) public view returns (bool) {
        return duplicateLearningLogTracker[queryString];
    }

    function getProvider() public view returns (address) {
        return provider;
    }
    
    constructor(address _owner, address _learner, bytes _recordType, address registrarAddress, bytes accessToken) public {
        Registrar registrar = Registrar(registrarAddress);
        if(registrar.isApprovedInstitute(accessToken)){
            owner = _owner;
            recordType = _recordType;
            permissions[_learner] = Permissions(true, true, true, false);
            permissions[msg.sender] = Permissions(true, true, true, false);
            provider = msg.sender;
            emit LearnerLearningProviderContractEvents(msg.sender, _owner, address(this), "LLPC");
        }
    }

    function insertLearningRecord(string queryString, string queryResultHash) public payable {
        if (permissions[msg.sender].canWrite) {
            if(duplicateLearningLogTracker[queryString] == false) {
                learningRecords.push(LearningRecord(queryResultHash, queryString, msg.sender));
                duplicateLearningLogTracker[queryString] = true;
                emit LearnerLearningProviderContractEvents(msg.sender, owner, address(this), "insertLearningRecord");
            }
        }
    }
    
    function requestAccess(bool grant, bool write, bool read) public payable {
        if((permissions[msg.sender].canGrant == false || permissions[msg.sender].canRead == false
          || permissions[msg.sender].canWrite == false)){
            permissionsRequests[msg.sender] = Permissions(read, write, grant, true);
            emit LearnerLearningProviderContractEvents(msg.sender, owner, address(this), "requestAccess");
        }
    }

    function getPendingRequestsCount() public view returns (uint) {
        return pendingRequests.length;
    }

    function getPendingRequests() public view returns(address[]) {
        return pendingRequests;
    }

    function grantAccess(address participantAddress, bool read, bool write, bool admin) public payable returns (bool) {
        if (permissions[msg.sender].canGrant && permissionsRequests[participantAddress].isPendingRequest) {
            permissions[participantAddress] = Permissions(read, write, admin, false);
            uint arrayLen = getPendingRequestsCount();
            for(uint i = 0; i < arrayLen; i++) {
                if(pendingRequests[i] == participantAddress) {
                    if(i != (pendingRequests.length-1)) {
                        pendingRequests[i] = pendingRequests[arrayLen-1];
                        delete pendingRequests[arrayLen-1];
                        delete permissionsRequests[participantAddress];
                    }
                    break;
                }
            }
            emit LearnerLearningProviderContractEvents(msg.sender, participantAddress, address(this), "grantAccess");
            return true;
        }else {
            return false;
        }
    }

    function getLearningRecordsCount() public view returns (uint) {
        if (permissions[msg.sender].canRead) {
            return learningRecords.length;
        }else {
            return 0;
        }
    }

    function getLearningRecord(uint index) public view returns (string, string, address) {
        if (permissions[msg.sender].canRead) {
            return (learningRecords[index].queryResultHash,learningRecords[index].queryHash,
            learningRecords[index].writer);
        }
    }

    function canGrant(address participantAddress, bool pendingRequest) public constant returns (bool) {
        return pendingRequest ? permissionsRequests[participantAddress].canGrant : permissions[participantAddress].canGrant;
    }

    function canWrite(address participantAddress, bool pendingRequest) public constant returns (bool) {
        return pendingRequest ? permissionsRequests[participantAddress].canWrite : permissions[participantAddress].canWrite;
    }

    function canRead(address participantAddress, bool pendingRequest) public constant returns (bool) {
        return pendingRequest ? permissionsRequests[participantAddress].canRead : permissions[participantAddress].canRead;
    }
}
