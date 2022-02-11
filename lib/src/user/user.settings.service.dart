import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../fireflutter.dart';

/// UserSettingsService
///
/// Refer readme.md for details.
class UserSettingsService with DatabaseMixin {
  static UserSettingsService? _instance;
  static UserSettingsService get instance {
    _instance ??= UserSettingsService();
    return _instance!;
  }

  UserSettingsModel settings = UserSettingsModel.empty();
  StreamSubscription? sub;

  /// This event will be posted whenever user settings document changes.
  // ignore: close_sinks
  BehaviorSubject<UserSettingsModel> changes = BehaviorSubject.seeded(
    UserSettingsModel.empty(),
  );

  UserSettingsService() {
    debugPrint('UserSettingsService::constructor');

    initAuthChanges();
  }

  /// User auth changes
  ///
  /// When auth changes, listen to newly signed-in user's setting.
  ///
  initAuthChanges() {
    print('UserSettingsService::initAuthChanges');
    FirebaseAuth.instance.authStateChanges().listen(
      (_user) async {
        if (_user == null) {
          ///
        } else {
          if (_user.isAnonymous) {
            /// Note, anonymous sigin-in is not supported by fireflutter.
          } else {
            sub?.cancel();
            sub = userSettingsDoc.onValue.listen((event) {
              // if settings doc does not exists, just use default empty setting.
              if (event.snapshot.exists) {
                print('UserSettingsService; Got new data');
                settings = UserSettingsModel.fromJson(event.snapshot.value);
              } else {
                // create the document /user-settings/uid with timestamp to avoid error when saving data with doc/data
                create();
                settings = UserSettingsModel.empty();
              }
              changes.add(settings);
            }, onError: (e) {
              print('UserSettingsDoc listening error; $e');
            });
          }
        }
      },
    );
  }

  Future<void> update(Json settings) async {
    final snapshot = await userSettingsDoc.get();
    if (snapshot.exists) {
      return userSettingsDoc.update(settings);
    } else {
      return userSettingsDoc.set(settings);
    }
  }

  Future<Json> read() async {
    final snapshot = await userSettingsDoc.get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as dynamic);
    } else {
      return {} as Json;
    }
  }

  /// Returns true if the user has subscribed the topic.
  /// If user subscribed the topic, that topic name will be saved into user meta in backend
  /// And when user profile is loaded, the subscriptions are saved into [subscriptions]
  bool hasSubscription(String topic) {
    return settings.topics[topic] ?? false;
  }

  Future<void> subscribe(String topic) {
    return update({'topic/$topic': true});
  }

  Future<void> unsubscribe(String topic) {
    return update({'topic/$topic': false});
  }

  Future<void> create() {
    return settings.create();
  }
}
