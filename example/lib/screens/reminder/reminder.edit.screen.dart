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
          onLinkPressed: (String page, dynamic arguments) =>
              Get.toNamed(page, arguments: arguments),
          onError: error,
        ),
      ),
    );
  }
}
