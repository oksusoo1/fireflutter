import 'dart:async';
import 'package:extended/extended.dart';
import 'package:fe/screens/forum/post.form.screen.dart';
import 'package:fe/screens/unit_test/forum/comment_unit_test.dart';
import 'package:fe/screens/unit_test/forum/post_unit_test.dart';
import 'package:fe/screens/unit_test/forum/voting_unit_test.dart';
import 'package:fe/screens/unit_test/job/job_seeker_unit_test.dart';
import 'package:fe/screens/unit_test/job/job_unit_test.dart';
import 'package:fe/screens/unit_test/report/report.test.dart';
import 'package:fe/service/app.service.dart';
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

class _UnitTestScreenState extends State<UnitTestScreen>
    with DatabaseMixin, FirestoreMixin, UnitTestMixin {
  // final test = UnitTestService.instance;
  late User user;
  late PostModel post;

  PostUnitTestController postUnitTestController = PostUnitTestController();
  CommentUnitTestController commentUnitTestController = CommentUnitTestController();
  VoteUnitTestController voteUnitTestController = VoteUnitTestController();
  JobUnitTestController jobUnitTestController = JobUnitTestController();
  JobSeekerUnitTestController jobSeekerUnitTestController = JobSeekerUnitTestController();
  PostFormController postFormController = PostFormController();
  ReportTestController reportTestController = ReportTestController();

  @override
  void initState() {
    super.initState();
    init();
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
              ElevatedButton(
                onPressed: runTests,
                child: Text('Start All Unit Tests'),
              ),
              Wrap(
                spacing: 8,
                children: [
                  PostUnitTest(controller: postUnitTestController),
                  CommentUnitTest(controller: commentUnitTestController),
                  VoteUnitTest(controller: voteUnitTestController),
                  JobUnitTest(controller: jobUnitTestController),
                  JobSeekerUnitTest(controller: jobSeekerUnitTestController),
                  ReportTest(controller: reportTestController),
                ],
              ),
              UnitTestLogs()
            ],
          ),
        ),
      ),
    );
  }

  runTests() async {
    clearLogs();

    await testCreatePostError();

    await postUnitTestController.state.runTests();
    await commentUnitTestController.state.runTests();
    await voteUnitTestController.state.runTests();
    await jobUnitTestController.state.runTests();
    await jobSeekerUnitTestController.state.runTests();

    await testPostFormWithoutSignIn();
    await testPostFormEmptyCategory();
    await testPostForm();
    await reportTestController.state.runTests();

    alert('Test done.', 'Test summary:\nSuccess: ${model.success}\nErrors: ${model.error}');
  }

  testCreatePostError() async {
    await signIn(a);
    try {
      await PostApi.instance.create(category: 'wrong-category');
    } catch (e) {
      expect(e == ERROR_CATEGORY_NOT_EXISTS, "Post creation with wrong category must failed.");
    }
  }

  Future openPostFormScreen() async {
    AppService.instance
        .open(PostFormScreen.routeName, arguments: {'postFormController': postFormController});

    return wait(200, 'Injecting post form controller in post edit screen.');
  }

  Future comeBack() async {
    AppService.instance.back();
    return wait(200, 'Opening unit test screen.');
  }

  testPostFormWithoutSignIn() async {
    await signOut();
    await openPostFormScreen();
    try {
      postFormController.state.category = 'qna';
      await postFormController.state.onSubmit();
      fail('Post creation without sign-in must fail');
    } catch (e) {
      expect(e == ERROR_NOT_SIGN_IN, 'Post creation without sign-in must fail - $e');
    }
    await comeBack();
  }

  testPostFormEmptyCategory() async {
    await openPostFormScreen();
    postFormController.state.title.text = 'Yo';
    try {
      await postFormController.state.onSubmit();
      fail('Post creation without category must fail');
    } catch (e) {
      expect(e == ERROR_EMPTY_CATEGORY, 'Post creation without category must fail');
    }
    await comeBack();
  }

  testPostForm() async {
    await signIn(a);
    await openPostFormScreen();
    postFormController.state.category = 'qna';
    String title = 'Test - ' + DateTime.now().millisecondsSinceEpoch.toString();
    postFormController.state.title.text = title;
    try {
      PostModel created = await postFormController.state.onSubmit();

      expect(created.title == title, 'Post create success - $title');

      final snapshot = await postDoc(created.id).get();
      expect(snapshot.exists, 'Post exists');
      expect((snapshot.data() as Map)['title']! == title, 'Post title match.');

      final id = await created.delete();
      expect(id == created.id, 'Post deleted - $id');
    } catch (e) {
      fail('Post creation without category must fail - $e');
    }
    await comeBack();
  }
}
