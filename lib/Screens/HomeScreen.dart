import 'package:flutter/material.dart';
import 'package:block_talk_v3/CustomWidgets/menu.dart';
import 'package:block_talk_v3/CustomWidgets/sidebar.dart';
import 'package:block_talk_v3/CustomWidgets/chatbox.dart';
import 'package:block_talk_v3/Modals/User.dart';

class HomeScreen extends StatefulWidget {
  final String username, useraddress;

  HomeScreen({required this.username, required this.useraddress, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isChatSelected = false;
  late User selectedFriend;

  void refreshpage(bool val, User selectedFriend) {
    setState(() {
      isChatSelected = val;
      this.selectedFriend = selectedFriend;
      print("selected friend in homescreen is ${this.selectedFriend.name}");
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Username and address in homescreen is ${widget.username} ${widget.useraddress}");
    if (isChatSelected) {
      print("selected friend in homescreen is ${this.selectedFriend.name}");
    }
    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            user_address: widget.useraddress,
            user_name: widget.username,
          ),
          SideBar(function: refreshpage),
          Expanded(
            child: isChatSelected
                ? ChatPage(
              key: UniqueKey(), // Ensure ChatPage refreshes with new values
              contactAddress: this.selectedFriend.accountAddress,
              contactName: this.selectedFriend.name,
            )
                : Center(
              child: Text(
                "Select Friend to Start Chatting",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
