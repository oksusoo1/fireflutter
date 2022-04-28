import 'dart:async';
import 'dart:developer';

import 'package:extended/extended.dart';
import 'package:fe/screens/forum/post.form.screen.dart';
import 'package:fe/screens/unit_test/forum/post_unit_test.dart';
import 'package:fe/screens/unit_test/unit_test.service.dart';
import 'package:fe/service/app.service.dart';
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
  final test = UnitTestService.instance;
  late User user;
  late PostModel post;

  PostUnitTestController postUnitTestController = PostUnitTestController();
  PostFormController postFormController = PostFormController();

  bool waiting = false;
  String waitingMessage = '';

  @override
  void initState() {
    super.initState();
    test.init(setState: (x) => setState(() {}));
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
                    Expanded(
                      child: Text(
                        waitingMessage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              PostUnitTest(controller: postUnitTestController),
              ...test.logs
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
    test.logs = [];

    await prepareTest();
    await reportingTest();
    await testCreatePostError();

    await postUnitTestController.state.runTests();

    await testPostFormWithoutSignIn();
    await testPostFormEmptyCategory();

    await testPostForm();
  }

  /// Prepares the test
  ///
  /// 1. Check user accounts of apple, banana, cherry.
  /// 2. Check if QnA category exists.
  /// 3. Create a test post
  /// 4. Create a test comment
  prepareTest() async {
    print('a; ${test.a}');

    final categories = await CategoryService.instance.getCategories();
    final qnaExists = categories.indexWhere((element) => element.id == 'qna') != -1;
    test.expect(qnaExists, "QnA category must exists!");

    await signIn(test.a);

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

  Future signOut() async {
    await FirebaseAuth.instance.signOut();

    return wait(200, 'Sign-out');
  }

  reportingTest() async {
    await FirebaseAuth.instance.signOut();
    try {
      await createReport(target: 'post', targetId: post.id, reporteeUid: post.uid);
      test.expect(false, "Expect failure but succeed - Reporting without sign-in must fail.");
    } catch (e) {
      test.expect(e == ERROR_NOT_SIGN_IN,
          "Expecting failure with ERROR_NOT_SIGN_IN - Reporting without sign-in must fail.");
    }

    await signIn(test.b);
    try {
      final id = await createReport(target: 'post', targetId: post.id, reporteeUid: post.uid);
      test.expect(true, "Expect success and succeed.");
      final snapshot = await reportDoc(id).get();

      test.expect(snapshot.exists, 'Report document exists.');

      final data = snapshot.data() as Map;
      test.expect(data['targetId']! == post.id, 'Reported target id match.');
    } catch (e) {
      test.expect(false, "Expect success but failed with; $e");
    }
  }

  testCreatePostError() async {
    await signIn(test.a);
    try {
      await PostApi.instance.create(category: 'wrong-category');
    } catch (e) {
      test.expect(e == ERROR_CATEGORY_NOT_EXISTS, "Post creation with wrong category must failed.");
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
      test.fail('Post creation without sign-in must fail');
    } catch (e) {
      test.expect(e == ERROR_NOT_SIGN_IN, 'Post creation without sign-in must fail - $e');
    }
    await comeBack();
  }

  testPostFormEmptyCategory() async {
    await openPostFormScreen();
    postFormController.state.title.text = 'Yo';
    try {
      await postFormController.state.onSubmit();
      test.fail('Post creation without category must fail');
    } catch (e) {
      test.expect(e == ERROR_EMPTY_CATEGORY, 'Post creation without category must fail');
    }
    await comeBack();
  }

  testPostForm() async {
    await signIn(test.a);
    await openPostFormScreen();
    postFormController.state.category = 'qna';
    String title = 'Test - ' + DateTime.now().millisecondsSinceEpoch.toString();
    postFormController.state.title.text = title;
    try {
      PostModel created = await postFormController.state.onSubmit();

      test.expect(created.title == title, 'Post create success - $title');

      final snapshot = await postDoc(created.id).get();
      test.expect(snapshot.exists, 'Post exists');
      test.expect((snapshot.data() as Map)['title']! == title, 'Post title match.');

      final id = await created.delete();
      test.expect(id == created.id, 'Post deleted - $id');
    } catch (e) {
      test.fail('Post creation without category must fail - $e');
    }
    await comeBack();
  }
}
