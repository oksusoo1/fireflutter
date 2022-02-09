import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class ImageList extends StatelessWidget {
  const ImageList({
    required this.files,
    this.onImageTap,
    this.imageSize = 200,
    Key? key,
  }) : super(key: key);

  final List<String> files;
  final Function(int)? onImageTap;
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Wrap(
        spacing: 4.0,
        children: [
          for (int i = 0; i < files.length; i++)
            UploadedImage(
              height: imageSize,
              width: imageSize,
              url: files[i],
              onTap: () => onImageTap != null ? onImageTap!(i) : {},
            ),
        ],
      ),
    );
  }
}
