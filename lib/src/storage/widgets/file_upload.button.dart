import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../fireflutter.dart';

class FileUploadButton extends StatelessWidget {
  const FileUploadButton({
    this.child,
    required this.onUploaded,
    required this.onProgress,
    required this.onError,
    Key? key,
  }) : super(key: key);

  final Widget? child;
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
    final ImageSource? re = await showModalBottomSheet<ImageSource?>(
      context: ctx,
      builder: (context) => Container(
        color: Colors.white,
        child: SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text('Take Photo from Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera)),
              ListTile(
                  leading: Icon(Icons.photo),
                  title: Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery)),
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
      String uploadedFileUrl = await StorageService.instance.pickUpload(
        onProgress: onProgress,
        source: re,
      );
      onUploaded(uploadedFileUrl);
    } catch (e) {
      onError(e);
    }
  }
}
