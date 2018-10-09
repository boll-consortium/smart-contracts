pragma solidity ^0.4.17;

contract LearnerLearningProvider {

    struct LearningRecord {
        string queryResultHash;
        string queryHash;
        address writer;
    }
    
    struct Permissions {
        bool canRead;
        bool canWrite;
        bool canGrant;
    }
    
    address owner;
    mapping(address => Permissions) permissions;
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
    
    function LearnerLearningProvider(address _owner, address _learner, bytes _recordType) public {
        owner = _owner;
        recordType = _recordType;
        permissions[_learner] = Permissions(true, true, true);
        permissions[msg.sender] = Permissions(true, true, true);
        provider = msg.sender;
    }

    function insertLearningRecord(string queryString, string queryResultHash) public payable {
        if (permissions[msg.sender].canWrite) {
            if(duplicateLearningLogTracker[queryString] == false) {
                learningRecords.push(LearningRecord(queryResultHash, queryString, msg.sender));
                duplicateLearningLogTracker[queryString] = true;
            }
        }
    }
    
    function requestAccess() public payable {
        Permissions memory permsn = permissions[msg.sender];
        if(permsn.canGrant == false || permsn.canRead == false || permsn.canWrite == false ){
            pendingRequests.push(msg.sender);
        }
    }

    function getPendingRequestsCount() public view returns (uint) {
        return pendingRequests.length;
    }

    function getPendingRequests() public view returns(address[]) {
        return pendingRequests;
    }

    function grantAccess(address participantAddress, bool read, bool write, bool admin) public payable returns (bool) {
        if (permissions[msg.sender].canGrant ) {
            Permissions memory perm = permissions[participantAddress];
            perm.canGrant = admin;
            perm.canRead = read;
            perm.canWrite = write;
            permissions[participantAddress] = perm;
            return true;
        }else {
            return false;
        }
    }

    function grantAccess(uint participantIndex, bool read, bool write, bool admin) public payable returns (bool) {
        if (permissions[msg.sender].canGrant) {
            Permissions memory perm = permissions[pendingRequests[participantIndex]];
            perm.canGrant = admin;
            perm.canRead = read;
            perm.canWrite = write;
            permissions[pendingRequests[participantIndex]] = perm;
            pendingRequests[participantIndex] = pendingRequests[pendingRequests.length-1];
            delete pendingRequests[pendingRequests.length-1];
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

    function canGrant(address participantAddress) public constant returns (bool) {
        return permissions[participantAddress].canGrant;
    }

    function canWrite(address participantAddress) public constant returns (bool) {
        return permissions[participantAddress].canWrite;
    }

    function canRead(address participantAddress) public constant returns (bool) {
        return permissions[participantAddress].canRead;
    }
}
