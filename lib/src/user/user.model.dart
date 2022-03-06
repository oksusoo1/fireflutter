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
    this.profileReady = false,
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
    'profileReady',
    'isAdmin',
  ];

  /// Note, user settings instance is connected to user model. Not user service.
  /// Note, it is user settings **service**, Not model.
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
    return '';
  }

  bool get hasDisplayName => displayName != '';

  String photoUrl;

  /// default is 0 if it's not set.
  int birthday;
  String gender;

  /// return age.
  int get age {
    final String birthdayString = birthday.toString();
    if (birthdayString.length != 8) return 0;

    final today = new DateTime.now();
    final birthDate = new DateTime(
      int.tryParse(birthdayString.substring(0, 4)) ?? 0,
      int.tryParse(birthdayString.substring(4, 6)) ?? 0,
      int.tryParse(birthdayString.substring(6, 8)) ?? 0,
    );

    int age = today.year - birthDate.year;
    final m = today.month - birthDate.month;
    if (m < 0 || (m == 0 && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// It becomes true when the user's profile is ready.
  bool profileReady;

  bool get signedIn => FirebaseAuth.instance.currentUser != null;
  bool get signedOut => signedIn == false;

  ///
  DatabaseReference get _userDoc => FirebaseDatabase.instance.ref('users').child(uid);

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
      profileReady: data['profileReady'] ?? false,
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
    return _userDoc.set({
      'registeredAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
    });
  }

  /// Update login user's document on `/users/{userDoc}` in realtime database.
  ///
  /// ```dart
  /// return update(field: 'nickname', value: name);
  /// ```
  Future<void> update({required String field, required dynamic value}) {
    if (fields.indexOf(field) == -1) {
      // throw Exception(ERROR_NOT_SUPPORTED_FIELD_ON_USER_UPDATE);
      throw ERROR_NOT_SUPPORTED_FIELD_ON_USER_UPDATE;
    }
    return _userDoc.update({
      field: value,
      'updatedAt': ServerValue.timestamp,
    });
  }

  /// Updating `updatedAt` field.
  ///
  /// Use this method to update user document, so it can trigger any listening callbacks.
  Future<void> updateUpdatedAt() {
    return _userDoc.update({
      'updatedAt': ServerValue.timestamp,
    });
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
    if (signedOut) return;
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
