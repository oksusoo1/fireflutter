import 'package:flutter/material.dart';
import '../../../../fireflutter.dart';

class Post extends StatelessWidget {
  const Post({
    Key? key,
    // this.contentBuilder,
    this.buttonBuilder,
    this.shareButton,
    required this.post,
    required this.onProfile,
    required this.onReply,
    required this.onReport,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
    this.onDislike,
    required this.onChat,
    required this.onImageTap,
    this.onHide,
    required this.onSendPushNotification,
    this.padding,
    this.onBlockUser,
    this.onUnblockUser,
  }) : super(key: key);

  // final Function(PostModel)? contentBuilder;
  final Widget Function(String, Function())? buttonBuilder;
  final Widget? shareButton;
  final PostModel post;
  final Function(String uid) onProfile;
  final Function(PostModel post) onReport;
  final Function(PostModel post) onReply;
  final Function(PostModel post) onEdit;
  final Function(PostModel post) onDelete;
  final Function(PostModel post) onLike;
  final Function(PostModel post)? onDislike;
  final Function(PostModel post) onChat;
  final Function()? onHide;
  final Function(PostModel post) onSendPushNotification;
  final Function(int index, List<String> fileList) onImageTap;
  final EdgeInsets? padding;

  final Function(String uid)? onBlockUser;
  final Function(String uid)? onUnblockUser;

  @override
  Widget build(BuildContext context) {
    final _onDislike = onDislike == null ? null : () => onDislike!(post);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostContent(
          post,
          onImageTapped: (url) {
            onImageTap(post.files.indexWhere((u) => url == u), post.files);
          },
          padding: padding,
        ),
        ForumPoint(uid: post.uid, point: post.point),
        if (post.summary != '')
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey.shade200,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Summary',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  post.summary,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        if (post.isHtmlContent == false)
          ImageList(
            files: post.files,
            onImageTap: (i) => onImageTap(i, post.files),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ButtonBase(
            uid: post.uid,
            isPost: true,
            noOfComments: post.noOfComments,
            onProfile: onProfile,
            onReply: () => onReply(post),
            onReport: () => onReport(post),
            onEdit: () => onEdit(post),
            onDelete: () => onDelete(post),
            onLike: () => onLike(post),
            onDislike: _onDislike,
            onChat: () => onChat(post),
            onHide: onHide,
            buttonBuilder: buttonBuilder,
            likeCount: post.like,
            dislikeCount: post.dislike,
            shareButton: shareButton,
            onSendPushNotification: () => onSendPushNotification(post),
            onBlockUser: onBlockUser,
            onUnblockUser: onUnblockUser,
          ),
        ),
      ],
    );
  }
}
