import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReminderEditScreen extends StatelessWidget {
  const ReminderEditScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Edit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReminderEdit(
          onPreview: (data) async {
            bool? re = await ReminderService.instance.display(
              context: context,
              onLinkPressed: (String page, dynamic arguments) =>
                  Get.toNamed(page, arguments: arguments),
              data: data,
            );

            debugPrint('re; $re');
          },
          onError: (e) {
            debugPrint(e.toString());
            error(e);
          },
        ),
      ),
    );
  }
}
