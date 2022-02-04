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

class _ForumListScreenState extends State<ForumListScreen> with FirestoreBase {
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
              newPostId = await app.openPostCreate(category: category);
              setState(() {});
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

          print('got new doc id; ${post.id}');

          return ExpansionTile(
            initiallyExpanded: true,
            maintainState: true,
            title: Text(post.title),
            onExpansionChanged: (value) async {
              if (value) {
                try {
                  await post.increaseViewCounter();
                } catch (e) {
                  print('increaseViewCounter() error; $e');
                  error(e);
                }
              }
            },
            subtitle: Text(
              DateTime.fromMillisecondsSinceEpoch(post.timestamp.millisecondsSinceEpoch)
                      .toString() +
                  ', ' +
                  post.id,
            ),
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
                  ElevatedButton(
                    onPressed: () => app.openPostCreate(id: post.id),
                    child: const Text('Edit'),
                  ),
                ],
              ),
              Divider(color: Colors.red),
              Comment(
                post: post,
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
              await form.create(postId: post.id, parent: comment?.id ?? 'root');
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
