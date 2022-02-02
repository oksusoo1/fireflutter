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
                // final data = PostModel.toCreate(
                //   category: Get.arguments['category'],
                //   title: title.text,
                //   content: content.text,
                // );
                // print('post create data; $data');
                // await postCol.add(data);

                await PostService.instance.create(
                  category: Get.arguments['category'],
                  title: title.text,
                  content: content.text,
                );
                Get.back();
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
