import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance {
    _instance ??= UserService();
    return _instance!;
  }

  DocumentReference get myDoc =>
      FirebaseFirestore.instance.collection('user').doc(FirebaseAuth.instance.currentUser!.uid);

  updateName(String name) {
    return myDoc.set({'name': name}, SetOptions(merge: true));
  }

  updatePhotoUrl(String url) {
    return myDoc.set({'url': url}, SetOptions(merge: true));
  }
}
