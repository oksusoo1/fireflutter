import '../../../fireflutter.dart';
import 'package:flutter/material.dart';

class ReminderEditController {
  late final _ReminderEditState state;

  /// 주의, 이미지를 document 에 저장하므로, listen 하는 모든 사용자의 앱에서 새로운 공지를 표시한다.
  ///
  updateImageUrl(String url) async {
    await ReminderService.instance.setImageUrl(url);
    state.load();
  }
}

class ReminderEdit extends StatefulWidget {
  final ReminderEditController? controller;
  ReminderEdit({
    Key? key,
    required this.onPreview,
    required this.onError,
    this.controller,
  }) : super(key: key);
  final Function onError;
  final void Function(ReminderModel) onPreview;

  @override
  _ReminderEditState createState() => _ReminderEditState();
}

class _ReminderEditState extends State<ReminderEdit> {
  final title = TextEditingController();
  final content = TextEditingController();
  final imageUrl = TextEditingController();
  final link = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      widget.controller!.state = this;
    }
    load();
  }

  load() {
    ReminderService.instance.get().then((ReminderModel? reminder) {
      if (reminder != null) {
        if (mounted)
          setState(() {
            title.text = reminder.title;
            content.text = reminder.content;
            imageUrl.text = reminder.imageUrl;
            link.text = reminder.link;
          });
      }
    }).catchError((e) => widget.onError(e));
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
        const SizedBox(height: 16),
        const Text('Content'),
        TextField(
          controller: content,
        ),
        const SizedBox(height: 16),
        const Text('Image Url'),
        TextField(
          controller: imageUrl,
        ),
        const SizedBox(height: 16),
        const Text('Link'),
        TextField(
          controller: link,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                ReminderService.instance
                    .save(
                      title: title.text,
                      content: content.text,
                      imageUrl: imageUrl.text,
                      link: link.text,
                    )
                    .catchError(widget.onError);
              },
              child: const Text('Save'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => widget.onPreview(
                ReminderModel(
                  title: title.text,
                  content: content.text,
                  imageUrl: imageUrl.text,
                  link: link.text,
                ),
              ),
              child: const Text('Preview'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: ReminderService.instance.delete,
              child: const Text('Delete'),
            ),
          ],
        )
      ],
    );
  }
}
