// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

abstract contract MyNFT is ERC721URIStorage, Ownable {
    uint private _nextTokenId;

    constructor() ERC721("MyNFT", "MNFT") {}

    function mintNFT(address to, string memory tokenURI) external onlyOwner {
        uint256 tokenId = _nextTokenId;
        _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
    }
}