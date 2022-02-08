import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

// import 'package:firebase_core/firebase_core.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  // print("---> Handling a background message: ${message.messageId}");
  if (message.data['type'] == 'chat' && message.data['badge'] != null) {
    FlutterAppBadger.updateBadgeCount(int.parse(message.data['badge']));
  }
}

class MessagingService {
  String token = '';

  MessagingService() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
          onNotificationPermissionDenied();
          break;
        case AuthorizationStatus.notDetermined:
          onNotificationPermissionNotDetermined();
          break;
        case AuthorizationStatus.provisional:
          break;
      }
    }

    // Handler, when app is on Foreground.
    FirebaseMessaging.onMessage.listen(onForegroundMessage);

    // Check if app is opened from terminated state and get message data.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      onMessageOpenedFromTermiated(initialMessage);
    }

    // Check if the app is opened from the background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onMessageOpenedFromBackground(message);
    });

    // Get the token each time the application loads and save it to database.

    try {
      token = (await FirebaseMessaging.instance.getToken())!;
      print(token);
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
    //     _updateToken(token);
    //   }
    // });
  }

  /// 토큰 업데이트
  ///
  _updateToken(String token) async {
    this.token = token;
    if (this.token == '') return;
    // try {
    //   await MessagingApi.instance.updateToken(token);
    // } catch (e) {
    //   service.error(e);
    // }
  }

  /// Forground Message
  ///
  /// [message.data] would something like `{a: apple}`
  ///
  /// Test on both Android device, Emulator, and iOS device. Simulator is not working.
  onForegroundMessage(RemoteMessage message) {
    // print('---> onForegroundMessage::message');
    // print(message);
    // if (UserApi.instance.currentUser.loggedIn &&
    //     message.data['sender_ID'] == "${UserApi.instance.currentUser.id}")
    //   return;

    // if (message.data['type'] == 'chat') {
    //   // determin if the room is open dont send push notification
    //   // return if the message is coming from current chat room and the user is on the chat room.
    //   if (message.data['otherUid'] == ChatService.instance.otherUid) return;

    //   //
    //   if (message.data['badge'] != null)
    //     FlutterAppBadger.updateBadgeCount(int.parse(message.data['badge']));
    // }

    // Service.instance.toast(
    //   message.notification!.title ?? '',
    //   message.notification!.body ?? '',
    //   onTap: () {
    //     onMessageOpenedShowMessage(message);
    //   },
    // );
  }

  /// This will be invoked when the app is opened from terminated state.
  ///
  /// Test on both Android device, Emulator, and iOS device. Simulator is not working.
  onMessageOpenedFromTermiated(RemoteMessage message) {
    // print('onMessageOpenedFromTermiated::message');
    // print(message);
    // If it the message has data, then do some exttra work based on the data.
    onMessageOpenedShowMessage(message);
    // FlutterAppBadger.removeBadge(); // remove badge if open on terminated state.
  }

  /// This will be invoked when the app is opened from backgroun state.
  ///
  /// Test on both Android device, Emulator, and iOS device. Simulator is not working.
  onMessageOpenedFromBackground(RemoteMessage message) {
    // print('onMessageOpenedFromBackground::message');
    // print(message);
    onMessageOpenedShowMessage(message);
  }

  onMessageOpenedShowMessage(RemoteMessage message) {
    // print(message);
    /**
     * return if the the sender is also the current loggedIn user.
     */
    // if (UserApi.instance.currentUser.loggedIn &&
    //     message.data['sender_ID'] == "${UserApi.instance.currentUser.id}")
    //   return;

    // /**
    //  * If the type is post then move it to a specific post.
    //  */
    // if (message.data['type'] == 'post') {
    //   Service.instance.open(
    //     RouteNames.forumList,
    //     arguments: {'id': int.parse(message.data['id'])},
    //     preventDuplicates: false,
    //   );
    // }

    // /**
    //  * If the type is chat then move it to chat room.
    //  */
    // if (message.data['type'] == 'chat') {
    //   Service.instance.open(
    //     RouteNames.chatRoom,
    //     arguments: {'user_login': message.data['otherUid']},
    //     preventDuplicates: true,
    //   );
    // }
  }

  /// User denied push notification
  ///
  /// What to do: App may show a dialog box to open Device Settings and grant the permission.
  onNotificationPermissionDenied() {
    // print('onNotificationPermissionDenied()');
  }

  /// User didn't grant, nor denied the permission, yet.
  onNotificationPermissionNotDetermined() {
    // print('onNotificationPermissionNotDetermined()');
  }
}
