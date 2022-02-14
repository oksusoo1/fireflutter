import 'package:flutter/material.dart';
import '../../../../fireflutter.dart';

class PostForm extends StatefulWidget {
  const PostForm({
    this.category,
    this.post,
    required this.onCreate,
    required this.onUpdate,
    required this.onError,
    this.heightBetween = 10.0,
    this.titleFieldBuilder,
    this.contentFieldBuilder,
    this.submitButtonBuilder,
    Key? key,
  }) : super(key: key);

  final PostModel? post;
  final String? category;
  final double heightBetween;

  final Function(String) onCreate;
  final Function(String) onUpdate;
  final Function(dynamic) onError;

  final Widget Function(TextEditingController)? titleFieldBuilder;
  final Widget Function(TextEditingController)? contentFieldBuilder;
  final Widget Function(Function())? submitButtonBuilder;
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
    final titleField = widget.titleFieldBuilder != null
        ? widget.titleFieldBuilder!(title)
        : TextField(controller: title);
    final contentField = widget.contentFieldBuilder != null
        ? widget.contentFieldBuilder!(content)
        : TextField(controller: content);

    final submitButton = widget.submitButtonBuilder != null
        ? widget.submitButtonBuilder!(onSubmit)
        : ElevatedButton(onPressed: () => onSubmit(), child: const Text('SUBMIT'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Title'),
        titleField,
        SizedBox(height: widget.heightBetween),
        const Text('Content'),
        contentField,
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
            submitButton
          ],
        ),
        ImageListEdit(files: files, onError: widget.onError),
      ],
    );
  }

  Future<void> onSubmit() async {
    try {
      if (widget.category != null && widget.category!.isNotEmpty) {
        final ref = await PostModel().create(
          category: widget.category!,
          title: title.text,
          content: content.text,
          files: files,
        );
        widget.onCreate(ref.id);
      } else {
        await widget.post!.update(
          title: title.text,
          content: content.text,
          files: files,
        );
        widget.onUpdate(widget.post!.id);
      }
    } catch (e) {
      widget.onError(e);
    }
  }
}
