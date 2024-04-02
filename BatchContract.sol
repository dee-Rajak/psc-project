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
        string qrCodeUrl;
    }

    struct Lot {
        uint256 lotId;
        uint256 batchId;
        uint256 quantity;
        address currentOwner;
    }

    mapping(uint256 => Batch) public batches;
    mapping(uint256 => Lot[]) public batchLots;
    mapping(uint256 => mapping(uint256 => Lot)) public lotDetails;
    uint256 public batchCount;
    uint256 public lotCount;

    event BatchCreated(uint256 indexed batchId, uint256 indexed productId, uint256 totalQuantity);
    event LotCreated(uint256 indexed batchId, uint256 indexed lotId, uint256 quantity);
    event OwnershipTransferred(uint256 indexed batchId, uint256 indexed lotId, address newOwner);
    event LotLocationUpdated(uint256 indexed batchId, uint256 indexed lotId, string newLocation);
    event LotDispensedToConsumer(uint256 indexed batchId, uint256 indexed lotId, address consumer);

    function createBatch(
        uint256 _productId,
        uint256 _totalQuantity,
        uint256 _expiryDate,
        uint256 _manufacturingDate,
        uint256 _numLots,
        string memory _qrCodeUrl
    ) public onlyManufacturer returns (uint256) {
        require(_totalQuantity > 0, "Total quantity must be greater than zero.");
        require(_expiryDate > _manufacturingDate, "Expiry date must be after manufacturing date.");
        require(_numLots > 0, "Number of lots must be greater than zero.");

        uint256 newBatchId = batchCount++;
        batches[newBatchId] = Batch(
            newBatchId,
            _productId,
            _totalQuantity,
            _expiryDate,
            _manufacturingDate,
            _qrCodeUrl
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

    function transferOwnership(uint256 _batchId, uint256 _lotId, address _newOwner)
        public
        onlyDistributor
        onlyWholesaler
        onlyPharmacy
    {
        require(_newOwner != address(0), "Invalid new owner address.");
        require(lotDetails[_batchId][_lotId].currentOwner == msg.sender, "Only the current owner can transfer ownership.");

        lotDetails[_batchId][_lotId].currentOwner = _newOwner;
        emit OwnershipTransferred(_batchId, _lotId, _newOwner);
    }

    function updateLotLocation(uint256 _batchId, uint256 _lotId, string memory _newLocation)
        public
        onlyDistributor
        onlyWholesaler
        onlyPharmacy
    {
        require(lotDetails[_batchId][_lotId].currentOwner == msg.sender, "Only the current owner can update location.");
        emit LotLocationUpdated(_batchId, _lotId, _newLocation);
    }

    function dispenseLotToConsumer(uint256 _batchId, uint256 _lotId, address _consumer) public onlyPharmacy {
        require(lotDetails[_batchId][_lotId].currentOwner == msg.sender, "Only the current owner can dispense.");
        require(_consumer != address(0), "Invalid consumer address.");

        lotDetails[_batchId][_lotId].currentOwner = _consumer;
        emit LotDispensedToConsumer(_batchId, _lotId, _consumer);
    }
}