import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../fireflutter.dart';
import 'package:email_validator/email_validator.dart';

/// UserModel
///
/// Note that, you can only put uid and use the member methods.
class UserModel with FirestoreMixin, DatabaseMixin {
  UserModel({
    this.uid = '',
    this.email = '',
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
    this.nickname = '',
    this.photoUrl = '',
    this.birthday = 0,
    this.gender = '',
    this.point = 0,
    this.profileReady = 90000000000000,
    this.isAdmin = false,
    this.disabled = false,
    this.registeredAt = 0,
    this.updatedAt = 0,
    this.level = 0,
  });

  final allowedFields = [
    'email',
    'firstName',
    'middleName',
    'lastName',
    'nickname',
    'photoUrl',
    'birthday',
    'gender',
    'profileReady',
    'isAdmin',
    'disabled'
  ];

  /// Note, user settings instance is connected to user model. Not user service.
  /// Note, it is user settings **service**, Not model.
  UserSettingService settings = UserSettingService.instance;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  /// Returns currently signed in user's uid or empty string.
  String get phoneNumber => currentUser?.phoneNumber ?? '';

  // No more email verification by Apr 13, 2022.
  // String get email => currentUser?.email ?? '';
  // bool get emailIsVerified => currentUser?.emailVerified ?? false;

  /// This is the user's document id which is the uid.
  /// If it is empty, the user may not be signed-in
  String uid;

  /// If id is empty string, then the model has no user info or the doc of the model does not exists.
  /// * warning - it returns true as long as [uid] is set even if the user document does not exists.
  bool get exists => uid != '';

  /// returns true if user document is truely exists.
  bool get docExists => registeredAt > 0;
  bool isAdmin;
  bool disabled;

  String email;

  String firstName;
  String middleName;
  String lastName;
  String nickname;

  int point;
  int level;

  int registeredAt;
  String get registeredDate => DateFormat("MMMM dd, yyyy")
      .format(DateTime.fromMillisecondsSinceEpoch(registeredAt));
  int updatedAt;

  /// Use display name to display user name.
  /// Don't confuse the displayName of FirebaseAuth.
  String get displayName {
    String name = '';
    if (nickname != '') {
      name = nickname;
    } else if (firstName != '') {
      name = firstName;
    } else if (FirebaseAuth.instance.currentUser?.displayName != null) {
      name = FirebaseAuth.instance.currentUser!.displayName!;
    }
    if (name.length > 12) {
      name = name.substring(0, 10) + '...';
    }
    return name;
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

  /// It becomes int when the user's profile is ready.
  int profileReady;
  bool get ready => profileReady < 90000000000000;
  bool get notReady => ready == false;

  bool get signedIn => FirebaseAuth.instance.currentUser != null;
  bool get signedOut => signedIn == false;

  ///
  DatabaseReference get _userDoc =>
      FirebaseDatabase.instance.ref('users').child(uid);

  factory UserModel.fromJson(dynamic data, String uid) {
    if (data == null) return UserModel();

    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      disabled: data['disabled'] ?? false,
      firstName: data['firstName'] ?? '',
      middleName: data['middleName'] ?? '',
      lastName: data['lastName'] ?? '',
      nickname: data['nickname'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      birthday: (data['birthday'] is int)
          ? data['birthday']
          : (int.tryParse(data['birthday'] ?? '0')),
      gender: data['gender'] ?? '',
      point: data['point'] ?? 0,
      level: data['level'] ?? 0,
      profileReady: data['profileReady'] ?? 0,
      registeredAt: data['registeredAt'] ?? 0,
      updatedAt: data['updatedAt'] ?? 0,
    );
  }

  /// Data for updating firestore user document
  Map<String, dynamic> get data {
    return {
      'email': email,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'nickname': nickname,
      'photoUrl': photoUrl,
      'birthday': birthday,
      'gender': gender,
      'disabled': disabled,
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

  /// Creates user document.
  ///
  /// Note, `update()` will create document if it's not existing.
  Future<void> create() {
    return _userDoc.update({
      'registeredAt': ServerValue.timestamp,
      'updatedAt': ServerValue.timestamp,
      'profileReady': 90000000000000,
      'lastSignInAt': ServerValue.timestamp,
    });
  }

  /// Update last sign in stamp
  Future<void> updateLastSignInAt() {
    return _userDoc.update({
      'lastSignInAt': ServerValue.timestamp,
    });
  }

  /// Load user data into the member variables. See README for details.
  Future<void> load() async {
    final snapshot = await _userDoc.get();
    final u = UserModel.fromJson(snapshot.value, uid);
    if (u.docExists) {
      copyWith(u);
    }
  }

  /// Copy user data from antoher user model.
  copyWith(UserModel u) {
    uid = u.uid;
    isAdmin = u.isAdmin;
    disabled = u.disabled;
    firstName = u.firstName;
    middleName = u.middleName;
    lastName = u.lastName;
    nickname = u.nickname;
    photoUrl = u.photoUrl;
    birthday = u.birthday;
    gender = u.gender;
    point = u.point;
    level = u.level;
    profileReady = u.profileReady;
    registeredAt = u.registeredAt;
    updatedAt = u.updatedAt;
  }

  /// Return empty string('') if there is no error on profile.
  String get profileError {
    if (photoUrl == '') return ERROR_NO_PROFILE_PHOTO;
    if (email == '')
      return ERROR_NO_EMAIL;
    else if (EmailValidator.validate(email) == false)
      return ERROR_MALFORMED_EMAIL;
    if (firstName == '') return ERROR_NO_FIRST_NAME;
    if (lastName == '') return ERROR_NO_LAST_NAME;
    if (gender == '') return ERROR_NO_GENER;
    if (birthday == 0) return ERROR_NO_BIRTHDAY;
    return '';
  }

  /// Set user profile ready or not.
  /// * Note that, this only updates when the value changes. If the value does not change, then it does not update.
  /// ! To prevent perpetual update.
  /// * Note, this code is written in client app. Meaning, this won't work on web.
  Future<void> updateProfileReady() async {
    /// If there is no error on profile,
    if (profileError == '') {
      /// But the profile is set to false on database, then set it true.
      if (profileReady == 90000000000000) {
        /// It does +1 here to block perpetual running. This may happens somehow when registeredAt is 0.
        return update(
            field: 'profileReady', value: 90000000000000 - registeredAt + 1);
      }
    }

    /// If there is error on profile,
    else {
      // And the profile is set to true on database, then set it false.
      if (profileReady != 90000000000000) {
        return update(field: 'profileReady', value: 90000000000000);
      }
    }
  }

  /// Update login user's document on `/users/{userDoc}` in realtime database.
  ///
  /// ```dart
  /// return update(field: 'nickname', value: name);
  /// ```
  Future<void> update({required String field, required dynamic value}) {
    if (allowedFields.indexOf(field) == -1) {
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
