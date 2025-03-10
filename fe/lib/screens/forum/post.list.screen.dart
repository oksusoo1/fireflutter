import 'package:extended/extended.dart';
import 'package:fe/screens/admin/send.push.notification.dart';
import 'package:fe/screens/forum/forum.mixin.dart';
import 'package:fe/services/app.service.dart';
import 'package:fe/services/defines.dart';
import 'package:fe/services/global.dart';
import 'package:fe/widgets/layout/layout.dart';
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
    category = widget.arguments['category'] ?? 'Forum';
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      backButton: true,
      bottomLine: true,
      title: Text(
        category,
        style: titleStyle,
      ),
      actions: [
        ForumListPushNotificationIcon(
          category,
          // onError: service.error,
          onSigninRequired: () => service.alert(
            'Sign-in Required',
            'Please, sign in to subscribe this forum',
          ),
          onChanged: (String postOrComment, bool subscribed) {
            service.alert(
              subscribed ? 'Subscription' : 'Unsubscription',
              'You have ${subscribed ? 'subscribed' : 'unsubscribed'} the $category $postOrComment subscription.',
            );
          },
          size: 32,
        ),
        IconButton(
            onPressed: () => service.router.openPostForm(category: category),
            icon: Icon(
              Icons.create,
              color: Colors.black,
            )),
      ],
      body: FirestoreQueryBuilder(
        key: ValueKey((newPostId ?? '') + 'FirestoreListView'),
        query: postCol.where('category', isEqualTo: category).orderBy(
              'createdAt',
              descending: true,
            ),
        builder: (context, snapshot, _) {
          if (snapshot.isFetching) {
            return Spinner();
          }

          if (snapshot.hasError) {
            return Text('Something went wrong! ${snapshot.error}');
          }
          return ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
                snapshot.fetchMore();
              }

              final post = PostModel.fromJson(
                snapshot.docs[index].data() as Json,
                snapshot.docs[index].id,
              );
              return Column(
                children: [
                  ExtendedListTile(
                    key: ValueKey(post.id),
                    // margin: EdgeInsets.only(top: index == 0 ? 16 : 0),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: post.files.isNotEmpty
                        ? UploadedImage(
                            url: post.files.first,
                            width: 62,
                            height: 62,
                          )
                        : null,
                    title: Text(post.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(post.shortDateTime),
                    ),
                    trailing: Icon(
                      post.open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: grey,
                    ),
                    onTap: () => setState(() => post.open = !post.open),
                  ),
                  if (post.open)
                    PagePadding(
                      children: [
                        Text('post id; ${post.id}'),
                        Post(
                          key: ValueKey(post.id),
                          post: post,
                          onProfile: (uid) => alert('Open other user profile', 'uid: $uid'),
                          onReply: (post) => onReply(context, post),
                          onReport: onReport,
                          onImageTap: (i, files) => onImageTapped(context, i, files),
                          onEdit: (post) => AppService.instance.router.openPostForm(post: post),
                          onDelete: (post) => PostApi.instance.delete(post.id).catchError((e) {
                            error(e);
                          }),
                          onLike: onLike,
                          onDislike: onDislike,
                          onHide: () {},
                          onChat: (post) => AppService.instance.router.openChatRoom(post.uid),
                          onSendPushNotification: (post) => AppService.instance.router.open(
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
                  Divider(
                    color: Colors.grey.shade400,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
