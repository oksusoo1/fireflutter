import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// [FirestoreRules] provides
/// - the paths of firestore structures and
/// - rule (validation) check up
///
/// You may think of it as 'path provider' or 'rule validator' of firestore.
///
/// It has paths of collections, documents of users, forums, and etc
/// except chat. chat has its own mixin for path.
mixin FirestoreRules {
  /// Returns Firestore instance. Firebase database instance.
  final FirebaseFirestore db = FirebaseFirestore.instance;
  User get _user => FirebaseAuth.instance.currentUser!;

  CollectionReference get categoryCol => db.collection('categories');
  CollectionReference get postCol => db.collection('posts');
  CollectionReference get tokenCol => db.collection('tokens');
  CollectionReference get settingDoc => db.collection('settings');

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
}
