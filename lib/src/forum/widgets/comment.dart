import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';

class Comment extends StatelessWidget with FirestoreBase {
  Comment({
    Key? key,
    required this.postId,
    this.parent = 'root',
  }) : super(key: key);

  final String postId;
  final String parent;
  @override
  Widget build(BuildContext context) {
    final query = commentCol(postId).where('parent', isEqualTo: parent).orderBy(
          'timestamp',
          descending: true,
        );

    return FirestoreQueryBuilder(
      query: query,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Text('Something went wrong! ${snapshot.error}');
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.docs.length,
          itemBuilder: (context, index) {
            // if we reached the end of the currently obtained items, we try to
            // obtain more items
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              // Tell FirestoreQueryBuilder to try to obtain more items.
              // It is safe to call this function from within the build method.
              snapshot.fetchMore();
              debugPrint('snapshot.fetchMore() called...');
            }
            final doc = snapshot.docs[index];

            final comment = PostModel.fromJson(doc.data() as Json, doc.id);

            return Container(
              padding: const EdgeInsets.all(24),
              color: Colors.teal[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("content: ${comment.content}"),
                  ElevatedButton(onPressed: () {}, child: const Text('Reply'))
                ],
              ),
            );
          },
        );
      },
    );

    // return FirestoreListView(
    //   physics: NeverScrollableScrollPhysics(),
    //   shrinkWrap: true,
    //   query: commentCol(postId).where('parent', isEqualTo: parent).orderBy(
    //         'timestamp',
    //         descending: true,
    //       ),
    //   loadingBuilder: (context) {
    //     print('loadingBuilder...');
    //     return Text('loading...');
    //   },
    //   itemBuilder: (context, snapshot) {
    //     final comment = PostModel.fromJson(
    //       snapshot.data() as Json,
    //       snapshot.id,
    //     );

    //     return Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(comment.content),
    //         const Text('Children...'),
    //         Divider(),
    //         Comment(postId: postId, parent: comment.id),
    //       ],
    //     );
    //   },
    // );
  }
}
