import 'package:flutter/material.dart';
import '../../../../fireflutter.dart';

class Post extends StatelessWidget {
  const Post({
    Key? key,
    this.contentBuilder,
    this.buttonBuilder,
    required this.post,
    required this.onReply,
    required this.onReport,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
    required this.onDislike,
    required this.onChat,
    required this.onShare,
    required this.onImageTap,
    this.onHide,
  }) : super(key: key);

  final Function(String)? contentBuilder;
  final Widget Function(String, Function())? buttonBuilder;
  final PostModel post;
  final Function(PostModel post) onReport;
  final Function(PostModel post) onReply;
  final Function(PostModel post) onEdit;
  final Function(PostModel post) onDelete;
  final Function(PostModel post) onLike;
  final Function(PostModel post) onDislike;
  final Function(PostModel post) onChat;
  final Function(PostModel post) onShare;
  final Function()? onHide;
  final Function(int index, List<String> fileList) onImageTap;

  @override
  Widget build(BuildContext context) {
    final content = contentBuilder != null
        ? contentBuilder!(post.displayContent)
        : Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              post.displayContent,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        content,
        ImageList(
          files: post.files,
          onImageTap: (i) => onImageTap(i, post.files),
        ),
        ButtonBase(
          uid: post.uid,
          isPost: true,
          onReply: () => onReply(post),
          onReport: () => onReport(post),
          onEdit: () => onEdit(post),
          onDelete: () => onDelete(post),
          onLike: () => onLike(post),
          onDislike: () => onDislike(post),
          onShare: () => onShare(post),
          onChat: () => onChat(post),
          onHide: onHide,
          buttonBuilder: buttonBuilder,
          likeCount: post.like,
          dislikeCount: post.dislike,
        ),
      ],
    );
  }
}
