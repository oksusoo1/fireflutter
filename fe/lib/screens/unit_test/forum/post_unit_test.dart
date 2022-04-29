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

class _PostUnitTestState extends State<PostUnitTest> with UnitTestMixin, FirestoreMixin {
  // final test = UnitTestService.instance;

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
        clearLogs();
        runTests();
      },
      child: Text('Run Vote Unit Test'),
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
    await postCRUDsuccess();
  }

  createPostWithoutSignIn() async {
    await FirebaseAuth.instance.signOut();

    final re = await submit(PostApi.instance.create(category: 'qna'));
    expect(
      re == ERROR_NOT_SIGN_IN,
      'Cannot create post without signing in. - $re',
    );
  }

  createPostWithWrongCategory() async {
    await signIn(a);

    final re1 = await submit(PostApi.instance.create(category: ''));
    expect(
      re1 == ERROR_EMPTY_CATEGORY,
      'Cannot create post without category (empty) - $re1',
    );

    final re2 = await submit(PostApi.instance.create(category: 'wrongCategory'));
    expect(
      re2 == ERROR_CATEGORY_NOT_EXISTS,
      'Cannot create post with wrong category- $re2',
    );
  }

  updatePostWithoutSignIn() async {
    await signIn(b);
    final orgPost = await PostApi.instance.create(category: 'qna');

    await FirebaseAuth.instance.signOut();

    final re = await submit(PostApi.instance.update(
      id: orgPost.id,
      title: orgPost.title,
      content: orgPost.content,
    ));

    expect(
      re == ERROR_EMPTY_UID,
      'Cannot update post without signing in - $re',
    );
  }

  updateNotExistingPost() async {
    await signIn(b);

    final re = await submit(PostApi.instance.update(
      id: 'not-existing-id----123',
      title: 'sometitle',
      content: 'someCOntent',
    ));
    expect(
      re == ERROR_POST_NOT_EXIST,
      'Cannot update non existing post - $re',
    );
  }

  updatePostWithDifferentUser() async {
    await signIn(a);
    final orgPost = await PostApi.instance.create(category: 'qna');

    await FirebaseAuth.instance.signOut();
    await signIn(b);
    final re = await submit(PostApi.instance.update(
      id: orgPost.id,
      title: orgPost.title,
      content: orgPost.content,
    ));
    expect(
      re == ERROR_NOT_YOUR_POST,
      'Cannot update other user\'s post- $re',
    );
  }

  deleteNotExistingPost() async {
    await signIn(a);
    final re = await submit(PostApi.instance.delete('someId'));
    expect(re == ERROR_POST_NOT_EXIST, "Can't delete non existing post. $re");
  }

  deleteOtherUsersPost() async {
    await signIn(a);
    final post = await PostApi.instance.create(category: 'qna');

    await signIn(b);
    final re = await submit(PostApi.instance.delete(post.id));
    expect(re == ERROR_NOT_YOUR_POST, "Can't delete other user's post. $re");

    /// cleanup
    await signIn(a);
    await post.delete();
  }

  deleteAlreadyDeletedPost() async {
    await signIn(a);
    final post = await PostApi.instance.create(category: 'qna');
    await PostApi.instance.update(id: post.id, title: '', content: '', extra: {'noOfComments': 1});
    await post.delete();

    final re = await submit(PostApi.instance.delete(post.id));
    expect(re == ERROR_ALREADY_DELETED, "Can't delete already deleted post. $re");
  }

  postCRUDsuccess() async {
    await signIn(a);

    final created = await PostApi.instance.create(category: 'qna', title: 'AAA');
    expect(created.title == 'AAA', 'Post created with proper title.');

    final updated = await PostApi.instance.update(id: created.id, title: 'BBB', content: 'Hi MOM!');
    expect(updated.id == created.id, 'Still the same post.');
    expect(updated.title == 'BBB', 'Title is updated.');
    expect(updated.content == 'Hi MOM!', 'Content is update.');

    final deleted = await PostApi.instance.delete(created.id);
    expect(deleted == created.id, 'Post is deleted.');
  }
}
