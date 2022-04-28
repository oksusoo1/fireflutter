import 'package:fe/screens/unit_test/unit_test.service.dart';
import 'package:flutter/material.dart';

import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostUnitTest extends StatefulWidget {
  const PostUnitTest({Key? key}) : super(key: key);

  @override
  State<PostUnitTest> createState() => _PostUnitTestState();
}

class _PostUnitTestState extends State<PostUnitTest> {
  final test = UnitTestService.instance;
  String currentTest = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(onPressed: runTests, child: Text('Run Post Unit Test')),
        if (currentTest.isNotEmpty) Text('Task: $currentTest'),
        Divider(),
        ...test.logs.map(
          (e) => Text(e, style: TextStyle(color: e.contains('ERROR:') ? Colors.red : Colors.black)),
        )
      ],
    );
  }

  runTests() async {
    test.logs = [];
    await createPostNotLoggedIn();
    await createPostLoggedIn();
  }

  createPostNotLoggedIn() async {
    setCurrentTest('Creating post without signing in');
    await FirebaseAuth.instance.signOut();

    dynamic outcome = await test.getOutcome(
      () => PostApi.instance.create(category: 'qna'),
    );
    test.expect(
      outcome == ERROR_NOT_SIGN_IN,
      'Post creation failure without signing in.',
    );
    endCurrentTest();
  }

  createPostLoggedIn() async {
    setCurrentTest('Creating post with signing in');
    await test.signIn(test.a);

    dynamic outcome = await PostApi.instance.create(category: 'qna', title: 'AAA');
    test.expect(outcome is PostModel, 'Post creation success.');
    test.expect((outcome as PostModel).title == 'AAA', 'Post title matched.');
    endCurrentTest();
  }

  setCurrentTest(String task) {
    setState(() => currentTest = task);
  }

  endCurrentTest() {
    setState(() => currentTest = '');
  }
}
