pragma solidity ^0.4.17;
import './LearnerLearningProvider.sol';

contract ProviderIndex {
    event ProviderIndexContractEvents(address indexed sender, address indexed participantAddress,
        address affectedContractAddress, string indexed actionType);
    mapping(address => address[]) learners2LearningRecords;
    mapping(address => bool) duplicateTracker;
    mapping(address => bool) learnersDuplicateTracker;
    address owner;
    address [] learners;

constructor(address _owner) public {
        owner = _owner;
        emit ProviderIndexContractEvents(msg.sender, _owner, address(this), "PIC");
    }

    function insertLearningRecord(address learner, address llpcContract) public payable {
        LearnerLearningProvider llpc = LearnerLearningProvider(llpcContract);
        if ( duplicateTracker[llpcContract] == false && llpc.canWrite(msg.sender, false) == true) {
            duplicateTracker[llpcContract] = true;
            learners2LearningRecords[learner].push(llpc);
            if(learnersDuplicateTracker[learner] == false) {
                learners.push(learner);
            }
            emit ProviderIndexContractEvents(msg.sender, learner, address(this), "insertLearningRecord");
        }
    }

    function getOwner() public view returns (address _owner) {
        return owner;
    }

    function getLearningRecordsByLearner(address learner) public view returns (address[]) {
        return learners2LearningRecords[learner];
    }
    
    function getLearners() public view returns (address []) {
        if(msg.sender == owner) {
            return learners;
        }
    }
    
}
