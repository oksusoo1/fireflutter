import 'package:extended/extended.dart';
import 'package:fe/screens/phone_sign_in/phone_sign_in.screen.dart';
import 'package:fe/service/app.service.dart';
import 'package:flutter/material.dart';

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
          Text('when; ' + (getArg(context, 'when') ?? 'no when')),
          Text('where; ' + (getArg(context, 'where') ?? 'no where')),
          Text('who; ' + (getArg(context, 'who') ?? 'no who')),
          Text('what; ' + (getArg(context, 'what') ?? 'no what')),
          ElevatedButton(
            onPressed: () => AppService.instance.open(PhoneSignInScreen.routeName),
            child: const Text('Phone Sign-In'),
          ),
        ],
      ),
    );
  }
}
