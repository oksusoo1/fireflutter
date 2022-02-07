import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentEditDialog extends StatefulWidget {
  CommentEditDialog({
    Key? key,
    required this.onCancel,
    required this.onCreate,
  }) : super(key: key);

  final Function() onCancel;
  final Function(Json) onCreate;

  @override
  State<CommentEditDialog> createState() => _CommentEditDialogState();
}

class _CommentEditDialogState extends State<CommentEditDialog> {
  final content = TextEditingController();
  final List<String> files = [];
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Comment Edit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: content,
          ),
          Row(children: [
            FileUploadButton(
              onUploaded: (url) {},
              onProgress: (progress) {},
              onError: (e) {},
            ),
            Spacer(),
            TextButton(
              child: const Text('CANCEL'),
              onPressed: widget.onCancel,
            ),
            TextButton(
              child: const Text('CREATE COMMENT'),
              onPressed: () {
                widget.onCreate({'content': content.text});
              },
            ),
          ]),
        ],
      ),
    );
  }
}
