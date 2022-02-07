import 'package:extended/extended.dart';
import 'package:fe/service/app.controller.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:get/get.dart';

class ForumListScreen extends StatefulWidget {
  ForumListScreen({Key? key}) : super(key: key);

  @override
  State<ForumListScreen> createState() => _ForumListScreenState();
}

class _ForumListScreenState extends State<ForumListScreen> with FirestoreMixin {
  final app = AppController.of;
  final category = Get.arguments['category'];
  String? newPostId;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        actions: [
          IconButton(
            onPressed: () async {
              newPostId = await app.openPostForm(category: category);
              if (newPostId != null) setState(() {});
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
            initiallyExpanded: true,
            title: Text(post.title),
            subtitle: Row(
              children: [
                UserFutureDoc(
                  uid: post.uid,
                  builder: (user) => user.exists ? Text('By: ${user.nickname} ') : Text('NO-USER '),
                ),
                ShortDate(post.timestamp.millisecondsSinceEpoch),
              ],
            ),
            onExpansionChanged: (value) {
              if (value) {
                post.increaseViewCounter().catchError(error);
              }
            },
            children: [
              Post(
                post: post,
                onReply: onReply,
                onReport: onReport,
                onEdit: (post) => AppController.of.openPostForm(),
              ),
              Divider(color: Colors.red),
              Comment(
                post: post,
                parentId: post.id,
                onReply: onReply,
                onReport: onReport,
              ),
            ],
          );
        },
      ),
    );
  }

  onReply(PostModel post, [CommentModel? comment]) async {
    return showDialog(
      context: context,
      builder: (_) {
        return CommentEditDialog(
          onCancel: Get.back,
          onCreate: (CommentModel form) async {
            try {
              await form.create(postId: post.id, parentId: comment?.id ?? post.id);
              Get.back();
              alert('Comment created', 'Your comment has created successfully');
            } catch (e) {
              error(e);
            }
          },
        );
      },
    );
  }

  onReport(dynamic postOrComment) async {
    final input = TextEditingController(text: '');
    String? re = await showDialog(
      context: Get.context!,
      builder: (c) => AlertDialog(
        title: Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reason'),
            TextField(
              controller: input,
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('close'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(result: input.text);
            },
            child: Text('submit'),
          ),
        ],
      ),
    );

    if (re == null) return;
    try {
      await postOrComment.report(input.text);
      alert('Report success', 'You have reported this post.');
    } catch (e) {
      error(e);
    }
  }
}
