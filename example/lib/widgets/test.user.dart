import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestUser extends StatelessWidget {
  const TestUser({required this.email, required this.name, required this.uid, Key? key})
      : super(key: key);
  final String email;
  final String name;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => Get.toNamed('/chat-room-screen', arguments: {'uid': uid}),
            child: Text(name),
          ),
          UserPresence(
            uid: uid,
            builder: (PresenceType type) => Row(
              children: [
                Icon(
                  Icons.circle,
                  color: type == PresenceType.online
                      ? Colors.green
                      : (type == PresenceType.offline ? Colors.red : Colors.yellow),
                ),
                Text(type.name),
              ],
            ),
          ),
          TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                      email: email,
                      password: '12345a',
                    )
                    .catchError(error);
              },
              child: const Text('Login')),
        ],
      ),
    );
  }
}
