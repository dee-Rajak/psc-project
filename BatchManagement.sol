// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProductRegistration.sol";

contract BatchManagement is ProductRegistration {
    struct Batch {
        uint256 id;
        uint256 productId;
        string batchNumber;
        uint256 quantity;
        uint256 expirationDate;
        string ipfsHash;
        address manufacturer;
    }

    mapping(uint256 => Batch) private batches;
    mapping(uint256 => uint256[]) private productBatches;
    uint256 private batchCount;

    event BatchCreated(uint256 indexed batchId, uint256 indexed productId, string batchNumber, uint256 quantity);

    function createBatch(
        uint256 _productId,
        string memory _batchNumber,
        uint256 _quantity,
        uint256 _expirationDate,
        string memory _ipfsHash
    ) public onlyManufacturer {
        require(products[_productId].approved, "Product is not approved");
        require(products[_productId].manufacturer == stakeholders[msg.sender].name, "Only the product manufacturer can create a batch");

        batchCount++;
        batches[batchCount] = Batch(
            batchCount,
            _productId,
            _batchNumber,
            _quantity,
            _expirationDate,
            _ipfsHash,
            msg.sender
        );
        productBatches[_productId].push(batchCount);
        emit BatchCreated(batchCount, _productId, _batchNumber, _quantity);
    }

    function getBatchDetails(uint256 _batchId)
        public
        view
        returns (
            uint256,
            uint256,
            string memory,
            uint256,
            uint256,
            string memory,
            address
        )
    {
        Batch memory batch = batches[_batchId];
        return (
            batch.id,
            batch.productId,
            batch.batchNumber,
            batch.quantity,
            batch.expirationDate,
            batch.ipfsHash,
            batch.manufacturer
        );
    }

    function getProductBatches(uint256 _productId) public view returns (uint256[] memory) {
        return productBatches[_productId];
    }
}