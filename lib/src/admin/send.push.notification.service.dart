import '../../fireflutter.dart';

class SendPushNotificationService {
  static SendPushNotificationService? _instance;
  static SendPushNotificationService get instance {
    _instance ??= SendPushNotificationService();
    return _instance!;
  }

  sendToAll(Map<String, dynamic> data) async {
    // return Dio().get(
    //   _serverUrl + '/sendMessageToAll',
    //   queryParameters: data,
    // );
    return FunctionsApi.instance
        .request('sendMessageToAll', data: data, addAuth: true);
  }

  sendToToken(Map<String, dynamic> data) async {
    return FunctionsApi.instance
        .request('sendMessageToTokens', data: data, addAuth: true);
  }

  sendToTopic(Map<String, dynamic> data) async {
    return FunctionsApi.instance
        .request('sendMessageToTopic', data: data, addAuth: true);
  }

  sendToUsers(Map<String, dynamic> data) async {
    return FunctionsApi.instance
        .request('sendMessageToUsers', data: data, addAuth: true);
  }
}
