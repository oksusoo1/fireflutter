import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/subjects.dart';
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
    initAuthChanges();
  }

  UserModel user = UserModel();
  User? get currentUser => FirebaseAuth.instance.currentUser;

  String get displayName => user.displayName;

  /// Returns currently signed in user's uid or empty string.
  String get uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get phoneNumber => currentUser?.phoneNumber ?? '';

  String get email => user.email;

  // No more email verification by Apr 13, 2022.
  // String get email => currentUser?.email ?? '';
  // bool get emailIsVerified => currentUser?.emailVerified ?? false;

  /// To display email on screen, use this.
  String get displayEmail => email == '' ? 'No email' : email;

  String get photoUrl => user.photoUrl;

  // DatabaseReference get _myDoc => FirebaseDatabase.instance.ref('users').child(uid);

  StreamSubscription? userSubscription;
  StreamSubscription? messagingPermissionSubscription;

  /// This event will be posted whenever user document changes.
  // ignore: close_sinks
  BehaviorSubject<UserModel> changes = BehaviorSubject.seeded(UserModel());

  /// Nothing but to instantiate `UserSerivce` object. So it will listen auth changes and update user profile.
  init() {}

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
          // debugPrint('User signed-out');
          changes.add(user);
        } else {
          user = UserModel(uid: uid);
          if (_user.isAnonymous) {
            /// Note, anonymous sigin-in is not supported by fireflutter.
            // debugPrint(  'User sign-in as Anonymous; Warning! Fireflutter does not user anonymous account.');
            changes.add(user);
          } else {
            messagingPermissionSubscription?.cancel();
            messagingPermissionSubscription =
                MessagingService.instance.permissionGranted.listen((x) {
              if (x) {
                MessagingService.instance.initializeSubscriptions();
              }
            });

            final doc = userDoc(_user.uid);

            /// Put user uid first, and use the model.
            user = UserModel(uid: uid);

            await user.load();

            /// Update last sign in stamp
            if (user.docExists) {
              user.updateLastSignInAt();
            } else {
              user.create();
            }

            userSubscription = doc.onValue.listen((event) {
              /// ! Warning, Don't change user doc inside here. It will perpetually run.

              /// if user doc does not exists, create one.
              if (event.snapshot.exists) {
                /// User profile information has been updated.
                user = UserModel.fromJson(event.snapshot.value, _user.uid);
                changes.add(user);

                /// This must be here. So, whenever user updates his profile, it will update also.
                user.updateProfileReady();
              }
            }, onError: (e) {
              // print('UserDoc listening error; $e');
            });
          }
        }
      },
    );
  }

  signOut() async {
    FirebaseAuth.instance.signOut();
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

  /// Update wether if the user is an admin or not.
  /// Refer readme for details
  Future<void> updateAdminStatus() async {
    user.updateAdminStatus();
  }

  bool isOtherUserDisabled(String uid) {
    if (others[uid] == null) return false;
    return others[uid]!.disabled;
  }

  bool isOtherUserNotDisabled(String uid) {
    return !isOtherUserDisabled(uid);
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

  Future<dynamic> blockUser(String uid) async {
    UserModel user = await getOtherUserDoc(uid);
    if (user.disabled) throw ERROR_USER_ALREADY_BLOCKED;
    HttpsCallable onCallDisableUser =
        FirebaseFunctions.instanceFor(region: 'asia-northeast3')
            .httpsCallable('disableUser');
    try {
      final res = await onCallDisableUser.call({'uid': uid});
      UserModel u = UserModel.fromJson(res.data, uid);
      if (u.disabled) UserService.instance.others[uid] = u;
      return u;
    } catch (e) {
      // print(e);
      rethrow;
    }
  }

  Future<dynamic> unblockUser(String uid) async {
    UserModel user = await getOtherUserDoc(uid);
    if (!user.disabled) throw ERROR_USER_ALREADY_UNBLOCKED;
    HttpsCallable onCallDisableUser =
        FirebaseFunctions.instanceFor(region: 'asia-northeast3')
            .httpsCallable('enableUser');
    try {
      final res = await onCallDisableUser.call({'uid': uid});
      UserModel u = UserModel.fromJson(res.data, uid);
      if (u.disabled == false) UserService.instance.others[uid] = u;
      return u;
    } catch (e) {
      // print(e);
      rethrow;
    }
  }
}
