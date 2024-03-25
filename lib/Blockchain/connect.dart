// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_web3/flutter_web3.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:convert/convert.dart';
//
// class Homecontroller {
//   static const operatingChain = 1; //First we will define operating chain
//
//   String? currentAddress; //current address
//
//   int currentChain = -1;
//
//   BigInt currentBalance = BigInt.zero;
//
//   String? contractAddress;
//   String? abi;
//
//
//   // Homecontroller._();//private constructor
//   //
//   // static Future<Homecontroller> create(context)async{
//   //   final h = Homecontroller._();
//   //   print("inside create");
//   //   await h.Initialize(context);
//   //   print("create exicuted");
//   //   return h;
//   // }
//
//   Initialize(context) async{
//     //retrieve the abi and contract address
//     final abistringfile = await DefaultAssetBundle.of(context)
//         .loadString("build/contracts/main.json");
//     final abijson = jsonDecode(abistringfile);
//     abi = jsonEncode(abijson["abi"]);
//     contractAddress = abijson["networks"]["5777"]["address"].toString();
//
//     print("Initialize exicuted");
//   }
//
//
//   Contract? contract;
//
//   bool get isEnabled => ethereum != null; // check if web3 is enable
//
//   bool get isInOperatingChain =>
//       currentChain ==
//       operatingChain; //current chain which will allow you to chain in application
//
//   bool get isConnected => isEnabled && currentAddress != null;
//
//   Web3Provider? get provider =>
//       Ethereum.isSupported ? Web3Provider(Ethereum.provider) : null;
//
//
//   connect() async {
//     if (isEnabled) {
//       final accs = await ethereum!.requestAccount();
//       if (accs.isNotEmpty) {
//         currentAddress = accs[0];
//         print(currentAddress);
//         final pref = await SharedPreferences.getInstance();
//         await pref.setString("current_user_address", accs[0]);
//       }
//       currentChain = await ethereum!.getChainId();
//     }
//     print("connect exicuted");
//   }
//
//   // getaccountbalance() async{
//   //   print(provider!.getSigner().toString());
//   //   if(erc20 == null){
//   //     erc20 = ContractERC20("0x1d048968915422c6e9de071f3c8839eeff0b5b4c", provider!.getSigner());
//   //   }
//   //   currentBalance = await erc20!.balanceOf(currentAddress);
//   //   print(currentBalance);
//   //   update();
//   // }
//
//   // getcontract()async{
//   //   if(contract==null){
//   //     contract = Contract(contract_add, abi, provider!.getSigner());
//   //   }
//   //   var argu = [currentAddress];
//   //
//   //   await contract!.call("sendMessage",["0x9dD43c54967E68D05f7E49450b3e9092df6dfC27","Hello123","123"]);
//   //
//   //   final messages =await contract!.call("getMessage",["0x9dD43c54967E68D05f7E49450b3e9092df6dfC27"]);
//   //   print(messages);
//   // }
//
//   _getcontract() async {
//     contract ??= Contract(contractAddress!, abi, provider!.getSigner());
//     print("Get contract exicuted");
//   }
//
//   Future<dynamic> exicute(String functionName, List<dynamic> arguments,context) async {
//     final abistringfile = await DefaultAssetBundle.of(context)
//         .loadString("build/contracts/main.json");
//     final abijson = jsonDecode(abistringfile);
//     abi = jsonEncode(abijson["abi"]);
//     contractAddress = abijson["networks"]["5777"]["address"].toString();
//     print("inside exicute");
//     if(contract==null){
//       print("inside if");
//       contract = Contract(contractAddress!, abi, provider!.getSigner());
//     }
//     print("after if");
//     final result = await contract!.call(functionName, arguments);
//     print("after res");
//     return result;
//   }
//
//   clear() {
//     //clear address and chain
//     currentAddress = null;
//     currentChain = -1; //it will update listener
//   }
//
//   init() {
//     //initialize listener
//     if (isEnabled) {
//       ethereum!.onAccountsChanged((accs) {
//         //account change
//         connect();
//       });
//       ethereum!.onChainChanged((chain) {
//         clear(); //chain change
//       });
//     }
//   }
// }
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:block_talk_v3/main.dart';

