import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class Comment extends StatelessWidget with FirestoreBase {
  Comment({
    Key? key,
    required this.post,
    this.parent = 'root',
    required this.onReply,
    required this.onReport,
  }) : super(key: key);

  final PostModel post;
  final String parent;

  /// Callback on reply button pressed. The parameter is the parent comment of
  /// the new comment to be created.
  final Function(PostModel post, CommentModel comment) onReply;
  final Function(CommentModel comment) onReport;
  @override
  Widget build(BuildContext context) {
    final query = commentCol(post.id).where('parent', isEqualTo: parent).orderBy(
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
              Comment(post: post, parent: comment.id, onReply: onReply, onReport: onReport)
            ],
          ),
        );
      },
    );
  }
}
