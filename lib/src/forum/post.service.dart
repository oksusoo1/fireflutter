import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireflutter/fireflutter.dart';
import 'package:fireflutter/src/firestore.rules.mixin.dart';

/// See readme.md
class PostService with FirestoreRules {
  static PostService? _instance;
  static PostService get instance {
    _instance ??= PostService();
    return _instance!;
  }

  Future<DocumentReference<Object?>> create({String? title, String? content}) {
    final data = PostModel.toCreate(title: title, content: content);
    return postCol.add(data);
  }
}
