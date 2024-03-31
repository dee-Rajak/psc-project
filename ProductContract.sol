// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AccessControl.sol";

contract ProductContract is AccessControl {
    struct Product {
        uint256 id;
        address manufacturer;
        string name;
        string description;
        string[] ingredients;
        // Additional product details can be added here
    }

    mapping(uint256 => Product) public products;
    mapping(address => uint256[]) public manufacturerProducts;
    uint256 public productCount;

    event ProductRegistered(uint256 indexed productId, address indexed manufacturer);

    modifier onlyManufacturer(uint256 productId) {
        require(products[productId].manufacturer == msg.sender, "Only the manufacturer can perform this action.");
        _;
    }

    function registerProduct(string memory _name, string memory _description, string[] memory _ingredients) public onlyManufacturer returns (uint256) {
        // Input validation
        require(bytes(_name).length > 0, "Product name cannot be empty.");
        require(bytes(_description).length > 0, "Product description cannot be empty.");
        require(_ingredients.length > 0, "At least one ingredient must be provided.");

        uint256 newProductId = productCount++;
        products[newProductId] = Product(newProductId, msg.sender, _name, _description, _ingredients);
        manufacturerProducts[msg.sender].push(newProductId);

        emit ProductRegistered(newProductId, msg.sender);

        return newProductId;
    }

    // Add other functions for product management if needed
}