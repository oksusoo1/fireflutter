import 'package:cloud_functions/cloud_functions.dart';

class SendPushNotificationService {
  static SendPushNotificationService? _instance;
  static SendPushNotificationService get instance {
    _instance ??= SendPushNotificationService();
    return _instance!;
  }

  sendToToken(Map<String, dynamic>? data) async {}
  sendToTopic(Map<String, dynamic>? data) async {}

  sendToUsers(Map<String, dynamic>? data) async {}
}
