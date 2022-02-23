import 'package:dio/dio.dart';

class SendPushNotificationService {
  static SendPushNotificationService? _instance;
  static SendPushNotificationService get instance {
    _instance ??= SendPushNotificationService();
    return _instance!;
  }

  sendToAll(Map<String, dynamic>? data) async {
    return Dio().get(
      'https://asia-northeast3-withcenter-test-project.cloudfunctions.net/sendMessageToAll',
      queryParameters: data,
    );
  }

  sendToToken(Map<String, dynamic>? data) async {
    return Dio().get(
      'https://asia-northeast3-withcenter-test-project.cloudfunctions.net/sendMessageToTokens',
      queryParameters: data,
    );
  }

  sendToTopic(Map<String, dynamic>? data) async {
    return Dio().get(
      'https://asia-northeast3-withcenter-test-project.cloudfunctions.net/sendMessageToTopic',
      queryParameters: data,
    );
  }

  sendToUsers(Map<String, dynamic>? data) async {
    return Dio().get(
      'https://asia-northeast3-withcenter-test-project.cloudfunctions.net/sendMessageToUsers',
      queryParameters: data,
    );
  }
}
