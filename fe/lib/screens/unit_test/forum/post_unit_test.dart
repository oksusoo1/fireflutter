import 'package:fe/screens/unit_test/unit_test.service.dart';
import 'package:flutter/material.dart';

import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostUnitTestController {
  late _PostUnitTestState state;
}

class PostUnitTest extends StatefulWidget {
  const PostUnitTest({Key? key, this.controller}) : super(key: key);
  final PostUnitTestController? controller;

  @override
  State<PostUnitTest> createState() => _PostUnitTestState();
}

class _PostUnitTestState extends State<PostUnitTest> {
  final test = UnitTestService.instance;
  String currentTest = '';

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.state = this;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
            onPressed: () {
              test.logs = [];
              runTests();
            },
            child: Text('Run Post Unit Test')),
        if (currentTest.isNotEmpty) Text('Task: $currentTest'),
      ],
    );
  }

  runTests() async {
    await createPostNotLoggedIn();
    await createPostLoggedIn();
  }

  createPostNotLoggedIn() async {
    await FirebaseAuth.instance.signOut();

    final re = await test.submit(PostApi.instance.create(category: 'qna'));
    test.expect(
      re == ERROR_NOT_SIGN_IN,
      'Post creation failure without signing in.',
    );
  }

  createPostLoggedIn() async {
    await test.signIn(test.a);

    final re = await PostApi.instance.create(category: 'qna', title: 'AAA');
    test.expect(re.title == 'AAA', 'Post title matched.');
  }
}
