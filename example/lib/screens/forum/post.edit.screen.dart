// import 'package:extended/extended.dart';
// import 'package:fe/widgets/file_upload.button.dart';
// import 'package:flutter/material.dart';
// import 'package:fireflutter/fireflutter.dart';
// import 'package:get/get.dart';

// class PostEditScreen extends StatefulWidget {
//   const PostEditScreen({Key? key}) : super(key: key);

//   @override
//   State<PostEditScreen> createState() => _PostEditScreenState();
// }

// class _PostEditScreenState extends State<PostEditScreen> with FirestoreMixin {
//   final title = TextEditingController();

//   final content = TextEditingController();

//   // PostModel post = PostModel(category: Get.arguments['category'] ?? '');
//   late PostModel post;

//   @override
//   void initState() {
//     super.initState();

//     if (Get.arguments['post'] != null) {
//       post = Get.arguments['post'];
//       title.text = post.title;
//       content.text = post.content;
//     } else {
//       post = PostModel(category: Get.arguments['category']);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Post Edit'),
//       ),
//       body: PagePadding(vertical: sm, children: [
//         const Text('Title'),
//         TextField(controller: title),
//         spaceLg,
//         const Text('Content'),
//         TextField(controller: content),
//         spaceLg,
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             FileUploadButton(
//               onUploaded: (url) {
//                 post.files = [...post.files, url];
//                 if (mounted) setState(() {});
//               },
//               onProgress: (progress) => print("upload progress =>>> $progress"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 post..title = title.text;
//                 post..content = content.text;

//                 try {
//                   if (post.id.isNotEmpty) {
//                     await post.update(title: title.text, content: content.text, extra: {
//                       'files': post.files,
//                     });
//                     Get.back();
//                   } else {
//                     final ref = await post.create(
//                       title: title.text, content: content.text
//                     );
//                     Get.back(result: ref.id);

//                     print('post created; ${ref.id}');
//                     print('post created; $ref');
//                   }

//                   await alert("Post ${post.id.isNotEmpty ? 'updated' : 'created'}", 'Thank you');
//                 } catch (e) {
//                   error(e);
//                 }
//               },
//               child: const Text('SUBMIT'),
//             ),
//           ],
//         ),
//         for (String fileUrl in post.files)
//           Stack(
//             children: [
//               Image.network(fileUrl, height: 100, width: 100, fit: BoxFit.cover),
//               Positioned(
//                 top: 10,
//                 left: 10,
//                 child: GestureDetector(
//                   behavior: HitTestBehavior.opaque,
//                   child: Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
//                   onTap: () async {
//                     bool? re = await showDialog(
//                       context: Get.context!,
//                       builder: (c) => AlertDialog(
//                         title: Text('Delete file?'),
//                         actions: [
//                           TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
//                           TextButton(onPressed: () => Get.back(result: true), child: Text('Yes')),
//                         ],
//                       ),
//                     );
//                     if (re == null) return;
//                     try {
//                       await FileStorageService.instance.delete(fileUrl);
//                       post.files.remove(fileUrl);
//                       print('file deleted $fileUrl');
//                       if (mounted) setState(() {});
//                     } catch (e) {
//                       error(e);
//                     }
//                   },
//                 ),
//               )
//             ],
//           )
//       ]),
//     );
//   }
// }
