import 'package:flutter/material.dart';
import 'package:block_talk_v3/theme.dart';
import 'package:block_talk_v3/Screens/profile.dart';

class SideMenu extends StatefulWidget {
  String user_name,user_address;
  SideMenu({required this.user_name,required this.user_address,Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  bool isregistered = true;

  @override
  Widget build(BuildContext context) {
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
              ? GestureDetector(
            onTap: (){
              showDialog(context: context, builder: (context)=>Profile(user_name: widget.user_name,user_address: widget.user_address,));
            },
                  child: Container(
                      padding: const EdgeInsets.all(5),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                      )))
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
            height: 70, // Adjust as needed
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child:
                Icon(Icons.home_outlined, color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: Icon(Icons.message_outlined,
                color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: Icon(Icons.settings_outlined,
                color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
