import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../fireflutter.dart';

/// UserModel
///
///
class UserModel with FirestoreMixin, DatabaseMixin {
  UserModel({
    this.uid = '',
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.nickname = '',
    this.photoUrl = '',
    this.birthday = 0,
    this.gender = '',
    this.isAdmin = false,
  });

  final fields = [
    'firstName',
    'middleName',
    'lastName',
    'nickname',
    'photoUrl',
    'birthday',
    'gender',
    'isAdmin',
  ];

  UserSettingsService settings = UserSettingsService.instance;

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
  /// Don't confuse the displayName of FirebaseAuth.
  String get displayName {
    if (nickname != '') return nickname;
    if (firstName != '') return firstName;
    if (FirebaseAuth.instance.currentUser?.displayName != null)
      return FirebaseAuth.instance.currentUser!.displayName!;
    return 'NO-NAME';
  }

  String photoUrl;
  int birthday;
  String gender;

  bool get signedIn => FirebaseAuth.instance.currentUser != null;
  bool get signedOut => signedIn == false;

  ///
  DatabaseReference get _myDoc => FirebaseDatabase.instance.ref('users').child(uid);

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
      birthday: data['birthday'] ?? 0,
      gender: data['gender'] ?? '',
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

  ///
  Future<void> create() {
    return _myDoc.set({'timestamp_registered': ServerValue.timestamp});
  }

  /// Update login user's document on `/users/{userDoc}` in realtime database.
  ///
  /// ```dart
  /// return update(field: 'nickname', value: name);
  /// ```
  Future<void> update({required String field, required dynamic value}) {
    if (fields.indexOf(field) == -1) {
      throw ERROR_NOT_SUPPORTED_FIELD_ON_USER_UPDATE;
    }
    return _myDoc.update({field: value});
  }

  /// Update nickname
  ///
  /// Update nickname and update its member variable.
  /// Throws exception on error.
  ///
  /// When user doc is updated, the model data will automatically updated by
  /// auth state change listening in UserService.
  Future<void> updateNickname(String name) {
    return update(field: 'nickname', value: name);
  }

  /// When user doc is updated, the model data will automatically updated by
  /// auth state change listening in UserService.
  Future<void> updatePhotoUrl(String url) {
    return update(field: 'photoUrl', value: url);
  }

  Future<void> updateGender(String gender) {
    assert(gender == 'M' || gender == 'F');
    return update(field: 'gender', value: gender);
  }

  Future<void> updateBirthday(int birthday) {
    return update(field: 'birthday', value: birthday);
  }

  /// Update wether if the user is an admin or not.
  /// Refer readme for details
  Future<void> updateAdminStatus() async {
    final DocumentSnapshot doc = await adminsDoc.get();
    if (doc.exists) {
      final data = doc.data()! as Map<String, dynamic>;
      if (data[uid] == true) {
        await update(field: 'isAdmin', value: true);
        isAdmin = true;
      } else {
        await update(field: 'isAdmin', value: null);
        isAdmin = false;
      }
    }
  }
}
