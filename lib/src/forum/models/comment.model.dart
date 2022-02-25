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
    createdAt,
    updatedAt,
    required this.data,
    this.files = const [],
  })  : createdAt = createdAt ?? Timestamp.now(),
        updatedAt = updatedAt ?? Timestamp.now();

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

  Timestamp updatedAt;
  Timestamp createdAt;
  int depth = 0;

  /// Get document data of map and convert it into post model
  factory CommentModel.fromJson(
    Json data, {
    required String id,
  }) {
    return CommentModel(
      content: data['content'] ?? '',
      files: new List<String>.from(data['files']),
      id: id,
      postId: data['postId'],
      parentId: data['parentId'],
      uid: data['uid'],
      deleted: data['deleted'] ?? false,
      like: data['like'] ?? 0,
      dislike: data['dislike'] ?? 0,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      data: data,
    );
  }

  /// Get indexed document data from meilisearch of map and convert it into comment model
  factory CommentModel.fromMeili(Json data, String id) {
    final _createdAt = data['createdAt'] ?? 0;
    final _updatedAt = data['updatedAt'] ?? 0;

    return CommentModel(
      id: id,
      postId: data['postId'],
      parentId: data['parentId'],
      content: data['content'] ?? '',
      uid: data['uid'] ?? '',
      like: data['like'] ?? 0,
      dislike: data['dislike'] ?? 0,
      deleted: data.containsKey('deleted') ? data['deleted'] == 'Y' : false,
      createdAt: Timestamp.fromMillisecondsSinceEpoch(_createdAt * 1000),
      updatedAt: Timestamp.fromMillisecondsSinceEpoch(_updatedAt * 1000),
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
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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
  //     'updatedAt': FieldValue.serverTimestamp(),
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
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete() {
    if (deleted) throw ERROR_ALREADY_DELETED;
    return commentDoc(id).update({
      'deleted': true,
      'content': '',
      'updatedAt': FieldValue.serverTimestamp(),
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
