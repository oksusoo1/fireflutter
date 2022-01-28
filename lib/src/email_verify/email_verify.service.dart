import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class EmailVerifyService {
  static EmailVerifyService? _instance;
  static EmailVerifyService get instance {
    _instance ??= EmailVerifyService();
    return _instance!;
  }

  Timer? _timer;

  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  bool get userEmailVerifield => FirebaseAuth.instance.currentUser!.emailVerified;

  bool get userHasEmail {
    if (FirebaseAuth.instance.currentUser!.email == null) return false;
    return FirebaseAuth.instance.currentUser!.email!.isNotEmpty;
  }

  String get userEmail => FirebaseAuth.instance.currentUser!.email ?? '';

  Future updateUserEmail(String email) async {
    await firebaseAuth.currentUser!.updateEmail(email);
  }

  Future sendEmailVerification() async {
    await firebaseAuth.currentUser!.sendEmailVerification();
    _startVerificationChecker();
  }

  Future<bool> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    if (userEmailVerifield) {
      _timer?.cancel();
      return true;
    }
    return false;
  }

  _startVerificationChecker() {
    if (_timer != null) return;
    _timer = Timer.periodic(Duration(seconds: 3), (timer) => checkEmailVerified());
  }
}
