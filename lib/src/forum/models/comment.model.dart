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
    this.like = 0,
    this.dislike = 0,
    required this.uid,
    this.deleted = false,
    required this.timestamp,
    required this.data,
    this.files = const [],
  });

  /// data is the document data object.
  Json data;

  String id;
  String get path => commentDoc(id).path;
  String postId;
  String parentId;

  String content;
  String get displayContent {
    return deleted ? 'comment-content-deleted' : content;
  }

  int like;
  int dislike;

  String uid;

  bool deleted;

  List<String> files;

  Timestamp timestamp;
  int depth = 0;

  /// Get document data of map and convert it into post model
  factory CommentModel.fromJson(
    Json data, {
    required String id,
  }) {
    List<String> _files = data['files'] != null
        ? new List<String>.from(data['files'])
        : <String>[];

    return CommentModel(
      content: data['content'] ?? '',
      files: _files,
      id: id,
      postId: data['postId'],
      parentId: data['parentId'],
      uid: data['uid'],
      deleted: data['deleted'] ?? false,
      like: data['like'] ?? 0,
      dislike: data['dislike'] ?? 0,
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
      'files': files,
      'uid': uid,
      'like': like,
      'dislike': dislike,
      'deleted': deleted,
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

  /// Increases the view counter
  ///
  /// Becareful of using this. This makes another document changes and if there are
  /// event trigger functions in cloud functions, those function may be trigger too
  /// often.
  Future<void> increaseViewCounter() {
    return increaseForumViewCounter(commentDoc(id));
  }

  /// Create a comment with extra data
  static Future<DocumentReference<Object?>> create({
    required String postId,
    required String parentId,
    String content = '',
    List<String> files = const [],
  }) async {
    final _ = CommentModel.empty();
    final ref = await _.commentCol.add({
      'postId': postId,
      'parentId': parentId,
      'content': content,
      'files': files,
      'timestamp': FieldValue.serverTimestamp(),
      'uid': FirebaseAuth.instance.currentUser?.uid ?? '',
    });

    // final post = await PostModel().get(postId);
    // await post.increaseNoOfComments();

    PostModel.increaseNoOfComments(postId);

    return ref;
  }

  Future<void> update({
    required String content,
    List<String>? files,
  }) {
    if (deleted) throw ERROR_ALREADY_DELETED;
    return commentDoc(id).update({
      'content': content,
      if (files != null) 'files': files,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete() {
    if (deleted) throw ERROR_ALREADY_DELETED;
    return commentDoc(id).update({
      'deleted': true,
      'content': '',
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

  Future feedLike() {
    return feed(path, 'like');
  }

  Future feedDislike() {
    return feed(path, 'dislike');
  }
}
