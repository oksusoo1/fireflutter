import 'package:extended/extended.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class ReminderEditScreen extends StatelessWidget {
  const ReminderEditScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Edit'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ReminderEdit(onError: error),
      ),
    );
  }
}
