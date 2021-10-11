// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import 'hardhat/console.sol';


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


// inherit from pausable so that we can pause in case anything goes wrong?
contract NFTShopify is ERC721, Ownable {
    bool public isSaleStarted = false; 
    string public baseURI; 
    uint256 public constant maxSupply = 100;  
    uint256 public price = 0.1 ether;
    string contractURIAddress;

    using Counters for Counters.Counter; 
    Counters.Counter public tokenCount; // default value is 0. public so that we can see how many have been minted



    event Minted(address to, uint256 tokenId);
    event SaleStarted();
    event SaleStopped();



    constructor(string memory _newBaseURI, string memory _contractURI) ERC721('ehya', 'EHY') {
        // set the base uri to be the api endpoint that returns the json of token metadata. baseURI/tokenID -> {image: 'ipfs/someHash'}
        // initialise the contract metadata here also. 
        setBaseURI(_newBaseURI); 
        setContractURI(_contractURI);
    }



    // for listing on opensea. getter function for contractURIAddress
    function contractURI() public view returns (string memory) {
        return contractURIAddress;
    }

    function setContractURI(string memory _contractURI) public onlyOwner {
        contractURIAddress = _contractURI;
    }

    // impt as it feeds the baseURI to tokenURI()
    function _baseURI() internal view virtual override returns (string memory){
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    // sale contract functions
    function startSale() public onlyOwner {
        require(!isSaleStarted, 'Sale has already started');
        isSaleStarted = true;
        emit SaleStarted();
    }

    function stopSale() public onlyOwner {
        require(isSaleStarted, 'Sale has not started yet');
        isSaleStarted = false;
        emit SaleStopped();
    }



    // send all the remaining funds to the owner, if any (backup function)
    function returnFunds() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function mint() payable public {
        require(isSaleStarted, 'Sale has not started');
        require(tokenCount.current() < maxSupply, 'Exceeded max mint');
        require(msg.value == price, 'Invalid value');

        payable(owner()).transfer(msg.value);

        tokenCount.increment();
        uint256 tokenId = tokenCount.current();
        _safeMint(_msgSender(), tokenId);

        emit Minted(msg.sender, tokenId);
    }
}