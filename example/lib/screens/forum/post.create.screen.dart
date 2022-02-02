import 'package:extended/extended.dart';
import 'package:flutter/material.dart';

class PostCreateScreen extends StatelessWidget {
  const PostCreateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Create'),
      ),
      body: PagePadding(vertical: sm, children: [
        const Text('Title'),
        TextField(),
        spaceLg,
        const Text('Content'),
        TextField(),
        spaceLg,
        ElevatedButton(onPressed: () {}, child: const Text('CREATE POST')),
      ]),
    );
  }
}
