import 'package:block_talk_v3/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Map<String, UserInfo> chats = {
  'Rishabh': UserInfo(messages: [
    {'sentByMe': 'false', 'text': 'Hey, how are you?', 'time': '10:00 AM'},
    {'sentByMe': 'true', 'text': 'Good !', 'time': '10:05 AM'},
    {'sentByMe': 'true', 'text': 'What about you ?', 'time': '10:10 AM'},
    {'sentByMe': 'false', 'text': 'I am also good', 'time': '10:15 AM'},
    {
      'sentByMe': 'true',
      'text': 'Okay , how is your work going on',
      'time': '10:20 AM'
    },
    {'sentByMe': 'true', 'text': 'It is going great', 'time': '10:25 AM'},
    {
      'sentByMe': 'true',
      'text': 'Where were you working ?',
      'time': '10:30 AM'
    },
    {'sentByMe': 'true', 'text': 'At Zoomentum', 'time': '10:35 AM'},
  ], dp: 'https://cdn.sharechat.com/cccbcdd8-38e6-45f5-ad88-dcf7c5dc2b38-d8e1f3f0-8489-417e-898b-219d8a6eede0.jpeg'),
  'Ankit': UserInfo(messages: [
    {'sentByMe': 'true', 'text': 'Hello', 'time': '9:30 AM'},
    {'sentByMe': 'true', 'text': '?', 'time': '9:35 AM'},
    {'sentByMe': 'false', 'text': 'Yes', 'time': '9:40 AM'},
    {'sentByMe': 'false', 'text': 'How are you ?', 'time': '9:45 AM'},
  ], dp: 'https://images.pexels.com/photos/1315741/pexels-photo-1315741.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500'),
  // Other users' info omitted for brevity
};

class UserInfo {
  final List<Map<String, String>> messages;
  final String dp;

  UserInfo({required this.messages, required this.dp});

  addMessage(String val, String date) {
    messages.add({
      'sentByMe': 'true',
      'text': val,
      'time': date
    }); // You can replace '11:00 AM' with actual time
  }
}

class Chat extends StatefulWidget {
  final String chatRoomId;
  final String chatUsername;

  Chat({required this.chatRoomId, required this.chatUsername});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController messageEditingController = TextEditingController();

  Widget chatMessages() {
    double h = MediaQuery.of(context).size.height;

    return Container(
      color: CustomTheme.darkBlack,
      height: h / 1.2,
      child: ListView.builder(
          reverse: true,
          itemCount: chats[widget.chatUsername] == null
              ? 0
              : chats[widget.chatUsername]!.messages.length,
          itemBuilder: (context, index) {
            return MessageTile(
              name: widget.chatUsername,
              message: chats[widget.chatUsername]!
                  .messages[chats[widget.chatUsername]!.messages.length -
                      1 -
                      index]['text']
                  .toString(),
              time: chats[widget.chatUsername]!
                  .messages[chats[widget.chatUsername]!.messages.length -
                      1 -
                      index]['time']
                  .toString(), // Add time here
              sendByMe: chats[widget.chatUsername]!.messages[
                          chats[widget.chatUsername]!.messages.length -
                              1 -
                              index]['sentByMe'] ==
                      'true'
                  ? true
                  : false,
            );
          }),
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      print(messageEditingController.text);

      var now = DateTime.now();
      var amPm = now.hour >= 12 ? 'PM' : 'AM';
      var hour = now.hour > 12 ? now.hour - 12 : now.hour;
      if (hour == 0) hour = 12;
      var formattedTime = '$hour:${now.minute} $amPm';

      chats[widget.chatUsername]
          ?.addMessage(messageEditingController.text, formattedTime);
      setState(() {
        messageEditingController.text = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  onTextFieldKey(RawKeyEvent event) {
    if (event is RawKeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        submit();
      } else if (event.data is RawKeyEventDataWeb) {
        final data = event.data as RawKeyEventDataWeb;
        if (data.keyLabel == 'Enter') submit();
      } else if (event.data is RawKeyEventDataAndroid) {
        final data = event.data as RawKeyEventDataAndroid;
        if (data.keyCode == 13) submit();
      }
    }
  }

  submit() {
    addMessage();
    // have fun
  }

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return widget.chatUsername == null
        ? Container()
        : Scaffold(
            backgroundColor: CustomTheme.lightBlack,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(h / 15),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                centerTitle: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(30),
                    //   child: Container(
                    //     height: 40,
                    //     width: 40,
                    //     decoration: BoxDecoration(
                    //         color: CustomTheme.lightBlue,
                    //         borderRadius: BorderRadius.circular(30)),
                    //     child: const Icon(Icons.person),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   width: 20,
                    // ),
                    Text(
                      widget.chatUsername,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            body: Container(
              color: CustomTheme.darkBlack,
              child: Stack(
                children: [
                  chatMessages(),
                  Container(
                    alignment: Alignment.bottomCenter,
                    margin:
                        const EdgeInsets.only(left: 45, right: 45, bottom: 20),
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      height: h / 15,
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      decoration: BoxDecoration(
                          color: CustomTheme.lightBlack,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          Expanded(
                              child: RawKeyboardListener(
                            focusNode: focusNode,
                            onKey: onTextFieldKey,
                            child: TextFormField(
                              onFieldSubmitted: (_textController) {
                                addMessage();
                              },
                              style: const TextStyle(color: Colors.white),
                              textInputAction: TextInputAction.go,
                              controller: messageEditingController,
                              decoration: InputDecoration(
                                  hintText: "Type Something ...",
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none),
                            ),
                          )),
                          const SizedBox(
                            width: 16,
                          ),
                          IconButton(
                            onPressed: () {
                              print(messageEditingController.text);
                              addMessage();
                            },
                            icon: Container(
                              height: 40,
                              width: 40,
                              padding: const EdgeInsets.all(12),
                              color: Colors.transparent,
                              child: Transform.scale(
                                scale: 3,
                                // Adjust the scale factor as per your requirement
                                child: Image.asset(
                                  "Images/send.jpg",
                                ),
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

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final String name;
  final String time;

  MessageTile(
      {required this.message,
      required this.sendByMe,
      required this.name,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15))
                : const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
            gradient: LinearGradient(
              begin: const FractionalOffset(0.5, 1.1),
              end: const FractionalOffset(1.0, 10.1),
              stops: const [0.0, 1.0],
              tileMode: TileMode.clamp,
              colors: sendByMe
                  ? [const Color(0xFF8988e9), const Color(0xFF664ff7)]
                  : [
                      const Color(0xFF664ff7),
                      const Color(0xFF8988e9),
                    ],
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message,
                textAlign: TextAlign.start,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),
            const SizedBox(height: 5),
            // Add some space between message and time
            Text(
              time, // Display the time here
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
