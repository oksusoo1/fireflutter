import 'package:fe/screens/phone_sign_in/phone_sign_in.screen.dart';
import 'package:fe/service/app.service.dart';
import 'package:fe/widgets/layout.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({
    Key? key,
  }) : super(key: key);

  static const String routeName = '/about';
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      isHome: true,
      title: Text('About'),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => AppService.instance.router.open(PhoneSignInScreen.routeName),
            child: const Text('Phone Sign-In'),
          ),
        ],
      ),
    );
  }
}
