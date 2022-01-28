import 'package:firebase_auth/firebase_auth.dart';

class EmailVerifyService {
  static EmailVerifyService? _instance;
  static EmailVerifyService get instance {
    _instance ??= EmailVerifyService();
    return _instance!;
  }

  bool get userHasEmail {
    return email != '';
  }

  String get email => FirebaseAuth.instance.currentUser?.email ?? '';

////
  checkEmailVerified({
    required Function onVerified,
  }) async {
    await FirebaseAuth.instance.currentUser!.reload();

    if (FirebaseAuth.instance.currentUser!.emailVerified) {
      onVerified();
    }
  }
}
