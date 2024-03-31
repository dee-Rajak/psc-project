// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProductContract.sol";

contract BatchContract is ProductContract {
    struct Batch {
        uint256 batchId;
        uint256 productId;
        uint256 totalQuantity;
        uint256 expiryDate;
        uint256 manufacturingDate;
        // Add more batch details as needed
    }

    struct Lot {
        uint256 lotId;
        uint256 batchId;
        uint256 quantity;
        address currentOwner;
        // Add more lot details as needed
    }

    mapping(uint256 => Batch) public batches;
    mapping(uint256 => Lot[]) public batchLots;
    mapping(uint256 => mapping(uint256 => Lot)) public lotDetails;
    uint256 public batchCount;
    uint256 public lotCount;

    event BatchCreated(uint256 indexed batchId, uint256 indexed productId, uint256 totalQuantity);
    event LotCreated(uint256 indexed batchId, uint256 indexed lotId, uint256 quantity);
    event OwnershipTransferred(uint256 indexed batchId, uint256 indexed lotId, address newOwner);

    modifier onlyManufacturer(uint256 productId) {
        require(products[productId].manufacturer == msg.sender, "Only the manufacturer can perform this action.");
        _;
    }

    // Add functions for batch and lot creation, ownership transfers, etc.

    function createBatch(
        uint256 _productId,
        uint256 _totalQuantity,
        uint256 _expiryDate,
        uint256 _manufacturingDate,
        uint256 _numLots
    ) public onlyManufacturer(_productId) returns (uint256) {
        require(_totalQuantity > 0, "Total quantity must be greater than zero.");
        require(_expiryDate > _manufacturingDate, "Expiry date must be after manufacturing date.");
        require(_numLots > 0, "Number of lots must be greater than zero.");

        uint256 newBatchId = batchCount++;
        batches[newBatchId] = Batch(
            newBatchId,
            _productId,
            _totalQuantity,
            _expiryDate,
            _manufacturingDate
        );

        uint256 lotQuantity = _totalQuantity / _numLots;
        for (uint256 i = 0; i < _numLots; i++) {
            uint256 newLotId = lotCount++;
            batchLots[newBatchId].push(
                Lot(newLotId, newBatchId, lotQuantity, msg.sender)
            );
            lotDetails[newBatchId][newLotId] = Lot(newLotId, newBatchId, lotQuantity, msg.sender);
            emit LotCreated(newBatchId, newLotId, lotQuantity);
        }

        emit BatchCreated(newBatchId, _productId, _totalQuantity);
        return newBatchId;
    }

    function transferOwnership(uint256 _batchId, uint256 _lotId, address _newOwner) public {
        require(_newOwner != address(0), "Invalid new owner address.");
        require(lotDetails[_batchId][_lotId].currentOwner == msg.sender, "Only the current owner can transfer ownership.");

        lotDetails[_batchId][_lotId].currentOwner = _newOwner;
        emit OwnershipTransferred(_batchId, _lotId, _newOwner);
    }

    // Update Lot Location
    event LotLocationUpdated(uint256 indexed batchId, uint256 indexed lotId, string newLocation);

    function updateLotLocation(uint256 _batchId, uint256 _lotId, string memory _newLocation) public {
        require(lotDetails[_batchId][_lotId].currentOwner == msg.sender, "Only the current owner can update location.");
        
        // You can add additional logic here to validate or process the location data if needed
        
        emit LotLocationUpdated(_batchId, _lotId, _newLocation);
    }

    // Dispense Lot To Customer
    event LotDispensedToConsumer(uint256 indexed batchId, uint256 indexed lotId, address consumer);

    function dispenseLotToConsumer(uint256 _batchId, uint256 _lotId, address _consumer) public {
        require(lotDetails[_batchId][_lotId].currentOwner == msg.sender, "Only the current owner can dispense.");
        require(_consumer != address(0), "Invalid consumer address.");
        
        // Additional logic to validate that the caller is a pharmacy or authorized to dispense
        
        lotDetails[_batchId][_lotId].currentOwner = _consumer;
        emit LotDispensedToConsumer(_batchId, _lotId, _consumer);
    }

    // Report Issue
    struct Issue {
        uint256 batchId;
        uint256 lotId;
        string description;
        address reporter;
    }

    Issue[] public reportedIssues;

    event IssueReported(uint256 indexed batchId, uint256 indexed lotId, string description, address reporter);

    function reportIssue(uint256 _batchId, uint256 _lotId, string memory _description) public {
        reportedIssues.push(Issue(_batchId, _lotId, _description, msg.sender));
        emit IssueReported(_batchId, _lotId, _description, msg.sender);
    }
}