import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:translator/translator.dart';

import 'package:block_talk_v3/Blockchain/connect.dart';
import 'package:block_talk_v3/main.dart';
import 'package:block_talk_v3/theme.dart';
import 'package:block_talk_v3/Screens/profile.dart';
import 'package:block_talk_v3/Modals/Message.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:block_talk_v3/Screens/new_chat.dart';
import 'package:block_talk_v3/Modals/User.dart';
import 'package:block_talk_v3/CustomWidgets/transaction_page.dart';

import 'package:showcaseview/showcaseview.dart';
import 'package:block_talk_v3/Modals/inheritkeys.dart';
import 'package:block_talk_v3/CustomWidgets/TransactionHistory.dart';

import 'package:block_talk_v3/CustomWidgets/Delegate.dart';

import 'package:web3dart/web3dart.dart' as Web3;

int number_of_friends = 0;
int flag = 0;
late User selectedFriend;
String SelectedLanguage = "English";
List<Message> messages = [];
List<Message> translated_messages = [];
bool translate_language = false;
int messageIdCounter = 0;

Map<String, String> language = {
  "Bengali": "bn",
  "English": "en",
  "Dutch": "nl",
  "French": "fr",
  "German": "de",
  "Greek": "el",
  "Hindi": "hi",
  "Italian": "it",
  "Japanese": "ja",
  "Kannada": "kn",
  "Korean": "ko",
  "Malayalam": "ml",
  "Marati": "mr",
  "Russian": "ru",
  "Spanish": "es",
  "Tamil": "ta",
  "Telugu": "te",
  "Chinese": "zh-TW",
  "Urdu": "ur"
};

class Home extends StatelessWidget {
  final String username, useraddress;

  Home({required this.username, required this.useraddress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ShowCaseWidget(
            builder: Builder(
                builder: (context) =>
                    HomeScreen(username: username, useraddress: useraddress))));
  }
}

class HomeScreen extends StatefulWidget {
  final String username, useraddress;

  HomeScreen({required this.username, required this.useraddress, Key? key})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isChatSelected = false;
  bool refresh_sidebar = false;
  GlobalKey _profile = GlobalKey();
  GlobalKey _newChat = GlobalKey();
  GlobalKey _search = GlobalKey();
  GlobalKey _home = GlobalKey();
  GlobalKey _newChat2 = GlobalKey();
  GlobalKey _tranHistory = GlobalKey();

