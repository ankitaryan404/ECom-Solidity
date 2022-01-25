// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract Product{

    enum Status{
        Activate,
        Deactivate
    }

    struct ProductDetails{
        string name;
        uint totalAvail;
        uint price;
        Status status;
    }

    struct OrderDetails{
        string name;
        uint orderQuantity;
        uint price;
        uint time;
    }

    mapping(uint=>ProductDetails) products;

    mapping(address=>OrderDetails) orders;

    address owner;
    address parentContract;
    bytes32 categoryHash;
    uint productCount;
    uint sellCount;
    uint balance;

    modifier onlyOwner{
        require(owner==msg.sender,"Only Owner is Allowed");
        _;
    }

    constructor(address _owner,address _parentContract,bytes32 _categoryHash){
        owner=_owner;
        parentContract=_parentContract;
        categoryHash=_categoryHash;
    }

    function addProduct(string memory _name,uint _price,uint _quantity) external onlyOwner{
        productCount++;
        products[productCount].name=_name;
        products[productCount].totalAvail=_quantity;
        products[productCount].price=_price;
        products[productCount].status=Status.Activate;
    }

    function purchaseProduct(uint _id,uint _quantity) external payable{
        require(products[_id].totalAvail>=_quantity ,"Not Enougth Products left");
        uint totalAmt = products[_id].price*_quantity;
        require(msg.value==totalAmt,"Pay exact amount");
        balance +=msg.value;
        products[_id].totalAvail -=_quantity;
        OrderDetails memory order = OrderDetails(products[_id].name,_quantity,msg.value,block.timestamp);
        orders[msg.sender] = order;
        (bool success,)=parentContract.call(abi.encodeWithSignature("addBalance(uint)",balance));
        require(success); 
        payable(owner).transfer(address(this).balance);
    }

    

    function getBalance() external view onlyOwner returns(uint){
        return balance;
    }

    function orderSummary()external view returns(OrderDetails[] memory){
        
    }

}

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
