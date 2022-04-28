import 'dart:developer';

import 'package:extended/extended.dart';
import 'package:fe/screens/unit_test/forum/post_unit_test.dart';
import 'package:fe/service/config.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Custom unit tests for fireflutter.
///
/// It will first prepqre the test accounts, test category, and test post.
/// To sign-in a user A, B, C, just call `await signIn(a)`, `await signIn(b)`, `await signIn(c)`.
///
class UnitTestScreen extends StatefulWidget {
  const UnitTestScreen({Key? key}) : super(key: key);

  static const String routeName = '/unitTest';

  @override
  State<UnitTestScreen> createState() => _UnitTestScreenState();
}

class _UnitTestScreenState extends State<UnitTestScreen> with DatabaseMixin, FirestoreMixin {
  late User user;
  late PostModel post;
  late UserModel a;
  late UserModel b;
  late UserModel c;
  late UserModel d;

  List<String> logTexts = [];
  bool waiting = false;
  String waitingMessage = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    a = UserModel(uid: Config.testUsers['apple']!['uid']!);
    await a.load();
    b = UserModel(uid: Config.testUsers['banana']!['uid']!);
    await b.load();
    c = UserModel(uid: Config.testUsers['cherry']!['uid']!);
    await c.load();
  }

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
                  if (waiting) ...[
                    CircularProgressIndicator.adaptive(),
                    spaceXxs,
                    Text(waitingMessage),
                  ],
                ],
              ),
              ...logTexts
                  .map((e) => Text(
                        e,
                        style: TextStyle(color: e.contains('ERROR:') ? Colors.red : Colors.black),
                      ))
                  .toList(),
              PostUnitTest(),
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
  /// 1. Check user accounts of apple, banana, cherry.
  /// 2. Check if QnA category exists.
  /// 3. Create a test post
  /// 4. Create a test comment
  prepareTest() async {
    print('a; $a');

    final categories = await CategoryService.instance.getCategories();
    final qnaExists = categories.indexWhere((element) => element.id == 'qna') != -1;
    check(qnaExists, "QnA category must exists!");

    await signIn(a);

    post = await PostApi.instance.create(category: 'qna');

    log(post.toString());
  }

  Future signIn(UserModel u) async {
    final e = Config.testUsers.entries.firstWhere((element) => element.value['uid'] == u.uid);
    final email = Config.testUsers[e.key]!['email']!;
    print('signIn as; $email');

    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: '12345a');

    return wait(500, 'Sign-in as $email');
  }

  reportingTest() async {
    await FirebaseAuth.instance.signOut();
    try {
      await createReport(target: 'post', targetId: post.id, reporteeUid: post.uid);
      check(false, "Expect failure but succeed - Reporting without sign-in must fail.");
    } catch (e) {
      check(e == ERROR_NOT_SIGN_IN,
          "Expecting failure with ERROR_NOT_SIGN_IN - Reporting without sign-in must fail.");
    }

    await signIn(b);
    try {
      final id = await createReport(target: 'post', targetId: post.id, reporteeUid: post.uid);
      check(true, "Expect success and succeed.");
      final snapshot = await reportDoc(id).get();

      check(snapshot.exists, 'Report document exists.');

      final data = snapshot.data() as Map;
      check(data['targetId']! == post.id, 'Reported target id match.');
    } catch (e) {
      check(false, "Expect success but failed with; $e");
    }
  }

  Future wait(int ms, String msg) async {
    setState(() {
      waiting = true;
      waitingMessage = msg;
    });
    await Future.delayed(Duration(milliseconds: ms));
    setState(() {
      waiting = false;
      waitingMessage = '';
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
