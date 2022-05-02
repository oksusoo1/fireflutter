import 'package:fe/screens/forum/post.form.screen.dart';
import 'package:fe/screens/unit_test/unit_test.service.dart';
import 'package:fe/services/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostScreenTestController {
  late final _PostScreenTestState state;
}

class PostScreenTest extends StatefulWidget {
  const PostScreenTest({Key? key, required this.controller}) : super(key: key);
  final PostScreenTestController controller;

  @override
  State<PostScreenTest> createState() => _PostScreenTestState();
}

class _PostScreenTestState extends State<PostScreenTest> with UnitTestMixin, FirestoreMixin {
  final ut = UnitTestService.instance;

  PostFormController postFormController = PostFormController();

  @override
  void initState() {
    super.initState();
    widget.controller.state = this;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          clearLogs();
          runTests();
        },
        child: Text('Post screen test'));
  }

  runTests() async {
    await testPostFormWithoutSignIn();
    await testPostFormEmptyCategory();
    await testPostForm();
  }

  Future openPostFormScreen() async {
    AppService.instance.router
        .open(PostFormScreen.routeName, arguments: {'postFormController': postFormController});

    return ut.wait(200, 'Injecting post form controller in post edit screen.');
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
    await ut.comeBack();
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
    await ut.comeBack();
  }

  /// Success
  ///
  /// After create a post, the post form screen pops the page. So, it does not need to pop it here.
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
      fail('testPostForm should succeed - $e');
    }
  }
}
