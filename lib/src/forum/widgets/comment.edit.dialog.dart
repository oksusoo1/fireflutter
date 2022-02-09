import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class CommentEditDialog extends StatefulWidget {
  CommentEditDialog({
    Key? key,
    required this.onCancel,
    required this.onSubmit,
    required this.onError,
    this.comment,
  }) : super(key: key);

  final Function() onCancel;
  final Function(Json) onSubmit;
  final Function(dynamic) onError;
  final CommentModel? comment;

  @override
  State<CommentEditDialog> createState() => _CommentEditDialogState();
}

class _CommentEditDialogState extends State<CommentEditDialog> {
  final content = TextEditingController();
  List<String> files = [];

  double uploadProgress = 0;

  @override
  void initState() {
    super.initState();

    if (widget.comment != null) {
      content.text = widget.comment!.content;
      files = widget.comment!.files;
    }
  }

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
              onUploaded: (url) {
                files = [...files, url];
                uploadProgress = 0;
                if (mounted) setState(() {});
              },
              onProgress: (progress) {
                if (mounted) setState(() => uploadProgress = progress);
              },
              onError: widget.onError,
            ),
            Spacer(),
            TextButton(
              child: const Text('CANCEL'),
              onPressed: widget.onCancel,
            ),
            TextButton(
              child: const Text('CREATE COMMENT'),
              onPressed: () {
                widget.onSubmit({'content': content.text, 'files': files});
              },
            ),
          ]),
          if (uploadProgress > 0) LinearProgressIndicator(value: uploadProgress),
          FileListEdit(files: files, onError: widget.onError)
        ],
      ),
    );
  }
}
