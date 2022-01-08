import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestUser extends StatelessWidget {
  const TestUser({required this.name, required this.uid, Key? key})
      : super(key: key);
  final String name;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () =>
                Get.toNamed('/chat-room-screen', arguments: {'uid': uid}),
            child: Text(name),
          ),
          UserPresence(
            uid: uid,
            onlineBuilder: () => Row(
              children: const [
                Icon(Icons.circle, color: Colors.green),
                Text('Online'),
              ],
            ),
            offlineBuilder: () => Row(
              children: const [
                Icon(Icons.circle, color: Colors.red),
                Text('Offline'),
              ],
            ),
            awayBuilder: () => Row(
              children: const [
                Icon(Icons.circle, color: Colors.yellow),
                Text('Away'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
