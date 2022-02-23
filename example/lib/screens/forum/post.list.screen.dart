import 'package:extended/extended.dart';
import 'package:fe/screens/forum/forum.mixin.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class PostListScreen extends StatefulWidget {
  PostListScreen({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/postList';
  final Map arguments;

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> with FirestoreMixin, ForumMixin {
  late final String category;
  String? newPostId;
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
              newPostId = await AppService.instance.openPostForm(category: category);
              if (mounted) setState(() {});
            },
            icon: Icon(
              Icons.create_rounded,
            ),
          ),
        ],
      ),
      body: FirestoreListView(
        key: ValueKey(newPostId),
        query: postCol.where('category', isEqualTo: category).orderBy(
              'timestamp',
              descending: true,
            ),
        itemBuilder: (context, snapshot) {
          final post = PostModel.fromJson(
            snapshot.data() as Json,
            snapshot.id,
          );

          print('got new doc id; ${post.id}: ${post.title}');

          return ExpansionTile(
            maintainState: true,
            key: ValueKey(post.id),
            initiallyExpanded: false,
            title: Text(post.displayTitle),
            subtitle: Row(
              children: [
                UserDoc(
                  uid: post.uid,
                  builder: (user) => user.exists ? Text('By: ${user.nickname} ') : Text('NO-USER '),
                ),
                ShortDate(post.timestamp.millisecondsSinceEpoch),
              ],
            ),
            onExpansionChanged: (value) {
              if (value) {
                // post.increaseViewCounter().catchError((e) => error(e));
              }
            },
            children: [
              // Text('Post Id: ${post.id}'),
              Post(
                post: post,
                onReply: (post) => onReply(context, post),
                onReport: onReport,
                onImageTap: (i, files) => onImageTapped(context, i, files),
                onEdit: (post) => AppService.instance.openPostForm(post: post),
                onDelete: onDelete,
                onLike: onLike,
                onDislike: onDislike,
                onHide: () {},
                onChat: (post) {},
              ),
              Divider(color: Colors.red),
              Comment(
                post: post,
                parentId: post.id,
                onReply: (post, comment) => onReply(context, post, comment),
                onReport: onReport,
                onEdit: (comment) => onEdit(context, comment),
                onDelete: onDelete,
                onLike: onLike,
                onDislike: onDislike,
                onImageTap: (i, files) => onImageTapped(context, i, files),
              ),
            ],
          );
        },
      ),
    );
  }
}
