import 'package:example/services/global.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfire_ui/auth.dart';

class HomeAuth extends StatelessWidget {
  const HomeAuth({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Auth(
      signedIn: (user) => Container(
        padding: const EdgeInsets.all(36),
        child: Column(
          children: [
            Text('You have signed in as ${user.email}'),
            TextButton(
              onPressed: FirebaseAuth.instance.signOut,
              child: const Text(
                'Sign Out',
              ),
            )
          ],
        ),
      ),
      signedOut: () => SignInScreen(
        providerConfigs: const [
          EmailProviderConfiguration(),
        ],
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            service.router.openHome();
          }),
        ],
      ),
    );
  }
}
