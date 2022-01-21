import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance {
    _instance ??= UserService();
    return _instance!;
  }

  DocumentReference get _myDoc => FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  /// Update user name of currently login user.
  Future<void> updateName(String name) {
    return _myDoc.set({'name': name}, SetOptions(merge: true));
  }

  /// Update photoUrl of currently login user.
  Future<void> updatePhotoUrl(String url) {
    return _myDoc.set({'photoUrl': url}, SetOptions(merge: true));
  }
}
