// import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  String id;
  String title;
  ReminderModel({
    required this.id,
    required this.title,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> data) {
    return ReminderModel(
      id: data['id'],
      title: data['title'] ?? '',
    );
  }
}
