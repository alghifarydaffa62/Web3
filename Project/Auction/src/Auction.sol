// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract NFTAuction is ReentrancyGuard {
    struct Auction {
        address seller;
        uint minBid;
        address highestBidder;
        uint highestBid;
        bool isActive;
    }

    mapping(address => mapping(uint => Auction)) public auctions;
    mapping(address => mapping(uint => bool)) public nftLocked;

    event auctionCreated(address indexed nft, uint indexed tokenId, uint minBid);

    function createAuction(address nft, uint tokenId, uint minBid) external {
        IERC721 token = IERC721(nft);
        require(token.ownerOf(tokenId) == msg.sender, "Not the owner!");
        require(!nftLocked[nft][tokenId], "NFT already in auction");

        token.transferFrom(msg.sender, address(this), tokenId);
        nftLocked[nft][tokenId] = true;

        auctions[nft][tokenId] = Auction({
            seller: msg.sender,
            minBid: minBid,
            highestBidder: address(0),
            highestBid: 0,
            isActive: true
        });

        emit auctionCreated(nft, tokenId, minBid);
    }

    function placeBid(address nft, uint tokenId) external payable {
        Auction storage auction = auctions[nft][tokenId];
        require(auction.isActive, "Auction invalid!");
        require(msg.value > auction.highestBid && msg.value >= auction.minBid, "Bid to low!");

        if(auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
    }
}
