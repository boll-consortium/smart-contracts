pragma solidity ^0.4.17;

contract BackupCenter {
    event BackupCenterEvents(address indexed sender, address indexed participantAddress,
        address affectedContractAddress, string indexed actionType);

    struct BackupProvider {
        address providerAddress;
        address learnerAddress;
        bool providerApproved;
        bool learnerApproved;
        string backupSiteAddress;
        string plan;
    }

    mapping(address => BackupProvider[]) learner2BackupProviders;
    mapping(address => address[]) backupProvider2Learners;
    mapping(address => bool) backupProvidersDuplicateTracker;
    address initializer;
    address [] backupProviders;

    constructor(address _initializer) public {
        initializer = _initializer;
        emit BackupCenterEvents(msg.sender, _initializer, address(this), "BCC");
    }

    function addBackupProvider(address providerAddress) public payable {
        if (msg.sender == initializer && backupProvidersDuplicateTracker[providerAddress] == false) {
            backupProviders.push(providerAddress);
            backupProvidersDuplicateTracker[providerAddress] = true;
            emit BackupCenterEvents(msg.sender, providerAddress, address(this), "addBackupProvider");
        }
    }

    function subscribe2BackupProvider(address providerAddress, address learnerAddress, string plan) public payable {
        if (msg.sender == learnerAddress && backupProvidersDuplicateTracker[providerAddress] == true) {
            if(learner2BackupProviders[learnerAddress].length > 0) {
                for (uint i = 0; i < learner2BackupProviders[learnerAddress].length; i++) {
                    if(learner2BackupProviders[learnerAddress][i].providerAddress == providerAddress) {
                        if (learner2BackupProviders[learnerAddress][i].learnerApproved == false) {
                            learner2BackupProviders[learnerAddress][i].learnerApproved = true;
                            learner2BackupProviders[learnerAddress][i].plan = plan;
                            emit BackupCenterEvents(msg.sender, providerAddress, address(this), "subscribe2BackupProvider");
                        }
                        return;
                    }
                }
            }

            learner2BackupProviders[learnerAddress].push(BackupProvider(providerAddress, learnerAddress, false, true, "", plan));
            emit BackupCenterEvents(msg.sender, providerAddress, address(this), "subscribe2BackupProvider");
        }
    }

    function approveUserSubscription(address providerAddress, address learnerAddress, string backupSiteAddress, string plan) public payable {
        if (msg.sender == providerAddress && backupProvidersDuplicateTracker[providerAddress] == true) {
            if(learner2BackupProviders[learnerAddress].length > 0) {
                for (uint i = 0; i < learner2BackupProviders[learnerAddress].length; i++) {
                    if(learner2BackupProviders[learnerAddress][i].providerAddress == providerAddress) {
                        if (learner2BackupProviders[learnerAddress][i].learnerApproved == true && keccak256(abi.encodePacked(learner2BackupProviders[learnerAddress][i].plan))
                            == keccak256(abi.encodePacked(plan))) {
                            learner2BackupProviders[learnerAddress][i].providerApproved = true;
                            learner2BackupProviders[learnerAddress][i].backupSiteAddress = backupSiteAddress;
                            backupProvider2Learners[providerAddress].push(learnerAddress);
                            emit BackupCenterEvents(msg.sender, learnerAddress, address(this), "approveUserSubscription");
                        }
                        return;
                    }
                }
            }
        }
    }

    function getInitializer() public view returns (address _initializer) {
        return initializer;
    }

    function getMyLearners(address providerAddress) public view returns (address[]) {
        return backupProvider2Learners[providerAddress];
    }

    function getBackupProviders() public view returns (address []) {
        return backupProviders;
    }

    function getBackupProvidersCount(address learnerAddress) public view returns (uint) {
        return learner2BackupProviders[learnerAddress].length;
    }

    function getMyBackupProviders(address learnerAddress, uint index) public view returns (address, bool, bool, string, string) {
        if(learner2BackupProviders[learnerAddress].length > 0) {
            return (learner2BackupProviders[learnerAddress][index].providerAddress, learner2BackupProviders[learnerAddress][index].providerApproved,
            learner2BackupProviders[learnerAddress][index].learnerApproved, learner2BackupProviders[learnerAddress][index].backupSiteAddress, learner2BackupProviders[learnerAddress][index].plan);
        }
    }

}
