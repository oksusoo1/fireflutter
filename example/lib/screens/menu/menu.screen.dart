import 'package:example/services/global.dart';
import 'package:example/widgets/layout/layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  static const String routeName = '/menu';

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Text(
        'Menu ...',
        style: TextStyle(color: Colors.blue),
      ),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              service.router.openHome();
            },
            child: Text('Sign-out'),
          ),
          Text('body'),
        ],
      ),
    );
  }
}
