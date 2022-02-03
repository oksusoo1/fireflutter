import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';

/// PostModel
///
/// Post and comment are a lot similiar. So both uses the same model.
/// And [PostModel] may be customized and used for something else like shopping
/// item model.
class PostModel {
  PostModel({
    this.id = '',
    this.category = '',
    this.title = '',
    this.content = '',
    this.authorNickname = '',
    this.authorPhotoUrl = '',
    this.authorUid = '',
    this.timestamp_,
  });

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

  factory PostModel.fromJson(Map<String, dynamic> data, String id) {
    return PostModel(
      id: id,
      category: data['category'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorUid: data['authorUid'] ?? '',
      authorNickname: data['authorNickname'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      timestamp_: data['timestamp'] ?? Timestamp.now(),
    );
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

  Map<String, dynamic> get commentCreateData {
    return {
      'content': content,
      'authorUid': UserService.instance.user.uid,
      'authorNickname': UserService.instance.user.nickname,
      'authorPhotoUrl': UserService.instance.user.photoUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> get map {
    return {
      'title': title,
      'content': content,
      'authorUid': authorUid,
      'authorNickname': authorNickname,
      'authorPhotoUrl': authorPhotoUrl,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return '''PostModel($map)''';
  }

  Future<void> report({String? reason}) {
    return PostService.instance.report(
      target: 'post',
      targetId: id,
      reporteeUid: authorUid,
      reason: reason,
    );
  }

  Future<void> increaseViewCounter() {
    return PostService.instance.increaseViewCounter(id);
  }
}
