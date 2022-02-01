import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fireflutter/fireflutter.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance {
    _instance ??= UserService();
    return _instance!;
  }

  DocumentReference get _myDoc =>
      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  /// Update user name of currently login user.
  Future<void> updateNickname(String name) {
    return _myDoc.set({'nickname': name}, SetOptions(merge: true));
  }

  /// Update photoUrl of currently login user.
  Future<void> updatePhotoUrl(String url) {
    return _myDoc.set({'photoUrl': url}, SetOptions(merge: true));
  }

  Future<UserModel> get() async {
    final doc = await _myDoc.get();
    final user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    user.id = doc.id;
    return user;
  }
}
