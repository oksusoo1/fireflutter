import 'package:firebase_auth/firebase_auth.dart';

class EmailVerifyService {
  static EmailVerifyService? _instance;
  static EmailVerifyService get instance {
    _instance ??= EmailVerifyService();
    return _instance!;
  }

  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  bool get userHasEmail {
    if (FirebaseAuth.instance.currentUser!.email == null) return false;
    return FirebaseAuth.instance.currentUser!.email!.isNotEmpty;
  }

  String get userEmail => FirebaseAuth.instance.currentUser!.email ?? '';

  checkEmailVerified({
    required Function onVerified,
  }) async {
    await FirebaseAuth.instance.currentUser!.reload();

    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      onVerified();
    }
  }

  Future<void> updateUserEmail({
    required String email,
    required Function(Function) onReAuthenticate,
  }) async {
    try {
      await FirebaseAuth.instance.currentUser!.updateEmail(email);
    } catch (e) {
      if (e.toString().contains('requires-recent-login')) {
        onReAuthenticate(updateUserEmail);
      } else {
        throw e;
      }
    }
  }
}
