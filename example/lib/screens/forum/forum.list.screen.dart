import 'package:extended/extended.dart';
import 'package:fe/screens/admin/send.push.notification.dart';
import 'package:fe/screens/forum/forum.mixin.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ForumListScreen extends StatefulWidget {
  ForumListScreen({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/forumList';
  final Map arguments;

  @override
  State<ForumListScreen> createState() => _ForumListScreenState();
}

class _ForumListScreenState extends State<ForumListScreen>
    with FirestoreMixin, ForumMixin {
  late final String category;
  String newPostId = '';
  @override
  void initState() {
    super.initState();
    category = widget.arguments['category'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        actions: [
          ForumListPushNotificationIcon(
            category,
            onError: error,
            size: 28,
          ),
          IconButton(
            onPressed: () async {
              newPostId =
                  await AppService.instance.openPostForm(category: category);
              if (mounted) setState(() {});
            },
            icon: Icon(
              Icons.create_rounded,
            ),
          ),
        ],
      ),
      body: ForumListView(
        query: postCol.where('category', isEqualTo: category).orderBy(
              'createdAt',
              descending: true,
            ),
        postBuilder: (post, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              child: ExtendedText(
                post.displayTitle,
                padding: EdgeInsets.all(8),
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
            Post(
              key: ValueKey(post.id),
              post: post,
              onReply: (post) => onReply(context, post),
              onReport: onReport,
              onImageTap: (i, files) => onImageTapped(context, i, files),
              onEdit: (post) => AppService.instance.openPostForm(post: post),
              onDelete: onDelete,
              onLike: onLike,
              onDislike: onDislike,
              onHide: () {},
              onChat: (post) => AppService.instance.openChatRoom(post.uid),
              onSendPushNotification: (post) => AppService.instance.open(
                  PushNotificationScreen.routeName,
                  arguments: {'postId': post.id}),
            ),
          ],
        ),
      ),
    );
  }
}
