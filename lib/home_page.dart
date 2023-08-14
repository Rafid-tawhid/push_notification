import 'package:flutter/material.dart';
import 'package:push_notification/notification_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  NotificationServices services=NotificationServices();
  @override
  void initState() {
    services.requestForPermission();
    services.firebaseInit(context);
   // services.isTokenExperied();
    services.setupInteractMessage(context);
    services.getTokens().then((value) {
      print('Token is $value');
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications'),),
    );
  }
}
