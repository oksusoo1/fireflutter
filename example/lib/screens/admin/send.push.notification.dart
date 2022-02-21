import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PushNotificationScreen extends StatelessWidget {
  const PushNotificationScreen({Key? key}) : super(key: key);

  static const String routeName = '/pushNotification';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification'),
      ),
      body: SendPushNotification(),
    );
  }
}
