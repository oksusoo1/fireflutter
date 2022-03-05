import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

/// ForumListView
///
///
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

  late StreamSubscription sub;
  @override
  void initState() {
    super.initState();
    listenPosts();
  }

  listenPosts() {
    print('listenPosts(); ');
    sub = widget.query.snapshots().listen((QuerySnapshot snapshots) {
      snapshots.docs.forEach((QueryDocumentSnapshot snapshot) {
        /// is it immediate child?
        final p = PostModel.fromJson(snapshot.data() as Json, snapshot.id);

        if (keys.indexOf(p.id) == -1) {
          posts[p.id] = p;
          keys.add(p.id);
        } else {
          posts[p.id] = p;
        }

        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: posts.keys.length,
        itemBuilder: (context, index) {
          final id = posts.keys.elementAt(index);

          return widget.postBuilder(posts[id]!, index);
        });
  }
}
