import 'dart:developer';

import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UnitTestScreen extends StatefulWidget {
  const UnitTestScreen({Key? key}) : super(key: key);

  static const String routeName = '/unitTest';

  @override
  State<UnitTestScreen> createState() => _UnitTestScreenState();
}

class _UnitTestScreenState extends State<UnitTestScreen> with DatabaseMixin, FirestoreMixin {
  late User user;
  late PostModel post;
  List<String> logTexts = [];
  bool waiting = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Unit Testing')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: runTests,
                    child: Text('Start Unit Testing'),
                  ),
                  spaceXs,
                  if (waiting) CircularProgressIndicator.adaptive()
                ],
              ),
              ...logTexts
                  .map((e) => Text(
                        e,
                        style: TextStyle(color: e.contains('ERROR:') ? Colors.red : Colors.black),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  runTests() async {
    logTexts = [];
    await prepareTest();
    await reportingTest();
  }

  /// Prepares the test
  ///
  /// 1. Create a test user account
  /// 2. Check if QnA category exists.
  /// 3. Create a test post
  /// 4. Create a test comment
  prepareTest() async {
    /// Create a user
    String stamp = DateTime.now().millisecondsSinceEpoch.toString();
    String email = "unit-test-user-$stamp@test.com";
    String password = "$email$stamp";
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    user = cred.user!;

    check(cred.user != null, 'Test user created.');

    await wait(1000);
    await userDoc(user.uid).update({
      'email': email,
      'firstName': 'firstName',
      'lastName': 'lastName',
      'nickname': 'firstName + lastName',
      'birthday': 19731010,
      'gender': 'M',
      'photoUrl': 'https://philgo.com/test.jpg',
      'profileReady': 80000000000000,
      'registeredAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });

    final categories = await CategoryService.instance.getCategories();
    final qnaExists = categories.indexWhere((element) => element.id == 'qna') != -1;
    check(qnaExists, "QnA category must exists!");

    post = await PostApi.instance.create(category: 'qna');

    log(post.toString());
  }

  reportingTest() async {
    await FirebaseAuth.instance.signOut();
    try {
      await createReport(target: 'post', targetId: post.id, reporteeUid: post.uid);
      check(false, "Reporting without sign-in must fail.");
    } catch (e) {
      check(true, "Reporting without sign-in must fail.");
    }
  }

  Future wait(int ms) async {
    setState(() {
      waiting = true;
    });
    await Future.delayed(Duration(milliseconds: ms));
    setState(() {
      waiting = false;
    });
  }

  check(bool re, String msg) {
    String info;
    if (re) {
      info = 'SUCCESS: $msg';
    } else {
      info = 'ERROR: $msg';
    }
    log(info);
    setState(() {
      logTexts.add(info);
    });
  }
}
