import 'package:dio/dio.dart';

class SendPushNotificationService {
  static SendPushNotificationService? _instance;
  static SendPushNotificationService get instance {
    _instance ??= SendPushNotificationService();
    return _instance!;
  }

  late String _serverUrl;

  init({required String serverUrl}) {
    _serverUrl = serverUrl;
  }

  sendToAll(Map<String, dynamic>? data) async {
    return Dio().get(
      _serverUrl + '/sendMessageToAll',
      queryParameters: data,
    );
  }

  sendToToken(Map<String, dynamic>? data) async {
    return Dio().get(
      _serverUrl + '/sendMessageToTokens',
      queryParameters: data,
    );
  }

  sendToTopic(Map<String, dynamic>? data) async {
    return Dio().get(
      _serverUrl + '/sendMessageToTopic',
      queryParameters: data,
    );
  }

  sendToUsers(Map<String, dynamic>? data) async {
    return Dio().get(
      _serverUrl + '/sendMessageToUsers',
      queryParameters: data,
    );
  }
}
