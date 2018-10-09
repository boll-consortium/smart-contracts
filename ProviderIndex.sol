pragma solidity ^0.4.17;
import './LearnerLearningProvider.sol';

contract ProviderIndex {

    mapping(address => address[]) learners2LearningRecords;
    mapping(address => bool) duplicateTracker;
    mapping(address => bool) learnersDuplicateTracker;
    address owner;
    address [] learners;

    function ProviderIndex(address _owner) public {
        owner = _owner;
    }

    function insertLearningRecord(address learner, address llpcContract) public payable {
        LearnerLearningProvider llpc = LearnerLearningProvider(llpcContract);
        if ( duplicateTracker[llpcContract] == false && llpc.canWrite(msg.sender) == true) {
            duplicateTracker[llpcContract] = true;
            learners2LearningRecords[learner].push(llpc);
            if(learnersDuplicateTracker[learner] == false) {
                learners.push(learner);
            }
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
