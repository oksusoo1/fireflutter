import 'package:example/widgets/chat.user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Text('You have logged in as ${snapshot.data!.email}'),
                      ElevatedButton(
                          onPressed: () => FirebaseAuth.instance.signOut(),
                          child: const Text('Sign Out')),
                      const Divider(),
                      const Text('Chat with;'),
                      Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children: const [
                          ChatUser(name: 'Apple', uid: '#aaa'),
                          ChatUser(name: 'Banana', uid: '#aaa'),
                          ChatUser(name: 'Cherry', uid: '#aaa'),
                        ],
                      )
                    ],
                  );
                } else {
                  return ElevatedButton(
                    child: const Text('Sign-In'),
                    onPressed: () {
                      Get.toNamed('/sign-in');
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
