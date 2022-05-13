import 'package:example/services/global.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class PostEditScreen extends StatefulWidget {
  const PostEditScreen({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/postForm';
  final Map arguments;

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> with FirestoreMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Create'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          PostForm(
            controller: widget.arguments['postFormController'],
            category: widget.arguments['category'],
            post: widget.arguments['post'],
            onCreate: (postId) {
              service.router.back(postId);
              service.alert('Post created', 'Thank you');
            },
            onUpdate: (postId) {
              service.router.back(postId);
            },
            // onError: error,
          ),
        ]),
      ),
    );
  }
}
