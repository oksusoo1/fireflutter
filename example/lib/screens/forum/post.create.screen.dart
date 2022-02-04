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
        // ElevatedButton(onPressed: () => uploadFile(), child: const Text('Upload File')),
        ElevatedButton(
            onPressed: () async {
              try {
                final ref = await PostModel(
                  category: Get.arguments['category'],
                  title: title.text,
                  content: content.text,
                ).create();

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

      /// TODO update post files.
    } catch (e) {
      print('uploadFile:error ==>>> ${e.toString()}');
    }
  }
}
