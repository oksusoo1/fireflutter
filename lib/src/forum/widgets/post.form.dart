import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class PostForm extends StatefulWidget {
  const PostForm({
    this.category,
    required this.onCreate,
    required this.onError,
    this.heightBetween = 10.0,
    Key? key,
  }) : super(key: key);

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
  Widget build(BuildContext context) {
    return Column(
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
                final ref = await PostModel(
                  category: widget.category!,
                  title: title.text,
                  content: content.text,
                ).create();

                print('post created; ${ref.id}');
                print('post created; $ref');

                widget.onCreate(ref.id);
              } catch (e) {
                widget.onError(e);
              }
            },
            child: const Text('CREATE POST')),
      ],
    );
  }
}
