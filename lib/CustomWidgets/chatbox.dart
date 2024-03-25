import 'dart:async';
import 'package:block_talk_v3/theme.dart';
import 'package:flutter/material.dart';
import 'package:block_talk_v3/Blockchain/connect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:block_talk_v3/Modals/Message.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String contactName, contactAddress;

  const ChatPage(
      {Key? key, required this.contactName, required this.contactAddress})
      : super(key: key);

  @override
  _ChatPageState createState() =>
      _ChatPageState(contactAddress: contactAddress, contactName: contactName);
}

class _ChatPageState extends State<ChatPage> {
  bool isSender = false;
  String contactAddress, contactName;
  String recentmessage="";
  late String current_user;
  List<Message> messages = []; // a list of messages
  final TextEditingController _textController =
      TextEditingController(); // a controller for the text field

  _ChatPageState({required this.contactAddress, required this.contactName});

  @override
  void initState() {
    super.initState();
    print("selected user in chatbox is $contactAddress");
    fetchMessages();
    checkMessageSent(context);
  }

  // Function to fetch messages asynchronously
  Future<void> fetchMessages() async {

      final pref = await SharedPreferences.getInstance();
      current_user = pref.getString("current_user_address")!;

      Connector h = Connector();
      List<dynamic> messagedata =
      await h.getcontract(context, "readMessage", [widget.contactAddress]);

      List<List<dynamic>> messageList = messagedata.cast<List<dynamic>>();
      setState(() {
        messages = messageList.map((data) {
          isSender = false;
          if (data[0].toString().toLowerCase().compareTo(current_user) == 0) {
            isSender = true;
          }
          print("data 1 is ${data[1].runtimeType}");
          return Message(
              senderName: contactName,
              text: data[2],
              isSender: isSender,
              time: data[1].toString());
        }).toList();
      });
  }

  Future<void> sendMessage() async {
    Connector h = Connector();
    isSender = true;
    recentmessage = _textController.text;
    await h.getcontract(
        context, "sendMessage", [widget.contactAddress, _textController.text]);

    setState(() {
      int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      messages.add(Message(
        senderName: 'Current User',
        text: _textController.text,
        isSender: isSender,
        time: timestamp.toString(),
        isSending: true,
      ));
    });
    _textController.clear();
  }

  Future<void> checkMessageSent(BuildContext contex) async {
    Contract? contract;
    final abistringfile = await DefaultAssetBundle.of(contex)
        .loadString("build/contracts/Chat.json");
    final abijson = jsonDecode(abistringfile);
    final abi = jsonEncode(abijson["abi"]);

    final contractAddress = "0xFB1103A41509d54C37a3fFf6bf198EC3ff443859";
    print("Contract address is $contractAddress");
    if(mounted)
    {
      if (provider != null) {
        try {
          contract = Contract(contractAddress, abi, provider!.getSigner());
          final filter = contract!.getFilter('MessageSent');
          contract!.on(filter, (event, dynamic c) {
            print("Message Sent is $event");
            print("value of is Sender is $isSender");
            if (isSender == false) {
              fetchMessages();
            } else {
              if (event.toString() == recentmessage) {
                setState(() {
                  messages.last.isSending = false;
                });
              }
            }
            isSender = false;
          });
          print("Listening for 'MessageSent' event...");
        } on Exception catch (error) {
          print("Error creating contract or listening for event: $error");
        }
      } else {
        print("Provider is not yet available");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(h / 15),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                contactName,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: CustomTheme.darkBlack,
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const Center(
                child: Text(
                  "No messages yet.",
                  style: TextStyle(fontSize: 16, color: Colors.white54),
                ),
              )
                  : ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  Message message = messages[index];
                  int timestamp = int.parse(message.time);
                  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                  String formattedTime = DateFormat('h:mm a').format(dateTime);
                  return Container(
                    padding: EdgeInsets.only(
                      top: 8,
                      bottom: 8,
                      left: message.isSender ? 0 : 24,
                      right: message.isSender ? 24 : 0,
                    ),
                    alignment: message.isSender
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: messages[index].isSending
                        ? Container(
                        margin: message.isSender
                            ? const EdgeInsets.only(left: 30)
                            : const EdgeInsets.only(right: 30),
                        padding: const EdgeInsets.only(
                          top: 17,
                          bottom: 17,
                          left: 20,
                          right: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: message.isSender
                              ? const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          )
                              : const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          gradient: LinearGradient(
                            begin: const FractionalOffset(0.5, 1.1),
                            end: const FractionalOffset(1.0, 10.1),
                            stops: const [0.0, 1.0],
                            tileMode: TileMode.clamp,
                            colors: message.isSender
                                ? const [Color(0xFF8988e9), Color(0xFF664ff7)]
                                : const [Color(0xFF664ff7), Color(0xFF8988e9)],
                          ),
                        ),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3, // Adjust strokeWidth for the circular shape
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                    )
                        : Container(
                      margin: message.isSender
                          ? const EdgeInsets.only(left: 30)
                          : const EdgeInsets.only(right: 30),
                      padding: const EdgeInsets.only(
                        top: 17,
                        bottom: 17,
                        left: 20,
                        right: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: message.isSender
                            ? const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        )
                            : const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        gradient: LinearGradient(
                          begin: const FractionalOffset(0.5, 1.1),
                          end: const FractionalOffset(1.0, 10.1),
                          stops: const [0.0, 1.0],
                          tileMode: TileMode.clamp,
                          colors: message.isSender
                              ? const [Color(0xFF8988e9), Color(0xFF664ff7)]
                              : const [Color(0xFF664ff7), Color(0xFF8988e9)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.text,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'OverpassRegular',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 45, right: 45, bottom: 20),
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                height: h / 15,
                padding: const EdgeInsets.only(left: 25, right: 25),
                decoration: BoxDecoration(
                  color: CustomTheme.lightBlack,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onFieldSubmitted: (_textController) {
                          setState(() async {
                            await sendMessage();
                          });
                        },
                        controller: _textController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        setState(() async {
                          await sendMessage();
                        });
                      },
                      icon: Container(
                        height: 40,
                        width: 40,
                        padding: const EdgeInsets.all(12),
                        color: Colors.transparent,
                        child: Transform.scale(
                          scale: 3,
                          child: Image.asset("Images/send.jpg"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
