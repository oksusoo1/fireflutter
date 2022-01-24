import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/src/reminder/reminder.model.dart';
import 'package:flutter/material.dart';

typedef ReminderCallback = void Function(ReminderModel);

class ReminderService {
  static ReminderService? _instance;
  static ReminderService get instance {
    _instance ??= ReminderService();
    return _instance!;
  }

  final _settings = FirebaseFirestore.instance.collection('settings');
  DocumentReference<Map<String, dynamic>> get _reminderDoc => _settings.doc('reminder');

  listen(ReminderCallback callback) {
    _reminderDoc.snapshots().listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        callback(ReminderModel.fromJson(snapshot.data() as Map<String, dynamic>));
      }
    });
  }

  Future<ReminderModel?> get() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _reminderDoc.get();

    _settings.where('type', isEqualTo: 'reminder').get();

    if (snapshot.exists)
      return ReminderModel.fromJson(snapshot.data() as Map<String, dynamic>);
    else
      return null;
  }

  Future<void> save({
    required String title,
    required String content,
    required String imageUrl,
    required String link,
  }) {
    return _reminderDoc.set({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'link': link,
    });
  }

  Future<bool?> preview(BuildContext context) async {
    return display(context, await get());
  }

  Future<bool?> display(BuildContext context, ReminderModel? data) {
    if (data == null) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text('No reminder\nSave some reminder and preview again'),
              ));
    }

    if (data.title == '' || data.content == '' || data.imageUrl == '') {
      return Future.value(null);
    }

    ReminderModel reminder = data;

    return showDialog<bool?>(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        buttonPadding: const EdgeInsets.all(0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reminder.imageUrl != '') Image.network(reminder.imageUrl),
            if (reminder.title != '')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(reminder.title),
              ),
            if (reminder.content != '')
              Container(
                color: Colors.grey.shade100,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 16),
                child: Text(reminder.content),
              ),
            if (reminder.link != '')
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 16.0),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Text(
                    'MORE INFO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pushNamed(context, reminder.link),
              ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.grey.shade800,
                      child: Text(
                        "Dont' show again",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      color: Colors.blue,
                      child: Text(
                        "Remind me later",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
