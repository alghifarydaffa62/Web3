// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "../src/Auction.sol";
import "../src/MyNFT.sol";

contract AuctionTest is Test {
    MyNFT public nft;
    NFTAuction public auction;

    address owner = address(1);
    address bidder1 = address(2);
    address bidderw = address(3);

    function setUp() public {
        vm.startPrank(owner);
        nft = new MyNFT();
        auction = new NFTAuction();
        nft.mintNFT(owner, "tokenURI_1");
        vm.stopPrank();
    }

    function testCreateAuction() public {
        vm.startPrank(owner);
        nft.approve(address(auction), 0);
        auction.createAuction(address(nft), 0, 1 ether);
        vm.stopPrank();
    }

    function testPlaceBid() public {
        testCreateAuction();

        vm.startPrank(owner);
        vm.deal(bidder1, 2 ether);
        auction.placeBid{value: 1.5 ether}(address(nft), 0);
        vm.stopPrank();
    }

    function testEndAuction() public {
        testPlaceBid();

        vm.startPrank(owner);
        auction.endAuction(address(nft), 0);
        vm.stopPrank();
    }

}

