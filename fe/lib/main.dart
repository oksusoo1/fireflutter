// import 'package:fe/screens/chat/chat.room.screen.dart';
// import 'dart:async';

import 'dart:async';
import 'dart:developer';

import 'package:extended/extended.dart';
import 'package:fe/services/app.router.dart';
import 'package:fe/services/app.service.dart';
import 'package:fe/screens/friend_map/friend_map.screen.dart';
import 'package:fe/screens/home/home.screen.dart';
import 'package:fe/services/global.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      FlutterError.onError = (FlutterErrorDetails details) {
        /// Flutter exceptions come here.
        log("--> FlutterError.onError : from (the inside of) Flutter framework.");
        log("------------------------------------------------------------------");
        FlutterError.dumpErrorToConsole(details);
        AppService.instance.error(details.exception);
      };
      runApp(MainApp(
        initialLink: await DynamicLinkService.instance.initialLink,
      ));
    },
    (e, stackTrace) {
      /// Firebase exceptions and dart(outside flutter) exceptions come here.
      log("--> runZoneGuarded() : exceptions outside flutter framework.");
      log("------------------------------------------------------------");
      log("--> runtimeType: ${e.runtimeType}");
      log("Dart Error :  $e");
      debugPrintStack(stackTrace: stackTrace);
      AppService.instance.error(e);
    },
  );
}

class MainApp extends StatefulWidget {
  const MainApp({required this.initialLink, Key? key}) : super(key: key);
  final PendingDynamicLinkData? initialLink;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    FunctionsApi.instance.init(
      serverUrl: "https://asia-northeast3-withcenter-test-project.cloudfunctions.net/",
      // onError: error,
    );

    /// Instantiate UserService & see debug print message
    if (UserService.instance.user.isAdmin) {
      // print('The user is admin...');
    }

    PresenceService.instance.activate(
      onError: (e) => debugPrint('--> Presence error: $e'),
    );

    ExtendedService.instance.navigatorKey = globalNavigatorKey;

    SearchService.instance.init(serverUrl: 'http://wonderfulkorea.kr:7700');

    // Timer(
    //     const Duration(milliseconds: 200),
    //     () => AppService.instance
    //         .open(ForumListScreen.routeName, arguments: {'category': 'qna'}));
    // Timer(const Duration(milliseconds: 200), () => Get.toNamed('/email-verify'));
    // Timer(const Duration(milliseconds: 200), AppController.of.openCategory);
    // Timer(
    //   const Duration(milliseconds: 200),
    //   () => AppService.instance.router.open(PostListScreen.routeName, arguments: {
    //     'category': 'qna',
    //   }),
    // );
    // Timer(const Duration(milliseconds: 200),
    //     () => AppService.instance.router.open(TranslationsScreen.routeName));
    // Timer(
    //     const Duration(milliseconds: 200), () => AppService.instance.router.open(JobEditScreen.routeName));

    // Open qna & open first post
    // Timer(const Duration(milliseconds: 100), () async {
    //   AppController.of.openPostList(category: 'qna');

    //   /// wait
    //   await Future.delayed(Duration(milliseconds: 200));
    // });

    /// Dynamic links for terminated app.
    if (widget.initialLink != null) {
      final Uri deepLink = widget.initialLink!.link;
      // Example of using the dynamic link to push the user to a different screen

      /// If you do alert too early, it may not appear on screen.
      WidgetsBinding.instance.addPostFrameCallback((dr) {
        alert('Terminated app',
            'Got dynamic link event. deepLink.path; ${deepLink.path},  ${deepLink.queryParametersAll}');
        // Get.toNamed(deepLink.path, arguments: deepLink.queryParameters);
      });
    }

    ///
    DynamicLinkService.instance.listen((Uri? deepLink) {
      alert('Background 2',
          'Dyanmic Link Event on background(or foreground). deepLink.path; ${deepLink?.path}, ${deepLink?.queryParametersAll}');
    });

