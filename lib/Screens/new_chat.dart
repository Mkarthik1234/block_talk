import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:block_talk_v3/Blockchain/connect.dart';
import 'package:block_talk_v3/Modals/User.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<User>> fetchUsers(BuildContext context) async {
  Connector h = Connector();
  List<dynamic> userdata = await h.getcontract(context, "getAllAppUser", []);
  List<List<dynamic>> userList = userdata.cast<List<dynamic>>();

  List<User> users = userList.map((data) {
    return User(name: data[0], accountAddress: data[1]);
  }).toList();

  return users;
}

class UserList extends StatefulWidget {
  final Function(bool,User) refreshPage;

  UserList(this.refreshPage);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late Future<List<User>> _futureUsers;
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
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // Adjust the radius as per your requirement
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            Positioned(
              child: OutlinedButton(
                onPressed: () {
                  _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                    context: context,
                    onCode: (code) async {
                      this.code = code;
                      List<String> user = code!.split(" ");
                      await addFriend(context, user[3], user[4]);
                      widget.refreshPage(true,User(name: user[4].toString(),accountAddress: user[3].toString()));
                      Navigator.of(context).pop();
                    },
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(10),
                  shape: CircleBorder(),
                  backgroundColor: Colors.white,
                ),
                child: Icon(
                  Icons.qr_code_scanner_outlined,
                  color: Colors.black,
                  size: 25,
                ),
              ),
            ),
            SizedBox(height: 50,),
            Expanded(
              child: FutureBuilder<List<User>>(
                future: _futureUsers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    List<User> users = snapshot.data!;
                    return Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          User user = users[index];
                          return UserCard(user: user, refreshPage: widget.refreshPage);
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
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
    if (listEquals([listItem[0].toUpperCase(), listItem[1]], newData)) {
      isDataExists = true;
      break;
    }
  }

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
  final Function(bool,User) refreshPage;

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
        } else if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final String? currentUser = snapshot.data;
            bool isCurrentUser = currentUser?.toLowerCase() ==
                widget.user.accountAddress.toLowerCase();
            if (!isCurrentUser) {
              return Card(
                margin: const EdgeInsets.fromLTRB(50, 10, 50, 5),
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    widget.user.name,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(widget.user.accountAddress),
                  trailing: IconButton(
                    onPressed: () async {
                      await addFriend(
                          context, widget.user.accountAddress, widget.user.name);
                      Navigator.of(context).pop();
                      widget.refreshPage(true,User(accountAddress:widget.user.accountAddress,name : widget.user.name));
                    },
                    icon: Icon(Icons.person_add_alt_1_rounded),
                  ),
                ),
              );
            } else {
              return Container();
            }
          }
        }
      },
    );
  }
}
