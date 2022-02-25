import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';
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
    this.noOfComments = 0,
    this.hasPhoto = false,
    this.files = const [],
    this.like = 0,
    this.dislike = 0,
    this.deleted = false,
    createdAt,
    updatedAt,
    this.data_,
    this.isHtmlContent = false,
  })  : createdAt = createdAt ?? Timestamp.now(),
        updatedAt = updatedAt ?? Timestamp.now();

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

  int noOfComments;

  bool hasPhoto;
  bool isHtmlContent;
  List<String> files;

  int like;
  int dislike;

  Timestamp createdAt;
  Timestamp updatedAt;

  /// Get document data of map and convert it into post model
  factory PostModel.fromJson(Json data, String id) {
    List<String> _files = <String>[];

    if (data['files'] is String && data['files'] != '') {
      _files = data['files'].split(', ');
    }

    if (data['files'] is List) {
      _files = new List<String>.from(data['files']);
    }

    String content = data['content'] ?? '';

    /// Check if the content has any html tag.
    bool html = false;
    if (content.indexOf('</p>') > -1 ||
        content.indexOf('</span') > -1 ||
        content.indexOf('</em>') > -1 ||
        content.indexOf('</strong>') > -1 ||
        content.indexOf('<br>') > -1 ||
        content.indexOf('<img') > -1 ||
        content.indexOf('style="') > -1) {
      html = true;
    }

    return PostModel(
      id: id,
      category: data['category'] ?? '',
      title: data['title'] ?? '',
      content: content,
      isHtmlContent: html,
      noOfComments: data['noOfComments'] ?? 0,
      hasPhoto: data['hasPhoto'] ?? false,
      files: _files,
      deleted: data['deleted'] ?? false,
      uid: data['uid'] ?? '',
      like: data['like'] ?? 0,
      dislike: data['dislike'] ?? 0,
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      data_: data,
    );
  }

  /// Contains all the data
  Map<String, dynamic> get map {
    return {
      'category': category,
      'title': title,
      'content': content,
      'isHtmlContent': isHtmlContent,
      'noOfComments': noOfComments,
      'hasPhoto': hasPhoto,
      'files': files,
      'deleted': deleted,
      'uid': uid,
      'like': like,
      'dislike': dislike,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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
  ///
  /// Read readme for [hasPhoto]
  Future<DocumentReference<Object?>> create({
    required String category,
    required String title,
    required String content,
    List<String>? files,
    Json extra = const {},
  }) {
    if (signedIn == false) throw ERROR_SIGN_IN;
    if (UserService.instance.user.exists == false) throw ERROR_USER_DOCUMENT_NOT_EXISTS;

    final j = Jiffy();
    int week = ((j.unix() - 345600) / 604800).floor();
    final createData = {
      'category': category,
      'title': title,
      'content': content,
      if (files != null) 'files': files,
      'uid': UserService.instance.user.uid,
      'hasPhoto': (files == null || files.length == 0) ? false : true,
      'deleted': false,
      'noOfComments': 0,
      'year': j.year,
      'month': j.month,
      'day': j.date,
      'dayOfYear': j.dayOfYear,
      'week': week,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    return postCol.add({...createData, ...extra});
  }

  Future<void> update({
    required String title,
    required String content,
    List<String>? files,
    Json extra = const {},
  }) {
    if (deleted) throw ERROR_ALREADY_DELETED;
    return postDoc(id).update({
      ...{
        'title': title,
        'content': content,
        if (files != null) 'files': files,
        'hasPhoto': (files == null || files.length == 0) ? false : true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      ...extra
    });
  }

  Future<PostModel> get(String postId) async {
    final snapshot = await postDoc(postId).get();
    return PostModel.fromJson(snapshot.data() as Json, snapshot.id);
  }

  Future<void> delete() {
    if (deleted) throw ERROR_ALREADY_DELETED;

    return postDoc(id).update({
      'deleted': true,
      'content': '',
      'title': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Increases no of the post read.
  ///
  /// Note that, this is not a recommended way of counting post view.
  /// When you do this on post view action, the document will be updated every
  /// time the user opens the document. and if the app is listening document's
  /// change, or if a cloud function is listing on `post update event`, the cost
  /// will be increased.
  ///
  /// Be careful using this.
  Future<void> increaseViewCounter() {
    return increaseForumViewCounter(postDoc(id));
  }

  /// Increase no of comments
  ///
  /// Note that, this is a static method.
  ///
  /// ```dart
  /// PostModel.increaseNoOfComments(postId);
  /// ```
  static Future<void> increaseNoOfComments(postId) {
    return FirestoreMixin.postDocument(postId).update({'noOfComments': FieldValue.increment(1)});
  }

  ///
  Future feedLike() {
    return feed(path, 'like');
  }

  ///
  Future feedDislike() {
    return feed(path, 'dislike');
  }
}
