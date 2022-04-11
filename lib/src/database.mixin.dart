import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

mixin DatabaseMixin {
  DatabaseReference get usersRef => FirebaseDatabase.instance.ref('users');
  DatabaseReference get pointRef => FirebaseDatabase.instance.ref('point');

  DatabaseReference userDoc(uid) => usersRef.child(uid);
  DatabaseReference get userSettingsDoc => FirebaseDatabase.instance
      .ref('user-settings')
      .child(FirebaseAuth.instance.currentUser!.uid);

  DatabaseReference get translationDoc =>
      FirebaseDatabase.instance.ref('settings').child('translations');

  DatabaseReference get messageTokensRef =>
      FirebaseDatabase.instance.ref('message-tokens');

  DatabaseReference userPointRef(String uid) => pointRef.child(uid);
}
