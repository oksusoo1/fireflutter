import 'package:fe/screens/phone_sign_in/phone_sign_in.screen.dart';
import 'package:fe/services/app.service.dart';
import 'package:fe/services/global.dart';
import 'package:fe/widgets/layout/layout.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    Key? key,
  }) : super(key: key);

  static const String routeName = '/menu';
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      title: Text('Menu'),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => AppService.instance.router.open(PhoneSignInScreen.routeName),
            child: const Text('Phone Sign-In'),
          ),
          ElevatedButton(
            onPressed: service.router.openTest,
            child: const Text('Test Screen'),
          ),
        ],
      ),
    );
  }
}
