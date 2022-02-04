import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../fireflutter.dart';

/// PostModel
///
/// Post and comment are a lot similiar. So both uses the same model.
/// Refer readme for details
class PostModel with FirestoreBase, ForumBase {
  PostModel({
    this.id = '',
    this.category = '',
    this.title = '',
    this.content = '',
    this.authorNickname = '',
    this.authorPhotoUrl = '',
    this.authorUid = '',
    this.files = const [],
    this.deleted = false,
    this.timestamp_,
    this.data_,
  });

  /// data is the document data object.
  Json? data_;
  Json get data => data_ ?? const {};

  String id;

  /// Category of the post.
  ///
  /// Category is not needed for comment.
  String category;

  String title;
  String content;

  bool deleted;

  String authorUid;
  String authorNickname;
  String authorPhotoUrl;

  List<String> files;

  Timestamp? timestamp_;
  Timestamp get timestamp => timestamp_ ?? Timestamp.now();

  /// Get document data of map and convert it into post model
  factory PostModel.fromJson(Json data, String id) {
    return PostModel(
      id: id,
      category: data['category'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      deleted: data['deleted'] ?? false,
      authorUid: data['authorUid'] ?? '',
      authorNickname: data['authorNickname'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      timestamp_: data['timestamp'] ?? Timestamp.now(),
      data_: data,
    );
  }

  Map<String, dynamic> get createData {
    return {
      'category': category,
      'title': title,
      'content': content,
      'files': files,
      'deleted': deleted,
      'authorUid': UserService.instance.user.uid,
      'authorNickname': UserService.instance.user.nickname,
      'authorPhotoUrl': UserService.instance.user.photoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Contains all the data
  Map<String, dynamic> get map {
    return {
      'category': category,
      'title': title,
      'content': content,
      'files': files,
      'deleted': deleted,
      'authorUid': authorUid,
      'authorNickname': authorNickname,
      'authorPhotoUrl': authorPhotoUrl,
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
      reporteeUid: authorUid,
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
  Future<DocumentReference<Object?>> create({Json extra = const {}}) {
    return postCol.add({...createData, ...extra});
  }

  Future<void> update() {
    return postDoc(id).update(data);
  }

  Future<void> delete() {
    return postDoc(id).update({'deleted': true, 'content': '', 'title': ''});
  }

  Future<void> increaseViewCounter() {
    return increaseForumViewCounter(postDoc(id));
  }
}
