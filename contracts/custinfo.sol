pragma solidity ^0.5.0;

contract custinfo {
    
    address admin; 
    
    struct Customer{
        uint id;
        string name;
        uint dateOfBirth;
        uint social;
        uint status;
        //string data_hash;  //unique
       // uint8 userRating;
    }
    
    uint active = 1;
    uint pending = 2;
    uint deleted = 3;
    mapping (uint => Customer) customers;
    uint public count = 0;
    
    address public owner;
    address [] public users;
    
    function ACLContract() public {
        owner = msg.sender;
        users.push(owner);
    }
    
    function addUser(address user) public {
        require (msg.sender != owner,"You are not the owner!");
        users.push(user);
    }
    
        function getIthUser(uint i) public returns (address) {
        return users[i];
    }
    
    function getUserCount() public returns (uint) {
        return users.length;
    }
    
    function deleteUser(address user) public {
        require (msg.sender != owner,"You are not the owner!");
        for (uint8 i = 0; i < users.length; i++) {
            if (users[i] == user) {
                delete users[i];
            }
        }
    }
    
    function isUser(address candidate, string memory method) public returns (bool) {
        for (uint8 i = 0; i < users.length; i++) {
            if (users[i] == candidate) {
        emit LogAccess(candidate, now, method, "successful access");
                return true;
            }
        }
        emit LogAccess(candidate, now, method, "failed access");
        return false;
    }
    
    function isOwner() public returns (bool) {
        if (msg.sender != owner) return false;
        else return true;
    }
    
    event LogAccess(address indexed by, uint indexed accessTime, string method, string desc);
    
    function createCustomer(uint id, string memory name, uint dateOfBirth, uint social) public {
        if (isUser(msg.sender, "createCustomer")) {
            customers[count] = Customer(id, name, dateOfBirth, social, pending);
            count++;
        }
       // else require;
    }
    
    function getCustomer(uint index) public
    returns (uint id, string memory name, uint dateOfBirth, uint social, uint status){
        id = customers[index].id;
        name = customers[index].name;
        dateOfBirth = customers[index].dateOfBirth;
        social = customers[index].social;
        status = customers[index].status;
    }

    function getCustomerById(uint id) public
    returns (uint idRet, string memory name, uint dateOfBirth, uint social, uint status)
    {
        for (uint8 i=0; i<count; i++)
        {
            if (customers[i].id == id) {
                idRet = customers[i].id;
                name = customers[i].name;
                dateOfBirth = customers[i].dateOfBirth;
                social = customers[i].social;
                status = customers[i].status;
                return;
            }
        }
    }

    function updateCustomer(uint index, string memory name) public {
        if (isUser(msg.sender, "updateCustomer")) {
            require (index > count);
            customers[index].name = name;
        }
      //  else require;
    }

    function updateCustomerStatus(uint index, uint status) public {
        if (isUser(msg.sender, "updateCustomer")) {
            require (index > count);
            customers[index].status = status;
        }
        //else require;
    }
    
       // modifier to check the existence of userName
    modifier isUsernameExists(string memory _userName) {
        require(stringsEquals(customers[_userName].name, _userName), "t");
        _;
    }

    function getCustomerRating(string memory _userName) isUsernameExists(_userName) public view returns(uint8) {
               return customers[_userName].userRating;
    }
    
    // only admin has the privilege to add customer
     modifier onlyAdmin() {
        require( admin == msg.sender ,"The admin can only add/remove the Bank");
        _;
    }
    function stringsEquals(string storage _a, string memory _b) internal view returns (bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b); 
        if (a.length != b.length)
            return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
        {
            if (a[i] != b[i])
                return false;
        }
        return true;
    }
}
  