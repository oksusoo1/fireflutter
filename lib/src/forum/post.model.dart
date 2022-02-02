import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';

class PostModel {
  PostModel({
    required this.id,
    this.title = '',
    this.content = '',
    this.authorNickname = '',
    this.authorPhotoUrl = '',
    this.authorUid = '',
    required this.timestamp,
  });

  /// This is the user's document id.
  /// If it is empty, then it means that, the user does not exist.
  String id;

  String title;
  String content;

  String authorUid;
  String authorNickname;
  String authorPhotoUrl;

  Timestamp timestamp;

  factory PostModel.fromJson(Map<String, dynamic> data, String id) {
    return PostModel(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorUid: data['authorUid'] ?? '',
      authorNickname: data['authorNickname'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
      timestamp: data['timestamp'],
    );
  }

  static Map<String, dynamic> toCreate({
    required String category,
    String? title,
    String? content,
    String? featuredPhotoUrl,
  }) {
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

  Future<DocumentReference> report([String? reason]) {
    return PostService.instance.report(
      target: 'post',
      targetId: id,
      reporteeUid: authorUid,
    );
  }
}
