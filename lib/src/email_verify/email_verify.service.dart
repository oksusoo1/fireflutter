import 'package:firebase_auth/firebase_auth.dart';

class EmailVerifyService {
  static EmailVerifyService? _instance;
  static EmailVerifyService get instance {
    _instance ??= EmailVerifyService();
    return _instance!;
  }

  bool get isVerified {
    if (FirebaseAuth.instance.currentUser == null) {
      return false;
    } else {
      return FirebaseAuth.instance.currentUser!.emailVerified;
    }
  }

  Future sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
  }
}
