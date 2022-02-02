import 'package:extended/extended.dart';
import 'package:fe/service/app.controller.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForumListScreen extends StatefulWidget {
  ForumListScreen({Key? key}) : super(key: key);

  @override
  State<ForumListScreen> createState() => _ForumListScreenState();
}

class _ForumListScreenState extends State<ForumListScreen> with FirestoreBase {
  final app = AppController.of;
  final ForumModel forum = AppController.of.forum;
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
            onPressed: () => app.openPostCreate(category: Get.arguments['category']),
            icon: Icon(
              Icons.create_rounded,
            ),
          ),
        ],
      ),
      body: FirestoreListView(
        query: postCol
            .where('category', isEqualTo: Get.arguments['category'])
            .orderBy('timestamp', descending: true),
        itemBuilder: (context, snapshot) {
          final post = PostModel.fromJson(
            snapshot.data() as Json,
            snapshot.id,
          );

          return ExpansionTile(
            title: Text(post.title),
            subtitle: Text(
              DateTime.fromMillisecondsSinceEpoch(post.timestamp.millisecondsSinceEpoch).toString(),
            ),
            children: [
              Text(post.content),
              ElevatedButton(
                onPressed: () {
                  post.report().then((x) {}).catchError(error);
                },
                child: const Text('Report'),
              ),
            ],
          );
        },
      ),
    );
  }
}
