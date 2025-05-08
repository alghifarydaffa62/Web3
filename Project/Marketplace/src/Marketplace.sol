// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Marketplace {
    struct Buyer {
        address buyer;
        uint balance;
        uint[] cart;
        uint totalSpent;
    }

    struct Product {
        address owner;
        uint id;
        string name;
        uint price;
        uint stock;
        bool soldOut;
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
    event depositSuccess(address indexed buyer, uint amount);
    event withdrawSuccess(address indexed seller, uint amount);
    event createProductSuccess(address indexed seller, uint productId, string name, uint price, uint stock);
    event checkOutSuccess(address indexed buyer, uint totalSpent);
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
            balance: 0,
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

    function deposit() external payable onlyBuyer {
        require(msg.value > 0, "must send ether!");
        buyers[msg.sender].balance += msg.value;
        emit depositSuccess(msg.sender, msg.value);
    }

    function withdraw(uint amount) external payable onlySeller {
        require(sellers[msg.sender].revenue >= amount, "Insufficient balance!");

        sellers[msg.sender].revenue -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "withdraw failed!");

        emit withdrawSuccess(msg.sender, amount);
    }

    function createProduct(string memory name, uint price, uint stock) external onlySeller {
        productCount++;
        products[productCount] = Product(msg.sender, productCount, name, price, stock, false);
        sellers[msg.sender].productOwn.push(productCount);

        emit createProductSuccess(msg.sender, productCount, name, price, stock);
    }
    
    function updatePrice(uint productId, uint newPrice) external onlySeller {
        require(newPrice > 0, "Invalid price!");
        Product storage product = products[productId];

        require(product.owner == msg.sender);
        product.price = newPrice;
    }
    
    function addToCart(uint productId) external payable onlyBuyer() {
        Product storage product = products[productId];
        require(!product.soldOut, "sold out!");

        buyers[msg.sender].cart.push(productId);

        emit addedToCart(msg.sender, productId);
    }

    function removeFromCart(uint productId) external onlyBuyer {
        Buyer storage buyer = buyers[msg.sender];
        uint[] storage cart = buyer.cart;

        for(uint i = 0; i < cart.length; i++) {
            if(cart[i] == productId) {
                for(uint j = i; j < cart.length - 1; j++){
                    cart[j] = cart[j + 1];
                }

                cart.pop();
                buyer.totalSpent -= products[productId].price;
                return;
            }
        }

        revert("Product not found in cart");
    }

    function checkOut() external payable onlyBuyer() {
        Buyer storage buyer = buyers[msg.sender];
        require(buyer.cart.length > 0, "Cart is empty!");

        uint totalPrice = 0;
        for(uint i = 0; i < buyer.cart.length; i++) {
            uint productId = buyer.cart[i];
            Product storage product = products[productId];

            totalPrice += product.price;
        }

        require(buyer.balance >= totalPrice, "Insufficient balances!");

        for(uint i = 0; i < buyer.cart.length; i++) {
            uint productId = buyer.cart[i];
            Product storage product = products[productId];

            product.stock--;
            if(product.stock == 0) {
                product.soldOut = true;
            }

            sellers[product.owner].revenue += product.price;
        }

        buyer.balance -= totalPrice;
        delete buyer.cart;

        emit checkOutSuccess(msg.sender, totalPrice);
    }

    function showCart() external view onlyBuyer returns(uint[] memory) {
        return buyers[msg.sender].cart;
    }
}
