import 'package:fe/screens/unit_test/unit_test.service.dart';
import 'package:fe/service/config.dart';
import 'package:flutter/material.dart';

import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostUnitTest extends StatefulWidget {
  const PostUnitTest({Key? key}) : super(key: key);

  @override
  State<PostUnitTest> createState() => _PostUnitTestState();
}

class _PostUnitTestState extends State<PostUnitTest> {
  String currentTest = '';
  late UserModel a;
  late UserModel b;
  late UserModel c;
  late UserModel d;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(onPressed: runTests, child: Text('Run Post Unit Test')),
        if (currentTest.isNotEmpty) Text('Task: $currentTest'),
        Divider(),
        ...UnitTestService.logTexts.map(
          (e) => Text(e, style: TextStyle(color: e.contains('ERROR:') ? Colors.red : Colors.black)),
        )
      ],
    );
  }

  runTests() async {
    UnitTestService.logTexts = [];
    await createPostNotLoggedIn();
    await createPostLoggedIn();
  }

  createPostNotLoggedIn() async {
    setCurrentTest('Creating post without signing in');
    await FirebaseAuth.instance.signOut();

    dynamic outcome = await UnitTestService.getOutcome(
      () => PostApi.instance.create(category: 'qna'),
    );
    UnitTestService.expect(
      outcome == ERROR_NOT_SIGN_IN,
      'Post creation failure without signing in.',
    );
    endCurrentTest();
  }

  createPostLoggedIn() async {
    setCurrentTest('Creating post with signing in');
    await UnitTestService.signIn(a);

    dynamic outcome = await UnitTestService.getOutcome(
      () => PostApi.instance.create(category: 'qna', title: 'AAA'),
    );
    UnitTestService.expect(outcome is PostModel, 'Post creation success.');
    UnitTestService.expect((outcome as PostModel).title == 'AAA', 'Post title matched.');
    endCurrentTest();
  }

  setCurrentTest(String task) {
    setState(() => currentTest = task);
  }

  endCurrentTest() {
    setState(() => currentTest = '');
  }
}
