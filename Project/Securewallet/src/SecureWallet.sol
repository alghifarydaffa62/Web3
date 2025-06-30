// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SecureWallet
 * @author [M Daffa Al Ghifary a.k.a dfpro]
 * @notice A secure wallet contract for storing, withdrawing and transferring Ether between user
 * @dev This contract uses a custom struct `User` to track balance and ownership status
 */

contract SecureWallet {
    // -------------------------------
    // Struct
    // -------------------------------

    /**
     * @dev Represents a registered user of the wallet
     * @param balances The current Ether balance of the user within the contract.
     * @param isOwner Indicates whether the address has been registered as an owner.  
     */

    struct User {
        uint balances; 
        bool isOwner; 
    }

    /// @notice Mapping to store user data based on the user address
    mapping(address => User) public Owner;

    // ----------------------
    // Modifier
    // ----------------------

    /// @dev Restricts access on only registered owner of secure wallet
    modifier onlyOwner {
         require(Owner[msg.sender].isOwner, "You are not an owner!");
         _;
    }

    // -------------------------------
    // Events
    // -------------------------------

    /// @notice Emitted when a user is successfully registers as an owner.
    event registered(address indexed user);

    /// @notice Emitted when a user is successfully deposit an amount of ether.
    event deposited(address indexed user, uint amount);

    /// @notice Emitted when a user is successfully withdraw an amount of ether.
    event withdrawn(address indexed user, uint amount);

    /// @notice Emitted when a user is successfully transfer ether to another registered owner.
    event transfered(address indexed sender, address indexed recipient, uint amount);

    // --------------------------------
    // External Function
    // --------------------------------

    /**
     * @notice Registers the msg.sender as a wallet owner.
     * @dev only unregistered address can call this function once.
     */
    function registerOwner() external {
        require(!Owner[msg.sender].isOwner, "Already registered!");
        Owner[msg.sender].isOwner = true;
        emit registered(msg.sender);
    }

    /**
     * @notice Deposits ether into the msg.sender's wallet
     * @dev Only registered owner can call this function and send ether > 0
     */
    function depositEther() external payable onlyOwner {
        require(msg.value > 0, "Must send ether!");
        Owner[msg.sender].balances += msg.value;
        emit deposited(msg.sender, msg.value);
    }

    /**
     * @notice Withdraws a specified amount of ether to the msg.sender
     * @param amount The amount of ether to withdraw
     * @dev Only registered owners with sufficient balance can call this function.
     */
    function withdrawEther(uint amount) external payable onlyOwner {
        require(Owner[msg.sender].balances >= amount, "Insufficient balances!");

        Owner[msg.sender].balances -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Withdraw failed!");

        emit withdrawn(msg.sender, amount);
    }

    /**
     * @notice Transfer a specified amount of ether to another registered owner
     * @param recipient The address of the recipient
     * @param amount The amount of ether to transfer
     * @dev Both sender and recipient must be registered owners.
     * @dev sender must have enough balance to transfer
     */
    function Transfer(address recipient, uint amount) external payable onlyOwner {
        require(Owner[recipient].isOwner, "Recipient is not an owner!");
        require(Owner[msg.sender].balances >= amount, "Insufficient balances!");
        
        Owner[msg.sender].balances -= amount;
        Owner[recipient].balances += amount;

        emit transfered(msg.sender, recipient, amount);
    }
}
