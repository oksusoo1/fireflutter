import 'dart:async';
import 'dart:io';
// import 'package:rxdart/subjects.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../../fireflutter.dart';
// import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// MessagingService
///
/// Push notification will be appears on system tray(or on the top of the mobile device)
/// when the app is closed or in background state.
///
/// [onBackgroundMessage] is being invoked when the app is closed(terminated). (NOT running the app.)
///
/// [onForegroundMessage] will be called when the user(or device) receives a push notification
/// while the app is running and in foreground state.
///
/// [onMessageOpenedFromBackground] will be called when the user tapped on the push notification
/// on system tray while the app was running but in background state.
///
/// [onMessageOpenedFromTermiated] will be called when the user tapped on the push notification
/// on system tray while the app was closed(terminated).
///
///
///
class MessagingService with FirestoreMixin, DatabaseMixin {
  static MessagingService? _instance;
  static MessagingService get instance {
    _instance ??= MessagingService();
    return _instance!;
  }

  // final BehaviorSubject<bool> permissionGranted = BehaviorSubject.seeded(false);

  MessagingService() {
    // debugPrint('MessagingService::constructor');
  }

  late Function(RemoteMessage) onForegroundMessage;
  late Function(RemoteMessage) onMessageOpenedFromTermiated;
  late Function(RemoteMessage) onMessageOpenedFromBackground;
  late Function onNotificationPermissionDenied;
  late Function onNotificationPermissionNotDetermined;
  String token = '';
  String defaultTopic = 'defaultTopic';
  bool doneDefaultTopic = false;

  // StreamSubscription? sub;

  init({
    required Future<void> Function(RemoteMessage)? onBackgroundMessage,
    required Function(RemoteMessage) onForegroundMessage,
    required Function(RemoteMessage) onMessageOpenedFromTermiated,
    required Function(RemoteMessage) onMessageOpenedFromBackground,
    required Function onNotificationPermissionDenied,
    required Function onNotificationPermissionNotDetermined,
  }) {
    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }

    this.onForegroundMessage = onForegroundMessage;
    this.onMessageOpenedFromTermiated = onMessageOpenedFromTermiated;
    this.onMessageOpenedFromBackground = onMessageOpenedFromBackground;
    this.onNotificationPermissionDenied = onNotificationPermissionDenied;
    this.onNotificationPermissionNotDetermined = onNotificationPermissionNotDetermined;
    _init();
  }

  /// Initialize Messaging
  _init() async {
    /// Update token only after the app gets user information. NOT immediately after user sign-in.
    UserService.instance.signIn.listen((user) {
      if (user.loaded) {
        _updateToken();
      }
    });

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

      /// Check if permission had given.
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return onNotificationPermissionDenied();
      }
      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        return onNotificationPermissionNotDetermined();
      }
    }

    // Get the token each time the application loads and save it to database.
    token = await FirebaseMessaging.instance.getToken() ?? '';

    // Handler, when app is on Foreground.
    FirebaseMessaging.onMessage.listen(onForegroundMessage);

    // Check if app is opened from CLOSED(TERMINATED) state and get message data.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      onMessageOpenedFromTermiated(initialMessage);
    }

    // Check if the app is opened(running) from the background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onMessageOpenedFromBackground(message);
    });

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(_updateToken);

    _updateToken(token);
  }

  /// Create or update token info
  ///
  /// User may not signed in. That is why we cannot put this code in user model.
  /// must be called when user signIn or when tokenRefresh
  /// skip if user is not signIn. _updateToken() will registered the device to default topic
  _updateToken([String? token]) {
    if (token == null) token = this.token;
    if (token == '') return;

    subscribeToDefaultTopic();

    if (UserService.instance.user.loaded == false) return;
    FunctionsApi.instance.request('updateToken', data: {'token': token}, addAuth: true);
  }

  /// Subcribe to default topic.
  ///
  /// This may be called on every app boot (after permission, initialization)
  subscribeToDefaultTopic() {
    if (doneDefaultTopic) return;
    doneDefaultTopic = true;
    FirebaseMessaging.instance.subscribeToTopic(defaultTopic);
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
