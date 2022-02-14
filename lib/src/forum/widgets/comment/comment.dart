import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../fireflutter.dart';

class Comment extends StatefulWidget {
  Comment({
    Key? key,
    required this.post,
    required this.parentId,
    required this.onReply,
    required this.onReport,
    required this.onEdit,
    required this.onDelete,
    required this.onImageTap,
    required this.onLike,
    required this.onDislike,
    this.buttonBuilder,
    this.headerBuilder,
    this.contentBuilder,
  }) : super(key: key);

  final PostModel post;
  final String parentId;

  /// Callback on reply button pressed. The parameter is the parent comment of
  /// the new comment to be created.
  final Function(PostModel post, CommentModel comment) onReply;
  final Function(CommentModel comment) onEdit;
  final Function(CommentModel comment) onReport;
  final Function(CommentModel comment) onDelete;
  final Function(CommentModel comment) onLike;
  final Function(CommentModel comment) onDislike;
  final Function(int index, List<String> fileList) onImageTap;

  final Widget Function(Function()?)? buttonBuilder;
  final Widget Function()? headerBuilder;
  final Widget Function()? contentBuilder;

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
            margin: EdgeInsets.only(left: comment.depth * 16, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _commentHeader(comment),
                _contentBuilder(comment),
                ImageList(
                  files: comment.files,
                  onImageTap: (i) => widget.onImageTap(i, comment.files),
                ),
                ButtonBase(
                  uid: comment.uid,
                  isPost: false,
                  onReply: () => widget.onReply(widget.post, comment),
                  onReport: () => widget.onReport(comment),
                  onEdit: () => widget.onEdit(comment),
                  onDelete: () => widget.onDelete(comment),
                  onLike: () => widget.onLike(comment),
                  onDislike: () => widget.onDislike(comment),
                  buttonBuilder: widget.buttonBuilder,
                  likeCount: comment.like,
                  dislikeCount: comment.dislike,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _commentHeader(CommentModel comment) {
    return widget.headerBuilder != null
        ? widget.headerBuilder!()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: UserDoc(
              uid: comment.uid,
              builder: (user) => Row(
                children: [
                  ClipOval(
                    child: user.photoUrl != ''
                        ? UploadedImage(url: user.photoUrl)
                        : Icon(Icons.person, color: Colors.black, size: 30),
                  ),
                  SizedBox(width: 8),
                  Column(
                    children: [
                      Text(user.displayName.isNotEmpty ? "${user.displayName}" : "No name"),
                      SizedBox(height: 8),
                      ShortDate(comment.timestamp.millisecondsSinceEpoch),
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  Widget _contentBuilder(CommentModel comment) {
    return widget.contentBuilder != null
        ? widget.contentBuilder!()
        : Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: Colors.grey[300],
            child: Text("${comment.displayContent}"),
          );
  }
}
