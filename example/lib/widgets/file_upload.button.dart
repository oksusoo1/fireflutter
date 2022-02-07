import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class FileUploadButton extends StatelessWidget {
  const FileUploadButton({
    this.child,
    required this.onUploaded,
    required this.onProgress,
    Key? key,
  }) : super(key: key);

  final Widget? child;
  final Function(String) onUploaded;
  final Function(double) onProgress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: child != null ? child : Icon(Icons.image),
      onTap: uploadFile,
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
        onProgress: onProgress,
        source: re,
      );
      onUploaded(uploadedFileUrl);
    } catch (e) {
      error(e);
    }
  }
}
