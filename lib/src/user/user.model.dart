class UserModel {
  UserModel({
    required this.name,
    required this.photoUrl,
    this.exists = true,
  });

  String name;
  String photoUrl;

  /// [none] becomes true if the document does not exists.
  bool exists;

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  factory UserModel.nonExist() {
    return UserModel(name: 'Not exists', photoUrl: '', exists: false);
  }
}
