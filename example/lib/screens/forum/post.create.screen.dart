import 'package:extended/extended.dart';
import 'package:flutter/material.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class PostCreateScreen extends StatefulWidget {
  const PostCreateScreen({Key? key}) : super(key: key);

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> with FirestoreMixin {
  final title = TextEditingController();

  final content = TextEditingController();

  final post = PostModel();

  @override
  void initState() {
    super.initState();

    post..category = Get.arguments['category'] ?? '';
    post..id = Get.arguments['id'] ?? '';

    print(post.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Create'),
      ),
      body: PagePadding(vertical: sm, children: [
        const Text('Title'),
        TextField(controller: title),
        spaceLg,
        const Text('Content'),
        TextField(controller: content),
        spaceLg,
        Row(
          children: [
            ElevatedButton(onPressed: () => uploadFile(), child: const Text('Upload File')),
            ElevatedButton(
                onPressed: () async {
                  post..title = title.text;
                  post..content = content.text;

                  try {
                    final ref = await post.create();
                    // final ref = await PostModel(
                    //   category: Get.arguments['category'],
                    //   title: title.text,
                    //   content: content.text,
                    // ).create();

                    print('post created; ${ref.id}');
                    print('post created; $ref');

                    Get.back(result: ref.id);
                    await alert('Post created', 'Thank you');
                  } catch (e) {
                    error(e);
                  }
                },
                child: const Text('CREATE POST')),
          ],
        ),
        for (String fileUrl in post.files) Text('$fileUrl')
      ]),
    );
  }

  uploadFile() async {
    final ImageSource? re = await Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take Photo from Camera'),
                  onTap: () => Get.back(result: ImageSource.camera)),
              ListTile(
                  leading: Icon(Icons.photo),
                  title: Text('Choose from Gallery'),
                  onTap: () => Get.back(result: ImageSource.gallery)),
              ListTile(leading: Icon(Icons.cancel), title: Text('Cancel'), onTap: () => Get.back()),
            ],
          ),
        ),
      ),
    );

    try {
      if (re == null) return;
      String uploadedFileUrl = await FileUploadService.instance.pickUpload(
        onProgress: (progress) => print("Upload progress =>> ${progress.toString()}"),
        source: re,
      );

      post.files = [...post.files, uploadedFileUrl];
      setState(() {});
    } catch (e) {
      error(e);
    }
  }
}
