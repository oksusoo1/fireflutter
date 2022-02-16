import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
    // debugPrint('UserSettingsService::constructor');

    initAuthChanges();
  }

  List<String> topicsDontNeedSubscription = ['newCommentUnderMyPostOrCOmment'];

  /// User auth changes
  ///
  /// When auth changes, listen to newly signed-in user's setting.
  ///
  initAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen(
      (_user) async {
        sub?.cancel();
        settings = UserSettingsModel.empty();
        if (_user == null) {
          ///
        } else {
          if (_user.isAnonymous) {
            /// Note, anonymous sigin-in is not supported by fireflutter.
          } else {
            // print('path; ${userSettingsDoc.path}');
            sub = userSettingsDoc.onValue.listen((event) {
              // if settings doc does not exists, just use default empty setting.
              if (event.snapshot.exists) {
                print('UserSettingsService; Got new data');
                settings = UserSettingsModel.fromJson(event.snapshot.value);
              } else {
                // create the document /user-settings/uid with timestamp to avoid error when saving data with doc/data
                create();
              }
              changes.add(settings);
            }, onError: (e) {
              print('====> UserSettingsDoc listening error; $e');
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

  Future<void> unsubscribeAllTopic() async {
    for (CategoryModel cat in CategoryService.instance.categories) {
      await FirebaseMessaging.instance.unsubscribeFromTopic('posts_${cat.id}');
      await FirebaseMessaging.instance
          .unsubscribeFromTopic('comments_${cat.id}');
    }
  }

  Future<void> subscribeToUserTopics() async {
    for (String topic in settings.topics.keys) {
      if (topicsDontNeedSubscription.contains(topic)) continue;
      if (settings.topics[topic] == true) {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
      }
    }
  }
}
