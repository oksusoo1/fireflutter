import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  const Post({
    Key? key,
    required this.post,
    required this.onReply,
    required this.onReport,
    required this.onEdit,
  }) : super(key: key);

  final PostModel post;
  final Function(PostModel post) onReport;
  final Function(PostModel post) onReply;
  final Function(PostModel post) onEdit;

  bool get isMine => UserService.instance.currentUser?.uid == post.uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(post.content),
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
          ],
        ),
      ],
    );
  }
}
