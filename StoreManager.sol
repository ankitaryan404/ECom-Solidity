// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./ProductManager.sol";

contract ItemStore{

    enum State{
        Activated,
        Deactivated
    }

    struct Category{
        string name;
        Product productAddress;
        State state;

    }

    mapping(bytes32=>Category) hashToCategory;
    mapping(uint=>bytes32) categories;
    uint categoryCount;
    address owner;
    uint balance;

    modifier onlyOwner{
        require(msg.sender==owner,"Only Owner is Allowed");
        _;
    }

    constructor(){
        owner=msg.sender;
    }

    function addCategory(string memory _name)external onlyOwner{
        bytes32 hash = keccak256(abi.encodePacked(_name,msg.sender));
        categoryCount++;
        categories[categoryCount]=hash;
        hashToCategory[hash].name=_name;
        hashToCategory[hash].productAddress=new Product(owner,address(this),hash);
        hashToCategory[hash].state = State.Activated;
    }

    function getCategoryHash(uint _id) external view returns(bytes32){
        return categories[_id];
    }

    function getCategoryByHash(bytes32 _hash) external view returns(Product,string memory){
        return(hashToCategory[_hash].productAddress,hashToCategory[_hash].name);
    }

    function addBalance(uint _amt) external{
        balance+=_amt;
    }

}
