import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notification/second_screen.dart';

class NotificationServices {

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin=FlutterLocalNotificationsPlugin();

  requestForPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert : true,
      announcement : true,
      badge : true,
      carPlay : true,
      criticalAlert : true,
      provisional : true,
      sound : true,
    );

    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print('Permission granted');
    }
    else if(settings.authorizationStatus==AuthorizationStatus.provisional){
      print('Permission granted provosional');
    }
    else {
      AppSettings.openNotificationSettings().then((value) {});
      print('Permission denied');
    }
  }

  initLocalNotification(BuildContext context,RemoteMessage message)async{
    var androidSettings=const AndroidInitializationSettings('mipmap/ic_launcher');
    var iosSettings=const DarwinInitializationSettings();

    var intialization=InitializationSettings(
      android: androidSettings,
      iOS: iosSettings
    );
    await _localNotificationsPlugin.initialize(intialization,onDidReceiveNotificationResponse: (payload){
      handleMessage(context,message);
      }
    );
  }

  Future<void> showNotification(RemoteMessage message) async{

    AndroidNotificationChannel channel=AndroidNotificationChannel(Random.secure().nextInt(1000).toString(),
      'High Importance nitification',importance: Importance.high);

    AndroidNotificationDetails androidNotificationDetails=AndroidNotificationDetails(
        channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'My loading description',
      priority: Priority.high,
      importance: Importance.high ,
      ticker: 'Ticker'
        );
    DarwinNotificationDetails details=DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    NotificationDetails notificationDetails=NotificationDetails(
      android: androidNotificationDetails,
      // iOS: details
    );
    await _localNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails
    );

  }

  void firebaseInit(BuildContext context,){
    FirebaseMessaging.onMessage.listen((message) {

      if(kDebugMode){
        print('Title :${message.notification!.title.toString()}');
        print('Body : ${message.notification!.body.toString()}');
        print('Data : ${message.data.toString()}');
      }
      if(Platform.isAndroid){
        initLocalNotification(context, message);
        showNotification(message);
      }
      else {

      }

    });
  }

  Future<String> getTokens()async{
    String? token=await messaging.getToken();
   return token!;
  }

  void isTokenExperied(){
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print('refresh');
    });
  }


  void handleMessage(BuildContext context,RemoteMessage message){

    if(message.data['data']=='Hellow world'){
      Navigator.push(context,MaterialPageRoute(builder: (context)=>SecondScreen()));
    }
  }


  Future<void> setupInteractMessage(BuildContext context)async{
    //when app is terminated
    RemoteMessage? initialMessage=await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage!=null){
      handleMessage(context, initialMessage);
    }

    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });

  }

}
