// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//Write a simple NFT market contract, using your own issued Token to buy and sell NFTs. The functions include:

// list(): Implement the listing function, where the NFT holder can set a price 
// (how many tokens are needed to purchase the NFT) and list the NFT on the NFT market.
// buyNFT(): Implement the purchase function for NFTs,
// where users transfer the specified token quantity and receive the corresponding NFT.
contract NFTmarket {

    struct listOfNFTs{
        uint256 price;
        address seller;
    }
    IERC20 tokenContract;
    IERC721 nftContract;

    // tokenId => ListOfNFTS
    mapping (uint256 => listOfNFTs)public listings;

    event Listed(uint256 indexed tokenId, address seller, uint256 price);
    event Bought(uint256 indexed tokenId, address buyer, address seller, uint256 price);

    address owner;
    constructor(address _tokenAdress, address _nftAdress){
        owner = msg.sender;
        tokenContract = IERC20(_tokenAdress);
        nftContract = IERC721(_nftAdress);
    }

    function list(uint256 tokenId, uint256 price)public {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You are not the owner");
        require(price>0, "price must be greater than 0");   
        listings[tokenId] = listOfNFTs(price, msg.sender);
        emit Listed(tokenId, msg.sender, price);
    }

    function buy(uint256 tokenId)public {
        listOfNFTs memory listing = listings[tokenId];
        require(listing.price>0, "this is not for sale");
        require(nftContract.ownerOf(tokenId) == listings[tokenId].seller, "already selled");
        tokenContract.transferFrom(msg.sender, listing.seller, listing.price);
        nftContract.transferFrom(listing.seller, msg.sender, tokenId);
        delete listings[tokenId];
        emit Bought(tokenId, msg.sender, listing.seller, listing.price);
    }

}