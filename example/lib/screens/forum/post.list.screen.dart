import 'package:example/services/defines.dart';
import 'package:example/services/global.dart';
import 'package:example/widgets/layout/layout.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/postList';
  final Map arguments;

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> with FirestoreMixin {
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
      title: Text(
        category,
        style: titleStyle,
      ),
      actions: [
        // ForumListPushNotificationIcon(
        //   category,
        //   // onError: service.error,
        //   onSigninRequired: () => service.alert(
        //     'Sign-in Required',
        //     'Please, sign in to subscribe this forum',
        //   ),
        //   onChanged: (String postOrComment, bool subscribed) {
        //     service.alert(
        //       subscribed ? 'Subscription' : 'Unsubscription',
        //       'You have ${subscribed ? 'subscribed' : 'unsubscribed'} the $category $postOrComment subscription.',
        //     );
        //   },
        //   size: 32,
        // ),
        IconButton(
            onPressed: () => service.router.openPostEdit(category: category),
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
            return CircularProgressIndicator.adaptive();
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
                  ListTile(
                    title: Text(post.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(post.shortDateTime),
                    ),
                    onTap: () => setState(() => post.open = !post.open),
                  ),
                  if (post.open)
                    Column(
                      children: [
                        Text('post id; ${post.id}'),
                        Post(
                          key: ValueKey(post.id),
                          post: post,
                          onProfile: (uid) {},
                          onReply: (post) {},
                          onReport: (post) {},
                          onImageTap: (i, files) => {},
                          onEdit: (post) => {},
                          onDelete: (post) => PostApi.instance.delete(post.id).catchError((e) {
                            //
                          }),
                          onLike: (post) {},
                          onDislike: (post) {},
                          onHide: () {},
                          onChat: (post) {},
                          onSendPushNotification: (post) => {},
                        ),
                        Divider(color: Colors.red),
                        Comment(
                          post: post,
                          parentId: post.id,
                          onProfile: (uid) => service.alert('Open other user profile', 'uid: $uid'),
                          onReply: (post, comment) {},
                          onReport: (comment) {},
                          onEdit: (comment) {},
                          onDelete: (comment) =>
                              CommentApi.instance.delete(comment.id).catchError((e) {
                            ///
                          }),
                          onLike: (comment) {},
                          onDislike: (comment) {},
                          onImageTap: (i, files) {},
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
