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
    test.logs = [];
    // await createPostWithoutSignIn();
    // await createPostSuccess();
    await updatePostWithoutSignIn();
    await updateNotExistingPost();
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

  updateNotExistingPost() async {
    setCurrentTest('Updating post without signing in');
    await test.signIn(test.b);

    try {
      await PostApi.instance.update(
        id: 'not-existing-id----123',
        title: 'sometitle',
        content: 'someCOntent',
      );
      test.expect(false, 'Post update should fail because post does not exists.');
    } catch (e) {
      test.expect(e == ERROR_NOT_SIGN_IN, 'Post update failure - post does not exists.');
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
