// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Charity
 * @notice A simple and secure charity wallet to receive donations and distribute them to the recipient
 * @dev Only the owner can close the charity and send collected funds into recipient
 */
contract Charity {
    /// @dev The owner of the charity contract
    address public owner;

    /// @notice Total amount of ether colledted from donations
    uint public TotalCharity;

    /// @dev Indicates whether the charity is still active or not
    bool isActive;

    /**
     * @notice Initialize the charity contract and sets the owner and active status
     */
    constructor() {
        owner = msg.sender;
        isActive = true;
    }

    // -------------------
    // Modifier
    // -------------------

    /// @dev Restricts function access to only the owner
    modifier onlyOwner { 
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    // --------------------
    // Events
    // --------------------

    /// @notice Emitted when a donator successfully donate to the charity
    event donateSuccess(address indexed donator, uint amount);

    /// @notice Emitted when the owner successfully send all the collected funds into recipient
    event CharitySended(address indexed owner, address indexed recipient, uint amount);

    /// @notice Emitted when the owner successfully close the charity contract
    event CharityClosed(address indexed owner);

    // ------------------------
    // External Functions
    // ------------------------

    /**
     * @notice Allows anyone to donate to the charity while is's active
     * @dev The donation must be greather than zero
     */
    function donate() external payable {
        require(msg.value > 0, "Must send ether!");
        require(isActive, "Charity donations are closed!");

        TotalCharity += msg.value;

        emit donateSuccess(msg.sender, msg.value);
    }

    /**
     * @notice Sends the collected funds into the specified recipient address
     * @dev Only the owner can call this function and only after the charity is closed
     * @param recipient The address to receive the total charity amount
     */
    function SendCharity(address recipient) external payable onlyOwner {
        require(!isActive, "Charity is still active!");
        require(recipient != address(0), "Invalid recipient address!");

        uint amount = TotalCharity;
        (bool success, ) = recipient.call{value: amount}("");
        require(success);
        TotalCharity = 0;

        emit CharitySended(msg.sender, recipient, amount);
    }

    /**
     * @notice Close the charity so that no more accept donations
     * @dev Only the owner can call this function
     */
    function closeCharity() external onlyOwner {
        isActive = false;
        emit CharityClosed(msg.sender);
    }

    /**
     * @notice Anyone can call this function to get the current status of the charity
     * @return A boolean value indicating the charity status
     */
    function getStatus() external view returns(bool) {
        return isActive;
    }
}
