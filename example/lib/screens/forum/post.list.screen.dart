import 'package:extended/extended.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:get/get.dart';

class PostListScreen extends StatefulWidget {
  PostListScreen({Key? key}) : super(key: key);

  static const String routeName = '/postList';

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> with FirestoreMixin {
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
          ForumListPushNotificationIcon(
            category,
            onError: error,
            size: 28,
          ),
          IconButton(
            onPressed: () async {
              newPostId = await app.openPostForm(category: category);
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
                post.increaseViewCounter().catchError(error);
              }
            },
            children: [
              Post(
                post: post,
                onReply: onReply,
                onReport: onReport,
                onEdit: (post) => AppController.of.openPostForm(post: post),
                onDelete: onDelete,
                onLike: onLike,
                onDislike: onDislike,
                onImageTap: onImageTapped,
              ),
              Divider(color: Colors.red),
              Comment(
                post: post,
                parentId: post.id,
                onReply: onReply,
                onReport: onReport,
                onEdit: onEdit,
                onDelete: onDelete,
                onImageTap: onImageTapped,
              ),
            ],
          );
        },
      ),
    );
  }

  /// [post] is the post
  /// [comment] is null for immediate child comment or the parent comment
  onReply(PostModel post, [CommentModel? comment]) async {
    return showDialog(
      context: context,
      builder: (_) {
        return CommentEditDialog(
          onCancel: Get.back,
          onError: error,
          onSubmit: (Json form) async {
            try {
              await CommentModel.create(
                postId: post.id,
                parentId: comment?.id ?? post.id,
                content: form['content'],
                files: form['files'],
              );
              // form.create(postId: post.id, parentId: comment?.id ?? post.id);
              Get.back();
              alert('Comment created', 'Your comment has created successfully');

              // @TODO send push notification on create using "comments_category" topic
              // MessagingService.instance.sendCommentNotification();
            } catch (e) {
              error(e);
            }
          },
        );
      },
    );
  }

  onEdit(CommentModel comment) async {
    return showDialog(
      context: context,
      builder: (_) {
        return CommentEditDialog(
          comment: comment,
          onCancel: Get.back,
          onError: error,
          onSubmit: (Json form) async {
            try {
              await comment.update(
                content: form['content'],
                files: form['files'],
              );
              // form.create(postId: post.id, parentId: comment?.id ?? post.id);
              Get.back();
              alert('Comment updated', 'You have updated the comment successfully');
            } catch (e) {
              error(e);
            }
          },
        );
      },
    );
  }

  onDelete(dynamic postOrComment) async {
    try {
      if (postOrComment is PostModel) {
        await postOrComment.delete();
        alert('Post deleted', 'You have deleted this post.');
      } else if (postOrComment is CommentModel) {
        await postOrComment.delete();
        alert('Comment deleted', 'You have deleted this comment.');
      }
    } catch (e) {
      error(e);
    }
  }

  onLike(dynamic postOrComment) async {
    try {
      await feed(postOrComment.path, 'like');
    } catch (e) {
      error(e);
    }
  }

  onDislike(dynamic postOrComment) async {
    try {
      await feed(postOrComment.path, 'dislike');
    } catch (e) {
      error(e);
    }
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

  onImageTapped(int initialIndex, List<String> files) {
    return Get.dialog(ImageViewer(files, initialIndex: initialIndex));
  }
}
