import 'package:flutter/material.dart';
import '../../../fireflutter.dart';

class PostForm extends StatefulWidget {
  const PostForm({
    this.category,
    this.post,
    required this.onCreate,
    required this.onUpdate,
    required this.onError,
    this.heightBetween = 10.0,
    Key? key,
  }) : super(key: key);

  final PostModel? post;
  final String? category;
  final double heightBetween;

  final Function(String) onCreate;
  final Function(String) onUpdate;
  final Function(dynamic) onError;
  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final title = TextEditingController();
  final content = TextEditingController();

  late List<String> files = [];

  double uploadProgress = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      title.text = widget.post?.title ?? '';
      content.text = widget.post?.content ?? '';
      files = widget.post?.files ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Title'),
        TextField(
          controller: title,
        ),
        SizedBox(height: widget.heightBetween),
        const Text('Content'),
        TextField(
          controller: content,
        ),
        SizedBox(height: widget.heightBetween),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FileUploadButton(
              onUploaded: (url) {
                files = [...files, url];
                if (mounted) setState(() {});
              },
              onProgress: (progress) {
                if (mounted) setState(() => uploadProgress = progress);
              },
              onError: widget.onError,
            ),
            ElevatedButton(
                onPressed: () async {
                  try {
                    if (widget.category != null) {
                      final ref = await PostModel().create(
                        category: widget.category!,
                        title: title.text,
                        content: content.text,
                        extra: {'files': files},
                      );
                      widget.onCreate(ref.id);
                    } else {
                      await widget.post!.update(
                        title: title.text,
                        content: content.text,
                        extra: {'files': files},
                      );
                      widget.onUpdate(widget.post!.id);
                    }
                  } catch (e) {
                    widget.onError(e);
                  }
                },
                child: const Text('SUBMIT')),
          ],
        ),
        ImageListEdit(files: files, onError: widget.onError),
      ],
    );
  }
}
