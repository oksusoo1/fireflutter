import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fireflutter/fireflutter.dart';

/// The user must be logged in.
class Chat {
  final String otherUid;
  Chat({required this.otherUid});

  String get myUid => FirebaseAuth.instance.currentUser!.uid;
  String get roomId => getChatRoomId(myUid, otherUid);
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  DatabaseReference get room => ref.child('/chat').child(roomId);

  /// Set a message on /chat/uid__uid
  ///
  /// Throws permission error on
  /// - none
  Future send({required String message}) async {
    await room.push().set({
      'uid': myUid,
      'message': message,
    });
  }
}
