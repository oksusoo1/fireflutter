import 'dart:developer';

import 'package:fe/service/config.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UnitTestService {
  static List<String> logTexts = [];

  static expect(bool re, String msg) {
    String info;
    if (re) {
      info = 'SUCCESS: $msg';
    } else {
      info = 'ERROR: $msg';
    }
    log(info);
    logTexts.add(info);
  }

  static Future signIn(UserModel u) async {
    final e = Config.testUsers.entries.firstWhere((element) => element.value['uid'] == u.uid);
    final email = Config.testUsers[e.key]!['email']!;
    print('signIn as; $email');

    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: '12345a');
    await Future.delayed(Duration(milliseconds: 500));
  }

  static dynamic getOutcome(Future callback()) async {
    try {
      dynamic res = await callback();
      return res;
    } catch (e) {
      return e;
    }
  }
}
