pragma solidity ^0.4.17;
import './LearnerLearningProvider.sol';

contract UserIndex {
    event UserIndexContractEvents(address indexed sender, address indexed participantAddress,
        address affectedContractAddress, string indexed actionType);
    mapping(address => address[]) providers2LearningRecords;
    mapping(address => bool) duplicateTracker;
    mapping(bytes => address) recordType2LLPC;
    mapping(address => bool) duplicateProviderTracker;
    address owner;
    address[] providers;

constructor(address _owner) public {
        owner = _owner;
        emit UserIndexContractEvents(msg.sender, _owner, address(this), "UIC");
    }

    function insertLearningRecord(address provider, address llpcContract, bytes recordType) public payable {
        LearnerLearningProvider llpc = LearnerLearningProvider(llpcContract);
        if (llpc.getOwner() == owner && duplicateTracker[llpcContract] == false && llpc.canWrite(msg.sender, false) == true &&
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
            emit UserIndexContractEvents(msg.sender, provider, address(this), "insertLearningRecord");
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
