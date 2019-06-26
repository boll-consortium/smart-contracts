pragma solidity ^0.4.17;
import './LearnerLearningProvider.sol';

contract ProviderIndex {
    event ProviderIndexContractEvents(address indexed sender, address indexed participantAddress,
        address affectedContractAddress, string indexed actionType);

    struct Staff {
        address staff;
        uint8 [] staff_type; // 0 = teacher
        uint64 joined; // timestamp of recruitment date
        uint64 left; // timestamp of withdrawal date
        bool active;
    }
    mapping(address => address[]) learners2LearningRecords;
    mapping(address => Staff) staffMembers;
    mapping(address => bool) duplicateTracker;
    mapping(address => bool) learnersDuplicateTracker;
    address owner;
    address [] learners;
    address [] staffLUT; // staff members lookup table

    constructor(address _owner) public {
        owner = _owner;
        emit ProviderIndexContractEvents(msg.sender, _owner, address(this), "PIC");
    }

    function insertLearningRecord(address learner, address llpcContract) public payable {
        LearnerLearningProvider llpc = LearnerLearningProvider(llpcContract);
        if ( duplicateTracker[llpcContract] == false && llpc.canWrite(msg.sender, false) == true) {
            duplicateTracker[llpcContract] = true;
            learners2LearningRecords[learner].push(llpcContract);
            if(learnersDuplicateTracker[learner] == false) {
                learners.push(learner);
            }
            emit ProviderIndexContractEvents(msg.sender, learner, address(this), "insertLearningRecord");
        }
    }

    function approveStaffMember(address staff, uint8 staff_type, uint64 joined, bool active) public payable{
        if(msg.sender == owner) {
            if(staffMembers[staff].staff == address(0)) {
                staffLUT.push(staff);
                staffMembers[staff].staff_type.push(staff_type);
                staffMembers[staff] = Staff(staff, staffMembers[staff].staff_type, joined, 0, active);
            } else {
                staffMembers[staff].staff_type.push(staff_type);
                staffMembers[staff].active = active;
            }
        } else {
            revert();
        }
    }

    function disapproveStaffMember(address staff, uint8 staff_type, uint64 left) public payable{
        if(msg.sender == owner && (staffMembers[staff].active || staffMembers[staff].staff != address(0))) {
            bool deleted = false;
            for(uint i = 0; i < staffMembers[staff].staff_type.length; i++) {
                if (staffMembers[staff].staff_type[i] == staff_type) {
                    // remove permission for this staff_type
                    staffMembers[staff].staff_type[i] = staffMembers[staff].staff_type[staffMembers[staff].staff_type.length - 1];
                    deleted = true;
                    break;
                }
            }

            if (deleted) {
                delete staffMembers[staff].staff_type[staffMembers[staff].staff_type.length - 1];
                staffMembers[staff].staff_type.length--;
            }

            if (staffMembers[staff].staff_type.length == 0) {
                staffMembers[staff].left = left;
                staffMembers[staff].active = false;
            }

        } else {
            revert();
        }
    }

    function getOwner() public view returns (address _owner) {
        return owner;
    }

    function getLearningRecordsByLearner(address learner) public view returns (address[]) {
        return learners2LearningRecords[learner];
    }

    function getStaffMember(address staff) public view returns (address, uint8 [], uint64, uint64, bool) {
        return (staffMembers[staff].staff, staffMembers[staff].staff_type, staffMembers[staff].joined, staffMembers[staff].left, staffMembers[staff].active);
    }

    function isStaffActive(address staff) public view returns (bool) {
        return staffMembers[staff].active;
    }

    function getStaff() public view returns (address []) {
        if(msg.sender == owner) {
            return staffLUT;
        }
    }

    function getStaffCount() public view returns (uint) {
        if(msg.sender == owner) {
            return staffLUT.length;
        }
    }

    function getLearners() public view returns (address []) {
        if(msg.sender == owner) {
            return learners;
        }
    }

}
