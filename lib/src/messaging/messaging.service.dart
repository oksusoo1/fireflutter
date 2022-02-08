import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
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

  Future<void> updateToken(String token) {
    return messageTokensCol.doc(token).set({
      'uid': FirebaseAuth.instance.currentUser?.uid ?? '',
    }, SetOptions(merge: true));
  }

  Future<dynamic> updateSubscription(String topic) async {
    await UserService.instance.update(
        field: 'topics',
        value: FieldValue.arrayUnion([
          {topic: true}
        ]));
    return FirebaseMessaging.instance.subscribeToTopic(topic);
  }
}
