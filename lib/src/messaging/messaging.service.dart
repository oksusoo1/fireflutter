import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService with FirestoreMixin, DatabaseMixin {
  static MessagingService? _instance;
  static MessagingService get instance {
    _instance ??= MessagingService();
    return _instance!;
  }

  MessagingService() {
    debugPrint('MessagingService::constructor');
  }

  /// Create or update token info
  ///
  /// User may not signed in. That is why we cannot put this code in user model.
  Future<void> updateToken(String token) {
    return messageTokensCol.doc(token).set(
      {
        'uid': UserService.instance.uid,
      },
      SetOptions(merge: true),
    );
  }

  /// Updates the subscriptions (subscribe or unsubscribe)
  Future<dynamic> updateSubscription(String topic) async {
    List<String> list = UserService.instance.user.topics;
    if (list.contains(topic)) {
      list.remove(topic);
    } else {
      list.add(topic);
    }

    await UserService.instance.update(
      field: 'topics',
      value: list,
    );
    return FirebaseMessaging.instance.subscribeToTopic(topic);
  }
}
