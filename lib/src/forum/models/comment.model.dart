import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../fireflutter.dart';

/// CommentModel
///
/// Refer readme for details
class CommentModel with FirestoreMixin, ForumBase {
  CommentModel({
    this.id = '',
    required this.postId,
    required this.parentId,
    this.content = '',
    required this.uid,
    required this.timestamp,
    required this.data,
  });

  /// data is the document data object.
  Json data;

  String id;
  String postId;
  String parentId;

  String content;

  String uid;

  Timestamp timestamp;
  int depth = 0;

  /// Get document data of map and convert it into post model
  factory CommentModel.fromJson(
    Json data, {
    required String id,
  }) {
    return CommentModel(
      content: data['content'] ?? '',
      id: id,
      postId: data['postId'],
      parentId: data['parentId'],
      uid: data['uid'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      data: data,
    );
  }

  /// Returns an empty object.
  ///
  /// Use this when you need to use comment model's methods, like when you are
  /// going to create a new comment.
  factory CommentModel.empty() {
    return CommentModel(
      postId: '',
      parentId: '',
      content: '',
      uid: '',
      timestamp: Timestamp.now(),
      data: {},
    );
  }

  /// Contains all the data
  Map<String, dynamic> get map {
    return {
      'id': id,
      'postId': postId,
      'parentId': parentId,
      'content': content,
      'depth': depth,
      'uid': uid,
      'timestamp': timestamp,
      'data': data,
    };
  }

  @override
  String toString() {
    return '''CommentModel($map)''';
  }

  // Map<String, dynamic> get createData {
  //   return {
  //     'content': content,
  //     'uid': UserService.instance.user.uid,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   };
  // }

  Future<void> increaseViewCounter() {
    return increaseForumViewCounter(commentDoc(id));
  }

  /// Create a comment with extra data
  static Future<DocumentReference<Object?>> create({
    required String postId,
    required String parentId,
    String content = '',
  }) {
    final _ = CommentModel.empty();
    return _.commentCol.add({
      'postId': postId,
      'parentId': parentId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'uid': FirebaseAuth.instance.currentUser?.uid ?? '',
    });
  }

  Future<void> update({
    required String content,
  }) {
    return commentDoc(id).update({
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> report(String? reason) {
    return createReport(
      target: 'comment',
      targetId: id,
      reporteeUid: uid,
      reason: reason,
    );
  }
}
