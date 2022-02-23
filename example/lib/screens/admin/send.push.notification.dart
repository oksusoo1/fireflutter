import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PushNotificationScreen extends StatelessWidget {
  const PushNotificationScreen({this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/pushNotification';
  final Map? arguments;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Push Notification'),
      ),
      body: SendPushNotification(
        arguments: arguments,
        onError: error,
      ),
    );
  }
}
