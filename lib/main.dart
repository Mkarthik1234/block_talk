import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CustomWidgets/metamaskerror.dart';
import 'Screens/HomeScreen2.dart';
import 'Screens/Registration/homescreen.dart';
import 'Blockchain/connect.dart';

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
  int key = 0; // Key to force rebuild

  @override
  void initState() {
    super.initState();
    if (connector.isEnabled) {
      _initializeUserData();
      connector.init();
      connector.onAccountChanged((newAccount) {
        _handleAccountChange(newAccount);
      });
    }
  }

  Future<void> _initializeUserData() async {
    if (connector.isEnabled ?? false) {
      print("inside initializeuserdata int main +++++++++++++++++++++++++++++++");
      await set_user_address();
      await connector.connect();
      String add = await get_user_address();
      print("[main] user address is $user_address");
      var result =
      await connector.getcontract(context, "checkUserExists", [add]);
      if (result == true) {
        var name = await connector.getcontract(context, "getUsername", [add]);
        setState(() {
          userIsRegistered = true;
          user_address = add;
          user_name = name.toString();
        });
      } else {
        setState(() {
          user_address = add;
        });
      }
    }
  }

  Future<void> set_user_address() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString("current_user_address", "");
    await pref.setString("current_user_name", "");
    await pref.setString("Friend_List", "Empty");
    bool? showcaseVisibilityStatus = pref.getBool("RegistrationPreviouspage");
    if (showcaseVisibilityStatus == null) {
      await pref.setBool("RegistrationPreviouspage", false);
    }
  }

  Future<String> get_user_address() async {
    final pref = await SharedPreferences.getInstance();
    final address = pref.getString("current_user_address")!;
    return address;
  }

  void _handleAccountChange(String? newAccount) {
    if (newAccount != null) {
      setState(() {
        user_address = newAccount;
        key++; // Incrementing the key to force a rebuild
        userIsRegistered = false; // Reset userIsRegistered
      });
      _initializeUserData();
    } else {
      // Navigate to the MetaMask error screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MetamaskErrorCustomDialogBox()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        key: Key(key.toString()),
        title: 'Block Talk',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
          home: !connector.isEnabled ?
        const Scaffold(
          body: MetamaskErrorCustomDialogBox(),
        ) : user_address.isNotEmpty ?
        userIsRegistered ?Home(useraddress: user_address,username: user_name,)
            : RegisterScreen(user_address: user_address)
            : Scaffold(
          body: Container(
            color: Colors.black,
          ),
        )
      );
    }
}

















// import 'package:flutter/material.dart';
// import 'Screens/HomeScreen2.dart';
// import 'Blockchain/connect.dart';
// import 'CustomWidgets/metamaskerror.dart';
// import 'Screens/Registration/homescreen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
//
// //check for metamask
// //check for registered
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   late bool userIsRegistered = false;
//   late String user_address = "";
//   late String user_name = "";
//   Connector connector = Connector();
//
//
//   @override
//   void initState() {
//     super.initState();
//     if (connector.isEnabled) {
//       _initializeUserData();
//     }
//     connector.init();
//   }
//
//   Future<void> _initializeUserData() async {
//     print("inside initializeuserdata int main +++++++++++++++++++++++++++++++");
//     await set_user_address();
//     await connector.connect();
//     String add = await get_user_address();
//     print("[main] user address is $user_address");
//     var result = await connector.getcontract(context, "checkUserExists", [add]);
//     if (result == true) {
//       var name = await connector.getcontract(context, "getUsername", [add]);
//       setState(() {
//         userIsRegistered = true;
//         user_address = add;
//         user_name = name.toString();
//       });
//     }
//     else {
//       setState(() {
//         user_address = add;
//       });
//     }
//   }
//
//   Future<void> set_user_address() async {
//     final pref = await SharedPreferences.getInstance();
//     await pref.setString("current_user_address", "");
//     await pref.setString("current_user_name", "");
//     await pref.setString("Friend_List", "Empty");
//     bool? showcaseVisibilityStatus = pref.getBool("RegistrationPreviouspage");
//     if(showcaseVisibilityStatus==null){
//       await pref.setBool("RegistrationPreviouspage", false);
//     }
//
//   }
//
//   Future<String> get_user_address() async {
//     final pref = await SharedPreferences.getInstance();
//     final address = pref.getString("current_user_address")!;
//     return address;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'Block Talk',
//         debugShowCheckedModeBanner: false,
//         // theme: ThemeData(
//         //   primaryColor: const Color(0xff145C9E),
//         //   scaffoldBackgroundColor: const Color(0xff1F1F1F),
//         //   hintColor: const Color(0xff007EF4),
//         //   fontFamily: "OverpassRegular",
//         //   visualDensity: VisualDensity.adaptivePlatformDensity,
//         // ),
//         theme: ThemeData.dark(),
//         home: !connector.isEnabled ?
//         const Scaffold(
//           body: MetamaskErrorCustomDialogBox(),
//         ) : user_address.isNotEmpty ?
//         userIsRegistered ?Home(useraddress: user_address,username: user_name,)
//             : RegisterScreen(user_address: user_address)
//             : Scaffold(
//           body: Container(
//             color: Colors.black,
//           ),
//         )
//
//     );
//   }
// }