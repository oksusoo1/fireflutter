import 'package:extended/extended.dart';
import 'package:fe/services/app.service.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';

class PostFormScreen extends StatefulWidget {
  const PostFormScreen({required this.arguments, Key? key}) : super(key: key);

  static const String routeName = '/postForm';
  final Map arguments;

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
            controller: widget.arguments['postFormController'],
            category: widget.arguments['category'],
            post: widget.arguments['post'],
            onCreate: (postId) {
              AppService.instance.router.back(postId);
              alert('Post created', 'Thank you');
            },
            onUpdate: (postId) {
              AppService.instance.router.back(postId);
            },
            // onError: error,
          ),
        ]),
      ),
    );
  }
}
