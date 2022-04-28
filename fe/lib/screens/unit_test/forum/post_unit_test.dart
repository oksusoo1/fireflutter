import 'dart:async';

import 'package:fe/screens/unit_test/unit_test.service.dart';
import 'package:fe/service/global.keys.dart';
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
    // await createPostWithoutSignIn();
    // await createPostSuccess();
    await updatePostWithoutSignIn();
    await updatePostWithDifferentUser();
  }

  createPostWithoutSignIn() async {
    setCurrentTest('Creating post without signing in');
    await FirebaseAuth.instance.signOut();

    // Problem : if this is implemented, other tests will not run also.
    // test.onError = (e) {
    //   test.expect(e == ERROR_NOT_SIGN_IN, 'Post creation failure without signing in.');
    //   Timer(Duration(milliseconds: 200), () {
    //     Navigator.of(globalNavigatorKey.currentContext!).pop();
    //   });
    // };

    try {
      await PostApi.instance.create(category: 'qna');
      test.expect(false, 'Post creation should fail without logging in.');
    } catch (e) {
      test.expect(e == ERROR_NOT_SIGN_IN, 'Post creation failure without signing in.');
    }
    endCurrentTest();
  }

  createPostSuccess() async {
    setCurrentTest('Creating post with signing in');
    await test.signIn(test.a);

    PostModel post = await PostApi.instance.create(category: 'qna', title: 'AAA');
    test.expect(post.id.isNotEmpty, 'Post creation success.');
    test.expect(post.title == 'AAA', 'Post title matched.');
    endCurrentTest();
  }

  updatePostWithoutSignIn() async {
    setCurrentTest('Updating post without signing in');
    await test.signIn(test.b);
    final orgPost = await PostApi.instance.create(category: 'qna');

    await FirebaseAuth.instance.signOut();
    try {
      await PostApi.instance.update(
        id: orgPost.id,
        title: orgPost.title,
        content: orgPost.content,
      );
      test.expect(false, 'Post update should fail without signing in.');
    } catch (e) {
      test.expect(e == ERROR_NOT_SIGN_IN, 'Post update failure without signing in.');
    }
    endCurrentTest();
  }

  updatePostWithDifferentUser() async {
    setCurrentTest('Updating post without signing in');
    await test.signIn(test.a);
    final orgPost = await PostApi.instance.create(category: 'qna');

    await FirebaseAuth.instance.signOut();
    await test.signIn(test.b);
    try {
      await PostApi.instance.update(
        id: orgPost.id,
        title: orgPost.title,
        content: orgPost.content,
      );
      test.expect(false, 'Post update should fail without signing in.');
    } catch (e) {
      test.expect(e == ERROR_NOT_YOUR_POST, 'Post update failure with different user.');
    }
    endCurrentTest();
  }

  setCurrentTest(String task) {
    setState(() => currentTest = task);
  }

  endCurrentTest() {
    setState(() => currentTest = '');
  }
}
