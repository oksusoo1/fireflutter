import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

class UnitTestModel {
  static UnitTestModel? _instance;
  static UnitTestModel get instance {
    _instance ??= UnitTestModel();
    return _instance!;
  }

  List<String> logs = [];
  bool waiting = false;
  String waitingMessage = '';
  // ignore: close_sinks
  final render = PublishSubject();

  int success = 0;
  int error = 0;
}

/// See readme for details.
mixin UnitTestMixin {
  final model = UnitTestModel.instance;
  clearLogs() {
    model.success = 0;
    model.error = 0;
    model.logs = [];
  }

  final String a = 'test-user-a';
  final String b = 'test-user-b';
  final String c = 'test-user-c';
  final String d = 'test-user-d';
  late PostModel post;

  _render() {
    model.render.add(true);
    print('render added');
  }

  init() async {
    await _prepareTest();
  }

  /// Prepares the test. See README.md for details.
  ///
  /// 1. Check user accounts of apple, banana, cherry.
  /// 2. Check if QnA category exists.
  /// 3. Create a test post
  /// 4. Create a test comment
  _prepareTest() async {
    final categories = await CategoryService.instance.getCategories();
    final qnaExists = categories.indexWhere((element) => element.id == 'qna') != -1;
    expect(qnaExists, "QnA category must exists!");

    await signIn(b);
    post = await PostApi.instance.create(category: 'qna');
    expect(true, 'Test ready.');
  }

  expect(bool re, String msg) {
    String info;
    if (re) {
      info = 'SUCCESS: $msg';
      model.success++;
    } else {
      info = 'ERROR: $msg';
      model.error++;
    }
    log(info);
    model.logs.add(info);
    _render();
  }

  fail(String msg) => expect(false, '(fail) ' + msg);

  Future signIn(String id) async {
    String email = "$id@testemail.com";
    debugPrint('--> Signing in as; $email');

    User user;
    try {
      final cred =
          await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: '12345a');
      user = cred.user!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        final cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: '12345a');

        user = cred.user!;
      } else {
        rethrow;
      }
    }
    await Future.delayed(Duration(milliseconds: 500));

    debugPrint('--> Signed in as; ${user.uid}');
    await FirebaseDatabase.instance.ref('/users/${user.uid}').update({
      'email': email,
      'firstName': 'firstName',
      'middleName': 'middleName',
      'lastName': 'lastName',
      'photoUrl': '...',
      'gender': 'M',
      'birthday': 12341234,
    });
  }

  dynamic submit(Future future) async {
    try {
      return await future;
    } catch (e) {
      return e;
    }
  }

  Future signOut() async {
    await FirebaseAuth.instance.signOut();

    return wait(200, 'Sign-out');
  }

  Future wait(int ms, String msg) async {
    model.waiting = true;
    model.waitingMessage = msg;
    _render();
    await Future.delayed(Duration(milliseconds: ms));
    model.waiting = false;
    model.waitingMessage = '';
    _render();
  }
}
