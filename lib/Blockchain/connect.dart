import 'package:flutter/material.dart';
import 'package:block_talk_v3/main.dart';
import 'dart:convert';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Connector {
  static const operatingChain = 1;

  String? currentAddress;
  int currentChain = -1;
  BigInt currentBalance = BigInt.zero;
  String contract_add = "";
  String abi = '';

  Contract? contract;

  bool get isEnabled => ethereum != null;
  bool get isInOperatingChain => currentChain == operatingChain;
  bool get isConnected => isEnabled && currentAddress != null;

  Web3Provider? get provider =>
      Ethereum.isSupported ? Web3Provider(Ethereum.provider) : null;

  connect() async {
    if (isEnabled) {
      final accs = await ethereum!.requestAccount();
      if (accs.isNotEmpty) {
        currentAddress = accs[0];
        final pref = await SharedPreferences.getInstance();
        await pref.setString("current_user_address", accs[0]);
      }
      currentChain = await ethereum!.getChainId();
    }
  }

  Future<dynamic> getcontract(
      BuildContext context, String function_name, List<dynamic> arguments) async {
    final abistringfile = await DefaultAssetBundle.of(context)
        .loadString("build/contracts/Chat.json");
    final abijson = jsonDecode(abistringfile);
    abi = jsonEncode(abijson["abi"]);

    contract_add = "0xbD58270A35A26092602027946ACC1d4b875456b5";

    contract ??= Contract(contract_add, abi, provider!.getSigner());

    final val = await contract!.call(function_name, arguments);
    return val;
  }

  Future<void> checkuseradded(BuildContext context, String address) async {
    final abistringfile = await DefaultAssetBundle.of(context)
        .loadString("build/contracts/Chat.json");
    final abijson = jsonDecode(abistringfile);
    final abi = jsonEncode(abijson["abi"]);

    final contractAddress = "0xbD58270A35A26092602027946ACC1d4b875456b5";

    if (provider != null) {
      try {
        contract = Contract(contractAddress, abi, provider!.getSigner());
        final filter = contract!.getFilter('UserAdded');
        showCircularProgressIndicator(context); // Show circular progress indicator
        contract!.on(filter, (event, dynamic c) {
          print(
              "User Added: ${event.toString().toLowerCase()} and address is ${address.toLowerCase()}");
          if (event.toString().toLowerCase() == address.toLowerCase()) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          }
          hideCircularProgressIndicator(context); // Hide circular progress indicator once event is triggered
        });
        print("Listening for 'UserAdded' event...");
      } on Exception catch (error) {
        print("Error creating contract or listening for event: $error");
      }
    } else {
      print("Provider is not yet available");
    }
  }

  void showCircularProgressIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void hideCircularProgressIndicator(BuildContext context) {
    Navigator.of(context).pop();
  }

  transfer_ethers(BuildContext context, String toAddress, double value) async {
    final abistringfile = await DefaultAssetBundle.of(context)
        .loadString("build/contracts/Chat.json");
    final abijson = jsonDecode(abistringfile);
    final abi = jsonEncode(abijson["abi"]);

    final contractAddress = "0xbD58270A35A26092602027946ACC1d4b875456b5";

    var v = provider!.getSigner();

    contract ??= Contract(contractAddress, abi, v);
    print(BigInt.from((value * 1e18).toInt()));

    final ty = await contract!.send("transfer_Eth", [
      toAddress,
      BigInt.from((value * 1e18).toInt())
    ], TransactionOverride(
        value: BigInt.from((value * 1e18).toInt())));
    print(" value from blockchain00$ty");
  }

  Future<BigInt> getBalance() async {
    var res = await provider!.getSigner().getBalance();
    var result = res / BigInt.from(10).pow(18);
    return BigInt.from(result);
  }

  clear() {
    currentAddress = null;
    currentChain = -1;
  }

  void onAccountChanged(Function(String) callback) {
    ethereum!.onAccountsChanged((List<String> accounts) {
      if (accounts.isNotEmpty) {
        callback(accounts[0]);
      }
    });
  }

  init() {
    if (isEnabled) {
      ethereum!.onAccountsChanged((accs) {
        print("Account changed");
        clear();
      });
      ethereum!.onChainChanged((chain) {
        clear();
      });
    }
  }
}
