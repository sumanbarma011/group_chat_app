import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_chat_app/widgets/chart_message.dart';
import 'package:group_chat_app/widgets/new_message.dart';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';// for push notification

class Chart extends StatefulWidget {
  const Chart({super.key});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  
  void sendPushNotification()async{
     final fcm=FirebaseMessaging.instance; // push notification instance
   await fcm.requestPermission();
   final token= await fcm.getToken(); // address of the device
   log('$token'); 
   fcm.subscribeToTopic('chat');// send noifications to all devices related to channel chat
    
  }
  @override
  void initState() {
    sendPushNotification();
   
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chart Screen'),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut(); // to signout user
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          ],
        ),
        body: Column(
          children: const [
            Expanded(
              child: ChartMessage(),
            ),
            NewMessages(),
          ],
        ));
  }
}
