class UserModel {
  UserModel({
    required this.name,
    required this.photoUrl,
    this.none = false,
  });

  String name;
  String photoUrl;

  /// [none] becomes true if the document does not exists.
  bool none;

  factory UserModel.fromJson(dynamic data) {
    return UserModel(name: data['name'], photoUrl: data['photoUrl']);
  }

  factory UserModel.none() {
    return UserModel(name: '', photoUrl: '', none: true);
  }
}
