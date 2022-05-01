import 'package:fe/services/app.service.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class SignInWidget extends StatelessWidget {
  const SignInWidget({Key? key}) : super(key: key);

  static const String routeName = '/sign-in';

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      actions: [
        AuthStateChangeAction<SignedIn>((context, _) {
          AppService.instance.router.openHome();
        }),
        SignedOutAction((context) {
          AppService.instance.router.openHome();
        }),
      ],
      providerConfigs: const [
        EmailProviderConfiguration(),
        GoogleProviderConfiguration(clientId: 'com.withcenter.test'),
      ],
      footerBuilder: (context, _) {
        return TextButton(
          onPressed: () => AppService.instance.router.openHome(),
          child: const Text(
            'Back to home',
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}
