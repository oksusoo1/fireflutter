/// UserSettingsModel
///
///
class UserSettingsModel {
  UserSettingsModel({
    required this.topic,
    required this.data,
  });

  Map<String, bool> topic;

  Map<String, dynamic> data;
  factory UserSettingsModel.fromJson(dynamic data) {
    return UserSettingsModel(
      topic: data['topic'] ?? {},
      data: Map<String, dynamic>.from(data),
    );
  }
}
