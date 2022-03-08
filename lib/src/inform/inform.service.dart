import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../fireflutter.dart';

/// To inform message between users.
///
/// See readme.md for more details
class InformService {
  static InformService? _instance;
  static InformService get instance {
    _instance ??= InformService();
    return _instance!;
  }

  String get uid => FirebaseAuth.instance.currentUser!.uid;
  DatabaseReference get myDoc =>
      FirebaseDatabase.instance.ref("inform").child(uid);

  // ignore: cancel_subscriptions
  StreamSubscription? sub;

  init({required VoidMapCallback callback}) {
    sub = myDoc.onValue.listen((event) {
      if (event.snapshot.exists) {
        callback(Map.from(event.snapshot.value as dynamic));
        myDoc.remove();
      }
    });
  }

  dispose() {
    if (sub != null) {
      sub!.cancel();
    }
  }

  Future inform(String uid, Map<String, dynamic> data) {
    DatabaseReference otherDoc =
        FirebaseDatabase.instance.ref("inform").child(uid);
    return otherDoc.set(data);
  }
}
