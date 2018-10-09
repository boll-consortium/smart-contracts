pragma solidity ^0.4.17;
import './LearnerLearningProvider.sol';

contract UserIndex {

    mapping(address => address[]) providers2LearningRecords;
    mapping(address => bool) duplicateTracker;
    mapping(bytes => address) recordType2LLPC;
    mapping(address => bool) duplicateProviderTracker;
    address owner;
    address[] providers;

    function UserIndex(address _owner) public {
        owner = _owner;
    }

    function insertLearningRecord(address provider, address llpcContract, bytes recordType) public payable {
        LearnerLearningProvider llpc = LearnerLearningProvider(llpcContract);
        if (llpc.getOwner() == owner && duplicateTracker[llpcContract] == false && llpc.canWrite(msg.sender) == true &&
          (recordType2LLPC[recordType]== address(0) || recordType2LLPC[recordType] == llpcContract)) {
            duplicateTracker[llpcContract] = true;
            if(recordType2LLPC[recordType] == address(0)) {
                recordType2LLPC[recordType] = llpcContract;
            }
            providers2LearningRecords[provider].push(llpc);
            if(duplicateProviderTracker[provider] == false) {
                providers.push(provider);
                duplicateProviderTracker[provider] = true;
            }
        }
    }

    function getOwner() public view returns (address _owner) {
        return owner;
    }

    function getLearningRecordsByProvider(address provider) public view returns (address[]) {
        return providers2LearningRecords[provider];
    }

    function getLearningRecordsByRecordType(bytes recordType) public view returns (address) {
        if(providers2LearningRecords[msg.sender].length > 0 || owner == msg.sender) {
            return recordType2LLPC[recordType];
        }
    }

    function getProviders() public view returns (address[]) {
        if(providers2LearningRecords[msg.sender].length > 0 || owner == msg.sender) {
            return providers;
        }
    }
    
}
