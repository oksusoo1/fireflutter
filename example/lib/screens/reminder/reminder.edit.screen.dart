import 'package:extended/extended.dart';
import 'package:fe/service/app.service.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReminderEditScreen extends StatelessWidget {
  ReminderEditScreen({Key? key}) : super(key: key);

  static const String routeName = '/reminderEdit';

  final controller = ReminderEditController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Edit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ReminderEdit(
              controller: controller,
              onPreview: (data) async {
                // bool? re =
                await ReminderService.instance.display(
                  context: context,
                  onLinkPressed: (String page, dynamic arguments) =>
                      AppService.instance.open(page, arguments: arguments),
                  data: data,
                );

                // debugPrint('re; $re');
              },
              onError: (e) {
                // debugPrint(e.toString());
                error(e);
              },
            ),
            const Divider(),
            ElevatedButton(
              onPressed: () {
                controller.updateImageUrl('abc');
              },
              child: const Text('Update imageUrl'),
            ),
          ],
        ),
      ),
    );
  }
}
