import 'package:extended/extended.dart';
import 'package:fe/screens/admin/send.push.notification.dart';
import 'package:fe/screens/forum/forum.mixin.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostViewScreen extends StatefulWidget {
  const PostViewScreen({required this.arguments, Key? key}) : super(key: key);
  static final String routeName = '/postView';

  final Map arguments;

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen>
    with FirestoreMixin, ForumMixin {
  PostModel post = PostModel();
  @override
  void initState() {
    super.initState();

    final id = widget.arguments['post'] != null
        ? widget.arguments['post']!.id
        : widget.arguments['id'];

    postDoc(id).snapshots().listen((event) {
      if (event.exists) {
        setState(() {
          post = PostModel.fromJson(
              event.data() as Map<String, dynamic>, event.id);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: ExpansionTile(
          maintainState: true,
          key: ValueKey(post.id),
          initiallyExpanded: true,
          title: Text(post.displayTitle),
          subtitle: Row(
            children: [
              UserDoc(
                uid: post.uid,
                builder: (user) => user.exists
                    ? Text('By: ${user.displayName} ')
                    : Text('NO-USER '),
              ),
              ShortDate(post.createdAt.millisecondsSinceEpoch),
            ],
          ),
          children: [
            Text('Post Id: ${post.id}'),
            Post(
              post: post,
              onProfile: (uid) => alert('Open other user profile', 'uid: $uid'),
              onReply: (post) => onReply(context, post),
              onReport: onReport,
              onImageTap: (i, files) => onImageTapped(context, i, files),
              onEdit: (post) => AppService.instance.openPostForm(post: post),
              onDelete: (post) =>
                  PostApi.instance.delete(post.id).catchError((e) {
                error(e);
              }),
              onLike: onLike,
              onDislike: onDislike,
              onHide: () {},
              onChat: (post) => AppService.instance.openChatRoom(post.uid),
              onSendPushNotification: (post) => AppService.instance.open(
                  PushNotificationScreen.routeName,
                  arguments: {'postId': post.id}),
            ),
            Divider(color: Colors.red),
            Comment(
              post: post,
              parentId: post.id,
              onProfile: (uid) => alert('Open other user profile', 'uid: $uid'),
              onReply: (post, comment) => onReply(context, post, comment),
              onReport: onReport,
              onEdit: (comment) => onEdit(context, comment),
              onDelete: (comment) =>
                  CommentApi.instance.delete(comment.id).catchError((e) {
                error(e);
              }),
              onLike: onLike,
              onDislike: onDislike,
              onImageTap: (i, files) => onImageTapped(context, i, files),
            ),
          ],
        ),
      ),
    );
  }
}
