import 'package:firebase_database/firebase_database.dart';

mixin DatabaseMixin {
  DatabaseReference userDoc(uid) => FirebaseDatabase.instance.ref('users').child(uid);
}
