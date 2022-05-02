import 'package:flutter/material.dart';

import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentUnitTestController {
  late _CommentUnitTestState state;
}

class CommentUnitTest extends StatefulWidget {
  const CommentUnitTest({Key? key, this.controller}) : super(key: key);
  final CommentUnitTestController? controller;

  @override
  State<CommentUnitTest> createState() => _CommentUnitTestState();
}

class _CommentUnitTestState extends State<CommentUnitTest> with UnitTestMixin {
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
      child: Text('Comment Unit Test'),
    );
  }

  runTests() async {
    await commentCRUDWithoutSignIn();
    await updateOtherUsersComment();
    await updateNotExistingComment();
    await deleteOtherUsersComment();
    await deleteAlreadyDeletedComment();
    await commentCRUDsuccess();
  }

  commentCRUDWithoutSignIn() async {
    await FirebaseAuth.instance.signOut();

    dynamic re = await submit(CommentApi.instance.create(
      postId: 'testPostId',
      parentId: 'testPostId',
    ));
    expect(
      re == ERROR_NOT_SIGN_IN,
      'Cannot create comment without signing in - $re',
    );

    re = await submit(CommentApi.instance.update(id: 'someId'));
    expect(
      re == ERROR_EMPTY_UID,
      'Cannot update comment without signing in - $re',
    );

    re = await submit(CommentApi.instance.delete('someId'));
    expect(
      re == ERROR_EMPTY_UID,
      'Cannot delete comment without signing in - $re',
    );
  }

  updateNotExistingComment() async {
    await signIn(b);
    final re = await submit(
      CommentApi.instance.update(id: 'not-existing---123', content: 'Hello'),
    );
    expect(
      re == ERROR_COMMENT_NOT_EXISTS,
      'Cannot update non existing comment - $re',
    );
  }

  updateOtherUsersComment() async {
    await signIn(a);
    final post = await PostApi.instance.create(category: 'qna');
    final comment = await CommentApi.instance.create(postId: post.id, parentId: post.id);

    await signIn(b);
    final re = await submit(CommentApi.instance.update(id: comment.id, content: 'Hello'));
    expect(
      re == ERROR_NOT_YOUR_COMMENT,
      'Cannot update other users comment - $re',
    );

    /// cleanup
    await signIn(a);
    comment.delete();
    post.delete();
  }

  deleteOtherUsersComment() async {
    await signIn(a);
    final post = await PostApi.instance.create(category: 'qna');
    final comment = await CommentApi.instance.create(postId: post.id, parentId: post.id);

    await signIn(b);
    final re = await submit(CommentApi.instance.delete(comment.id));
    expect(
      re == ERROR_NOT_YOUR_COMMENT,
      'Cannot delete other users comment - $re',
    );

    /// cleanup
    await signIn(a);
    await comment.delete();
    post.delete();
  }

  deleteAlreadyDeletedComment() async {
    await signIn(a);
    final post = await PostApi.instance.create(category: 'qna');
    final comment = await CommentApi.instance.create(postId: post.id, parentId: post.id);
    final comment2 = await CommentApi.instance.create(postId: post.id, parentId: comment.id);
    await comment.delete();

    final re = await submit(CommentApi.instance.delete(comment.id));
    expect(re == ERROR_ALREADY_DELETED, "Can't delete already deleted comment. $re");

    /// cleanup
    await signIn(a);
    await comment2.delete();
    post.delete();
  }

  commentCRUDsuccess() async {
    await signIn(a);
    final post = await PostApi.instance.create(category: 'qna');

    /// create
    final created = await CommentApi.instance.create(
      postId: post.id,
      parentId: post.id,
      content: 'Hello.',
    );
    expect(created.postId == post.id, "Comment created with correct post ID");
    expect(created.parentId == post.id, "Comment created with correct parent ID");
    expect(created.content == 'Hello.', "Comment created with correct content");

    /// update
    final updated = await CommentApi.instance.update(
      id: created.id,
      content: 'Hi Flutter.',
    );
    expect(updated.content == 'Hi Flutter.', "Comment updated");

    /// reply to comment
    final reply = await CommentApi.instance.create(
      postId: post.id,
      parentId: created.id,
      content: 'Reply',
    );
    expect(reply.postId == post.id, "Reply created with correct post ID");
    expect(reply.parentId == created.id, "Reply created with correct parent ID");
    expect(reply.content == 'Reply', "Reply created with correct content");

    /// delete reply
    final deletedReply = await CommentApi.instance.delete(reply.id);
    expect(deletedReply == reply.id, "Reply deleted.");

    /// delete comment
    final deletedComment = await CommentApi.instance.delete(created.id);
    expect(deletedComment == created.id, "Comment deleted.");

    /// clean up
    await post.delete();
  }
}
