// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Roles.sol";

contract AccessControl {
    using Roles for Roles.Role;

    Roles.Role private manufacturerRole;
    Roles.Role private distributorRole;
    Roles.Role private wholesalerRole;
    Roles.Role private pharmacyRole;

    event ManufacturerAdded(address indexed account);
    event ManufacturerRemoved(address indexed account);
    event DistributorAdded(address indexed account);
    event DistributorRemoved(address indexed account);
    event WholesalerAdded(address indexed account);
    event WholesalerRemoved(address indexed account);
    event PharmacyAdded(address indexed account);
    event PharmacyRemoved(address indexed account);

    constructor() {
        // Add your own logic for initial role assignments, if needed
    }

    modifier onlyManufacturer() {
        require(isManufacturer(msg.sender), "Caller is not a manufacturer");
        _;
    }

    modifier onlyDistributor() {
        require(isDistributor(msg.sender), "Caller is not a distributor");
        _;
    }

    modifier onlyWholesaler() {
        require(isWholesaler(msg.sender), "Caller is not a wholesaler");
        _;
    }

    modifier onlyPharmacy() {
        require(isPharmacy(msg.sender), "Caller is not a pharmacy");
        _;
    }

    function addManufacturer(address account) public {
        // Add your own logic for authorization checks
        manufacturerRole.add(account);
        emit ManufacturerAdded(account);
    }

    function removeManufacturer(address account) public {
        // Add your own logic for authorization checks
        manufacturerRole.remove(account);
        emit ManufacturerRemoved(account);
    }

    function addDistributor(address account) public {
        // Add your own logic for authorization checks
        distributorRole.add(account);
        emit DistributorAdded(account);
    }

    function removeDistributor(address account) public {
        // Add your own logic for authorization checks
        distributorRole.remove(account);
        emit DistributorRemoved(account);
    }

    function addWholesaler(address account) public {
        // Add your own logic for authorization checks
        wholesalerRole.add(account);
        emit WholesalerAdded(account);
    }

    function removeWholesaler(address account) public {
        // Add your own logic for authorization checks
        wholesalerRole.remove(account);
        emit WholesalerRemoved(account);
    }

    function addPharmacy(address account) public {
        // Add your own logic for authorization checks
        pharmacyRole.add(account);
        emit PharmacyAdded(account);
    }

    function removePharmacy(address account) public {
        // Add your own logic for authorization checks
        pharmacyRole.remove(account);
        emit PharmacyRemoved(account);
    }

    function isManufacturer(address account) public view returns (bool) {
        return manufacturerRole.has(account);
    }

    function isDistributor(address account) public view returns (bool) {
        return distributorRole.has(account);
    }

    function isWholesaler(address account) public view returns (bool) {
        return wholesalerRole.has(account);
    }

    function isPharmacy(address account) public view returns (bool) {
        return pharmacyRole.has(account);
    }
}