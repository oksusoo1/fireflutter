import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostForm extends StatefulWidget {
  const PostForm({
    this.category,
    this.post,
    required this.onCreate,
    required this.onError,
    this.heightBetween = 10.0,
    Key? key,
  }) : super(key: key);

  final PostModel? post;
  final String? category;
  final double heightBetween;

  final Function(String) onCreate;
  final Function(dynamic) onError;
  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final title = TextEditingController();
  final content = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      title.text = widget.post?.title ?? '';
      content.text = widget.post?.content ?? '';
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
        ElevatedButton(
            onPressed: () async {
              try {
                if (widget.category != null) {
                  final ref = await PostModel().create(
                    category: widget.category!,
                    title: title.text,
                    content: content.text,
                  );
                  widget.onCreate(ref.id);
                } else {
                  await widget.post!.update(
                    title: title.text,
                    content: content.text,
                  );
                  widget.onCreate(widget.post!.id);
                }
              } catch (e) {
                widget.onError(e);
              }
            },
            child: const Text('CREATE POST')),
      ],
    );
  }
}
