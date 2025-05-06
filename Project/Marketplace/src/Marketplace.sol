// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

    struct Market {
        uint[] activeProducts;
    }

    uint public productCount;
    mapping(uint => Product) public products;
    mapping(address => Seller) public sellers;
    mapping(address => Buyer) public buyers;

    function registerBuyer() external {
        require(buyers[msg.sender].buyer == address(0), "Already registered");

        buyers[msg.sender] = Buyer({
            buyer: msg.sender,
            cart: new uint[],
            totalSpent: 0
        });        
    }

    function registerSeller() external {
        require(sellers[msg.sender].seller == address(0), "Already registered!");
        
        sellers[msg.sender] = Seller({
            seller: msg.sender,
            productOwn: new uint ,
            revenue: 0
        });
    }
}
