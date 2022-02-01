import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance {
    _instance ??= UserService();
    return _instance!;
  }

  UserService() {
    debugPrint('UserService::constructor');

    initAuthChanges();
  }

  UserModel user = UserModel();

  /// User auth changes
  ///
  /// Warning! When user sign-out and sign-in quickly, it is expected
  /// - the user sign-out, first
  /// - and then, sign-in as anonymously,
  /// - and lastly, the user will sign-in as his auth.
  ///
  /// But it is asynchronus call. So, this may happens,
  /// - the user sign-out
  /// - then the user sign-in as his auth,
  /// - then lastly, the user sign-in as anonymous.
  ///
  /// So? Don't race on sign-out and sign-in.
  ///
  initAuthChanges() {
    print('UserService::initAuthChanges');
    FirebaseAuth.instance.authStateChanges().listen(
      (_user) async {
        if (_user == null) {
          print('User signed-out');
          user = UserModel();
        } else {
          if (_user.isAnonymous) {
            print('User sign-in as Anonymous;');
            user = UserModel();
          } else {
            user = await UserService.instance.get();
            print("User signed-in as; $user");
          }
        }
      },
    );
  }

  DocumentReference get _myDoc =>
      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  /// Update user name of currently login user.
  Future<void> updateNickname(String name) {
    return _myDoc.set({'nickname': name}, SetOptions(merge: true));
  }

  /// Update photoUrl of currently login user.
  Future<void> updatePhotoUrl(String url) {
    return _myDoc.set({'photoUrl': url}, SetOptions(merge: true));
  }

  Future<UserModel> get() async {
    final doc = await _myDoc.get();
    final user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    user.id = doc.id;
    return user;
  }
}
