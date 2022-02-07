import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Comment extends StatefulWidget {
  Comment({
    Key? key,
    required this.post,
    required this.parentId,
    required this.onReply,
    required this.onReport,
  }) : super(key: key);

  final PostModel post;
  final String parentId;

  /// Callback on reply button pressed. The parameter is the parent comment of
  /// the new comment to be created.
  final Function(PostModel post, CommentModel comment) onReply;
  final Function(CommentModel comment) onReport;

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> with FirestoreMixin {
  List<CommentModel> comments = [];
  StreamSubscription? sub;

  loadComments() {
    sub?.cancel();
    commentCol
        .where('postId', isEqualTo: widget.post.id)
        .orderBy('timestamp')
        .snapshots()
        .listen((QuerySnapshot snapshots) {
      snapshots.docs.forEach((QueryDocumentSnapshot snapshot) {
        /// is it immediate child?
        final CommentModel c = CommentModel.fromJson(snapshot.data() as Json, id: snapshot.id);
        // print(c);

        // if exists in array, just update it.
        int i = comments.indexWhere((e) => e.id == snapshot.id);
        if (i >= 0) {
          /// maintain the depth computation
          c.depth = comments[i].depth;
          comments[i] = c;
        } else {
          /// if immediate child comment,
          if (c.postId == c.parentId) {
            /// add at bottom
            comments.add(c);
          } else {
            /// It's a comment under another comemnt. Find parent.
            int i = comments.indexWhere((e) => e.id == c.parentId);
            if (i >= 0) {
              c.depth = comments[i].depth + 1;
              comments.insert(i + 1, c);
            } else {
              // error; can't find parent comment.
              print('---> error?; $c');
            }
          }
        }

        if (mounted) setState(() {});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  @override
  void dispose() {
    super.dispose();
    sub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        for (final CommentModel comment in comments)
          Container(
            margin: EdgeInsets.only(left: comment.depth * 16),
            padding: const EdgeInsets.all(24),
            color: Colors.teal[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserDoc(uid: comment.uid, builder: (u) => Text('Name: ${u.nickname}')),
                Text("content: ${comment.content}"),
                Wrap(
                  children: [
                    ElevatedButton(
                      onPressed: () => widget.onReply(widget.post, comment),
                      child: const Text('Reply'),
                    ),
                    ElevatedButton(
                      onPressed: () => widget.onReport(comment),
                      child: const Text('Report'),
                    ),
                  ],
                ),
                Divider(color: Colors.black),
              ],
            ),
          ),
      ],
    );
  }
}
