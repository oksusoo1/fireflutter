import 'package:extended/extended.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:get/get.dart';

class PostFormScreen extends StatefulWidget {
  const PostFormScreen({Key? key}) : super(key: key);

  static const String routeName = '/postForm';

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> with FirestoreMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Create'),
      ),
      body: SingleChildScrollView(
        child: PagePadding(vertical: sm, children: [
          PostForm(
            category: Get.arguments['category'],
            post: Get.arguments['post'],
            onCreate: (postId) {
              Get.back(result: postId);
              alert('Post created', 'Thank you');
              // @todo send push notification after create using "posts_category"
              // MessagingService.instance.sendPostsNotification();
            },
            onUpdate: (postId) {
              Get.back(result: postId);
            },
            onError: error,
          ),
        ]),
      ),
    );
  }
}
