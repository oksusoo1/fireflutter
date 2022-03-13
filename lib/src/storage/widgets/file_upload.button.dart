import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../fireflutter.dart';

class FileUploadButton extends StatelessWidget {
  const FileUploadButton({
    this.child,
    required this.type,
    required this.onUploaded,
    required this.onProgress,
    required this.onError,
    Key? key,
  }) : super(key: key);

  final Widget? child;
  final String type;
  final Function(String) onUploaded;
  final Function(double) onProgress;
  final Function(dynamic) onError;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: child != null ? child : Icon(Icons.image),
      onTap: () => uploadFile(context),
    );
  }

  uploadFile(BuildContext ctx) async {
    final String? re = await showModalBottomSheet<String?>(
      context: ctx,
      builder: (context) => Container(
        color: Colors.white,
        child: SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take Photo from Camera'),
                  onTap: () => Navigator.pop(context, 'camera')),
              ListTile(
                  leading: Icon(Icons.photo),
                  title: Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, 'gallery')),
              ListTile(
                  leading: Icon(Icons.photo),
                  title: Text('Attach File'),
                  onTap: () => Navigator.pop(context, 'file')),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      if (re == null) return;
      String uploadedFileUrl;
      if (re == 'camera' || re == 'gallery') {
        uploadedFileUrl = await StorageService.instance.pickUpload(
          onProgress: onProgress,
          source: re == 'camera' ? ImageSource.camera : ImageSource.gallery,
          type: type,
        );
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        if (result == null) return;
        File file = File(result.files.single.path!);
        uploadedFileUrl = await StorageService.instance.upload(
          file: file,
          type: type,
          onProgress: onProgress,
        );
      }

      onUploaded(uploadedFileUrl);
    } catch (e) {
      onError(e);
    }
  }
}
