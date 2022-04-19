import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../fireflutter.dart';

/// [FirestoreMixin] provides
/// - the paths of firestore structures and
/// - rule (validation) check up
///
/// You may think of it as 'path provider' or 'rule validator' of firestore.
///
/// It has paths of collections, documents of users, forums, and etc
/// except chat. chat has its own mixin for path.
mixin FirestoreMixin {
  /// Returns Firestore instance. Firebase database instance.
  final FirebaseFirestore db = FirebaseFirestore.instance;
  User get _user => FirebaseAuth.instance.currentUser!;
  bool get signedIn => FirebaseAuth.instance.currentUser != null;
  bool get notSignIn => signedIn == false;

  CollectionReference get userCol => db.collection('users');
  CollectionReference get categoryCol => db.collection('categories');
  CollectionReference get postCol => db.collection('posts');
  CollectionReference get commentCol => db.collection('comments');
  CollectionReference get tokenCol => db.collection('tokens');
  CollectionReference get settingDoc => db.collection('settings');
  CollectionReference get reportCol => db.collection('reports');
  CollectionReference get feedCol => db.collection('feeds');

  CollectionReference get jobs => db.collection('jobs');
  CollectionReference get jobSeekers => db.collection('job-seekers');

  // CollectionReference get messageTokensCol => db.collection('message-tokens');

  DocumentReference get adminsDoc => settingDoc.doc('admins');

  // Forum category menus
  DocumentReference get forumSettingDoc => settingDoc.doc('forum');

  // CollectionReference commentCol(String postId) {
  //   return postDoc(postId).collection('comments');
  // }

  DocumentReference categoryDoc(String id) {
    return db.collection('categories').doc(id);
  }

  DocumentReference postDoc(String id) {
    return postCol.doc(id);
  }

  // Use this for static.
  static DocumentReference postDocument(String id) {
    return FirebaseFirestore.instance.collection('posts').doc(id);
  }

  DocumentReference voteDoc(String id) {
    return postCol.doc(id).collection('votes').doc(_user.uid);
  }

  DocumentReference commentDoc(String commentId) {
    return commentCol.doc(commentId);
  }

  DocumentReference commentVoteDoc(String commentId) {
    return commentDoc(commentId).collection('votes').doc(_user.uid);
  }

  /// ************** Common Methods ***********************
  ///
  /// These are the methods that are used in multiple places
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

      /// If document exists, then already reported
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

  /// Like, dislike
  ///
  /// Don't put it in cloud functions since;
  /// - the logic is a bit complicated and it's easir to make it work on client
  ///   side.
  /// - It is not a critical work. It is okay that there might be an unexpted
  ///   behaviour.
  ///
  /// [targetDocPath] is the path of target document. The document could be one
  /// post, comment, or user.
  /// [likeOrDisliek] can be one of 'like' or 'dislike'.
  ///
  Future<void> feed(String targetDocPath, String likeOrDislike) async {
    if (notSignIn) throw ERROR_SIGN_IN;

    final targetDocRef = db.doc(targetDocPath);

    String feedDocId = "${targetDocRef.id}-${_user.uid}";

    // if feed not exists, then create new one and increase the number on doc.
    // if existing feed is same as new feed, then remove the feed and decrease the number on doc.
    // if existing feed is different from new feed, then change the feed and decrease one from the

    final feedDocRef = feedCol.doc(feedDocId);

    try {
      final feedDoc = await feedDocRef.get();
      if (feedDoc.exists) {
        // feed exists.
        final data = feedDoc.data() as Json;
        if (data['feed'] == likeOrDislike) {
          // same feed again
          final batch = db.batch();
          batch.delete(feedDocRef);
          batch.set(
            targetDocRef,
            {likeOrDislike: FieldValue.increment(-1)},
            SetOptions(merge: true),
          );
          return batch.commit();
        } else {
          // different feed
          final batch = db.batch();
          batch.set(feedDocRef, {'feed': likeOrDislike});
          if (likeOrDislike == 'like') {
            batch.set(
              targetDocRef,
              {
                'like': FieldValue.increment(1),
                'dislike': FieldValue.increment(-1),
              },
              SetOptions(merge: true),
            );
          } else {
            batch.set(
              targetDocRef,
              {
                'like': FieldValue.increment(-1),
                'dislike': FieldValue.increment(1),
              },
              SetOptions(merge: true),
            );
          }
          return batch.commit();
        }
      } else {
        await createFeed(feedDocRef, targetDocRef, likeOrDislike);
      }
    } catch (e) {
      await createFeed(feedDocRef, targetDocRef, likeOrDislike);
    }
  }

  Future<void> createFeed(feedDocRef, targetDocRef, likeOrDislike) {
    // feed doc does not exist. create one.
    final batch = db.batch();
    batch.set(feedDocRef, {'feed': likeOrDislike});
    batch.set<Map<String, dynamic>>(
      targetDocRef,
      {likeOrDislike: FieldValue.increment(1)},
      SetOptions(merge: true),
    );
    return batch.commit();
  }
}
