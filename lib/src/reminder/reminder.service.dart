import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/src/reminder/reminder.model.dart';

typedef ReminderCallback = void Function(ReminderModel);

class ReminderService {
  static ReminderService? _instance;
  static ReminderService get instance {
    _instance ??= ReminderService();
    return _instance!;
  }

  final _reminderDoc = FirebaseFirestore.instance.collection('settings').doc('reminder');
  listen(ReminderCallback callback) {
    _reminderDoc.snapshots().listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        callback(ReminderModel.fromJson(snapshot.data() as Map<String, dynamic>));
      }
    });
  }

  Future<void> save({
    required String title,
    required String content,
    required String imageUrl,
  }) {
    return _reminderDoc.set({
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
    });
  }
}
