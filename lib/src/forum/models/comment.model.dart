import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../fireflutter.dart';

/// CommentModel
///
/// Refer readme for details
class CommentModel with FirestoreMixin, ForumBase {
  CommentModel({
    this.id = '',
    this.postId = '',
    this.content = '',
    this.uid = '',
    this.timestamp_,
    this.data_,
  });

  /// data is the document data object.
  Json? data_;
  Json get data => data_ ?? const {};

  String id;
  String postId;

  String content;

  String uid;

  Timestamp? timestamp_;
  Timestamp get timestamp => timestamp_ ?? Timestamp.now();

  /// Get document data of map and convert it into post model
  factory CommentModel.fromJson(
    Json data, {
    required String id,
    required String postId,
  }) {
    return CommentModel(
      id: id,
      postId: postId,
      content: data['content'] ?? '',
      uid: data['uid'] ?? '',
      timestamp_: data['timestamp'] ?? Timestamp.now(),
      data_: data,
    );
  }

  /// Contains all the data
  Map<String, dynamic> get map {
    return {
      'id': id,
      'content': content,
      'uid': uid,
      'timestamp': timestamp,
      'data': data,
    };
  }

  @override
  String toString() {
    return '''CommentModel($map)''';
  }

  Map<String, dynamic> get createData {
    return {
      'content': content,
      'uid': UserService.instance.user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  Future<void> increaseViewCounter() {
    return increaseForumViewCounter(commentDoc(id));
  }

  /// Create a comment with extra data
  Future<DocumentReference<Object?>> create({required String postId, required String parentId}) {
    return commentCol.add({
      ...createData,
      ...{
        'postId': postId,
        'parentId': parentId,
      },
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