  void friendSelected(bool val, User friend) {
    setState(() {
      isChatSelected = val;
      refresh_sidebar = true;
      flag = 1;
      print("inside +++++++++++++++++++++friend selected with flag $flag");
      selectedFriend = friend;
      print("selected friend in homescreen is ${selectedFriend.name}");
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        "Username and address in homescreen is ${widget.username} ${widget.useraddress}");
    if (isChatSelected) {
      print("selected friend in homescreen is ${selectedFriend.name}");
    }

    SharedPreferences preferences;

    displayShowcase() async {
      preferences = await SharedPreferences.getInstance();
      bool? showcaseVisibilityStatus =
          await preferences.getBool("RegistrationPreviouspage");
      print(
          "inside display show case with $showcaseVisibilityStatus ++++++++++++++++++++++");
      if (showcaseVisibilityStatus == false) {
        return false;
      }
      return true;
    }

    displayShowcase().then((status) async {
      if (status) {
        WidgetsBinding.instance.addPostFrameCallback((_) =>
            ShowCaseWidget.of(context).startShowCase(
                [_profile, _newChat, _newChat2, _search, _tranHistory]));
        SharedPreferences preference;
        preference = await SharedPreferences.getInstance();
        preference.setBool("RegistrationPreviouspage", false);
      }
    });

    return keystobeinherited(
      profile: _profile,
      newChat: _newChat,
      home: _home,
      search: _search,
      newChat2: _newChat2,
      transactionHistory: _tranHistory,
      child: Scaffold(
        body: Row(
          children: [
            SideMenu(
              user_address: widget.useraddress,
              user_name: widget.username,
              refreshPage: friendSelected,
            ),
            Expanded(
              flex: 2,
              child: SideBar(
                username: widget.username,
                useraddress: widget.useraddress,
                function: friendSelected,
                refresh: refresh_sidebar,
              ),
            ),
            Expanded(
              flex: 5,
              child: isChatSelected
                  ? ChatPage(
                      key:
                          UniqueKey(), // Ensure ChatPage refreshes with new values
                      contactAddress: selectedFriend.accountAddress,
                      contactName: selectedFriend.name,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          child: Image.asset(
                            'Images/wired-gradient-981-consultation.gif',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover, // Adjust BoxFit as needed
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Select Friend to Start Chatting",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<String>> fetchUsers(BuildContext context) async {
  Connector h = Connector();
  List<dynamic> userdata = await h.getcontract(context, "getAllAppUser", []);
  List<List<dynamic>> userList = userdata.cast<List<dynamic>>();

  List<String> users = [];

  for (var user in userList) {
    users.add(user[0].toString());
    users.add(user[1].toString());
  }

  return users;
}

class SideBar extends StatefulWidget {
  Function(bool, User) function;
  String useraddress, username;
  bool refresh;

  SideBar(
      {required this.username,
      required this.useraddress,
      required this.function,
      required this.refresh,
      Key? key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late List<User> friends;
  String chatName = '';
  int selected = -1;
  bool friendsExist = false;
  Connector connector = Connector();
  var value = 0;

  void refreshpage() {
    setState(() {
      initializeData();
      build(context);
    });
  }

  @override
  void initState() {
    super.initState();
    checkFriendAdded(context);
  }

  Future<void> initializeData({var bypass}) async {
    value = 1;
    List<User> fetchedUsers = await fetchUsers(bypass: bypass);
    setState(() {
      friends = fetchedUsers;
      friendsExist = friends.isNotEmpty;
    });
  }

  Future<List<User>> fetchUsers({var bypass}) async {
    // Fetch friends list from shared preferences or contract
    final SharedPreferences pref = await SharedPreferences.getInstance();
    print("json string is ${pref.getString("Friend_List")}");
    final String? jsonString = pref.getString("Friend_List");
    if (jsonString != "Empty" && jsonString != null && bypass == null) {
      print("Shared preference has data");
      final List<List<dynamic>> userData =
          json.decode(jsonString!).cast<List<dynamic>>();
      if (userData.isNotEmpty) {
        print("UserData has data $userData");
        friendsExist = true;
        List<List<dynamic>> userList = userData;
        List<User> users = userList.map((data) {
          return User(accountAddress: data[0], name: data[1]);
        }).toList();
        number_of_friends = users.length;
        return users;
      }
    } else {
      // Fetch friends list from contract if not found in shared preferences
      List<dynamic> userData =
          await connector.getcontract(context, "getMyFriendList", []);

      final String jsonstring = jsonEncode(userData);
      pref.setString("Friend_List", jsonstring);

      print("user data from contract is $userData");
      if (!userData.isEmpty) {
        friendsExist = true;
        List<List<dynamic>> userList = userData.cast<List<dynamic>>();
        List<List<dynamic>> list = [];
        final SharedPreferences pref = await SharedPreferences.getInstance();
        list = userList;
        print("User list is $userList");
        final jsonstring = jsonEncode(list);
        pref.setString("Friend_List", jsonstring);
        List<User> users = userList.map((data) {
          // Convert data elements to expected types if necessary
          String address = data[0].toString(); // Example conversion to String
          String name = data[1].toString(); // Example conversion to String
          return User(accountAddress: address, name: name);
        }).toList();
        number_of_friends = users.length;
        return users;
      }
    }
    // If no users found, return an empty list
    print("no users ");
    return [];
  }

  Future<void> checkFriendAdded(BuildContext contex) async {
    Contract? contract;
    final abistringfile = await DefaultAssetBundle.of(contex)
        .loadString("build/contracts/Chat.json");
    final abijson = jsonDecode(abistringfile);
    final abi = jsonEncode(abijson["abi"]);

    const contractAddress = "0xbD58270A35A26092602027946ACC1d4b875456b5";
    print("Contract address is $contractAddress");
    contract = Contract(contractAddress, abi, provider!.getSigner());
    final filter = contract!.getFilter('FriendAdded');
    print("listening for friendAdded event");
    contract!.on(filter, (event, dynamic c) async {
      print("Friend added $event");
      await initializeData(bypass: 1);
      print("Initialize completed");
    });
    print("Listening for 'MessageSent' event...");
  }

  @override
  Widget build(BuildContext context) {
    if (value == 0 || widget.refresh) {
      initializeData();
      widget.refresh = false;
    }
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final getkey = keystobeinherited.of(context);
    return Container(
      color: CustomTheme.lightBlack,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 200),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10),
              //     color: CustomTheme.darkBlack,
              //   ),
              //   width: w / 6,
              //   height: 40,
              //   padding: const EdgeInsets.symmetric(horizontal: 15),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Expanded(
              //         child: TextField(
              //           style: TextStyle(
              //             fontSize: 14,
              //             color: Colors.white.withOpacity(0.6),
              //           ),
              //           decoration: InputDecoration(
              //             border: InputBorder.none,
              //             focusedBorder: InputBorder.none,
              //             enabledBorder: InputBorder.none,
              //             errorBorder: InputBorder.none,
              //             disabledBorder: InputBorder.none,
              //             hintText: 'Search',
              //             hintStyle: TextStyle(
              //               fontSize: 14,
              //               color: Colors.white.withOpacity(0.6),
              //             ),
              //           ),
              //         ),
              //       ),
              //       const Divider(),
              //       const Icon(
              //         Icons.search,
              //         size: 25,
              //         color: Colors.grey,
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
              Showcase(
                key: getkey.newChat,
                description: "You can find all the app users in here",
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => UserList(widget.function));
                  },
                  child: Container(
                    width: w / 6,
                    height: 50,
                    margin: EdgeInsets.only(
                        left: w / 30, right: w / 30, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                          colors: [
                            CustomTheme.lBlue,
                            CustomTheme.dBlue,
                          ],
                          begin: const FractionalOffset(1.1, 0.1),
                          end: const FractionalOffset(1.0, .5),
                          stops: const [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                    child: const Center(
                        child: Text(
                      "All Users",
                      style: TextStyle(color: Colors.white),
                    )),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: h / 1.6, //change h
                color: CustomTheme.lightBlack,
                width: w / 5,
                child: friendsExist
                    ? chatRoomsList(friends, widget.function)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            child: Image.asset(
                              'Images/wired-gradient-1808-skateboarding.gif',
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover, // Adjust BoxFit as needed
                            ),
                          ),
                          Text(
                            "No friends",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget chatRoomsList(List<User> friends, Function(bool, User) function) {

    return ListView.builder(
        itemCount: friends.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final friend = friends[index];
          if (flag == 1) {
            if (friend.name.compareTo(selectedFriend.name) == 0 &&
                friend.accountAddress
                        .compareTo(selectedFriend.accountAddress) ==
                    0) {
              selected = index;
              flag = 0;
              print(
                  "selected index is ###################  $selected , $index , ${selectedFriend.name}");
            }
            else{
              selected = -1;
            }
          }

          return chatRoomTile(
              friend.name,
              friend.accountAddress,
              selected != index
              ? CustomTheme.lightBlack
              : CustomTheme.darkBlack,
              index,
              function);
        });
  }

  chatRoomTile(String userName, String useraddress, Color color, int index,
      Function(bool, User) function) {
    User selecteduser = User(name: userName, accountAddress: useraddress);
    print("size of selected user address ${selecteduser.accountAddress}");
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected == index) {
            selected = -1; // Deselect if tapped again
          } else {
            selected = index; // Select the new item
          }
          function(true, selecteduser);
        });
      },
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: CustomTheme.lightBlue,
                    borderRadius: BorderRadius.circular(30)),
                child: const Icon(Icons.person),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: '',
                        fontWeight: FontWeight.w300)),
                // user address
                Text(
                    useraddress.substring(0, 6) +
                        "..." +
                        useraddress.substring(35),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        fontFamily: '',
                        fontWeight: FontWeight.w300))
              ],
            )
          ],
        ),
      ),
    );
  }
}


