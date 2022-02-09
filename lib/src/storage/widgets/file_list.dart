import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class FileList extends StatelessWidget {
  const FileList({required this.files, Key? key}) : super(key: key);

  final List<String> files;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [for (final url in files) UploadedImage(url: url)],
    );
  }
}
