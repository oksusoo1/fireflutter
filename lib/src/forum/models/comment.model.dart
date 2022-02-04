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
    this.authorNickname = '',
    this.authorPhotoUrl = '',
    this.authorUid = '',
    this.timestamp_,
    this.data_,
  });

  /// data is the document data object.
  Json? data_;
  Json get data => data_ ?? const {};

  String id;
  String postId;

  String content;

  String authorUid;
  String authorNickname;
  String authorPhotoUrl;

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
      authorUid: data['authorUid'] ?? '',
      authorNickname: data['authorNickname'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      timestamp_: data['timestamp'] ?? Timestamp.now(),
      data_: data,
    );
  }

  /// Contains all the data
  Map<String, dynamic> get map {
    return {
      'id': id,
      'content': content,
      'authorUid': authorUid,
      'authorNickname': authorNickname,
      'authorPhotoUrl': authorPhotoUrl,
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
      'authorUid': UserService.instance.user.uid,
      'authorNickname': UserService.instance.user.nickname,
      'authorPhotoUrl': UserService.instance.user.photoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  Future<void> increaseViewCounter() {
    return increaseForumViewCounter(commentDoc(postId, id));
  }

  /// Create a comment with extra data
  Future<DocumentReference<Object?>> create({required String postId, String parent = 'root'}) {
    final col = commentCol(postId);
    return col.add({
      ...createData,
      ...{'parent': parent},
    });
  }

  Future<void> report(String? reason) {
    return createReport(
      target: 'comment',
      targetId: id,
      reporteeUid: authorUid,
      reason: reason,
    );
  }
}
