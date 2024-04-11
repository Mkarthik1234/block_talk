import 'package:block_talk_v3/Blockchain/connect.dart';
import 'package:block_talk_v3/Screens/HomeScreen.dart';
import 'package:block_talk_v3/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';
import '../theme.dart';
import 'package:block_talk_v3/Modals/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:block_talk_v3/Screens/new_chat.dart';

class SideBar extends StatefulWidget {
  Function(bool,User) function;
  String useraddress,username;
  SideBar({required this.username,required this.useraddress,required this.function,super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  late List<User> friends;
  String chatName = '';
  int selected = -1;
  bool friendsExist = false;
  Connector connector = Connector();

  void refreshpage(){
    setState(() {
      initializeData();
      build(context);
    });
  }

  @override
  void initState() {
    super.initState();
    initializeData();
    checkFriendAdded(context);
  }

  Future<void> initializeData() async {
    List<User> fetchedUsers = await fetchUsers();
    setState(() {
      friends = fetchedUsers;
      friendsExist = friends.isNotEmpty;
    });
  }

  Future<List<User>> fetchUsers() async {
    // Fetch friends list from shared preferences or contract
    final SharedPreferences pref = await SharedPreferences.getInstance();
    print("json string is ${pref.getString("Friend_List")}");
    final String? jsonString = pref.getString("Friend_List");
    if (jsonString != "Empty" && jsonString != null) {
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

    final contractAddress = "0xFB1103A41509d54C37a3fFf6bf198EC3ff443859";
    print("Contract address is $contractAddress");
    contract = Contract(contractAddress, abi, provider!.getSigner());
    final filter = contract!.getFilter('FriendAdded');
    print("listening for friendAdded event");
    contract!.on(filter, (event, dynamic c) {
      print("Friend added $event");
      if (event.toString() == widget.useraddress) {
        HomeScreen(username: widget.username, useraddress: widget.useraddress);
      }
    });
    print("Listening for 'MessageSent' event...");
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Container(
      color: CustomTheme.lightBlack,
      child: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CustomTheme.darkBlack,
            ),
            width: w / 6,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                Divider(),
                Icon(
                  Icons.search,
                  size: 25,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: (){
              showDialog(context: context, builder: (context)=>UserList(widget.function(true,User(name:widget.username,accountAddress: widget.useraddress))));
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
                "Start new chat",
                style: TextStyle(color: Colors.white),
              )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            height: h / 1.6, //change h
            color: CustomTheme.lightBlack,
            width: w / 5,
            child: friendsExist?chatRoomsList(friends,widget.function):
            Center(child: const Text("No friends",style: TextStyle(color:Colors.white54),)),
          ),
          //chat lock part
          // Container(
          //   width: w / 10,
          //   height: 60,
          //   margin: EdgeInsets.only(
          //       left: w / 30, right: w / 30, top: 10, bottom: 10),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(10),
          //     color: const Color(0xfffef000),
          //   ),
          //   child: const Center(child: Icon(Icons.lock_outline)),
          // ),
        ],
      ),
    );
  }

  Widget chatRoomsList(List<User> friends,Function(bool,User) function) {
    return ListView.builder(
        itemCount: friends.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return chatRoomTile(
              friend.name,
              friend.accountAddress,
              selected != index
                  ? CustomTheme.lightBlack
                  : CustomTheme.darkBlack,
              index,function);
        });
  }

  chatRoomTile(String userName, String useraddress, Color color, int index,Function(bool,User) function) {
    User selecteduser = User(name: userName,accountAddress: useraddress);
    return GestureDetector(
      onTap: () {
        setState(() {
          selected = index;
          function(true,selecteduser);
        });
      },
      child: Container(
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
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
                    useraddress.substring(0,6)+"..."+useraddress.substring(35),
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
