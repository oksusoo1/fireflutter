import 'package:flutter/material.dart';

class FileList extends StatelessWidget {
  const FileList({required this.files, Key? key}) : super(key: key);

  final List<String> files;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (final url in files) Image.network(url, height: 100, width: 100, fit: BoxFit.cover)
      ],
    );
  }
}
