// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AccessControlContract.sol";

contract ProductContract is AccessControlContract {
    struct Product {
        uint256 id;
        address manufacturer;
        string name;
        string description;
        string[] ingredients;
        string imageUrl;
    }

    mapping(uint256 => Product) public products;
    mapping(address => uint256[]) public manufacturerProducts;
    uint256 public productCount;

    event ProductRegistered(uint256 indexed productId, address indexed manufacturer);

    function registerProduct(
        string memory _name,
        string memory _description,
        string[] memory _ingredients,
        string memory _imageUrl
    ) public onlyManufacturer returns (uint256) {
        uint256 newProductId = productCount++;
        products[newProductId] = Product(
            newProductId,
            msg.sender,
            _name,
            _description,
            _ingredients,
            _imageUrl
        );
        manufacturerProducts[msg.sender].push(newProductId);

        emit ProductRegistered(newProductId, msg.sender);

        return newProductId;
    }
}