    /// Listen to FriendMap
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        /// Re-init for listening the login user (when account changed)
        InformService.instance.init(callback: (data) {
          if (data['type'] == 'FriendMap') {
            /// If it's a freind map request, then open friend map screen.
            AppRouter.instance.open(FriendMapScreen.routeName, arguments: {
              'latitude': data['latitude'],
              'longitude': data['longitude'],
            });
          }
        });
      } else {
        InformService.instance.dispose();
      }
    });

    /// Listen to reminder
    ///
    /// Delay 3 seconds. This is just to display the reminder dialog 3 seconds
    /// after the app boots. No big deal here.
    ///
    /// See fireflutter readme for details
    Timer(const Duration(seconds: 3), () {
      /// Listen to the reminder update event.
      ReminderService.instance.init(onReminder: (reminder) {
        /// Display the reminder using default dialog UI. You may copy the code
        /// and customize by yourself.
        ReminderService.instance.display(
          context: globalNavigatorKey.currentContext!,
          data: reminder,
          onLinkPressed: (page, arguments) {
            AppRouter.instance.open(page, arguments: arguments);
          },
        );
      });
    });

    MessagingService.instance.init(
      // while the app is close and notification arrive you can use this to do small work
      // example are changing the badge count or informing backend.
      onBackgroundMessage: _firebaseMessagingBackgroundHandler,
      onForegroundMessage: (message) {
        // this will triggered while the app is opened
        // If the message has data, then do some extra work based on the data.
        // print(message);
        onMessageOpenedShowMessage(message);
      },
      onMessageOpenedFromTermiated: (message) {
        // this will triggered when the notification on tray was tap while the app is closed

        WidgetsBinding.instance.addPostFrameCallback((duration) {
          onMessageOpenedShowMessage(message);
        });
      },
      onMessageOpenedFromBackground: (message) {
        // this will triggered when the notification on tray was tap while the app is open but in background state.
        onMessageOpenedShowMessage(message);
      },
      onNotificationPermissionDenied: () {
        // print('onNotificationPermissionDenied()');
      },
      onNotificationPermissionNotDetermined: () {
        // print('onNotificationPermissionNotDetermined()');
      },
      // onTokenUpdated: (token) {
      //   // print('##########onTokenUpdated###########');
      //   // print(token);
      // },
    );

    ChatService.instance.newMessages.listen((int newMessages) {
      FlutterAppBadger.updateBadgeCount(newMessages);
    });
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null)
        ChatService.instance.unsubscribeNewMessages();
      else
        ChatService.instance.countNewMessages();
    });

    FirebaseAuth.instance.authStateChanges().listen((user) {
      InformService.instance.dispose();
      if (user != null) {
        /// Re-init for listening the login user (when account changed)
        InformService.instance.init(callback: (data) async {
          if (data['type'] == 'requestLocation') {
            bool re = await service.confirm(
              'Share location',
              '${data['name']} wants to get your location. So, ${data['name']} can find you.\n\nDo you want to share your location?',
            );

            if (re) {
              final pos = await LocationService.instance.currentPosition;
              await ChatService.instance.send(
                text: '${UserService.instance.displayName} shared location.',
                protocol: ChatMessageModel.createProtocol(
                  'location',
                  "${pos.latitude},${pos.longitude}",
                ),
                otherUid: data['uid'],
              );
            }
          }
        });
      }
    });
  } // EO initState()

  onMessageOpenedShowMessage(message) {
    // Handle the message here
    // print(message);
    showDialog(
      context: globalNavigatorKey.currentContext!,
      builder: (c) => AlertDialog(
        title: Text(message.notification!.title ?? ''),
        content: Text(message.notification!.body ?? ''),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    PresenceService.instance.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: HomeScreen.routeName,
      onGenerateRoute: AppRouter.onGenerateRoute,
      navigatorObservers: [AppService.instance.router],
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  // print("---> Handling a background message: ${message.messageId}");
  if (message.data['type'] == 'chat' && message.data['badge'] != null) {
    FlutterAppBadger.updateBadgeCount(int.parse(message.data['badge']));
  }
}
