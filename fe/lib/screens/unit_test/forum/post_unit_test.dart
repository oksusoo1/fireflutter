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
    return ElevatedButton(
      onPressed: () {
        test.logs = [];
        runTests();
      },
      child: Text('Run Post Unit Test'),
    );
  }

  runTests() async {
    /// failures
    await createPostWithoutSignIn();
    await createPostWithWrongCategory();
    await updatePostWithoutSignIn();
    await updateNotExistingPost();
    await updatePostWithDifferentUser();
    await deleteNotExistingPost();
    await deleteOtherUsersPost();
    await deleteAlreadyDeletedPost();

    /// successes
    await createPostSuccess();
    await updatePostSuccess();
    await deletePostSuccess();
  }

  createPostWithoutSignIn() async {
    await FirebaseAuth.instance.signOut();

    final re = await test.submit(PostApi.instance.create(category: 'qna'));
    test.expect(
      re == ERROR_NOT_SIGN_IN,
      'Cannot create post without signing in. - $re',
    );
  }

  createPostWithWrongCategory() async {
    await test.signIn(test.a);

    final re1 = await test.submit(PostApi.instance.create(category: ''));
    test.expect(
      re1 == ERROR_EMPTY_CATEGORY,
      'Cannot create post without category (empty) - $re1',
    );

    final re2 = await test.submit(PostApi.instance.create(category: 'wrongCategory'));
    test.expect(
      re2 == ERROR_CATEGORY_NOT_EXISTS,
      'Cannot create post with wrong category- $re2',
    );
  }

  updatePostWithoutSignIn() async {
    await test.signIn(test.b);
    final orgPost = await PostApi.instance.create(category: 'qna');

    await FirebaseAuth.instance.signOut();

    final re = await test.submit(PostApi.instance.update(
      id: orgPost.id,
      title: orgPost.title,
      content: orgPost.content,
    ));

    test.expect(
      re == ERROR_EMPTY_UID,
      'Cannot update post without signing in - $re',
    );
  }

  updateNotExistingPost() async {
    await test.signIn(test.b);

    final re = await test.submit(PostApi.instance.update(
      id: 'not-existing-id----123',
      title: 'sometitle',
      content: 'someCOntent',
    ));
    test.expect(
      re == ERROR_POST_NOT_EXIST,
      'Cannot update non existing post - $re',
    );
  }

  updatePostWithDifferentUser() async {
    await test.signIn(test.a);
    final orgPost = await PostApi.instance.create(category: 'qna');

    await FirebaseAuth.instance.signOut();
    await test.signIn(test.b);
    final re = await test.submit(PostApi.instance.update(
      id: orgPost.id,
      title: orgPost.title,
      content: orgPost.content,
    ));
    test.expect(
      re == ERROR_NOT_YOUR_POST,
      'Cannot update other user\'s post- $re',
    );
  }

  deleteNotExistingPost() async {
    await test.signIn(test.a);
    final re = await test.submit(PostApi.instance.delete('someId'));
    test.expect(re == ERROR_POST_NOT_EXIST, "Can't delete non existing post. $re");
  }

  deleteOtherUsersPost() async {
    await test.signIn(test.a);
    final post = await PostApi.instance.create(category: 'qna');

    await test.signIn(test.b);
    final re = await test.submit(PostApi.instance.delete(post.id));
    test.expect(re == ERROR_NOT_YOUR_POST, "Can't delete other user's post. $re");

    /// cleanup
    await test.signIn(test.a);
    await post.delete();
  }

  deleteAlreadyDeletedPost() async {
    await test.signIn(test.a);
    final post = await PostApi.instance.create(category: 'qna');
    await PostApi.instance.update(id: post.id, title: '', content: '', extra: {'noOfComments': 1});
    await post.delete();

    final re = await test.submit(PostApi.instance.delete(post.id));
    test.expect(re == ERROR_ALREADY_DELETED, "Can't delete already deleted post. $re");
  }

  createPostSuccess() async {
    await test.signIn(test.a);

    final post = await PostApi.instance.create(category: 'qna', title: 'AAA');
    test.expect(post.title == 'AAA', 'Post created with proper title.');

    /// cleanup
    await post.delete();
  }

  updatePostSuccess() async {
    await test.signIn(test.a);

    final created = await PostApi.instance.create(category: 'qna', title: 'AAA');
    final updated = await PostApi.instance.update(id: created.id, title: 'BBB', content: 'Hi MOM!');
    test.expect(updated.id == created.id, 'Still the same post.');
    test.expect(updated.title == 'BBB', 'Title is updated.');
    test.expect(updated.content == 'Hi MOM!', 'Content is update.');

    /// cleanup
    await created.delete();
  }

  deletePostSuccess() async {
    await test.signIn(test.a);

    final post = await PostApi.instance.create(category: 'qna', title: 'BBB');
    final re = await PostApi.instance.delete(post.id);
    test.expect(re == post.id, 'Post is deleted.');
  }
}
