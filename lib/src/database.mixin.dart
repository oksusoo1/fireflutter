import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

mixin DatabaseMixin {
  DatabaseReference userDoc(uid) => FirebaseDatabase.instance.ref('users').child(uid);
  DatabaseReference get userSettingsDoc =>
      FirebaseDatabase.instance.ref('user-settings').child(FirebaseAuth.instance.currentUser!.uid);

  DatabaseReference get translationDoc =>
      FirebaseDatabase.instance.ref('settings').child('translations');
}
