// Author: Philippe Waelchli, 2022-01-07
// The NFT marketplace is a smart contract to not only create new NFTs but also to have the functionalty to
// exchange NFTs (buy and sell).

// The code is based on the articel below and has been adjusted accordingly to meet the requirements
// https://betterprogramming.pub/creating-an-nft-marketplace-solidity-2323abca6346

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    // We need unique IDs for each NFT; Counters.Counter manages the counts for us
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    // The default price the user has to pay to list a NFT on the marketplace
    uint256 listingPrice = 10 wei;   // reduced the listing price (prev: 0.00025 ether)

    // The contract deployer becomes the owner of it
    address payable owner;

    // idToMarketItem holds list of all NFTs which are listed to buy 
    mapping(uint256 => MarketItem) private idToMarketItem;
    
    // Details about a NFT, which has not be listed yet
    struct MarketItem {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    
    // Holds the information about a listed NFT
    event MarketItemCreated (
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // Constructor, exectuted when this smart contract is deployed on the chain
    constructor() ERC721("NFT-P", "NFT-P") {
        owner = payable(msg.sender);
    }

    // Set new listing price for sellers who want to sell a NFT
    function updateListingPrice(uint _listingPrice) public payable {
        require(owner == msg.sender, "Only marketplace owner can update listing price.");
        listingPrice = _listingPrice;
    }

    // Get current listing price
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // Find corresponding market item based on tokenId
    function getNftPrice(uint256 tokenId) public view returns (uint256) {
        uint totalItemCount = _tokenIds.current();
        require(tokenId <= totalItemCount, "Provided tokenId is larger then totalItemCount.");
        
        uint nftPrice = idToMarketItem[tokenId].price;
        return nftPrice;
    }

    // Create a new NFT
    function createToken(string memory tokenURI, uint256 price) public payable returns (uint) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        createMarketItem(newTokenId, price);
        return newTokenId;
    }

    // Sell an owned NFT on the marketplace and request user to pay listing fee
    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        idToMarketItem[tokenId] =  MarketItem(tokenId,payable(msg.sender),payable(address(this)),price,false);
        _transfer(msg.sender, address(this), tokenId);
        emit MarketItemCreated(tokenId,msg.sender,address(this),price,false);
    }

    // Resell a token that has been previously bought on the marketplace
    function resellToken(uint256 tokenId, uint256 price) public payable {
        require(idToMarketItem[tokenId].owner == msg.sender, "Only item owner can perform this operation");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        idToMarketItem[tokenId].sold = false;
        idToMarketItem[tokenId].price = price;
        idToMarketItem[tokenId].seller = payable(msg.sender);
        idToMarketItem[tokenId].owner = payable(address(this));
        _itemsSold.decrement();
        _transfer(msg.sender, address(this), tokenId);
    }

    // Buy a listed NFT from the marketplace
    function createMarketSale(uint256 tokenId) public payable {
        uint price = idToMarketItem[tokenId].price;
        address payable creator = idToMarketItem[tokenId].seller;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");
        idToMarketItem[tokenId].owner = payable(msg.sender);
        idToMarketItem[tokenId].sold = true;
        idToMarketItem[tokenId].seller = payable(address(0));
        _itemsSold.increment();
        _transfer(address(this), msg.sender, tokenId);
        payable(owner).transfer(listingPrice);
        payable(creator).transfer(msg.value);
    }

    // List all NFTs that have been created by this smart contract
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _tokenIds.current();
        uint unsoldItemCount = _tokenIds.current() - _itemsSold.current();
        uint currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint i = 0; i < itemCount; i++) {
            if (idToMarketItem[i + 1].owner == address(this)) {
            uint currentId = i + 1;
            MarketItem storage currentItem = idToMarketItem[currentId];
            items[currentIndex] = currentItem;
            currentIndex += 1;
            }
        }
        return items;
    }

    // list user's owned NFTs
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalItemCount; i++) {
            // check if nft is mine
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
            for (uint i = 0; i < totalItemCount; i++) {
                if (idToMarketItem[i + 1].owner == msg.sender) {
                    uint currentId = i + 1;
                    MarketItem storage currentItem = idToMarketItem[currentId];
                    items[currentIndex] = currentItem;
                    currentIndex += 1;
                }
            }
        return items;
    }

    // List all listed items in the marketplace
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint totalItemCount = _tokenIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint currentId = i + 1;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}