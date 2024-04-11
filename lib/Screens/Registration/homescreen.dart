import 'dart:js_util';
import 'dart:ui';
import 'package:block_talk_v3/main.dart';

import 'package:block_talk_v3/Blockchain/connect.dart';
import 'package:flutter/material.dart';

import 'animation.dart';
import 'datafile.dart';
import 'textutils.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:block_talk_v3/Modals/User.dart';

class RegisterScreen extends StatefulWidget {
  late String user_address;

  RegisterScreen({required this.user_address});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int selectedIndex = 0;
  bool showOption = false;
  bool _usernameError = false;

  TextEditingController usernamecontroller = new TextEditingController();
  TextEditingController addresscontroller = new TextEditingController();

  Future<List<String>> fetchUsers(BuildContext context) async {
    print("HIIIIIIIIIIIIIIII");
    Connector h = Connector();
    List<dynamic> userdata = await h.getcontract(context, "getAllAppUser", []);
    List<List<dynamic>> userList = userdata.cast<List<dynamic>>();

    List<String> users = userList.map((data) {
      return data[0].toString().toLowerCase();
    }).toList();

    return users;
  }

  @override
  Widget build(BuildContext context) {
    addresscontroller.text = widget.user_address;
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(vertical: 50),
        height: 49,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
                child: showOption
                    ? ShowUpAnimation(
                        delay: 100,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: bgList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: selectedIndex == index
                                      ? Colors.white
                                      : Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: AssetImage(
                                        bgList[index],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      )
                    : const SizedBox()),
            const SizedBox(
              width: 20,
            ),
            showOption
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        showOption = false;
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ))
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        showOption = true;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(
                            bgList[selectedIndex],
                          ),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(bgList[selectedIndex]), fit: BoxFit.fill),
        ),
        alignment: Alignment.center,
        child: Container(
          height: h / 1.5,
          width: w / 2,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(),
                      Center(
                          child: TextUtil(
                        text: "Sign up",
                        weight: true,
                        size: 30,
                      )),
                      const Spacer(),
                      TextUtil(
                        text: "Username",
                      ),
                      Container(
                        height: 35,
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.white))),
                        child: TextFormField(
                          controller: usernamecontroller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            suffixIcon: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            fillColor: Colors.white,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextUtil(
                        text: "Public Key",
                      ),
                      Container(
                        height: 35,
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.white))),
                        child: TextFormField(
                          readOnly: true,
                          controller: addresscontroller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            suffixIcon: Icon(
                              Icons.key_sharp,
                              color: Colors.white,
                            ),
                            fillColor: Colors.white,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          Connector h = Connector();
                          bool UsernameExists = false;
                          print(
                              "[registration] User address is ${widget.user_address}");
                          List<String> res =
                              await fetchUsers(context);
                          print("[registration page] res is $res");
                          if(res.contains(usernamecontroller.text.toLowerCase())){
                            print("username exists");
                            UsernameExists = true;
                          }
                          if (usernamecontroller.text.isNotEmpty &&
                              addresscontroller.text.isNotEmpty &&
                              !UsernameExists) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              // Prevent dismissing dialog by tapping outside
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 0.0,
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        CircularProgressIndicator(),
                                        SizedBox(height: 20.0),
                                        Text(
                                          "Processing...",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                            await h.getcontract(context, "createAccount",
                                [usernamecontroller.text]);

                            SharedPreferences preference;
                            preference = await SharedPreferences.getInstance();
                            preference.setBool("RegistrationPreviouspage", true);

                            checkuseradded(context, addresscontroller.text);
                          } else if (usernamecontroller.text.isEmpty ||
                              addresscontroller.text.isEmpty) {
                            ErrorMessage(context,
                                "Please fill in both the username and public key fields.");
                          } else if (UsernameExists == true) {
                            ErrorMessage(context, "Username already taken.");
                          }
                        },
                        child: Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30)),
                          alignment: Alignment.center,
                          child: TextUtil(
                            text: "Register",
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  Future<dynamic> ErrorMessage(BuildContext context, String message) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

Future<void> checkuseradded(BuildContext contex, String address) async {
  Contract? contract;
  final abistringfile = await DefaultAssetBundle.of(contex)
      .loadString("build/contracts/Chat.json");
  final abijson = jsonDecode(abistringfile);
  final abi = jsonEncode(abijson["abi"]);

  final contractAddress = "0xbD58270A35A26092602027946ACC1d4b875456b5";
  print("Contract address is $contractAddress");

  if (provider != null) {
    try {
      contract = Contract(contractAddress, abi, provider!.getSigner());
      final filter = contract!.getFilter('UserAdded');
      contract!.on(filter, (event, dynamic c) {
        print(
            "User Added: ${event.toString().toLowerCase()} and address is ${address.toLowerCase()}");
        if (event.toString().toLowerCase() == address.toLowerCase()) {
          Navigator.push(
            contex,
            MaterialPageRoute(
                builder: (context) =>
                    MyApp()), // Replace MyApp with the desired page widget
          );
        }
      });
      print("Listening for 'UserAdded' event...");
    } on Exception catch (error) {
      print("Error creating contract or listening for event: $error");
    }
  } else {
    print("Provider is not yet available");
  }
}
