import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';

/// UserModel
///
///
class UserModel {
  UserModel({
    this.id = '',
    this.nickname = '',
    this.photoUrl = '',
    this.birthday = '',
    this.isAdmin = false,
  });

  /// This is the user's document id which is the uid.
  /// If it is empty, the user may not be signed-in
  String id;
  String get uid => id;

  bool isAdmin;

  String nickname;
  String photoUrl;
  String birthday;

  bool get signedIn => FirebaseAuth.instance.currentUser != null;
  bool get signedOut => signedIn == false;

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      nickname: data['nickname'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      birthday: data['birthday'] ?? '',
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
    re['id'] = id;
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
