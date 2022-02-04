import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class Post extends StatelessWidget {
  const Post({
    Key? key,
    required this.post,
    required this.onReply,
    required this.onReport,
  }) : super(key: key);

  final PostModel post;
  final Function(PostModel post) onReport;
  final Function(PostModel post) onReply;

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
          ],
        ),
      ],
    );
  }
}
