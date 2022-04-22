import 'package:firebase_auth/firebase_auth.dart';
import '../../defines.dart';
import 'package:flutter/material.dart';

/// Firebase Auth State Widget
///
///
/// ```dart
///  AuthState(
///    signedIn: (user) => Text('logged in'),
///    signedOut: () => Text('logged out'),
///    loader: Text('loading...'),
///  ),
/// ```
@Deprecated('User Auth')
class AuthState extends StatelessWidget {
  const AuthState({
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
