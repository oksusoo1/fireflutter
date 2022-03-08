import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ReminderCallback = void Function(ReminderModel);

typedef OnPressedCallback = void Function(String, Map<String, dynamic>);

class ReminderService {
  static ReminderService? _instance;
  static ReminderService get instance {
    _instance ??= ReminderService();
    return _instance!;
  }

  late ReminderCallback onReminder;
  // ignore: cancel_subscriptions
  StreamSubscription? subscription;

  final settingsCol = FirebaseFirestore.instance.collection('settings');
  DocumentReference<Map<String, dynamic>> get _reminderDoc =>
      settingsCol.doc('reminder');

  init({
    required ReminderCallback onReminder,
  }) {
    this.onReminder = onReminder;
    _listen();
  }

  /// Listen to the change of Reminder document.
  ///
  /// App needs to listen again after pressing 'remind me later' or 'more info',
  /// since the `link` has changed.
  ///
  /// If you don't listen again, the reminder dialog of same link will appear
  /// again when ever title, content, image url changes even if `link` does not
  /// changes.
  _listen() async {
    Query q = settingsCol.where('type', isEqualTo: 'reminder');

    /// If there is no link saved, then just get the data.
    String? link = await getLink();
    if (link != null) {
      q = q.where('link', isNotEqualTo: link);
    }

    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
    }

    subscription = q.snapshots().listen((QuerySnapshot<Object?> snapshot) {
      if (snapshot.size > 0) {
        onReminder(ReminderModel.fromJson(
            snapshot.docs.first.data() as Map<String, dynamic>));
      }
    });
  }

  /// Get the reminder document
  ///
  ///
  Future<ReminderModel?> get() async {
    Query q = settingsCol.where('type', isEqualTo: 'reminder');

    final QuerySnapshot snapshot = await q.get();
    if (snapshot.size == 0) return null;
    return ReminderModel.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>);
  }

  Future<bool> saveLink(String link) async {
    final prefs = await SharedPreferences.getInstance();
    final _return = prefs.setString('reminder.link', link);

    _listen();

    return _return;
  }

  Future<String?> getLink() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('reminder.link');
  }

  Future<void> save({
    required String title,
    required String content,
    required String imageUrl,
    required String link,
  }) {
    return _reminderDoc.set({
      'type': 'reminder',
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'link': link,
    });
  }

  Future<void> setImageUrl(String url) {
    return _reminderDoc.set({'imageUrl': url}, SetOptions(merge: true));
  }

  /// Returns
  /// - true if "more link" button or "don't show again" button is clicked.
  /// - false if "remind me later" is clicked
  /// - null if backdrop is clicked.
  Future<bool?> display({
    required BuildContext context,
    required OnPressedCallback onLinkPressed,
    ReminderModel? data,
  }) {
    if (data == null) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(
              'No reminder!\n\n-You have already pressed buttons on preview mode. Change the link and test again if you did.\n\n- Or, save some reminder and preview again'),
        ),
      );
    }

    if (data.title == '' && data.content == '' && data.imageUrl == '') {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text('Input one of title, content, or image Url'),
        ),
      );
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
                child: Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            if (reminder.content != '')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 16),
                child: Text(
                  reminder.content,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            if (reminder.link != '')
              GestureDetector(
                child: Container(
                  margin: EdgeInsets.only(top: 8.0, bottom: 24),
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
                onTap: () {
                  saveLink(reminder.link);
                  Navigator.pop(context, true);
                  onLinkPressed(reminder.link, splitQueryString(reminder.link));
                },
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
                      saveLink(reminder.link);
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

  delete() {
    _reminderDoc.delete();
  }
}
