// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MintMembership is ERC721Enumerable {
    constructor() ERC721("Membership", "MS") {}

    mapping(uint256 => uint256) public membershipTypes;

    function mintMembership() public {
        uint256 membershipId = totalSupply() + 1;

        

        _mint(msg.sender, membershipId);
        
    }

}