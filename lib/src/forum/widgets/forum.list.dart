import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

/// ForumListView
///
///
@Deprecated('Do not use use.')
class ForumListView extends StatefulWidget {
  ForumListView({
    Key? key,
    required this.query,
    required this.postBuilder,
  }) : super(key: key);

  final Query query;
  final Function(PostModel, int) postBuilder;

  @override
  State<ForumListView> createState() => _ForumListViewState();
}

class _ForumListViewState extends State<ForumListView> with FirestoreMixin {
  final Map<String, PostModel> posts = {};
  final List<String> keys = [];
  int pageNo = 0;
  bool loading = false;

  final scrollController = ScrollController();

  // 여기서 부터....
  // stream 을 한번에 제거하는 방법을 찾을 것.
  List<StreamSubscription> sub = [];
  @override
  void initState() {
    super.initState();
    listenPosts();
    scrollController.addListener(() {
      if (atBottom) {
        listenPosts();
      }
    });
  }

  bool get atBottom {
    return scrollController.offset >
        (scrollController.position.maxScrollExtent - 300);
  }

  listenPosts() {
    if (loading) return;
    print('listenPosts(); ... pageNo: $pageNo');
    final q = widget.query;
    if (posts.length > 0) q.startAfter([posts[keys.last]]);
    loading = true;

    /// 여기서 부터... 10개, 20개 씩 pagination 을 하고, scroll 이 밑으로 되면 추가 로드한다.
    /// 이 때, 한번 로드 한 것은 다시 로드하지 않는지 테스트를 한다.

    final stream = q.limit(10).snapshots().listen((QuerySnapshot snapshots) {
      snapshots.docs.forEach((QueryDocumentSnapshot snapshot) {
        /// is it immediate child?
        final p = PostModel.fromJson(snapshot.data() as Json, snapshot.id);

        if (keys.indexOf(p.id) == -1) {
          posts[p.id] = p;
          keys.add(p.id);
        } else {
          posts[p.id] = p;
        }
        print('title: ${p.title}');

        listenComments(p);
      });
      pageNo++;
      loading = false;
      if (mounted) setState(() {});
    });

    sub.add(stream);
  }

  listenComments(PostModel post) {
    // 여기서, 코멘트를 읽어 들인다.
    sub.add(

        /// It is listening any changes of the docs.
        commentCol
            .where('postId', isEqualTo: post.id)
            .orderBy('createdAt')
            .snapshots()
            .listen((QuerySnapshot snapshots) {
      snapshots.docs.forEach((QueryDocumentSnapshot snapshot) {
        /// is it immediate child?
        final CommentModel c =
            CommentModel.fromJson(snapshot.data() as Json, id: snapshot.id);
        // print(c);

        // if exists in array, just update it.
        int i = post.comments.indexWhere((e) => e.id == snapshot.id);
        if (i >= 0) {
          /// maintain the depth computation
          c.depth = post.comments[i].depth;
          post.comments[i] = c;
        } else {
          /// if immediate child comment,
          if (c.postId == c.parentId) {
            /// add at bottom
            post.comments.add(c);
          } else {
            /// It's a comment under another comemnt. Find parent.
            int i = post.comments.indexWhere((e) => e.id == c.parentId);
            if (i >= 0) {
              c.depth = post.comments[i].depth + 1;
              post.comments.insert(i + 1, c);
            } else {
              // error; can't find parent comment.
              print('---> error?; $c');
            }
          }
        }
      });
      print(post.comments);
    }));
  }

  @override
  void dispose() {
    sub.forEach((e) {
      e.cancel();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: scrollController,
        itemCount: posts.keys.length,
        itemBuilder: (context, index) {
          final id = posts.keys.elementAt(index);

          return widget.postBuilder(posts[id]!, index);
        });
  }
}
