// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Subscription is Ownable {
    IERC20 public paymentToken;
    uint public monthlyFee;

    Ownable(msg.sender);
    struct Subscriber {
        uint expiredDate;
        bool isActive;
    }

    mapping(address => Subscriber) public subs;
    event Subscribed(address indexed subscriber, uint expiredDate);
    event unSubscribed(address indexed subscriber);

    constructor(address _token, uint _monthlyFee) {
        paymentToken = IERC20(_token);
        monthlyFee = _monthlyFee;
    }

    function Subscribe(uint months) external {
        require(months > 0, "Subscribe at least 1 month");

        uint totalFee = months * monthlyFee;
        require(paymentToken.transferFrom(msg.sender, address(this), totalFee), "Token imbalance!");

        if(subs[msg.sender].isActive) {
            subs[msg.sender].expiredDate += months * 30 days;
        } else {
            subs[msg.sender] = Subscriber(block.timestamp + (months * 30 days), true);
        }   

        emit Subscribed(msg.sender, subs[msg.sender].expiredDate);
    }

    function unSubscribe() external {
        require(subs[msg.sender].isActive, "You are not subscriber");

        subs[msg.sender].isActive = false;
        emit unSubscribed(msg.sender);
    }

    function isSubscribed(address user) external view returns(bool) {
        return subs[user].isActive && block.timestamp < subs[user].expiredDate;
    }
}
