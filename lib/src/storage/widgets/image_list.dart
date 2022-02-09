import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class ImageList extends StatelessWidget {
  const ImageList({
    required this.files,
    this.onImageTap,
    Key? key,
  }) : super(key: key);

  final List<String> files;
  final Function(int)? onImageTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (int i = 0; i < files.length; i++)
          UploadedImage(
            url: files[i],
            onTap: () => onImageTap != null ? onImageTap!(i) : {},
          ),
      ],
    );
  }
}
