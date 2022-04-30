import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:example/widgets/layout/layout.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  static const String routeName = '/test';

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    super.initState();
    UserService.instance.updateAdminStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Text(
        'Test Screen',
        style: TextStyle(color: Colors.blue),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: 'asdf',
                password: 'wrong.email,*',
              );
            },
            child: Text('Produce FirebaseAuth - invalid-email Exception'),
          ),
          TextButton(
            onPressed: () {
              throw 'test-exception';
            },
            child: Text('Throw an error with `throw`'),
          ),
        ],
      ),
    );
  }
}
