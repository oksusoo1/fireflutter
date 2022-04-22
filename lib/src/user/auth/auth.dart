import 'package:firebase_auth/firebase_auth.dart';
import '../../defines.dart';
import 'package:flutter/material.dart';

/// Firebase Auth State Widget
///
///
/// ```dart
///  Auth(
///    signedIn: (user) => Text('logged in'),
///    signedOut: () => Text('logged out'),
///    loader: Text('loading...'),
///  ),
/// ```
class Auth extends StatelessWidget {
  const Auth({
    this.signedIn,
    this.signedOut,
    this.loader = const CircularProgressIndicator.adaptive(),
    Key? key,
  }) : super(key: key);

  final BuilderWidgetUserFunction? signedIn;
  final BuilderWidgetFunction? signedOut;
  final Widget loader;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      // If the user is already signed-in, use it as initial data
      initialData: FirebaseAuth.instance.currentUser,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return this.loader;
        } else if (snapshot.hasData) {
          if (this.signedIn == null) {
            return SizedBox.shrink();
          } else {
            return this.signedIn!(snapshot.data!);
          }
        } else {
          if (this.signedOut == null) {
            return SizedBox.shrink();
          } else {
            return this.signedOut!();
          }
        }
      },
    );
  }
}
