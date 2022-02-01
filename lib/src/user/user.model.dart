class UserModel {
  UserModel({
    this.nickname = '',
    this.photoUrl = '',
    this.birthday = '',
    this.exists = true,
  });

  String nickname;
  String photoUrl;
  String birthday;

  /// [none] becomes true if the document does not exists.
  bool exists;

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      nickname: data['nickname'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      birthday: data['birthday'] ?? 'birthday',
    );
  }

  factory UserModel.nonExist() {
    return UserModel(nickname: 'Not exists', exists: false);
  }

  Map<String, dynamic> get data {
    return {
      'nickname': nickname,
      'photoUrl': photoUrl,
      'birthday': birthday,
    };
  }
}
