import '../../fireflutter.dart';

class SendPushNotificationService {
  static SendPushNotificationService? _instance;
  static SendPushNotificationService get instance {
    _instance ??= SendPushNotificationService();
    return _instance!;
  }

  sendToAll(Map<String, dynamic> data) async {
    return FunctionsApi.instance.request('sendMessageToAll', data: data, addAuth: true);
  }

  sendToToken(Map<String, dynamic> data) async {
    return FunctionsApi.instance.request('sendMessageToTokens', data: data, addAuth: true);
  }

  sendToTopic(Map<String, dynamic> data) async {
    return FunctionsApi.instance.request('sendMessageToTopic', data: data, addAuth: true);
  }

  /// [data] should have all the necessary properties to send it to backend.
  /// 'title' is the title of the message
  /// 'content' is the body of the message.
  /// 'uids' is a string of uid(s) separated by comma(,).
  /// 'badge' is the number of new chat message. It may not work on Android.
  /// 'type' is the type of message
  /// 'senderUid' is the sender uid.
  sendToUsers(Map<String, dynamic> data) async {
    return FunctionsApi.instance.request('sendMessageToUsers', data: data, addAuth: true);
  }

  /// Sending message to the other user in chat room.
  ///
  /// Use this method to send push notification to the other user when login user sends a message to him.
  ///
  /// [data] should have all the necessary properties to send push notifications to chat user.
  ///
  ///  'title' is the title of the message
  /// 'content' is the body of the message.
  /// 'uids' is a string of uid(s) separated by comma(,).
  /// 'badge' is the number of new chat message. It may not work on Android.
  /// 'type' is the type of message
  /// 'senderUid' is the sender uid.
  /// 'subscription' to check if the user has that subscription. If the user has no subscription, then message will not be sent.
  sendToChatUser(Map<String, dynamic> data) async {
    return FunctionsApi.instance.request('sendMessageToChatUser', data: data, addAuth: true);
  }
}
