import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  static const String routeName = '/help';

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: Column(
        children: [
          Text('when; ' + (Get.arguments?['when'] ?? 'no when')),
          Text('where; ' + (Get.arguments?['where'] ?? 'no where')),
          Text('who; ' + (Get.arguments?['who'] ?? 'no who')),
          Text('what; ' + (Get.arguments?['what'] ?? 'no what')),
          ElevatedButton(
            onPressed: () => Get.toNamed('/phone-sign-in'),
            child: const Text('Phone Sign-In'),
          ),
        ],
      ),
    );
  }
}
