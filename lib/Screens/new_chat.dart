import 'dart:convert';

import 'package:block_talk_v3/Screens/HomeScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:block_talk_v3/Blockchain/connect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:block_talk_v3/Modals/User.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';

Future<List<User>> fetchUsers(BuildContext context) async {
  print("HIIIIIIIIIIIIIIII");
  Connector h = Connector();
  List<dynamic> userdata = await h.getcontract(context, "getAllAppUser", []);
  List<List<dynamic>> userList = userdata.cast<List<dynamic>>();

  List<User> users = userList.map((data) {
    return User(name: data[0], accountAddress: data[1]);
  }).toList();

  return users;
}

class UserList extends StatefulWidget {
  final VoidCallback refreshPage;
  UserList(this.refreshPage);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late Future<List<User>> _futureUsers;
  late List<String> user;
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;

  @override
  void initState() {
    super.initState();
    initialise();
  }

  initialise() {
    _futureUsers = fetchUsers(context);
  }

  @override
  Widget build(BuildContext context) {
    print("I am inside build of new chat");
    return Dialog(child: Builder(builder: (context) {
      return Container(
        width:500,
        height: 1000,
        child:Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 30,
              ),
              Positioned(
                child: OutlinedButton(
                  onPressed: () {
                    _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                      context: context,
                      onCode: (code) {
                        setState(() {
                          this.code = code;
                          user = code!.split(" ");
                          print("$code, $user, ${user[3]}, ${user[4]}");
                          addFriend(
                              context, user[3], user[4]); // Pass context here too
                        });
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    shape: CircleBorder(),
                    elevation: 0,
                    backgroundColor: Colors.white,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_outlined,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ),
              FutureBuilder<List<User>?>(
                future: _futureUsers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  else if(!snapshot.hasData){
                    print("hello hello hello");
                    return Center(child: CircularProgressIndicator());
                  }
                  else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<User> users = snapshot.data!;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          User user = users[index];
                          return UserCard(
                              user: user, refreshPage: widget.refreshPage);
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
      );
    }));
  }
}

addFriend(BuildContext context, String address, String name) async {
  List<List<dynamic>> list = [];
  final SharedPreferences pref = await SharedPreferences.getInstance();
  String? jsonstring = pref.getString("Friend_List");
  if (jsonstring != "Empty") {
    list = jsonDecode(jsonstring!).cast<List<dynamic>>();
  }
  List<dynamic> newData = [address.toUpperCase(), name];
  bool isDataExists = false;
  for (List<dynamic> listItem in list) {
    if (listEquals([listItem[0].toUpperCase(),listItem[1]], newData)) {
      isDataExists = true;
      break;
    }
  }

  // Add newData to dataList if it doesn't exist
  if (!isDataExists) {
    list.add([address, name]);
    print('Data added successfully: ${list.last}');
  } else {
    print('Data already exists: ${address.toUpperCase()},$name');
  }

  jsonstring = jsonEncode(list);
  pref.setString("Friend_List", jsonstring);
}

Future<String?> getcurrentuser() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final current_address = sharedPreferences.getString("current_user_address");
  return current_address;
}

class UserCard extends StatefulWidget {
  final User user;
  final VoidCallback refreshPage;

  const UserCard({Key? key, required this.user, required this.refreshPage})
      : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getcurrentuser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        else if(!snapshot.hasData){
          return CircularProgressIndicator();
        }
        else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            print("inside");
            final String? currentUser = snapshot.data;
            bool isCurrentUser = currentUser?.toLowerCase() ==
                widget.user.accountAddress.toLowerCase();
            print("$currentUser,${widget.user.accountAddress}");
            if (!isCurrentUser) {
              print("inside if");
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      widget.user.name,
                      style: const TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(widget.user.accountAddress),
                    trailing: IconButton(
                      onPressed: () async {
                        await addFriend(context, widget.user.accountAddress,
                            widget.user.name); // Pass context here too
                        const snackBar = SnackBar(
                          content: Text("Friend added successfully"),
                          behavior: SnackBarBehavior.floating,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.of(context).pop();
                        widget.refreshPage();
                      },
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                    )),
              );
            } else {
              print("inside else");
              return Container();
            }
          }
        }
      },
    );
  }
}
