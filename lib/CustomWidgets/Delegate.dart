import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:block_talk_v3/Modals/User.dart';
import 'package:block_talk_v3/Blockchain/connect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<List<String>?> fetchUsers(BuildContext context) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  List<String>? users = pref.getStringList("Users");
  return users;
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

class CustomSearchDelegate extends SearchDelegate {
  String UserAddress,UserName;
  final Function(bool,User) refreshPage;
  CustomSearchDelegate({required this.UserAddress,required this.UserName,required this.refreshPage});

  late Future<List<String>?> Users;


  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    int i = 0;
    return FutureBuilder<List<String>?>(
      future: fetchUsers(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Future hasn't completed yet, show a loading indicator
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Error occurred while fetching users
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          // No data available
          return Text('No users found');
        } else {
          // Data is available, process it
          List<String> matchQuery = [];
          List<String>? users = snapshot.data;

          for (var fruit in users!) {
            if (fruit.toLowerCase().contains(query.toLowerCase())) {
              matchQuery.add(fruit);
            }
          }

          return ListView.builder(
            itemCount: matchQuery.length,
            itemBuilder: (context, index) {
              var result = matchQuery[index];
              return ListTile(
                tileColor:Colors.black12,
                title: Text(result),
                onTap: ()async{
                  print(result.length);
                  if(result.length==42 && result.contains('0x'))
                    {
                      int i = 0;
                      print("address");
                      for (var k in users) {
                        if (k.compareTo(result) == 0) {
                          print("match found $i");
                          break;
                        }
                        i++;
                      }
                      if (i > 0) {
                        i--;
                        print("length is ${users.length} and i value is $i");
                        await addFriend(
                            context, result, users[i]);
                        Navigator.of(context).pop();
                        refreshPage(true, User(accountAddress: result, name: users[i]));
                      } else {
                        print("No user found that matches the condition.");
                      }
                    }
                  else{
                    print("name");
                    int i = 0;
                    for (var k in users) {
                      if (k.compareTo(result) == 0) {
                        print("match found $i");
                        break;
                      }
                      i++;
                    }
                    if (i < users.length) {
                      i++;
                      print("length is ${users.length} and i value is $i ${users[i].length}");
                      await addFriend(
                          context, users[i], result);
                      Navigator.of(context).pop();
                      refreshPage(true, User(accountAddress: users[i], name: result));
                    }
                  }

                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    return FutureBuilder<List<String>?>(
      future: fetchUsers(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('No users found');
        } else {
          // Data is available, process it
          List<String> matchQuery = [];
          List<String>? users = snapshot.data;

          for (var fruit in users!) {
            if (fruit.toLowerCase().contains(query.toLowerCase())) {
              matchQuery.add(fruit);
            }
          }

          return ListView.builder(
            itemCount: matchQuery.length,
            itemBuilder: (context, index) {
              var result = matchQuery[index];
              return ListTile(
                tileColor:Colors.black12,
                title: Text(result),
                onTap: ()async{
                  print(result.length);
                  if(result.length==42 && result.contains('0x'))
                  {
                    int i = 0;
                    print("address");
                    for (var k in users) {
                      if (k.compareTo(result) == 0) {
                        print("match found $i");
                        break;
                      }
                      i++;
                    }
                    if (i > 0) {
                      i--;
                      print("length is ${users.length} and i value is $i");
                      await addFriend(
                          context, result, users[i]);
                      Navigator.of(context).pop();
                      refreshPage(true, User(accountAddress: result, name: users[i]));
                    } else {
                      print("No user found that matches the condition.");
                    }
                  }
                  else{
                    print("name");
                    int i = 0;
                    for (var k in users) {
                      if (k.compareTo(result) == 0) {
                        print("match found $i");
                        break;
                      }
                      i++;
                    }
                    if (i < users.length) {
                      i++;
                      print("length is ${users.length} and i value is $i ${users[i].length}");
                      await addFriend(
                          context, users[i], result);
                      Navigator.of(context).pop();
                      refreshPage(true, User(accountAddress: users[i], name: result));
                    }
                  }
                },
              );
            },
          );
        }
      },
    );
  }


  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        },
      ),
      title: Text('Search'),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
          },
        ),
      ],
      // Adjust size of search icon by changing the value of size property
      iconTheme: IconThemeData(size: 30.0),
    );
  }
}
