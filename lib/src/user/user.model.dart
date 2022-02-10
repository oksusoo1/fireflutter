import 'package:firebase_auth/firebase_auth.dart';
import '../../fireflutter.dart';

/// UserModel
///
///
class UserModel {
  UserModel({
    this.uid = '',
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.nickname = '',
    this.photoUrl = '',
    this.birthday = '',
    this.gender = '',
    this.isAdmin = false,
    this.topics = const [],
  });

  /// This is the user's document id which is the uid.
  /// If it is empty, the user may not be signed-in
  String uid;

  /// If id is empty string, then the model has no user info or the doc of the model does not exists.
  bool get exists => uid != '';
  bool isAdmin;

  String firstName;
  String middleName;
  String lastName;
  String nickname;

  /// Use display name to display user name.
  String get displayName {
    if (nickname != '') return nickname;
    if (firstName != '') return firstName;
    if (FirebaseAuth.instance.currentUser?.displayName != null)
      return FirebaseAuth.instance.currentUser!.displayName!;
    return 'NO-NAME';
  }

  String photoUrl;
  String birthday;
  String gender;

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
      firstName: data['firstName'] ?? '',
      middleName: data['middleName'] ?? '',
      lastName: data['lastName'] ?? '',
      nickname: data['nickname'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      birthday: data['birthday'] ?? '',
      gender: data['gender'] ?? '',
      topics: data['topics'] ?? [],
    );
  }

  /// Data for updating firestore user document
  Map<String, dynamic> get data {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'nickname': nickname,
      'photoUrl': photoUrl,
      'birthday': birthday,
      'gender': gender,
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
