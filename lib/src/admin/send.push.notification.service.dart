import '../../fireflutter.dart';

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

  sendToAll(Map<String, dynamic> data) async {
    // return Dio().get(
    //   _serverUrl + '/sendMessageToAll',
    //   queryParameters: data,
    // );
    return FunctionsApi.instance.request(
      _serverUrl + '/sendMessageToAll',
      data,
    );
  }

  sendToToken(Map<String, dynamic> data) async {
    return FunctionsApi.instance.request(
      _serverUrl + '/sendMessageToTokens',
      data,
    );
  }

  sendToTopic(Map<String, dynamic> data) async {
    return FunctionsApi.instance.request(
      _serverUrl + '/sendMessageToTopic',
      data,
    );
  }

  sendToUsers(Map<String, dynamic> data) async {
    return FunctionsApi.instance.request(
      _serverUrl + '/sendMessageToUsers',
      data,
    );
  }
}
