import 'package:example/screens/chat/chat.room.screen.dart';
import 'package:example/screens/home/home.screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutterfire_ui/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
          page: () => SignInScreen(
            actions: [
              AuthStateChangeAction<SignedIn>((context, _) {
                Get.offAllNamed('/home');
              }),
              SignedOutAction((context) {
                Get.offAllNamed('/home');
              }),
            ],
            providerConfigs: const [
              EmailProviderConfiguration(),
            ],
            footerBuilder: (context, _) {
              return TextButton(
                onPressed: () => Get.offAllNamed('/home'),
                child: const Text(
                  'Back to home',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          ),
        ),
        GetPage(name: '/chat-room-screen', page: () => const ChatRoomScreen())
      ],
    );
  }
}
