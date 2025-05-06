// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Marketplace {
    struct Buyer {
        address buyer;
        uint[] cart;
        uint totalSpent;
    }

    struct Product {
        address owner;
        string name;
        uint id;
        uint price;
        uint stock;
    }

    struct Seller {
        address seller;
        uint[] productOwn;
        uint revenue;
    }

    uint public productCount;
    mapping(uint => Product) public products;
    mapping(address => Seller) public sellers;
    mapping(address => Buyer) public buyers;
}
