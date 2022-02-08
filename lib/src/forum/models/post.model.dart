import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../fireflutter.dart';

/// PostModel
///
/// Post and comment are a lot similiar. So both uses the same model.
/// Refer readme for details
class PostModel with FirestoreMixin, ForumBase {
  PostModel({
    this.id = '',
    this.category = '',
    this.title = '',
    this.content = '',
    this.uid = '',
    this.files = const [],
    this.like = 0,
    this.dislike = 0,
    this.deleted = false,
    this.timestamp_,
    this.data_,
  });

  /// data is the document data object.
  Json? data_;
  Json get data => data_ ?? const {};

  String id;
  String get path => postDoc(id).path;

  /// Category of the post.
  ///
  /// Category is not needed for comment.
  String category;

  String title;
  String get displayTitle {
    return deleted ? 'post-title-deleted' : title;
  }

  String content;
  String get displayContent {
    return deleted ? 'post-content-deleted' : content;
  }

  bool deleted;

  String uid;

  bool get isMine => UserService.instance.uid == uid;

  List<String> files;

  int like;
  int dislike;

  Timestamp? timestamp_;
  Timestamp get timestamp => timestamp_ ?? Timestamp.now();

  /// Get document data of map and convert it into post model
  factory PostModel.fromJson(Json data, String id) {
    List<String> _files = data['files'] != null ? new List<String>.from(data['files']) : <String>[];

    return PostModel(
      id: id,
      category: data['category'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      files: _files,
      deleted: data['deleted'] ?? false,
      uid: data['uid'] ?? '',
      like: data['like'] ?? 0,
      dislike: data['dislike'] ?? 0,
      timestamp_: data['timestamp'] ?? Timestamp.now(),
      data_: data,
    );
  }

  /// Contains all the data
  Map<String, dynamic> get map {
    return {
      'category': category,
      'title': title,
      'content': content,
      'files': files,
      'deleted': deleted,
      'uid': uid,
      'like': like,
      'dislike': dislike,
      'timestamp': timestamp,
      'data': data,
    };
  }

  @override
  String toString() {
    return '''PostModel($map)''';
  }

  Future<void> report(String? reason) {
    return createReport(
      target: 'post',
      targetId: id,
      reporteeUid: uid,
      reason: reason,
    );
  }

  /// Create a post with extra data
  ///
  /// ```dart
  /// final ref = await PostModel(
  ///   category: Get.arguments['category'],
  ///   title: title.text,
  ///   content: content.text,
  /// ).create(extra: {'yo': 'hey'});
  /// print('post created; ${ref.id}');
  /// ```
  Future<DocumentReference<Object?>> create({
    required String category,
    required String title,
    required String content,
    Json extra = const {},
  }) {
    if (signedIn == false) throw ERROR_SIGN_IN;
    if (UserService.instance.user.exists == false) throw ERROR_USER_DOCUMENT_NOT_EXISTS;
    final createData = {
      'category': category,
      'title': title,
      'content': content,
      'files': files,
      'uid': UserService.instance.user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };
    return postCol.add({...createData, ...extra});
  }

  Future<void> update({
    required String title,
    required String content,
    Json extra = const {},
  }) {
    if (deleted) throw ERROR_ALREADY_DELETED;
    return postDoc(id).update({
      ...{
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      },
      ...extra
    });
  }

  Future<void> delete() {
    if (deleted) throw ERROR_ALREADY_DELETED;
    return postDoc(id).update({
      'deleted': true,
      'content': '',
      'title': '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> increaseViewCounter() {
    return increaseForumViewCounter(postDoc(id));
  }
}
