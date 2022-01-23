// import 'package:fe/screens/chat/chat.room.screen.dart';
// import 'dart:async';

import 'package:fe/screens/chat/chat.room.screen.dart';
import 'package:fe/screens/chat/chat.rooms.blocked.screen.dart';
import 'package:fe/screens/chat/chat.rooms.screen.dart';
import 'package:fe/screens/friend_map/friend_map.screen.dart';
import 'package:fe/screens/help/help.screen.dart';
import 'package:fe/screens/home/home.screen.dart';
import 'package:fe/screens/phone_sign_in/phone_sign_in.screen.dart';
import 'package:fe/screens/phone_sign_in/sms_code.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/phone_sign_in_ui.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/sms_code_ui.screen.dart';
import 'package:fe/screens/reminder/reminder.edit.screen.dart';
import 'package:fe/widgets/sign_in.widget.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    PresenceService.instance.activate(
      onError: (e) => debugPrint('--> Presence error: $e'),
    );

    // Timer(const Duration(milliseconds: 200), () => Get.toNamed('/sms-code-ui'));

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        /// Re-init for listening the login user (when account changed)
        InformService.instance.init(callback: (data) {
          if (data['type'] == 'FriendMap') {
            /// If it's a freind map request, then open friend map screen.
            Get.toNamed('/friend-map', arguments: {
              'latitude': data['latitude'],
              'longitude': data['longitude'],
            });
          }
        });
      } else {
        InformService.instance.dispose();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    PresenceService.instance.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(
          name: '/sign-in',
          page: () => const SignInWidget(),
        ),
        GetPage(name: '/phone-sign-in', page: () => const PhoneSignInScreen()),
        GetPage(name: '/sms-code', page: () => const SmsCodeScreen()),
        GetPage(name: '/phone-sign-in-ui', page: () => const PhoneSignInUIScreen()),
        GetPage(name: '/sms-code-ui', page: () => const SmsCodeUIScreen()),
        GetPage(name: '/help', page: () => const HelpScreen()),
        GetPage(name: '/chat-room-screen', page: () => const ChatRoomScreen()),
        GetPage(
          name: '/chat-rooms-screen',
          page: () => const ChatRoomsScreen(),
        ),
        GetPage(
          name: '/chat-rooms-blocked-screen',
          page: () => const ChatRoomsBlockedScreen(),
        ),
        GetPage(name: '/friend-map', page: () => const FriendMapScreen()),
        GetPage(name: '/reminder-edit', page: () => const ReminderEditScreen())
      ],
    );
  }
}
