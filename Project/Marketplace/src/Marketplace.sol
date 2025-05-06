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
        uint id;
        string name;
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

    event registerSellerSuccess(address indexed seller);
    event registerBuyerSuccess(address indexed buyer);
    event createProductSuccess(address indexed seller, uint productId, string name, uint price, uint stock);
    event checkOut(address indexed buyer, uint totalSpent);
    event addedToCart(address indexed buyer, uint indexed productId);

    modifier onlySeller {
        require(sellers[msg.sender].seller != address(0), "Your role is not the seller");
        _;
    }

    modifier onlyBuyer {
        require(buyers[msg.sender].buyer != address(0), "Your role is not the buyer");
        _;
    }

    function registerBuyer() external {
        require(buyers[msg.sender].buyer == address(0), "Already registered");

        buyers[msg.sender] = Buyer({
            buyer: msg.sender,
            cart: new uint[](0),
            totalSpent: 0
        });        
        emit registerBuyerSuccess(msg.sender);
    }

    function registerSeller() external {
        require(sellers[msg.sender].seller == address(0), "Already registered!");

        sellers[msg.sender] = Seller({
            seller: msg.sender,
            productOwn: new uint[](0),
            revenue: 0
        });

        emit registerSellerSuccess(msg.sender);
    }

    function createProduct(string memory name, uint price, uint stock) external onlySeller {
        productCount++;
        products[msg.sender] = Product(msg.sender, productCount, name, price, stock);
        sellers[msg.sender].productOwn.push(productCount);

        emit createProductSuccess(msg.sender, productCount, name, price, stock);
    }

    function buyProduct(uint productId) external onlyBuyer {
        Product storage product = products[productId];
        require(product.stock > 0, "sold out!");
        require(msg.value == product.price, "incorrect amount");

        product.stock--;
        sellers[product.owner].revenue += msg.value;

        buyers[msg.sender].totalSpent += msg.value;
        buyers[msg.sender].cart.push(productId);
    }
    
    function addToCart() external onlyBuyer() {
        // on going
    }

    function checkOut() external onlyBuyer() {
        // on going
    }
}
