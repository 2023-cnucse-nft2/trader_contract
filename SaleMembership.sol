// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "MintMembership.sol";

contract SaleMembership {
    MintMembership public mintMembershipAddress;
    
    constructor (address _mintMembershipAddress){
        mintMembershipAddress = MintMembership(_mintMembershipAddress);
    }

    mapping(uint256 => uint256) public membershipPrices;

    uint256[] public onSaleMembershipArray;

    function setForSaleMembership(uint256 _membershipId, uint256 _price) public {
        address membershipOwner = mintMembershipAddress.ownerOf(_membershipId);

        require(membershipOwner == msg.sender, "Caller is not membership owner.");
        require(_price > 0, "Price is zero or lower.");
        require(membershipPrices[_membershipId] == 0, "Membership is already on sale.");
        require(mintMembershipAddress.isApprovedForAll(membershipOwner, address(this)), "Membership owner did not approve this.");

        membershipPrices[_membershipId] = _price;

        onSaleMembershipArray.push(_membershipId);
    }

    function purchaseMembership(uint256 _membershipId) public payable {
        uint256 price = membershipPrices[_membershipId];
        address membershipOwner = mintMembershipAddress.ownerOf(_membershipId);

        require(price > 0, "Membership is not sale.");
        require(price <= msg.value, "Caller sent lower than price.");
        require(membershipOwner != msg.sender, "Caller is Membership owner.");

        payable(membershipOwner).transfer(msg.value);
        mintMembershipAddress.safeTransferFrom(membershipOwner, msg.sender, _membershipId);

        membershipPrices[_membershipId] = 0;
        for(uint256 i = 0; i<onSaleMembershipArray.length; i++){
            if(membershipPrices[onSaleMembershipArray[i]] == 0){
                onSaleMembershipArray[i] = onSaleMembershipArray[onSaleMembershipArray.length - 1];
                onSaleMembershipArray.pop();
            }
        }
    }

    function getOnSaleMembershipArrayLength() view public returns (uint256){
        return onSaleMembershipArray.length;
    }
}