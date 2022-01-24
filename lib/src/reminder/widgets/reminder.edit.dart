import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReminderEdit extends StatefulWidget {
  const ReminderEdit({
    Key? key,
    required this.onLinkPressed,
    required this.onError,
  }) : super(key: key);
  final Function onError;
  final OnPressedCallback onLinkPressed;

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
    ReminderService.instance.get().then((ReminderModel? reminder) {
      if (reminder != null) {
        setState(() {
          title.text = reminder.title;
          content.text = reminder.content;
          imageUrl.text = reminder.imageUrl;
          link.text = reminder.link;
        });
      }
    }).catchError(widget.onError);
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
        const Text('Image url'),
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
            ElevatedButton(
              onPressed: () async {
                await ReminderService.instance
                    .save(
                      title: title.text,
                      content: content.text,
                      imageUrl: imageUrl.text,
                      link: link.text,
                    )
                    .catchError(widget.onError);
                bool? re = await ReminderService.instance.preview(
                  context: context,
                  onLinkPressed: widget.onLinkPressed,
                );
                print('re; $re');
              },
              child: const Text('Preview'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Start'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Stop'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Delete'),
            ),
          ],
        )
      ],
    );
  }
}
