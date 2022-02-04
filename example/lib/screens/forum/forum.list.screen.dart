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
  final ForumModel forum = AppController.of.forum;
  final category = Get.arguments['category'];
  String newPostId = '';
  @override
  void initState() {
    super.initState();
    forum.reset(category: Get.arguments['category']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(forum.title),
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
        query: postCol
            .where('category', isEqualTo: category)
            .orderBy('timestamp', descending: true),
        itemBuilder: (context, snapshot) {
          final post = PostModel.fromJson(
            snapshot.data() as Json,
            snapshot.id,
          );

          return ExpansionTile(
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
              DateTime.fromMillisecondsSinceEpoch(
                      post.timestamp.millisecondsSinceEpoch)
                  .toString(),
            ),
            children: [
              Text(post.content),
              Text(post.id),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) {
                          return CommentEditDialog(
                            onCancel: Get.back,
                            onCreate: (PostModel comment) async {
                              try {
                                comment.id = post.id;
                                await comment.commentCreate();
                                Get.back();
                                alert('Comment created',
                                    'Your comment has created successfully');
                              } catch (e) {
                                error(e);
                              }
                            },
                          );
                        },
                      );
                    },
                    child: const Text('Comment'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
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

                      post
                          .report(input.text)
                          .then((x) => alert(
                              'Report success', 'You have reported this post.'))
                          .catchError(error);
                    },
                    child: const Text('Report'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
