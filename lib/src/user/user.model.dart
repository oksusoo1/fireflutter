class UserModel {
  UserModel({
    required this.name,
    required this.photoUrl,
  });

  String name;
  String photoUrl;

  factory UserModel.fromJson(dynamic data) {
    return UserModel(name: data['name'], photoUrl: data['photoUrl']);
  }
}
