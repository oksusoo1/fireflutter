import 'dart:developer';

import 'package:fe/service/config.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UnitTestService {
  static UnitTestService? _instance;
  static UnitTestService get instance {
    _instance ??= UnitTestService();
    return _instance!;
  }

  late UserModel a;
  late UserModel b;
  late UserModel c;
  late UserModel d;

  Function(dynamic)? onError;

  UnitTestService() {
    () async {
      a = UserModel(uid: Config.testUsers['apple']!['uid']!);
      await a.load();
      b = UserModel(uid: Config.testUsers['banana']!['uid']!);
      await b.load();
      c = UserModel(uid: Config.testUsers['cherry']!['uid']!);
      await c.load();
    }();
  }

  List<String> logs = [];

  expect(bool re, String msg) {
    String info;
    if (re) {
      info = 'SUCCESS: $msg';
    } else {
      info = 'ERROR: $msg';
    }
    log(info);
    logs.add(info);
  }

  Future signIn(UserModel u) async {
    final e = Config.testUsers.entries.firstWhere((element) => element.value['uid'] == u.uid);
    final email = Config.testUsers[e.key]!['email']!;
    print('signIn as; $email');

    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: '12345a');
    await Future.delayed(Duration(milliseconds: 500));
  }
}
