import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatUser extends StatelessWidget {
  const ChatUser({required this.name, required this.uid, Key? key}) : super(key: key);
  final String name;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => Get.toNamed('/chat-room-screen'), child: Text(name));
  }
}
