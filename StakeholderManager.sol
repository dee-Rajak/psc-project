// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract StakeholderManager is AccessControl {
    using Strings for uint256;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant WHOLESALER_ROLE = keccak256("WHOLESALER_ROLE");
    bytes32 public constant PHARMACY_ROLE = keccak256("PHARMACY_ROLE");
    bytes32 public constant CONSUMER_ROLE = keccak256("CONSUMER_ROLE");

    struct Stakeholder {
        string name;
        string email;
        bytes32 hashedPassword;
        bytes32 role;
        bool approved;
        string location;
        string detailsIPFSHash;
    }

    address[] private registrationQueue;

    mapping(address => Stakeholder) public stakeholders;
    mapping(bytes32 => address[]) private stakeholdersByRole;
    mapping(address => bool) private isInRegistrationQueue;

    event StakeholderRegistered(address indexed stakeholder, bytes32 indexed role);
    event StakeholderApproved(address indexed stakeholder, bytes32 indexed role);
    event StakeholderRemoved(address indexed stakeholder, bytes32 indexed role);

    constructor() {
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function registerStakeholder(
        string memory name,
        string memory email,
        string memory password,
        bytes32 role,
        string memory location,
        string memory detailsIPFSHash
    ) public {
        require(!hasRole(role, msg.sender), "Stakeholder already registered");
        require(!hasRole(ADMIN_ROLE, msg.sender) || role == ADMIN_ROLE, "Admin cannot register for additional roles");
        require(!isInRegistrationQueue[msg.sender], "Stakeholder already in registration queue");
        bytes32 hashedPassword = keccak256(abi.encodePacked(password));
        bool isApproved = role == CONSUMER_ROLE;
        stakeholders[msg.sender] = Stakeholder(
            name,
            email,
            hashedPassword,
            role,
            isApproved,
            location,
            detailsIPFSHash
        );
        if (role != ADMIN_ROLE) {
            registrationQueue.push(msg.sender);
            isInRegistrationQueue[msg.sender] = true;
        }
        if (isApproved) {
            _grantRole(role, msg.sender);
            stakeholdersByRole[role].push(msg.sender);
        }
        emit StakeholderRegistered(msg.sender, role);
    }

    function updateStakeholderRegistration(
        string memory name,
        string memory email,
        string memory password,
        bytes32 role,
        string memory location,
        string memory detailsIPFSHash
    ) public {
        require(isInRegistrationQueue[msg.sender], "Stakeholder not in registration queue");
        require(!hasRole(ADMIN_ROLE, msg.sender) || role == ADMIN_ROLE, "Admin cannot update registration");
        bytes32 hashedPassword = keccak256(abi.encodePacked(password));
        stakeholders[msg.sender] = Stakeholder(
            name,
            email,
            hashedPassword,
            role,
            stakeholders[msg.sender].approved,
            location,
            detailsIPFSHash
        );
        emit StakeholderRegistered(msg.sender, role);
    }

    function approveStakeholder(address stakeholder) public onlyRole(ADMIN_ROLE) {
        require(!stakeholders[stakeholder].approved, "Stakeholder already approved");
        stakeholders[stakeholder].approved = true;
        _grantRole(stakeholders[stakeholder].role, stakeholder);
        stakeholdersByRole[stakeholders[stakeholder].role].push(stakeholder);
        emit StakeholderApproved(stakeholder, stakeholders[stakeholder].role);
    }

    function removeStakeholder(address stakeholder) public onlyRole(ADMIN_ROLE) {
        require(hasRole(stakeholders[stakeholder].role, stakeholder), "Stakeholder not registered");
        _revokeRole(stakeholders[stakeholder].role, stakeholder);
        emit StakeholderRemoved(stakeholder, stakeholders[stakeholder].role);
    }

    function loginStakeholder(string memory password) public view returns (bool) {
        bytes32 hashedPassword = keccak256(abi.encodePacked(password));
        return stakeholders[msg.sender].hashedPassword == hashedPassword;
    }

    function getStakeholdersByRole(bytes32 role) public view returns (address[] memory) {
        return stakeholdersByRole[role];
    }

    function getRegistrationQueueCount() public view onlyRole(ADMIN_ROLE) returns (uint256) {
        return registrationQueue.length;
    }

    function getRegistrationQueueAddresses() public view onlyRole(ADMIN_ROLE) returns (address[] memory) {
        return registrationQueue;
    }

    function getStakeholderDetails(address stakeholderAddress)
        public
        view
        onlyRole(ADMIN_ROLE)
        returns (
            string memory,
            string memory,
            bytes32,
            bool,
            string memory,
            string memory
        )
    {
        Stakeholder memory stakeholder = stakeholders[stakeholderAddress];
        return (
            stakeholder.name,
            stakeholder.email,
            stakeholder.role,
            stakeholder.approved,
            stakeholder.location,
            stakeholder.detailsIPFSHash
        );
    }
}