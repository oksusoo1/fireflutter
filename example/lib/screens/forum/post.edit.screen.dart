import 'package:extended/extended.dart';
import 'package:fe/widgets/file_upload.button.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:get/get.dart';

class PostEditScreen extends StatefulWidget {
  const PostEditScreen({Key? key}) : super(key: key);

  @override
  State<PostEditScreen> createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> with FirestoreMixin {
  final title = TextEditingController();

  final content = TextEditingController();

  // PostModel post = PostModel(category: Get.arguments['category'] ?? '');
  late PostModel post;

  @override
  void initState() {
    super.initState();

    if (Get.arguments['post'] != null) {
      post = Get.arguments['post'];
      title.text = post.title;
      content.text = post.content;
    } else {
      post = PostModel(category: Get.arguments['category']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Edit'),
      ),
      body: PagePadding(vertical: sm, children: [
        const Text('Title'),
        TextField(controller: title),
        spaceLg,
        const Text('Content'),
        TextField(controller: content),
        spaceLg,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FileUploadButton(
              onUploaded: (url) {
                post.files = [...post.files, url];
                if (mounted) setState(() {});
              },
              onProgress: (progress) => print("upload progress =>>> $progress"),
            ),
            ElevatedButton(
              onPressed: () async {
                post..title = title.text;
                post..content = content.text;

                try {
                  if (post.id.isNotEmpty) {
                    await post.update();
                    Get.back();
                  } else {
                    final ref = await post.create();
                    Get.back(result: ref.id);

                    print('post created; ${ref.id}');
                    print('post created; $ref');
                  }

                  await alert("Post ${post.id.isNotEmpty ? 'updated' : 'created'}", 'Thank you');
                } catch (e) {
                  error(e);
                }
              },
              child: const Text('SUBMIT'),
            ),
          ],
        ),
        for (String fileUrl in post.files) Text('$fileUrl')
      ]),
    );
  }
}
