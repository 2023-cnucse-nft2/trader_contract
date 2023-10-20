// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/MintMembership.sol";

contract SaleMembership {
    MintMembership public saleMembershipAddress;

    constructor (address _saleMembershipAddress){
        saleMembershipAddress = MintMembership(_saleMembershipAddress);
    }
    
    mapping(uint256 => uint256) public membershipPrices;
    mapping(uint256 => bool) public isBid;
    mapping(uint256 => address) public bidAddress;

    uint256[] public onSaleMembershipArray;

    function setForSaleMembership(uint256 _membershipId, uint256 _price) public payable {

        address membershipOwner = saleMembershipAddress.ownerOf(_membershipId);
        

        require(membershipOwner == msg.sender, "Caller is not membership owner.");
        require(_price > 0, "Price is zero or lower.");
        require(membershipPrices[_membershipId] == 0, "Membership is already on sale.");
        // saleMembershipAddress.setApprovalForAll(address(this), true);
        require(saleMembershipAddress.isApprovedForAll(membershipOwner, address(this)), "Membership owner did not approve this.");

        membershipPrices[_membershipId] = _price;
        isBid[_membershipId] = false;

        onSaleMembershipArray.push(_membershipId);
    }

    function bidMembership(uint256 _membershipId) public payable {
        uint256 price = membershipPrices[_membershipId];
        address membershipOwner = saleMembershipAddress.ownerOf(_membershipId);

        require(price > 0, "Membership is not sale.");
        require(price <= msg.value, "Caller sent lower than price.");
        require(membershipOwner != msg.sender, "Caller is Membership owner.");
        require(!isBid[_membershipId], "Membership is already Bided.");

        // payable(address(this)).transfer(msg.value);
        isBid[_membershipId] = true;
        bidAddress[_membershipId] = msg.sender;
    }

    function approveTrade(uint256 _membershipId) public payable {
        address membershipOwner = saleMembershipAddress.ownerOf(_membershipId);

        payable(membershipOwner).transfer(msg.value);
        saleMembershipAddress.safeTransferFrom(membershipOwner, msg.sender, _membershipId);

        membershipPrices[_membershipId] = 0;
        for(uint256 i = 0; i<onSaleMembershipArray.length; i++){
            if(membershipPrices[onSaleMembershipArray[i]] == 0){
                onSaleMembershipArray[i] = onSaleMembershipArray[onSaleMembershipArray.length - 1];
                onSaleMembershipArray.pop();
            }
        }
    }
    
    function denyTrade(uint256 _membershipId) public payable {
        address bidedAddress = bidAddress[_membershipId];
        uint256 price = membershipPrices[_membershipId];

        // 판매자만 승인되도록 제한 필요
        require(saleMembershipAddress.owner() == msg.sender, "Caller is not mint this.");
        require(isBid[_membershipId], "Membership is not Bided.");

        payable(bidedAddress).transfer(price);
        bidAddress[_membershipId] = address(0);
        isBid[_membershipId] = false;
    }

    function cancelSale(uint256 _membershipId) public payable {
        address membershipOwner = saleMembershipAddress.ownerOf(_membershipId);
    
        require(membershipOwner == msg.sender, "Caller is not Membership owner.");

        if (isBid[_membershipId]){
            address bidedAddress = bidAddress[_membershipId];
            uint256 price = membershipPrices[_membershipId];

            payable(bidedAddress).transfer(price);
            bidAddress[_membershipId] = address(0);
            isBid[_membershipId] = false;
        }

        membershipPrices[_membershipId] = 0;
        for(uint256 i = 0; i<onSaleMembershipArray.length; i++){
            if(membershipPrices[onSaleMembershipArray[i]] == 0){
                onSaleMembershipArray[i] = onSaleMembershipArray[onSaleMembershipArray.length - 1];
                onSaleMembershipArray.pop();
            }
        }
    }

    function cancelBid(uint256 _membershipId) public payable {
        address bidedAddress = bidAddress[_membershipId];
        uint256 price = membershipPrices[_membershipId];

        require(bidedAddress == msg.sender, "Caller is not Bider.");
        require(isBid[_membershipId], "Membership is not Bided.");

        payable(bidedAddress).transfer(price);
        bidAddress[_membershipId] = address(0);
        isBid[_membershipId] = false;
    }
    
    function getOnSaleArray() view public returns (uint256 [] memory){
        return onSaleMembershipArray;
    }
    
}