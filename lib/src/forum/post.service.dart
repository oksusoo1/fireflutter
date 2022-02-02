import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fireflutter.dart';

/// See readme.md
class PostService with FirestoreBase {
  static PostService? _instance;
  static PostService get instance {
    _instance ??= PostService();
    return _instance!;
  }

  Future<DocumentReference<Object?>> create({
    required String category,
    String? title,
    String? content,
  }) {
    final data = PostModel.toCreate(category: category, title: title, content: content);
    return postCol.add(data);
  }
}
