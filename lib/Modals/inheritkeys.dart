import 'package:flutter/cupertino.dart';

class keystobeinherited extends InheritedWidget{
  final GlobalKey profile;
  final GlobalKey newChat;
  final GlobalKey home,search,newChat2,transactionHistory;

  keystobeinherited({required this.profile,required this.newChat,required this.home,required this.search,required this.newChat2,required this.transactionHistory,required Widget child}):super(child: child);

  static keystobeinherited of(BuildContext context) {
    final keystobeinherited? result =
    context.dependOnInheritedWidgetOfExactType<keystobeinherited>();
    assert(result != null,
    'No Keystobeinherited found in context. Make sure to wrap your widget tree with Keystobeinherited.');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }
}