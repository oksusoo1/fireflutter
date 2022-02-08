import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  const Post({
    Key? key,
    required this.post,
    required this.onReply,
    required this.onReport,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
    required this.onDislike,
  }) : super(key: key);

  final PostModel post;
  final Function(PostModel post) onReport;
  final Function(PostModel post) onReply;
  final Function(PostModel post) onEdit;
  final Function(PostModel post) onDelete;
  final Function(PostModel post) onLike;
  final Function(PostModel post) onDislike;

  bool get isMine => UserService.instance.currentUser?.uid == post.uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(post.displayContent),
        Text(post.id),
        Wrap(
          children: [
            ElevatedButton(
              onPressed: () => onReply(post),
              child: const Text('Comment'),
            ),
            ElevatedButton(
              onPressed: () => onReport(post),
              child: const Text('Report'),
            ),
            if (isMine)
              ElevatedButton(
                onPressed: () => onEdit(post),
                child: const Text('Edit'),
              ),
            if (isMine)
              ElevatedButton(
                onPressed: () => onDelete(post),
                child: const Text('Delete'),
              ),
            ElevatedButton(
              onPressed: () => onLike(post),
              child: Text('Like ${post.like}'),
            ),
            ElevatedButton(
              onPressed: () => onDislike(post),
              child: Text('Dislike: ${post.dislike}'),
            ),
          ],
        ),
        FileList(files: post.files),
      ],
    );
  }
}
