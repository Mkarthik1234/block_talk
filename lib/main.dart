import 'package:flutter/material.dart';
import 'Screens/HomeScreen.dart';
import 'Blockchain/connect.dart';
import 'CustomWidgets/metamaskerror.dart';
import 'Screens/Registration/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';



//check for metamask
//check for registered

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool userIsRegistered = false;
  late String user_address = "";
  late String user_name = "";
  Connector connector = Connector();

  @override
  void initState() {
    super.initState();
    if (connector.isEnabled) {
      _initializeUserData();
    }
  }

  Future<void> _initializeUserData() async {
    await set_user_address();
    await connector.connect();
    String add = await get_user_address();
    print("user address is $user_address");
    var result = await connector.getcontract(context, "checkUserExists", [add]);
    if (result == true) {
      var name = await connector.getcontract(context, "getUsername", [add]);
      setState(() {
        userIsRegistered = true;
        user_address = add;
        user_name = name.toString();
      });
    }
    else {
      setState(() {
        user_address = add;
      });
    }
  }

  Future<void> set_user_address() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString("current_user_address", "");
    await pref.setString("current_user_name", "");
    await pref.setString("Friend_List", "Empty");
  }

  Future<String> get_user_address() async {
    final pref = await SharedPreferences.getInstance();
    final address = pref.getString("current_user_address")!;
    return address;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Block Talk',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xff145C9E),
          scaffoldBackgroundColor: const Color(0xff1F1F1F),
          hintColor: const Color(0xff007EF4),
          fontFamily: "OverpassRegular",
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: !connector.isEnabled ?
        const Scaffold(
          body: MetamaskErrorCustomDialogBox(),
        ) : user_address.isNotEmpty ?
        userIsRegistered ?
        HomeScreen(useraddress: user_address,username: user_name,) : RegisterScreen(user_address: user_address)
            : Scaffold(
          body: Container(
            color: Colors.black,
          ),
        )

    );
  }
}
