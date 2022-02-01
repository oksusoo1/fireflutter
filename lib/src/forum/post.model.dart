import 'package:fireflutter/fireflutter.dart';

class PostModel {
  PostModel({
    this.id = '',
    this.title = '',
    this.content = '',
    this.authorNickname = '',
    this.authorPhotoUrl = '',
    this.authorUid = '',
  });

  /// This is the user's document id.
  /// If it is empty, then it means that, the user does not exist.
  String id;

  String title;
  String content;

  String authorUid;
  String authorNickname;
  String authorPhotoUrl;

  factory PostModel.fromJson(Map<String, dynamic> data) {
    return PostModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorUid: data['authorUid'] ?? '',
      authorNickname: data['authorNickname'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toCreate(
    String? title,
    String? content,
    String? featuredPhotoUrl,
  ) {
    return {
      'title': title,
      'content': content,
      'authorUid': UserService.instance.user.uid,
      'authorNickname': UserService.instance.user.nickname,
      'authorPhotoUrl': UserService.instance.user.photoUrl,
    };
  }

  Map<String, dynamic> get map {
    return {
      'title': title,
      'content': content,
      'authorUid': authorUid,
      'authorNickname': authorNickname,
      'authorPhotoUrl': authorPhotoUrl,
    };
  }

  @override
  String toString() {
    return '''PostModel($map)''';
  }
}
