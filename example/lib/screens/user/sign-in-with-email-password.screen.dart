import 'package:example/services/global.dart';
import 'package:example/widgets/layout/layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInWithEmailAndPasswordScreen extends StatefulWidget {
  const SignInWithEmailAndPasswordScreen({Key? key}) : super(key: key);

  static const String routeName = '/signInWithEmailAndPassword';

  @override
  State<SignInWithEmailAndPasswordScreen> createState() =>
      _SignInWithEmailAndPasswordScreenState();
}

class _SignInWithEmailAndPasswordScreenState
    extends State<SignInWithEmailAndPasswordScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Text(
        'Email & Password Sign-in',
        style: TextStyle(color: Colors.blue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(label: Text('Email')),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(label: Text('Password')),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email.text,
                    password: password.text,
                  );
                  service.router.openHome();
                } on FirebaseException catch (e) {
                  if (e.code == 'email-already-in-use') {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email.text,
                      password: password.text,
                    );
                    service.router.openHome();
                  } else {
                    rethrow;
                  }
                }
              },
              child: Text('Sign-in Or Register'),
            ),
          ],
        ),
      ),
    );
  }
}
