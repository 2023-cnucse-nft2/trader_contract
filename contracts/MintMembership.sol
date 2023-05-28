// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MintMembership is ERC721Enumerable, Ownable {
    constructor() ERC721("Membership", "MS") {}

    mapping(uint256 => address) lastOwner;
    mapping(uint256 => uint256) lastPrice;
    mapping(uint256 => uint256) price;

    function mintMembership(uint256 _price, address _purchaser) public payable{
        uint256 membershipId = totalSupply() + 1;

        lastOwner[membershipId] = _purchaser;
        lastPrice[membershipId] = _price;
        price[membershipId] = _price;
        
        payable(Ownable.owner()).transfer(msg.value);

        _mint(_purchaser, membershipId);
        
    }

}