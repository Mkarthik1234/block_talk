// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.22 <0.9.0;


contract Chat {
    struct user {
        string name;
        friend[] friendList;
        transaction[] transactionList;
    }

    struct transaction{
        string method;
        uint value;
        uint timestamp;
    }

    struct friend {
        address pubkey;
        string name;
    }

    struct message {
        address sender;
        uint timestamp;
        string content;
    }

    struct AllUserStruct {
        string name;
        address accountAddress;
    }

    AllUserStruct[] getAllUsers;

    mapping(address => user) userList;
    mapping(bytes32 => message[]) allMessages;


    event UserAdded(address user_address);
    event MessageSent(string message);
    event FriendAdded(address friend_address);
    event PaymentComplete(address from,address to,string value);


    function checkUserExists(address pubkey) public view returns (bool){
        return bytes(userList[pubkey].name).length > 0;
    }

    function createAccount(string calldata name) external {
        require(checkUserExists(msg.sender) == false, "User already exists");
        require(bytes(name).length > 0, "Username cannot be empty");

        userList[msg.sender].name = name;
        getAllUsers.push(AllUserStruct(name, msg.sender));
        emit UserAdded(msg.sender);
    }

    function getUsername(address pubkey) external view returns (string memory){
        require(checkUserExists(pubkey), "user is not registered");
        return userList[pubkey].name;
    }

    function addFriend(address friend_key, string memory name) internal {
        require(checkUserExists(msg.sender), "Create account first");
        require(checkUserExists(friend_key), "user is not registered");
        require(msg.sender != friend_key, "User cannot add themselves");
        require(checkAlreadyFriends(msg.sender, friend_key) == false, "These users are already friends");

        _addFriend(msg.sender, friend_key, name);
        _addFriend(friend_key, msg.sender, userList[msg.sender].name);
        emit FriendAdded(friend_key);
    }

    function checkAlreadyFriends(address pubkey1, address pubkey2) internal view returns (bool){
        if (userList[pubkey1].friendList.length > userList[pubkey2].friendList.length) {
            address tmp = pubkey1;
            pubkey1 = pubkey2;
            pubkey2 = tmp;
        }
        for (uint256 i = 0; i < userList[pubkey1].friendList.length; i++) {
            if (userList[pubkey1].friendList[i].pubkey == pubkey2) return true;
        }
        return false;
    }

    function getTransactionHistory()external view returns (transaction[] memory){
      return userList[msg.sender].transactionList;
    }

    function _addFriend(address me, address friend_key, string memory name) internal {
        friend memory newFriend = friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }

    function getMyFriendList() external view returns (friend[] memory){
        return userList[msg.sender].friendList;
    }

    function _getChatCode(address pubkey1, address pubkey2) internal pure returns (bytes32){
        if (pubkey1 < pubkey2) {
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        }
        else return keccak256(abi.encodePacked(pubkey2, pubkey1));
    }

    function sendMessage(address friend_key, string calldata _msg) external {
        require(checkUserExists(msg.sender), "user is not registered");
        require(checkUserExists(friend_key), "user is not registered");
        //require(checkAlreadyFriends(msg.sender,friend_key),"You are not friend with given user");

        if (!checkAlreadyFriends(msg.sender, friend_key)) {
            addFriend(friend_key, userList[friend_key].name);
        }

        bytes32 chatcode = _getChatCode(msg.sender, friend_key);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);
        allMessages[chatcode].push(newMsg);
        emit MessageSent(_msg);
    }

//    function Uint2str(uint _i) internal pure returns (string memory _uintAsString) {
//        if (_i == 0) {
//            return "0";
//        }
//        uint j = _i;
//        uint len;
//        while (j != 0) {
//            len++;
//            j /= 10;
//        }
//        bytes memory bstr = new bytes(len);
//        uint k = len;
//        while (_i != 0) {
//            k = k-1;
//            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
//            bytes1 b1 = bytes1(temp);
//            bstr[k] = b1;
//            _i /= 10;
//        }
//        return string(bstr);
//    }

    function transfer_Eth(address friend_key, uint amount)public payable{
        require(address(this).balance >= amount, "Contract has insufficient balance");
        address payable wallet = address(uint160(friend_key));
        wallet.transfer(amount);
        transaction memory from = transaction("Sent", amount,block.timestamp);
        transaction memory to = transaction("Recieved", amount,block.timestamp);
        userList[msg.sender].transactionList.push(from);
        userList[friend_key].transactionList.push(to);
        emit PaymentComplete(msg.sender,friend_key,amount);
    }


    function readMessage(address friend_key) external view returns (message[] memory){
        bytes32 chatcode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatcode];
    }

    function getAllAppUser() public view returns (AllUserStruct[] memory){
        return getAllUsers;
    }

}