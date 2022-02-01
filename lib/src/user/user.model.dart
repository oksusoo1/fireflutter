import 'package:fireflutter/fireflutter.dart';

class UserModel {
  UserModel({
    this.nickname = '',
    this.photoUrl = '',
    this.birthday = '',
    this.id = '',
  });

  String nickname;
  String photoUrl;
  String birthday;

  /// This is the user's document id.
  /// If it is empty, then it means that, the user does not exist.
  String id;

  bool get signedIn => id != '';
  bool get signedOut => id == '';

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      nickname: data['nickname'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      birthday: data['birthday'] ?? '',
      id: data['id'] ?? '',
    );
  }

  Map<String, dynamic> get data {
    return {
      'nickname': nickname,
      'photoUrl': photoUrl,
      'birthday': birthday,
    };
  }

  Map<String, dynamic> get map {
    final re = data;
    re['id'] = id;
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
