import 'package:flutter/material.dart';
import '../../../../fireflutter.dart';

class CommentEditDialog extends StatefulWidget {
  CommentEditDialog({
    Key? key,
    required this.onCancel,
    required this.onSubmit,
    required this.onError,
    this.comment,
  }) : super(key: key);

  final Function() onCancel;
  final Function(Json, Function(bool)) onSubmit;
  final Function(dynamic) onError;
  final CommentModel? comment;

  @override
  State<CommentEditDialog> createState() => _CommentEditDialogState();
}

class _CommentEditDialogState extends State<CommentEditDialog> {
  final content = TextEditingController();
  List<String> files = [];

  double uploadProgress = 0;

  bool inSubmit = false;

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
      title: Text(
        'Comment ' + (widget.comment == null ? 'Create' : 'Update'),
        style: TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: content,
              minLines: 1,
              maxLines: 10,
            ),
            SizedBox(height: 8),
            Row(children: [
              FileUploadButton(
                child: Icon(
                  Icons.camera_alt,
                  size: 28,
                ),
                type: 'comment',
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
                child: inSubmit
                    ? Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(right: 16),
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('SUBMIT'),
                onPressed: inSubmit
                    ? null
                    : () {
                        widget.onSubmit(
                            {'content': content.text, 'files': files},
                            progress);
                      },
              ),
            ]),
            if (uploadProgress > 0)
              LinearProgressIndicator(value: uploadProgress),
            ImageListEdit(files: files, onError: widget.onError),
          ],
        ),
      ),
    );
  }

  progress(bool f) {
    setState(() {
      inSubmit = f;
    });
  }
}