class SideMenu extends StatefulWidget {
  String user_name, user_address;
  final Function(bool, User) refreshPage;

  SideMenu(
      {required this.user_name,
      required this.user_address,
      required this.refreshPage,
      Key? key})
      : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  GlobalKey _profile = GlobalKey();
  bool isregistered = true;

  @override
  Widget build(BuildContext context) {
    final getKeys = keystobeinherited.of(context);
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Container(
      color: const Color(0xff9872cb),
      height: h,
      width: w / 23,
      child: ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          isregistered
              ? Showcase(
                  key: getKeys.profile,
                  description: "This is your profile information",
                  child: GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) => Profile(
                                  user_name: widget.user_name,
                                  user_address: widget.user_address,
                                ));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                        ),
                      )),
                )
              : Container(
                  padding: const EdgeInsets.all(5),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.grey,
                    ),
                  )),
          const SizedBox(
            height: 80,
          ),
          Showcase(
            key: getKeys.newChat2,
            description: "You can find all the app users in here",
            child: GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => UserList(widget.refreshPage));
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Icon(Icons.message_outlined,
                    color: Colors.white.withOpacity(0.6)),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Showcase(
            key: getKeys.search,
            description: "Tap to search an user",
            child: GestureDetector(
              onTap: () async {
                List<String> u = await fetchUsers(context);
                final pref = await SharedPreferences.getInstance();
                await pref.setStringList("Users", u);
                showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(
                      UserAddress: widget.user_address,
                      UserName: widget.user_name,
                      refreshPage: widget.refreshPage,
                    ));
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Showcase(
            key: getKeys.transactionHistory,
            description: "Tap to View your Transaction History",
            child: GestureDetector(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (context) => TransactionHistoryDialog());
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Icon(Icons.history_rounded,
                    color: Colors.white.withOpacity(0.6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String contactName, contactAddress;

  ChatPage({Key? key, required this.contactName, required this.contactAddress})
      : super(key: key);

  @override
  _ChatPageState createState() =>
      _ChatPageState(contactAddress: contactAddress, contactName: contactName);
}


class _ChatPageState extends State<ChatPage> {
  bool isSender = false;
  String contactAddress, contactName;
  String recentmessage = "";
  late String current_user;
  GoogleTranslator translator = GoogleTranslator();
  bool translating = false; // Flag to track translation status

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
        print("data 1 is ${data[1].toString()}");
        return Message(
            id: messageIdCounter++,
            senderName: contactName,
            text: data[2],
            isSender: isSender,
            time: data[1].toString());
      }).toList();
    });
  }

  TranslateMessages() async {
    if (messages.isNotEmpty) {
      List<Message> translatedMessages = [];
      List<Future<void>> translationFutures = [];

      for (int i = 0; i < messages.length; i++) {
        Message m = messages[i];

        Future<void> translationFuture = translator
            .translate(m.text,
                to: language[SelectedLanguage.toString()] ?? 'en')
            .then((output) {
          translatedMessages.add(Message(
              id: m.id,
              senderName: m.senderName,
              text: output.toString(),
              isSender: m.isSender,
              time: m.time));
        });

        translationFutures.add(translationFuture);
      }

      await Future.wait(translationFutures);
      translatedMessages.sort((a, b) => a.id.compareTo(b.id));

      setState(() {
        messages = translatedMessages;
        translating = false;
      });
    }
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
        id: messageIdCounter++,
        senderName: 'Current User',
        text: _textController.text,
        isSender: isSender,
        time: timestamp.toString(),
        isSending: true,
      ));
    });
    _textController.clear();
    print("performing transaction");
  }

  Future<void> checkMessageSent(BuildContext context) async {
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
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          translating = true; // Set translating flag to true
                          TranslateMessages();
                        });
                      },
                      icon: Icon(Icons.refresh_outlined)),
                  LanguageDropdown()
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: CustomTheme.darkBlack,
        child: Column(
          children: [
            Expanded(
              child:
                  translating // Display circular progress indicator while translating
                      ? Center(child: CircularProgressIndicator())
                      : messages.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 200,
                                  height: 200,
                                  child: Image.asset(
                                    'Images/wired-gradient-453-savings-pig.gif',
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                const Text(
                                  "No messages yet.",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white54),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                Message message = messages[index];
                                int timestamp = int.parse(message.time);
                                DateTime now = DateTime.now();
                                String today = DateFormat('yyyy-MM-dd').format(now);
                                DateTime dateTime =
                                DateTime.fromMillisecondsSinceEpoch(
                                    timestamp * 1000);
                                String date = DateFormat('yyyy-MM-dd')
                                    .format(dateTime);
                                String formattedTime;
                                if(today == date){
                                  formattedTime =
                                  DateFormat('h:mm a').format(dateTime);
                                }
                                else{
                                  formattedTime =
                                      DateFormat('dd-MM-yyyy h:mm a').format(dateTime);
                                }
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
                                              : const EdgeInsets.only(
                                                  right: 30),
                                          padding: const EdgeInsets.only(
                                            top: 17,
                                            bottom: 17,
                                            left: 20,
                                            right: 20,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: message.isSender
                                                ? const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                    bottomLeft:
                                                        Radius.circular(15),
                                                  )
                                                : const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                    bottomRight:
                                                        Radius.circular(15),
                                                  ),
                                            gradient: LinearGradient(
                                                begin: const FractionalOffset(
                                                    0.5, 1.1),
                                                end: const FractionalOffset(
                                                    1.0, 10.1),
                                                stops: const [0.0, 1.0],
                                                tileMode: TileMode.clamp,
                                                colors: message.isSender
                                                    ? const [
                                                        Color(0xFF8988e9),
                                                        Color(0xFF664ff7)
                                                      ]
                                                    : const [Color(0xFF664ff)]),
                                          ),
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Container(
                                          margin: message.isSender
                                              ? const EdgeInsets.only(left: 30)
                                              : const EdgeInsets.only(
                                                  right: 30),
                                          padding: const EdgeInsets.only(
                                            top: 17,
                                            bottom: 17,
                                            left: 20,
                                            right: 20,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: message.isSender
                                                ? const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                    bottomLeft:
                                                        Radius.circular(15),
                                                  )
                                                : const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                    bottomRight:
                                                        Radius.circular(15),
                                                  ),
                                            gradient: LinearGradient(
                                              begin: const FractionalOffset(
                                                  0.5, 1.1),
                                              end: const FractionalOffset(
                                                  1.0, 10.1),
                                              stops: const [0.0, 1.0],
                                              tileMode: TileMode.clamp,
                                              colors: message.isSender
                                                  ? const [
                                                      Color(0xFF8988e9),
                                                      Color(0xFF664ff7)
                                                    ]
                                                  : const [
                                                      Color(0xFF664ff7),
                                                      Color(0xFF8988e9)
                                                    ],
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                  color: Colors.white
                                                      .withOpacity(0.6),
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
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => TransactionPage(
                                  toAddress: widget.contactAddress,
                                ));
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.transparent,
                        child: Transform.scale(
                          scale: 3,
                          child: Icon(
                            Icons.monetization_on_outlined,
                            size: 10,
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

class LanguageDropdown extends StatefulWidget {
  @override
  _LanguageDropdownState createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  String _selectedLanguage = 'English'; // Default selected language
  List<String> _languages = language.keys.toList(); // List of languages

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: _selectedLanguage,
        items: _languages.map((String language) {
          return DropdownMenuItem(
            value: language,
            child: Text(language),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedLanguage = newValue!;
            SelectedLanguage = newValue;
          });
        },
      ),
    );
  }
}
