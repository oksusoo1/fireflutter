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

  String uid;

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
      uid: data['uid'] ?? '',
      timestamp_: data['timestamp'] ?? Timestamp.now(),
      data_: data,
    );
  }

  Map<String, dynamic> get createData {
    return {
      'category': category,
      'title': title,
      'content': content,
      'deleted': deleted,
      'uid': UserService.instance.user.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Contains all the data
  Map<String, dynamic> get map {
    return {
      'title': title,
      'content': content,
      'deleted': deleted,
      'uid': uid,
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
  Future<DocumentReference<Object?>> create({Json extra = const {}}) {
    return postCol.add({...createData, ...extra});
  }

  Future<void> delete() {
    return postDoc(id).update({'deleted': true, 'content': '', 'title': ''});
  }

  Future<void> increaseViewCounter() {
    return increaseForumViewCounter(postDoc(id));
  }
}