class Connector{

  static const operatingChain = 1;                                        //First we will define operating chain

  String? currentAddress;                                             //current address

  int currentChain = -1;

  BigInt currentBalance = BigInt.zero;

  String contract_add = "";
  String abi = '''[
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "friend_key",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			}
		],
		"name": "addFriend",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "pubkey",
				"type": "address"
			}
		],
		"name": "checkUserExists",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			}
		],
		"name": "createAccount",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAllAppUser",
		"outputs": [
			{
				"components": [
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "address",
						"name": "accountAddress",
						"type": "address"
					}
				],
				"internalType": "struct Chat.AllUserStruct[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getMyFriendList",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "pubkey",
						"type": "address"
					},
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					}
				],
				"internalType": "struct Chat.friend[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "pubkey",
				"type": "address"
			}
		],
		"name": "getUsername",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "friend_key",
				"type": "address"
			}
		],
		"name": "readMessage",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "sender",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "timestamp",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "content",
						"type": "string"
					}
				],
				"internalType": "struct Chat.message[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "friend_key",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "_msg",
				"type": "string"
			}
		],
		"name": "sendMessage",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]''';
  Contract? contract;

  bool get isEnabled => ethereum != null;                                 // check if web3 is enable

  bool get isInOperatingChain => currentChain == operatingChain;          //current chain which will allow you to chain in application

  bool get isConnected => isEnabled && currentAddress!=null;

  Web3Provider? get provider =>Ethereum.isSupported?Web3Provider(Ethereum.provider):null;


  connect() async {//a function to connect to the wallet
    if (isEnabled){ //check if web3 is enabled
      final accs = await ethereum!.requestAccount();
      print(accs[0]);//we request address from the account
      if (accs.isNotEmpty){
        currentAddress = accs[0];//assign current address to first address
        final pref = await SharedPreferences.getInstance();
        await pref.setString("current_user_address", accs[0]);
      }
      currentChain = await ethereum!.getChainId();
    }
  }

  Future<dynamic> getcontract(BuildContext context,String function_name,List<String> arguments)async{
    final abistringfile = await DefaultAssetBundle.of(context).loadString("build/contracts/Chat.json");
    final abijson = jsonDecode(abistringfile);
    abi = jsonEncode(abijson["abi"]);

    contract_add = "0xFB1103A41509d54C37a3fFf6bf198EC3ff443859";

    print("Contract address is $contract_add");
    print("function name $function_name");
    print("argument is $arguments");

    contract ??= Contract(contract_add, abi, provider!.getSigner());

    final val = await contract!.call(function_name,arguments);
    print("Value from blockchain $val");
    return val;
  }

  Future<void> checkuseradded(BuildContext contex,String address) async {
    final abistringfile = await DefaultAssetBundle.of(contex).loadString("build/contracts/Chat.json");
    final abijson = jsonDecode(abistringfile);
    final abi = jsonEncode(abijson["abi"]);

    final contractAddress = "0x65a04E140de3247A0966Ddf4d9b113D3f01346Eb";
    print("Contract address is $contractAddress");


    if (provider != null) {
      try {
        contract = Contract(contractAddress, abi, provider!.getSigner());
        final filter = contract!.getFilter('UserAdded');
        contract!.on(filter, (event,dynamic c) {
          print("User Added: ${event.toString().toLowerCase()} and address is ${address.toLowerCase()}");
          if(event.toString().toLowerCase() == address.toLowerCase()){
            Navigator.push(
              contex,
              MaterialPageRoute(builder: (context) => MyApp()), // Replace MyApp with the desired page widget
            );
        }
        });
        print("Listening for 'UserAdded' event...");
      } on Exception catch (error) {
        print("Error creating contract or listening for event: $error");
      }
    } else {
      print("Provider is not yet available");
    }
  }


  clear() {                                                                //clear address and chain
    currentAddress = null;
    currentChain = -1; //it will update listener
  }

  init() {                                                                 //initialize listener
    if (isEnabled) {
      ethereum!.onAccountsChanged((accs) {                             //account change
        clear();
      });
      ethereum!.onChainChanged((chain) {
        clear();//chain change
      });
    }
  }
}

