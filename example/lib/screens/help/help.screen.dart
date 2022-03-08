import 'package:fe/screens/phone_sign_in/phone_sign_in.screen.dart';
import 'package:fe/service/app.service.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({
    required this.arguments,
    Key? key,
  }) : super(key: key);

  static const String routeName = '/help';
  final Map arguments;

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
          Text('when; ' + widget.arguments['when']),
          Text('where; ' + widget.arguments['where']),
          Text('who; ' + widget.arguments['who']),
          Text('what; ' + widget.arguments['what']),
          ElevatedButton(
            onPressed: () =>
                AppService.instance.open(PhoneSignInScreen.routeName),
            child: const Text('Phone Sign-In'),
          ),
        ],
      ),
    );
  }
}
