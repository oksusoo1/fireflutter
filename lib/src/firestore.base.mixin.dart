import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../fireflutter.dart';

/// [FirestoreBase] provides
/// - the paths of firestore structures and
/// - rule (validation) check up
///
/// You may think of it as 'path provider' or 'rule validator' of firestore.
///
/// It has paths of collections, documents of users, forums, and etc
/// except chat. chat has its own mixin for path.
mixin FirestoreBase {
  /// Returns Firestore instance. Firebase database instance.
  final FirebaseFirestore db = FirebaseFirestore.instance;
  User get _user => FirebaseAuth.instance.currentUser!;

  CollectionReference get categoryCol => db.collection('categories');
  CollectionReference get postCol => db.collection('posts');
  CollectionReference get tokenCol => db.collection('tokens');
  CollectionReference get settingDoc => db.collection('settings');
  CollectionReference get reportCol => db.collection('reports');

  DocumentReference get adminsDoc => settingDoc.doc('admins');

  CollectionReference commentCol(String postId) {
    return postDoc(postId).collection('comments');
  }

  DocumentReference categoryDoc(String id) {
    return db.collection('categories').doc(id);
  }

  DocumentReference postDoc(String id) {
    return postCol.doc(id);
  }

  DocumentReference voteDoc(String id) {
    return postCol.doc(id).collection('votes').doc(_user.uid);
  }

  DocumentReference commentDoc(String postId, String commentId) {
    return commentCol(postId).doc(commentId);
  }

  DocumentReference commentVoteDoc(String postId, String commentId) {
    return commentDoc(postId, commentId).collection('votes').doc(_user.uid);
  }

  /// ************** Common Methods ***********************
  ///
  /// These are the mehods that are used in multiple places
  ///
  /// *****************************************************
  Future<void> createReport({
    required String target,
    required String targetId,
    required String reporteeUid,
    String? reason,
  }) async {
    final id = "$target-$targetId-${_user.uid}";
    try {
      await reportCol.doc(id).get();

      /// If document exists, then already reporetd
      throw ERROR_ALREADY_REPORTED;
    } catch (e) {
      /// If already reporeted, throw exception and move out.
      if (e == ERROR_ALREADY_REPORTED) rethrow;

      /// Or continue ...
    }

    return reportCol.doc(id).set({
      'target': target,
      'targetId': targetId,
      'reporterUid': _user.uid,
      'reporteeUid': reporteeUid,
      'reason': reason ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
