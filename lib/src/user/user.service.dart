import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance {
    _instance ??= UserService();
    return _instance!;
  }

  DocumentReference get _myDoc =>
      FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.uid);

  Future<void> updateName(String name) {
    return _myDoc.set({'name': name}, SetOptions(merge: true));
  }

  Future<void> updatePhotoUrl(String url) {
    return _myDoc.set({'url': url}, SetOptions(merge: true));
  }
}
