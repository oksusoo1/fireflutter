import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:get/get.dart';


class SignInWidget extends StatelessWidget {
  const SignInWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
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
        GoogleProviderConfiguration(clientId: 'com.withcenter.test'),
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
    );
  }
}
