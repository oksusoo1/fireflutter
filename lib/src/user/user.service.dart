import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
    // debugPrint('UserService::constructor');

    initAuthChanges();
  }

  UserModel user = UserModel();
  User? get currentUser => FirebaseAuth.instance.currentUser;

  String get displayName => user.displayName;

  /// Returns currently signed in user's uid or empty string.
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get phoneNumber => currentUser?.phoneNumber ?? '';
  String get email => currentUser?.email ?? '';
  bool get emailIsVerified => currentUser?.emailVerified ?? false;

  /// To display email on screen, use this.
  String get displayEmail => email == '' ? 'NO-EMAIL' : email;

  String get photoUrl => user.photoUrl;

  // DatabaseReference get _myDoc => FirebaseDatabase.instance.ref('users').child(uid);

  StreamSubscription? userSubscription;

  /// This event will be posted whenever user document changes.
  // ignore: close_sinks
  BehaviorSubject<UserModel> changes = BehaviorSubject.seeded(UserModel());

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
    FirebaseAuth.instance.authStateChanges().listen(
      (_user) async {
        userSubscription?.cancel();
        if (_user == null) {
          user = UserModel();
          debugPrint('User signed-out');
          changes.add(user);
          onSignedOut();
        } else {
          user = UserModel(uid: uid);
          if (_user.isAnonymous) {
            /// Note, anonymous sigin-in is not supported by fireflutter.
            debugPrint(
                'User sign-in as Anonymous; Warning! Fireflutter does not user anonymous account.');
            changes.add(user);
          } else {
            resetTopicSubscription();
            final doc = userDoc(_user.uid);

            /// Put user uid first, and use the model.
            user = UserModel(uid: uid);

            /// Update last sign in stamp
            user.updateLastSignInAt();

            await user.load();

            // /// Update profile ready or not?
            // if (profileReady) {
            //   if (user.profileReady == false) {
            //     user.update(field: 'profileReady', value: true);
            //   }
            // } else {
            //   if (user.profileReady) {
            //     user.update(field: 'profileReady', value: false);
            //   }
            // }

            userSubscription = doc.onValue.listen((event) {
              /// ! Warning, Don't change user doc inside here. It will perpetually run.

              /// if user doc does not exists, create one.
              if (event.snapshot.exists == false) {
                create();
              } else {
                /// User profile information has been updated.
                user = UserModel.fromJson(event.snapshot.value, _user.uid);
                changes.add(user);

                /// This must be here. So, whenever user updates his profile, it will update also.
                user.updateProfileReady();
              }
            }, onError: (e) {
              print('UserDoc listening error; $e');
            });
          }
        }
      },
    );
  }

  /// Subscribe topics for newly sign-in user.
  ///
  /// This method will run the code only one time even if the user signed-in multiple times.
  ///
  /// when a user Sign-in, the app need to unsubscribe previous subscription
  /// then app needs to subscribe the sign-in user topics.
  /// `isUserLoggedIn` is set true when the user signed-in.
  /// this can be use to check if the user is already loggedIn even the app was closed and reopen.
  /// so it will not reset every time the app is relaunch.
  ///
  resetTopicSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isUserLoggedIn') != null) return;
    prefs.setBool('isUserLoggedIn', true);
    await UserSettingService.instance.unsubscribeAllTopic();
    await UserSettingService.instance.subscribeToUserTopics();
    await MessagingService.instance.updateSaveToken();
  }

  /// when user state change to null this will called and remove the isUserLoggedIn from the SharedPreferences instance.
  /// remove `isUserLoggedIn` on logout. this is use to check if user has sign-in in the device.
  ///
  onSignedOut() async {
    await SharedPreferences.getInstance()
      ..remove('isUserLoggedIn');
  }

  signOut() async {
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

  // @Deprecated('This is useless method.')
  // Future<UserModel> get() async {
  //   final doc = await _myDoc.get();
  //   if (doc.exists) {
  //     final user = UserModel.fromJson(doc.value, doc.key!);
  //     return user;
  //   } else {
  //     return UserModel(uid: currentUser?.uid ?? '');
  //   }
  // }

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

  /// It gets other user's document.
  ///
  /// It return cached data if the user doc is previous fetch. So, it can be
  /// used multiple times without refetching from realtime database.
  ///
  /// Use this method to get other user's doc.
  ///
  /// See readme for details.
  Map<String, UserModel> others = {};
  Future<UserModel> getOtherUserDoc(String uid) async {
    if (uid == '') return UserModel();
    if (others[uid] != null) {
      // print('--> reuse uid; $uid');
      return others[uid]!;
    }

    UserModel other = UserModel();

    final event = await userDoc(uid).get();

    if (event.exists) {
      other = UserModel.fromJson(event.value, event.key!);
    }

    others[uid] = other;
    return others[uid]!;
  }

  // String get profileError {
  //   if (photoUrl == '') return ERROR_NO_PROFILE_PHOTO;
  //   if (email == '') return ERROR_NO_EMAIL;
  //   if (user.firstName == '') return ERROR_NO_FIRST_NAME;
  //   if (user.lastName == '') return ERROR_NO_LAST_NAME;
  //   if (user.gender == '') return ERROR_NO_GENER;
  //   if (user.birthday == 0) return ERROR_NO_BIRTHDAY;
  //   return '';
  // }

  // bool get profileReady {
  //   if (profileError == '')
  //     return true;
  //   else
  //     return false;
  // }

  Future<dynamic> blockUser(String uid) async {
    UserModel user = await getOtherUserDoc(uid);
    if (user.disabled) return ERROR_USER_ALREADY_BLOCKED;
    HttpsCallable onCallDisableUser =
        FirebaseFunctions.instanceFor(region: 'asia-northeast3').httpsCallable('disableUser');
    try {
      final res = await onCallDisableUser.call({'uid': uid});
      print(res);
      UserModel newUser = UserModel.fromJson(res, uid); // error test
      // update other user profile
      print(newUser);
      return newUser;
    } catch (e) {
      print(e);
    }
  }
}
