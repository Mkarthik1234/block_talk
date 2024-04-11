import 'package:flutter/material.dart';
import 'package:block_talk_v3/Blockchain/connect.dart';

import 'package:intl/intl.dart';
class Transaction {
  final String method;
  final double value;
  final String dateTime;

  Transaction(this.method, this.value, this.dateTime);
}

// List<Transaction> exampleTransactions = [
//   Transaction('Send', 10.0, DateTime.now().subtract(Duration(days: 2))),
//   Transaction('Receive', 20.0, DateTime.now().subtract(Duration(days: 1))),
//   Transaction('Send', 15.0, DateTime.now()),
//   Transaction('Receive', 25.0, DateTime.now()),
//   Transaction('Send', 10.0, DateTime.now().subtract(Duration(days: 3))),
//   Transaction('Receive', 20.0, DateTime.now().subtract(Duration(days: 2))),
//   Transaction('Send', 15.0, DateTime.now().subtract(Duration(days: 1))),
//   Transaction('Receive', 25.0, DateTime.now().subtract(Duration(days: 1))),
//   Transaction('Send', 10.0, DateTime.now().subtract(Duration(days: 4))),
//   Transaction('Receive', 20.0, DateTime.now().subtract(Duration(days: 3))),
//   Transaction('Send', 15.0, DateTime.now().subtract(Duration(days: 2))),
//   Transaction('Receive', 25.0, DateTime.now().subtract(Duration(days: 2))),
//   Transaction('Send', 10.0, DateTime.now().subtract(Duration(days: 4))),
//   Transaction('Receive', 20.0, DateTime.now().subtract(Duration(days: 3))),
//   Transaction('Send', 15.0, DateTime.now().subtract(Duration(days: 2))),
//   Transaction('Receive', 25.0, DateTime.now().subtract(Duration(days: 2))),
//   Transaction('Send', 10.0, DateTime.now().subtract(Duration(days: 4))),
//   Transaction('Receive', 20.0, DateTime.now().subtract(Duration(days: 3))),
//   Transaction('Send', 15.0, DateTime.now().subtract(Duration(days: 2))),
//   Transaction('Receive', 25.0, DateTime.now().subtract(Duration(days: 2))),
// ];

class TransactionHistoryDialog extends StatefulWidget {
  @override
  State<TransactionHistoryDialog> createState() => _TransactionHistoryDialogState();
}

class _TransactionHistoryDialogState extends State<TransactionHistoryDialog> {
  Connector h = Connector();
  List<Transaction> TransactionHistory = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTransactions();
  }

  fetchTransactions() async {
    var result = await h.getcontract(context, "getTransactionHistory", []);
    List<Transaction> T = [];
    for (List<dynamic> item in result) {


      String method = item[0].toString(); // Transaction method
      double value = double.parse(item[1].toString()); // Transaction value
      int timestamp = int.parse(item[2].toString()); // Unix timestamp
      var v = BigInt.from(value) / BigInt.from(10).pow(18);
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      String formattedTime = DateFormat('MMM d, yyyy h:mm a').format(dateTime);
      T.add(Transaction(method, v, formattedTime));
    }
    setState(() {
      TransactionHistory = T;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Text(
              'Transaction History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            TransactionHistory.isNotEmpty ?  Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  children: TransactionHistory.map((transaction) {
                    return _TransactionBox(transaction: transaction);
                  }).toList(),
                ),
              ),
            ):Center(
              child: Text("No Transactions yet", style: TextStyle(color: Colors.black),),
            )
          ],
        ),
      )
    );
  }
}

class _TransactionBox extends StatelessWidget {
  final Transaction transaction;

  _TransactionBox({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "Images/Ether_icon.jpg",
                width: 20,
                height: 20,
              ),
              SizedBox(width: 10),
              Text(
                transaction.value.toString(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(width: 5),
              Text(
                "Eth",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            transaction.method,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          SizedBox(height: 5),
          Text(
            'Date & Time: ${transaction.dateTime}',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
