// import 'package:fe/screens/chat/chat.room.screen.dart';
import 'package:fe/screens/home/home.screen.dart';
import 'package:fe/screens/phone_sign_in/phone_sign_in.screen.dart';
import 'package:fe/screens/phone_sign_in/sms_code.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/phone_sign_in_ui.screen.dart';
import 'package:fe/screens/phone_sign_in_ui/sms_code_ui.screen.dart';
import 'package:fe/widgets/sign_in.widget.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
    Presence.instance.activate(
      onError: (e) => print('--> Presence error: $e'),
    );
  }

  @override
  void dispose() {
    super.dispose();
    Presence.instance.deactivate();
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
      ],
    );
  }
}
