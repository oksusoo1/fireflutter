import 'package:extended/extended.dart';
import 'package:fe/screens/unit_test/forum/comment_unit_test.dart';
import 'package:fe/screens/unit_test/forum/post_screen.test.dart';
import 'package:fe/screens/unit_test/forum/post_unit_test.dart';
import 'package:fe/screens/unit_test/forum/voting_unit_test.dart';
import 'package:fe/screens/unit_test/job/job_seeker_unit_test.dart';
import 'package:fe/screens/unit_test/job/job_unit_test.dart';
import 'package:fe/screens/unit_test/report/report.test.dart';
import 'package:fe/screens/unit_test/unit_test.service.dart';
import 'package:fe/services/defines.dart';
import 'package:fe/widgets/layout/layout.dart';
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

  final ut = UnitTestService.instance;

  PostUnitTestController postUnitTestController = PostUnitTestController();
  CommentUnitTestController commentUnitTestController = CommentUnitTestController();
  VoteUnitTestController voteUnitTestController = VoteUnitTestController();
  JobUnitTestController jobUnitTestController = JobUnitTestController();
  JobSeekerUnitTestController jobSeekerUnitTestController = JobSeekerUnitTestController();
  ReportTestController reportTestController = ReportTestController();
  PostScreenTestController postScreenTestController = PostScreenTestController();

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Text(
        'Unit Testing',
        style: titleStyle,
      ),
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
                  PostScreenTest(
                    controller: postScreenTestController,
                  ),
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

    await reportTestController.state.runTests();
    await postScreenTestController.state.runTests();

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
}
