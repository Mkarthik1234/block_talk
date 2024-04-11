import 'package:flutter/material.dart';
import 'package:block_talk_v3/Blockchain/connect.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'dart:convert';

class TransactionPage extends StatefulWidget {

  String toAddress;
  TransactionPage({super.key, required this.toAddress});

  @override
  State<TransactionPage> createState() => _TransactionPage2State();
}

class _TransactionPage2State extends State<TransactionPage> {
  TextEditingController _controller = TextEditingController();
  String errorMessage= "";
  Connector h = Connector();
  BigInt accountBalance = BigInt.from(0);
  String UserEntry = "";
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialise();
  }
  
  initialise()async {
    var res = await h.getBalance();
    setState((){
      print(res);
      accountBalance = res;
      _controller.text = "";
      errorMessage = "";
    });
  }

  Future<void> CheckSent(BuildContext context) async {
    Contract? contract;
    final abistringfile = await DefaultAssetBundle.of(context)
        .loadString("build/contracts/Chat.json");
    final abijson = jsonDecode(abistringfile);
    final abi = jsonEncode(abijson["abi"]);

    const contractAddress = "0xbD58270A35A26092602027946ACC1d4b875456b5";
    print("Contract address is $contractAddress");
    if (mounted) {
      if (provider != null) {
        try {
          contract = Contract(contractAddress, abi, provider!.getSigner());
          final filter = contract!.getFilter('PaymentComplete');
          contract!.on(filter, (event,dynamic to,dynamic value,dynamic from) {
            print(to.toString());
            print(value.toString());
            print(UserEntry);
            print((BigInt.from(double.parse(value)) / BigInt.from(10).pow(18)));
            if(BigInt.from(double.parse(UserEntry)) == BigInt.from(BigInt.from(double.parse(value)) / BigInt.from(10).pow(18)) && widget.toAddress == to.toString()) {
              print("inside if in transaction ");
              initialise();
            }
          });
          print("Listening for 'PaymentComplete' event...");
        } on Exception catch (error) {
          print("Error creating contract or listening for event: $error");
        }
      } else {
        print("Provider is not yet available");
      }
    }
  }

  void validateInput() async {
    String inputValue = _controller.text.trim();
    if (inputValue.isEmpty) {
      setState(() {
        errorMessage = "Please enter a number";
      });
    } else if (!RegExp(r'^\d*\.?\d+$').hasMatch(inputValue)) {
      setState(() {
        errorMessage = "Please enter valid number";
      });
    }
    else if(BigInt.from(double.parse(_controller.text))>accountBalance){
      setState(() {
        errorMessage = "Insufficient balance";
      });
    }
    else {
      UserEntry=_controller.text;
      // Do something with the valid number
      print('Valid input: $inputValue');

      await h.transfer_ethers(context,widget.toAddress,double.parse(inputValue));

      var v = await h.getcontract(context, "getTransactionHistory", []);
      print("value regarding transaction history is $v");
      print("transaction successfull");
      await CheckSent(context);
      initialise();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5.0,
      child: Container(
        height: 300,
        width: 500,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.black12,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("Images/Ether_image.png",width: 60,height: 60,),
                SizedBox(width: 10,),
                Text(accountBalance.toString(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                SizedBox(width: 5,),
                const Text("Eth",style: TextStyle(fontWeight: FontWeight.bold),)
              ],
            ),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter value to transfer',
                errorText: errorMessage,
                errorStyle: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: validateInput, child: const Text("SEND")),
              ],
            ),
          ],
        ),
      ),
    );
    //
    // return Dialog(
    //     child: AlertDialog(
    //         title: Text('Enter Transaction Amount'),
    //         content: TextField(
    //           controller: _controller,
    //           keyboardType: TextInputType.number,
    //           decoration: InputDecoration(hintText: 'Enter Transaction Amount'),
    //         ),
    //         actions: [
    //           TextButton(
    //             onPressed: () => Navigator.pop(context),
    //             child: Text('Cancel'),
    //           ),
    //           TextButton(
    //             onPressed: () {
    //               // Handle transaction logic here (e.g., update balance)
    //               // double amount = double.tryParse(_amountController.text) ?? 0.0;
    //               // if (amount > 0 && balance >= amount) {
    //               //   setState(() {
    //               //     balance -= amount;
    //               //   });
    //               // } else {
    //               //   // Show error message for invalid or insufficient funds
    //               //   ScaffoldMessenger.of(context).showSnackBar(
    //               //     SnackBar(
    //               //       content: Text('Invalid amount or insufficient funds'),
    //               //     ),
    //               //   );
    //               // }
    //               _controller.text = ''; // Clear input after submit
    //               Navigator.pop(context);
    //             },
    //             child: Text('Send'),
    //           ),
    //         ],
    //       )
    //   );

  }
}


//
// class TransactionPage2 extends StatefulWidget {
//   @override
//   _TransactionPageState createState() => _TransactionPageState();
// }
//
// class _TransactionPageState extends State<TransactionPage> {
//   double balance = 100.0; // Initial balance
//   final TextEditingController _amountController = TextEditingController();
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Transaction'),
//         backgroundColor: Colors.blue, // Add some color
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Display balance with a larger font and color
//             Text(
//               'Balance: \$' + balance.toStringAsFixed(2),
//               style: TextStyle(fontSize: 32.0, color: Colors.green),
//             ),
//             SizedBox(height: 20.0),
//             // Textfield with rounded corners and border
//             TextField(
//               controller: _amountController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 hintText: 'Enter Amount',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.0),
//             // ElevatedButton with a custom color and rounded corners
//             ElevatedButton(
//               onPressed: _showDialog,
//               child: Text('Send Money'),
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.blue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }