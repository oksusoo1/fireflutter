import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class Comment extends StatelessWidget with FirestoreMixin {
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
  Widget build(BuildContext context) {
    final query = commentCol.where('parentId', isEqualTo: parentId).orderBy(
          'timestamp',
          descending: true,
        );

    return FirestoreListView(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      query: query,
      itemBuilder: (context, snapshot) {
        final comment = CommentModel.fromJson(
          snapshot.data() as Json,
          id: snapshot.id,
          postId: post.id,
        );

        return Container(
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
                    onPressed: () => onReply(post, comment),
                    child: const Text('Reply'),
                  ),
                  ElevatedButton(
                    onPressed: () => onReport(comment),
                    child: const Text('Report'),
                  ),
                ],
              ),
              Divider(color: Colors.black),
              Comment(post: post, parentId: comment.id, onReply: onReply, onReport: onReport)
            ],
          ),
        );
      },
    );
  }
}
