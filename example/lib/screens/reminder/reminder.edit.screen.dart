import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReminderEditScreen extends StatefulWidget {
  const ReminderEditScreen({Key? key}) : super(key: key);

  @override
  _ReminderEditScreenState createState() => _ReminderEditScreenState();
}

class _ReminderEditScreenState extends State<ReminderEditScreen> {
  final title = TextEditingController();
  final content = TextEditingController();
  final imageUrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Edit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    ReminderService.instance
                        .save(
                          title: title.text,
                          content: content.text,
                          imageUrl: imageUrl.text,
                        )
                        .catchError(error);
                  },
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () {},
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
        ),
      ),
    );
  }
}
