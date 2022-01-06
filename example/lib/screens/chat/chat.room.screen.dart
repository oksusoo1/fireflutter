import 'package:flutter/material.dart';

class ChatRoomScreen extends StatelessWidget {
  const ChatRoomScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat room'),
      ),

      /// TODO 1. check user exist. Or alert error.
      /// TODO 2. write a message
      /// TODO 3. create database rule
      /// TODO 4. list with `https://firebase.flutter.dev/docs/ui/database#installation`
      /// TODO 5. Display if user is online or offline.
      body: Container(),
    );
  }
}
