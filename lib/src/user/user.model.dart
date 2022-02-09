import 'package:firebase_auth/firebase_auth.dart';
import '../../fireflutter.dart';

/// UserModel
///
///
class UserModel {
  UserModel({
    this.uid = '',
    this.nickname = '',
    this.photoUrl = '',
    this.birthday = '',
    this.isAdmin = false,
    this.topics = const [],
  });

  /// This is the user's document id which is the uid.
  /// If it is empty, the user may not be signed-in
  String uid;

  /// If id is empty string, then the model has no user info or the doc of the model does not exists.
  bool get exists => uid != '';
  bool isAdmin;

  String nickname;
  String photoUrl;
  String birthday;

  List<String> topics;

  bool get signedIn => FirebaseAuth.instance.currentUser != null;
  bool get signedOut => signedIn == false;

  /// Returns true if the user has subscribed the topic.
  /// If user subscribed the topic, that topic name will be saved into user meta in backend
  /// And when user profile is loaded, the subscriptions are saved into [subscriptions]
  bool hasSubscription(String topic) {
    return topics.contains(topic);
  }

  factory UserModel.fromJson(dynamic data, String uid) {
    if (data == null) return UserModel();
    return UserModel(
      uid: uid,
      isAdmin: data['isAdmin'] ?? false,
      nickname: data['nickname'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      birthday: data['birthday'] ?? '',
      topics: data['topics'] ?? [],
    );
  }

  /// Data for updating firestore user document
  Map<String, dynamic> get data {
    return {
      'nickname': nickname,
      'photoUrl': photoUrl,
      'birthday': birthday,
    };
  }

  /// Data of all user model
  Map<String, dynamic> get map {
    final re = data;
    re['uid'] = uid;
    re['isAdmin'] = isAdmin;
    return re;
  }

  @override
  String toString() {
    return '''UserModel($map)''';
  }

  /// Update nickname
  ///
  /// Update nickname and update its member variable.
  /// Throws exception on error.
  Future<void> updateNickname(String t) {
    return UserService.instance.updateNickname(t).then((value) => nickname = t);
  }

  Future<void> updatePhotoUrl(String t) {
    return UserService.instance.updatePhotoUrl(t).then((value) => photoUrl = t);
  }
}
