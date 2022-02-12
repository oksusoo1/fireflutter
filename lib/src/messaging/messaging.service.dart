import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';
// import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService with FirestoreMixin, DatabaseMixin {
  static MessagingService? _instance;
  static MessagingService get instance {
    _instance ??= MessagingService();
    return _instance!;
  }

  MessagingService() {
    // debugPrint('MessagingService::constructor');
  }

  Function(RemoteMessage)? onForegroundMessage;
  Function(RemoteMessage)? onMessageOpenedFromTermiated;
  Function(RemoteMessage)? onMessageOpenedFromBackground;
  Function? onNotificationPermissionDenied;
  Function? onNotificationPermissionNotDetermined;
  Function? onTokenUpdated;

  String token = '';

  init({
    Future<void> Function(RemoteMessage)? onBackgroundMessage,
    Function(RemoteMessage)? onForegroundMessage,
    Function(RemoteMessage)? onMessageOpenedFromTermiated,
    Function(RemoteMessage)? onMessageOpenedFromBackground,
    Function? onNotificationPermissionDenied,
    Function? onNotificationPermissionNotDetermined,
    Function? onTokenUpdated,
  }) {
    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }

    this.onForegroundMessage = onForegroundMessage;
    this.onMessageOpenedFromTermiated = onMessageOpenedFromTermiated;
    this.onMessageOpenedFromBackground = onMessageOpenedFromBackground;
    this.onNotificationPermissionDenied = onNotificationPermissionDenied;
    this.onNotificationPermissionNotDetermined = onNotificationPermissionNotDetermined;
    this.onTokenUpdated = onTokenUpdated;
    _init();
  }

  /// Initialize Messaging
  _init() async {
    /// Permission request for iOS only. For Android, the permission is granted by default.
    if (Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // print('User granted permission: ${settings.authorizationStatus}');

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          break;
        case AuthorizationStatus.denied:
          if (onNotificationPermissionDenied != null) onNotificationPermissionDenied!();
          break;
        case AuthorizationStatus.notDetermined:
          if (onNotificationPermissionNotDetermined != null)
            onNotificationPermissionNotDetermined!();
          break;
        case AuthorizationStatus.provisional:
          break;
      }
    }

    // Handler, when app is on Foreground.
    if (onForegroundMessage != null) FirebaseMessaging.onMessage.listen(onForegroundMessage!);

    // Check if app is opened from terminated state and get message data.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (onMessageOpenedFromTermiated != null) onMessageOpenedFromTermiated!(initialMessage);
    }

    // Check if the app is opened from the background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (onMessageOpenedFromBackground != null) onMessageOpenedFromBackground!(message);
    });

    // Get the token each time the application loads and save it to database.

    try {
      token = (await FirebaseMessaging.instance.getToken())!;
      // print(token);
    } catch (e) {
      print('------> getToken() error $e');
    }

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(_updateToken);

    // @TODO  updateToken

    // AppController.of.authComplete.stream.listen((bool? re) {
    //   if (re == null) {
    //     return;
    //   } else {
    _updateToken(token);
    //   }
    // });
  }

  /// Create or update token info
  ///
  /// User may not signed in. That is why we cannot put this code in user model.
  _updateToken(String token) {
    this.token = token;
    if (this.token == '') return;

    messageTokensCol.doc(token).set(
      {
        'uid': UserService.instance.uid,
      },
      SetOptions(merge: true),
    );
    if (onTokenUpdated != null) this.onTokenUpdated!(token);
  }

  /// Updates the subscriptions (subscribe or unsubscribe)
  Future<dynamic> updateSubscription(String topic, bool subscribe) async {
    if (subscribe) {
      await UserSettingsService.instance.subscribe(topic);
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    } else {
      await UserSettingsService.instance.unsubscribe(topic);
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    }
  }

  toggleSubscription(String topic) {
    return updateSubscription(
      topic,
      !UserSettingsService.instance.hasSubscription(topic),
    );
  }

  sendMessage({
    String? to,
    Map<String, String>? data,
    String? collapseKey,
    String? messageId,
    String? messageType,
    int? ttl,
  }) {
    return FirebaseMessaging.instance.sendMessage(
      to: to,
      data: data,
      collapseKey: collapseKey,
      messageId: messageId,
      messageType: messageType,
    );
  }
}
