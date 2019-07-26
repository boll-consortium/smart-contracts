pragma solidity ^0.4.17;
import './LearnerLearningProvider.sol';
import './ProviderIndex.sol';
import './Registrar.sol';

// web3j truffle generate --javaTypes /Users/admin/truffle-codes/build/contracts/UserIndex.json -o /Users/admin/repositories/boll-consortium/src/main/java -p jp.ac.kyoto_u.media.let.boll_consortium.contracts

contract UserIndex {
    event UserIndexContractEvents(address indexed sender, address indexed participantAddress,
        address affectedContractAddress, string indexed actionType);
    struct Testimonial {
        address from;
        uint8 format; // 0 = certificate, 1 = recommendation letter, 2 = others
        bytes url;
        bytes hash;
        address school;
        bool confidential;
    }
    mapping(address => address[]) providers2LearningRecords;
    Testimonial [] testimonials;
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
            providers2LearningRecords[provider].push(llpcContract);
            if(duplicateProviderTracker[provider] == false) {
                providers.push(provider);
                duplicateProviderTracker[provider] = true;
            }
            emit UserIndexContractEvents(msg.sender, provider, address(this), "insertLearningRecord");
        } else {
            revert();
        }
    }

    function insertTestimonial(address from, uint8 format, bytes url, bytes hash, address school, bool confidential, address registrarContract) public payable {
        Registrar registrar = Registrar(registrarContract);
        ProviderIndex pi = ProviderIndex(address(registrar.getIndexContract(school)));
        if (pi.isStaffActive(from)) {
            testimonials.push(Testimonial(from, format, url, hash, school, confidential));
        } else {
            revert();
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

    function getTestimonialsCount() public view returns (uint) {
        return testimonials.length;
    }

    function getTestimonial(uint index) public view returns (address, uint8, bytes, bytes, address, bool) {
        return (testimonials[index].from, testimonials[index].format, testimonials[index].url, testimonials[index].hash, testimonials[index].school, testimonials[index].confidential);
    }

}
