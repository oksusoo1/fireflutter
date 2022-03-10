import 'package:firebase_database/firebase_database.dart';
import './../../fireflutter.dart';

/// UserSettingsModel
///
///
class UserSettingsModel with DatabaseMixin {
  UserSettingsModel({
    required this.topics,
    required this.data,
  });

  Map<String, bool> topics;

  Map<String, dynamic> data;
  factory UserSettingsModel.fromJson(dynamic data) {
    return UserSettingsModel(
      topics: Map<String, bool>.from(data['topic'] ?? {}),
      data: Map<String, dynamic>.from(data),
    );
  }

  factory UserSettingsModel.empty() {
    return UserSettingsModel(topics: {}, data: {});
  }

  Future<void> create() {
    return userSettingsDoc.set({'timestamp': ServerValue.timestamp});
  }

  /// update user setting
  Future<void> update(Json settings) async {
    ///
    final snapshot = await userSettingsDoc.get();
    if (snapshot.exists) {
      return userSettingsDoc.update(settings);
    } else {
      return userSettingsDoc.set(settings);
    }
  }

  /// Returns the value of the key
  value(String key) {
    return data[key];
  }
}
