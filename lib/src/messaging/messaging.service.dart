import 'dart:io';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../fireflutter.dart';
// import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService with FirestoreMixin, DatabaseMixin {
  static MessagingService? _instance;
  static MessagingService get instance {
    _instance ??= MessagingService();
    return _instance!;
  }

  final BehaviorSubject<bool> permissionGranted = BehaviorSubject.seeded(false);

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
  String defaultTopic = 'defaultTopic';
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
    this.onNotificationPermissionNotDetermined =
        onNotificationPermissionNotDetermined;
    this.onTokenUpdated = onTokenUpdated;
    _init();
  }

  /// Initialize Messaging
  _init() async {
    /// Permission request for iOS only. For Android, the permission is granted by default.
    if (Platform.isIOS) {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
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
          if (onNotificationPermissionDenied != null)
            onNotificationPermissionDenied!();
          break;
        case AuthorizationStatus.notDetermined:
          if (onNotificationPermissionNotDetermined != null)
            onNotificationPermissionNotDetermined!();
          break;
        case AuthorizationStatus.provisional:
          break;
      }
    }

    // Get the token each time the application loads and save it to database.
    try {
      token = (await FirebaseMessaging.instance.getToken())!;
    } catch (e) {}

    /// Permission is granted hereby.
    permissionGranted.add(true);

    // Handler, when app is on Foreground.
    if (onForegroundMessage != null)
      FirebaseMessaging.onMessage.listen(onForegroundMessage!);

    // Check if app is opened from terminated state and get message data.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (onMessageOpenedFromTermiated != null)
        onMessageOpenedFromTermiated!(initialMessage);
    }

    // Check if the app is opened from the background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (onMessageOpenedFromBackground != null)
        onMessageOpenedFromBackground!(message);
    });

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(((token) {
      _updateToken(token);
      initializeSubscriptions();
    }));

    _updateToken(token);
  }

  updateSaveToken() {
    _updateToken(this.token);
  }

  /// Create or update token info
  ///
  /// User may not signed in. That is why we cannot put this code in user model.
  _updateToken(String token) {
    this.token = token;
    if (this.token == '') return;

    // print('token; $token');

    messageTokensRef.child(token).set({
      'uid': UserService.instance.uid,
    });

    subscribeToDefaultTopic();

    if (onTokenUpdated != null) this.onTokenUpdated!(token);
  }

  // subcribe to topic only when token is created or refresh
  subscribeToDefaultTopic() async {
    // subscribe device to default topic once.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('isSubscribeToDefaultTopic') != this.token) {
      FirebaseMessaging.instance.subscribeToTopic(defaultTopic);
      prefs.setString('isSubscribeToDefaultTopic', this.token);
    }
  }

  /// Updates the subscriptions (subscribe or unsubscribe)
  Future<dynamic> updateSubscription(String topic, bool subscribe) async {
    if (subscribe) {
      await UserSettingService.instance.subscribe(topic);
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    } else {
      await UserSettingService.instance.unsubscribe(topic);
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    }
  }

  toggleSubscription(String topic) {
    return updateSubscription(
      topic,
      !UserSettingService.instance.hasSubscription(topic),
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

  /// Subscribe topics for newly sign-in user.
  ///
  /// This method will run the code only one time even if the user signed-in multiple times.
  ///
  /// when a user Sign-in, the app need to unsubscribe previous subscription
  /// then app needs to subscribe the sign-in user topics.
  /// `isUserLoggedIn` is set true when the user signed-in.
  /// this can be use to check if the user is already loggedIn even the app was closed and reopen.
  /// so it will not reset every time the app is relaunch.
  ///
  /// Conditions of runing this code(unsubscribing).
  ///
  /// 1. Run this code only after the app gets push notification permission.
  ///   (weather it subsribe or not, this code must run after app gets permission.)
  /// 2. Run this code whenever app boots after user sign-in. Or
  ///
  ///   2.2 You may want to reduce the code running by segregating into two different code snipet like below.
  ///   ; - Run this code on token change
  ///   ; - Run this code on user change(sign-out and sign-in)
  ///
  ///   But doing this needs extra work and often leads mistakes.
  ///   So, run this code on every app boots.
  ///
  /// * Note, improvement may be needed here. App may only run this code `if (tokenChanged || userChanged) { ... }`.
  /// * Note, if, in case, the token changes while the app is running, this code will run again.
  ///   - This code is being called on token refresh also.
  ///   - Or when the app restarts, this code run again.
  ///   - And the token is not supposed to be change while the app is running.
  initializeSubscriptions() async {
    final _tokenChanged = await tokenChanged;
    final _userChanged = await userChanged;
    // print('_tokenChanged; $_tokenChanged, _userChanged; $_userChanged');
    if (_tokenChanged || _userChanged) {
      await UserSettingService.instance.unsubscribeAllTopic();
      await UserSettingService.instance.subscribeToUserTopics();
      await MessagingService.instance.updateSaveToken();
      // debugPrint("---> MessagngService::initializeSubscriptions();");
    }
  }

  /// check if token has changed.
  Future<bool> get tokenChanged async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('subscription_init_token');
    if (data == token) return false;
    await prefs.setString('subscription_init_token', token);
    return true;
  }

  /// check if user has changed.
  Future<bool> get userChanged async {
    final uid = UserService.instance.uid;
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('subscription_init_uid');
    if (data == uid) return false;
    await prefs.setString('subscription_init_uid', uid);
    return true;
  }
}
