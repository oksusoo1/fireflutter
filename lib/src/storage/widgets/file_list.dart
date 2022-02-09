import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FileList extends StatelessWidget {
  const FileList({
    required this.files,
    this.onImageTap,
    Key? key,
  }) : super(key: key);

  final List<String> files;
  final Function(int, String)? onImageTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (int i = 0; i < files.length; i++)
          UploadedImage(
            url: files[i],
            onTap: () => onImageTap != null ? onImageTap!(i, files[i]) : {},
          ),
      ],
    );
  }
}
