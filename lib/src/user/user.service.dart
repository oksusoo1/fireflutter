import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';

/// UserService
///
/// Refer readme.md for details.
class UserService with FirestoreMixin, DatabaseMixin {
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

  /// Returns currently signed in user's uid or empty string.
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get phoneNumber => currentUser?.phoneNumber ?? '';
  String get email => currentUser?.email ?? '';

  /// To display email on screen, use this.
  String get displayEmail => email == '' ? 'NO-EMAIL' : email;

  DatabaseReference get _myDoc => FirebaseDatabase.instance.ref('users').child(uid);

  StreamSubscription? authSubscription;
  StreamSubscription? userSubscription;

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
    authSubscription?.cancel();
    authSubscription = FirebaseAuth.instance.authStateChanges().listen(
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
            userSubscription?.cancel();
            final doc = userDoc(_user.uid);
            doc.onValue.listen((event) {
              // if user doc does not exists, create one.
              if (event.snapshot.exists == false) {
                create();
              } else {
                user = UserModel.fromJson(event.snapshot.value, _user.uid);
              }
            }, onError: (e) {
              print('UserDoc listening error; $e');
            });
          }
        }
      },
    );
  }

  signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> create() {
    return user.create();
  }

  /// Update login user's document on `/users/{userDoc}` in realtime database.
  ///
  /// ```dart
  /// return update(field: 'nickname', value: name);
  /// ```
  Future<void> update({required String field, required dynamic value}) {
    // return _myDoc.update({field: value});
    return user.update(field: field, value: value);
  }

  /// Update user name of currently login user.
  Future<void> updateNickname(String name) {
    // return update(field: 'nickname', value: name);
    return user.updateNickname(name);
  }

  /// Update photoUrl of currently login user.
  Future<void> updatePhotoUrl(String url) {
    return user.updatePhotoUrl(url);
  }

  @Deprecated('This is useless method.')
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
    user.updateAdminStatus();
    // final DocumentSnapshot doc = await adminsDoc.get();
    // if (doc.exists) {
    //   final data = doc.data()! as Map<String, dynamic>;
    //   if (data[user.uid] == true) {
    //     await update(field: 'isAdmin', value: true);
    //     user.isAdmin = true;
    //   } else {
    //     await update(field: 'isAdmin', value: null);
    //     user.isAdmin = false;
    //   }
    // }
  }
}
