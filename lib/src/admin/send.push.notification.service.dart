import 'package:cloud_functions/cloud_functions.dart';

class SendPushNotificationService {
  static SendPushNotificationService? _instance;
  static SendPushNotificationService get instance {
    _instance ??= SendPushNotificationService();
    return _instance!;
  }

  sendNotification(Map<String, dynamic>? data) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('sendPushNotification');
    final results = await callable(data);
    print(results);
  }
}
