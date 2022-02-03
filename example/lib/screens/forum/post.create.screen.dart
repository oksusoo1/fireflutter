import 'package:extended/extended.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:get/get.dart';

class PostCreateScreen extends StatefulWidget {
  const PostCreateScreen({Key? key}) : super(key: key);

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> with FirestoreBase {
  final title = TextEditingController();

  final content = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Create'),
      ),
      body: PagePadding(vertical: sm, children: [
        const Text('Title'),
        TextField(
          controller: title,
        ),
        spaceLg,
        const Text('Content'),
        TextField(
          controller: content,
        ),
        spaceLg,
        ElevatedButton(
            onPressed: () async {
              try {
                final ref = await PostModel(
                  category: Get.arguments['category'],
                  title: title.text,
                  content: content.text,
                ).create(extra: {'yo': 'hey'});

                print('post created; ${ref.id}');
                print('post created; $ref');

                Get.back(result: ref.id);
                await alert('Post created', 'Thank you');
              } catch (e) {
                error(e);
              }
            },
            child: const Text('CREATE POST')),
      ]),
    );
  }
}
