import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';

/// PostModel
///
/// Post and comment are a lot similiar. So both uses the same model.
/// Refer readme for details
class PostModel with FirestoreBase {
  PostModel({
    this.id = '',
    this.category = '',
    this.title = '',
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

  /// This is the user's document id.
  /// If it is empty, then it means that, the user does not exist.
  String id;

  /// Category of the post.
  ///
  /// Category is not needed for comment.
  String category;

  String title;
  String content;

  String authorUid;
  String authorNickname;
  String authorPhotoUrl;

  Timestamp? timestamp_;
  Timestamp get timestamp => timestamp_ ?? Timestamp.now();

  /// Get document data of map and convert it into post model
  factory PostModel.fromJson(Json data, String id) {
    return PostModel(
      id: id,
      category: data['category'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorUid: data['authorUid'] ?? '',
      authorNickname: data['authorNickname'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      timestamp_: data['timestamp'] ?? Timestamp.now(),
      data_: data,
    );
  }

  /// Convert post model from firestore document snapshot
  factory PostModel.fromSnapshot(DocumentSnapshot doc) {
    if (doc.exists) {
      return PostModel();
    } else {
      return PostModel();
    }
  }

  Map<String, dynamic> get createData {
    return {
      'category': category,
      'title': title,
      'content': content,
      'authorUid': UserService.instance.user.uid,
      'authorNickname': UserService.instance.user.nickname,
      'authorPhotoUrl': UserService.instance.user.photoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Contains all the data
  Map<String, dynamic> get map {
    return {
      'title': title,
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

  /// TODO: Make it work for comment also.
  Future<void> increaseViewCounter() {
    return postDoc(id).update({'viewCounter': FieldValue.increment(1)});
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

  /// **************************************************************************
  ///
  ///               Comment Member Variables & Methods
  ///
  /// **************************************************************************

  Map<String, dynamic> get commentCreateData {
    return {
      'content': content,
      'authorUid': UserService.instance.user.uid,
      'authorNickname': UserService.instance.user.nickname,
      'authorPhotoUrl': UserService.instance.user.photoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Create a comment with extra data
  Future<DocumentReference<Object?>> commentCreate({
    required String postId,
    String parent = 'root',
    Json extra = const {},
  }) {
    final col = commentCol(postId);
    return col.add({
      ...commentCreateData,
      ...{'parent': parent},
      ...extra,
    });
  }

  /// **************** EO Comment Member Variables & Methods *******************

}
