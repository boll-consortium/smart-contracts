pragma solidity ^0.4.17;
import './Registrar.sol';

contract LearnerLearningProvider {
    event LearnerLearningProviderContractEvents(address indexed sender, address indexed participantAddress,
        address affectedContractAddress, string indexed actionType, int index);
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
    
    constructor(address _owner, address _learner, bytes _recordType) public {
        //ToDo Prevent non-registered schools from creating LLPCs. This is a bug which should be fixed.
        //ToDo Otherwise, the first person to create a smart contract would like retain priority access to it
       /* Registrar registrar = Registrar(registrarAddress);
        if(registrar.isApprovedInstitute(accessToken)){*/
            owner = _owner;
            recordType = _recordType;
            permissions[_learner] = Permissions(true, true, true, false);
            permissions[msg.sender] = Permissions(true, true, true, false);
            provider = msg.sender;
            emit LearnerLearningProviderContractEvents(msg.sender, _owner, address(this), "LLPC", -1);
        //}
    }

    function insertLearningRecord(string queryString, string queryResultHash) public payable {
        if (permissions[msg.sender].canWrite) {
            if(duplicateLearningLogTracker[queryString] == false) {
                learningRecords.push(LearningRecord(queryResultHash, queryString, msg.sender));
                duplicateLearningLogTracker[queryString] = true;
                emit LearnerLearningProviderContractEvents(msg.sender, owner, address(this), "insertLearningRecord", learningRecords.length);
            }
        }
    }
    
    function requestAccess(bool grant, bool write, bool read) public payable {
        if((permissions[msg.sender].canGrant == false || permissions[msg.sender].canRead == false
          || permissions[msg.sender].canWrite == false)){
            permissionsRequests[msg.sender] = Permissions(read, write, grant, true);
            emit LearnerLearningProviderContractEvents(msg.sender, owner, address(this), "requestAccess", -1);
        }
    }

    function getPendingRequestsCount() public view returns (uint) {
        return pendingRequests.length;
    }

    function getPendingRequests() public view returns(address[]) {
        return pendingRequests;
    }

    function grantAccess(address participantAddress, bool read, bool write, bool admin) public payable returns (bool) {
        if (permissions[msg.sender].canGrant) {
            permissions[participantAddress] = Permissions(read, write, admin, false);

            if(permissionsRequests[participantAddress].isPendingRequest) {
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
            }

            emit LearnerLearningProviderContractEvents(msg.sender, participantAddress, address(this), "grantAccess", -1);
            return true;
        }else {
            return false;
        }
    }

    function updateAccess(address participantAddress, bool read, bool write, bool admin) public payable returns (bool) {
        if (permissions[msg.sender].canGrant) {
            permissions[participantAddress].canGrant = admin;
            permissions[participantAddress].canRead = read;
            permissions[participantAddress].canWrite = write;

            emit LearnerLearningProviderContractEvents(msg.sender, participantAddress, address(this), "updateAccess", -1);
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
