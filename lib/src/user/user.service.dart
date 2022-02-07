import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';

class UserService with FirestoreMixin {
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
  User? currentUser = FirebaseAuth.instance.currentUser;

  /// Returns currently signed in user's uid or null.
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  DatabaseReference get _myDoc => FirebaseDatabase.instance.ref('users').child(uid!);

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
            /// Note, anonymous sigin-in is not supported by fireflutter.
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

  /// Update user name of currently login user.
  Future<void> updateNickname(String name) {
    return update(field: 'nickname', value: name);
  }

  /// Update photoUrl of currently login user.
  Future<void> updatePhotoUrl(String url) {
    return update(field: 'photoUrl', value: url);
  }

  /// Update login user's document
  ///
  /// ```dart
  /// return update(field: 'nickname', value: name);
  /// ```
  Future<void> update({required String field, required dynamic value}) {
    return _myDoc.update({field: value});
  }

  Future<UserModel> get() async {
    final doc = await _myDoc.get();
    if (doc.exists) {
      final user = UserModel.fromJson(doc.value, doc.key!);
      return user;
    } else {
      return UserModel(uid: currentUser?.uid ?? '');
    }
  }

  /// Update wether if the user is an admin or not.
  /// Refer readme for details
  Future<void> updateAdminStatus() async {
    final DocumentSnapshot doc = await adminsDoc.get();
    if (doc.exists) {
      final data = doc.data()! as Map<String, dynamic>;
      if (data[user.uid] == true) {
        await update(field: 'isAdmin', value: true);
        user.isAdmin = true;
      } else {
        await update(field: 'isAdmin', value: FieldValue.delete());
        user.isAdmin = false;
      }
    }
  }
}
