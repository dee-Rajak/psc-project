// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract AccessControlContract is AccessControl {
    bytes32 public constant MANUFACTURER_ROLE = keccak256("MANUFACTURER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant WHOLESALER_ROLE = keccak256("WHOLESALER_ROLE");
    bytes32 public constant PHARMACY_ROLE = keccak256("PHARMACY_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    modifier onlyManufacturer() {
        require(hasRole(MANUFACTURER_ROLE, msg.sender), "Caller is not a manufacturer");
        _;
    }

    modifier onlyDistributor() {
        require(hasRole(DISTRIBUTOR_ROLE, msg.sender), "Caller is not a distributor");
        _;
    }

    modifier onlyWholesaler() {
        require(hasRole(WHOLESALER_ROLE, msg.sender), "Caller is not a wholesaler");
        _;
    }

    modifier onlyPharmacy() {
        require(hasRole(PHARMACY_ROLE, msg.sender), "Caller is not a pharmacy");
        _;
    }

    function addManufacturer(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MANUFACTURER_ROLE, account);
    }

    function removeManufacturer(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MANUFACTURER_ROLE, account);
    }
    function addDistributor(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(DISTRIBUTOR_ROLE, account);
    }

    function removeDistributor(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(DISTRIBUTOR_ROLE, account);
    }
    function addWholesaler(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(WHOLESALER_ROLE, account);
    }

    function removeWholesaler(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(WHOLESALER_ROLE, account);
    }
    function addPharmacy(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(PHARMACY_ROLE, account);
    }

    function removePharmacy(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(PHARMACY_ROLE, account);
    }

    // Similar functions for Distributor, Wholesaler, and Pharmacy roles
}