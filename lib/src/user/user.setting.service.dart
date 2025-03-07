import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

import '../../fireflutter.dart';

/// UserSettingService
///
/// Refer readme.md for details.
class UserSettingService with DatabaseMixin {
  static UserSettingService? _instance;
  static UserSettingService get instance {
    _instance ??= UserSettingService();
    return _instance!;
  }

  UserSettingsModel _settings = UserSettingsModel.empty();
  StreamSubscription? sub;

  /// This event will be posted whenever user settings document changes.
  // ignore: close_sinks
  BehaviorSubject<UserSettingsModel> changes = BehaviorSubject.seeded(
    UserSettingsModel.empty(),
  );

  UserSettingService() {
    // print('UserSettingService::constructor');

    initAuthChanges();
  }

  List<String> topicsDontNeedSubscription = ['newCommentUnderMyPostOrComment'];

  /// User auth changes
  ///
  /// When auth changes, listen to newly signed-in user's setting.
  ///
  initAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen(
      (_user) async {
        sub?.cancel();
        _settings = UserSettingsModel.empty();
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
                // print('UserSettingService; Got new data');
                _settings = UserSettingsModel.fromJson(event.snapshot.value);
              } else {
                // create the document /user-settings/uid with timestamp to avoid error when saving data with doc/data
                create();
              }
              changes.add(_settings);
            }, onError: (e) {
              // print('====> UserSettingsDoc listening error; $e');
            });
          }
        }
      },
    );
  }

  /// Returns the value of the key
  value(String key) {
    return _settings.data[key];
  }

  /// Update user setting.
  Future<void> update(Json settings) async {
    return _settings.update(settings);
  }

  /// Get user settings doc from realtime database, instread of using [_settings].
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
  bool hasSubscription(String topic, String type) {
    return _settings.data['topic']?[type]?[topic] ?? false;
  }

  bool hasDisabledSubscription(String topic, String type) {
    if (_settings.data['topic'] == null) return false;
    if (_settings.data['topic'][type] == null) return false;
    if (_settings.data['topic'][type][topic] == null) return false;
    if (_settings.data['topic'][type][topic] == false) return true;
    return false;
  }

  /// Updates the subscriptions (subscribe or unsubscribe) of the current user.
  Future<dynamic> updateSubscription(String topic, String type, bool subscribe) async {
    if (subscribe) {
      await UserSettingService.instance.subscribe(topic, type);
    } else {
      await UserSettingService.instance.unsubscribe(topic, type);
    }
  }

  /// Toggle the subscription (subscribe or unsubscribe) of the current user.
  toggleSubscription(String topic, String type) {
    return updateSubscription(
      topic,
      type,
      !UserSettingService.instance.hasSubscription(topic, type),
    );
  }

  Future<void> subscribe(String topic, String type) {
    return FunctionsApi.instance
        .request('subscribeTopic', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  Future<void> unsubscribe(String topic, String type) {
    return FunctionsApi.instance
        .request('unsubscribeTopic', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  Future<void> topicOn(String topic, String type) {
    return FunctionsApi.instance
        .request('topicOn', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  Future<void> topicOff(String topic, String type) {
    return FunctionsApi.instance
        .request('topicOff', data: {'topic': topic, 'type': type}, addAuth: true);
  }

  Future<dynamic> toggleTopic(String topic, String type, bool toggle) async {
    if (toggle) {
      await this.topicOn(topic, type);
    } else {
      await this.topicOff(topic, type);
    }
  }

  Future<void> create() {
    return _settings.create();
  }

  Future<List> unsubscribeAllTopic() async {
    List<CategoryModel> categories =
        await CategoryService.instance.loadCategories(categoryGroup: 'community');

    List<Future> futures = [];
    for (CategoryModel cat in categories) {
      futures.add(FirebaseMessaging.instance.unsubscribeFromTopic('posts_${cat.id}'));
      futures.add(FirebaseMessaging.instance.unsubscribeFromTopic('comments_${cat.id}'));
    }
    return Future.wait(futures);
  }

  Future<List> subscribeToUserTopics() async {
    List<Future> futures = [];
    for (String topic in _settings.topics.keys) {
      if (topicsDontNeedSubscription.contains(topic)) continue;
      if (_settings.topics[topic] == true) {
        // print('topic; $topic');
        futures.add(FirebaseMessaging.instance.subscribeToTopic(topic));
      }
    }
    return Future.wait(futures);
  }

  /// Functions

  Future<dynamic> enableAllNotification({String? group, String? type}) async {
    return FunctionsApi.instance
        .request('enableAllNotification', data: {'group': group, 'type': type}, addAuth: true);
  }

  Future<dynamic> disableAllNotification({String? group, String? type}) async {
    return FunctionsApi.instance
        .request('disableAllNotification', data: {'group': group, 'type': type}, addAuth: true);
  }

  // subscribeTopic(String topic, String type) async {
  // }

  // unsubscribeTopic(String topic, String type) async {
  // }

  // toggleTopic(String topic, String type) async {
  //   return FunctionsApi.instance
  //       .request('toggleTopic', data: {topic: topic, type: type}, addAuth: true);
  // }
}
