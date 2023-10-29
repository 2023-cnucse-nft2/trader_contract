// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MintMembership is ERC721Enumerable, Ownable {
    constructor() ERC721("Membership", "MS") {}

    mapping(uint256 => address) public lastOwner;
    mapping(uint256 => uint256[]) public price;
    mapping(uint256 => string) public name;

    function mintMembership(string memory _name, uint256 _price, address _purchaser) public payable{
        require(owner() == msg.sender, "Not Allowed.");
        uint256 membershipId = totalSupply();

        lastOwner[membershipId] = _purchaser;
        price[membershipId] = [_price];
        name[membershipId] = _name;
        
        payable(Ownable.owner()).transfer(msg.value);

        _mint(_purchaser, membershipId);
        
    }

    function getLastOwner() view public returns (address[] memory){
        uint256 totalSupplyCount = totalSupply();
        address[] memory owners = new address[](totalSupplyCount);

        for (uint256 i = 0; i < totalSupplyCount; i++) {
            owners[i] = lastOwner[i];
        }

        return owners;
    }

    function setLastOwner(uint256 _membershipId, address _lastOwner) public {
        lastOwner[_membershipId] = _lastOwner;
    }

    function getNames() view public returns (string[] memory){
        uint256 totalSupplyCount = totalSupply();
        string[] memory names = new string[](totalSupplyCount);

        for (uint256 i = 0; i < totalSupplyCount; i++) {
            names[i] = name[i];
        }

        return names;
    }

    function getPrice() view public returns (uint256[][] memory){
        uint256 totalSupplyCount = totalSupply();
        uint256[][] memory prices = new uint256[][](totalSupplyCount);

        for (uint256 i = 0; i < totalSupplyCount; i++) {
            prices[i] = price[i];
        }

        return prices;
    }

    function setPrice(uint256 _membershipId, uint256 _price) public {
        price[_membershipId].push(_price);
    }
}